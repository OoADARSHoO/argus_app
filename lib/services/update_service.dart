import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/break_timer_service.dart';
import '../services/notification_service.dart';
import '../services/settings_service.dart';
import '../services/tray_service.dart';
import '../services/window_service.dart';
import '../utils/update_feed.dart';
import '../utils/update_feed.dart' as update_feed;
import '../utils/version.dart';

/// Status of the update check/download process.
enum UpdateStatus {
  idle,      // Initial state, no check performed yet.
  checking,  // Currently checking for updates.
  upToDate,  // Already on the latest version.
  available, // Update available but not yet downloaded.
  downloading, // Currently downloading the update package.
  ready,     // Update downloaded and ready to apply.
  error,     // An error occurred during check/download.
}

/// Service that checks for Argus updates using Velopack's Update.exe.
///
/// Plain class extending [ChangeNotifier], created once in [main] and passed
/// down through the widget tree. No singletons.
///
/// Install detection: Update.exe must exist at the parent of the folder
/// containing [Platform.resolvedExecutable]. If not, the service stays idle
/// and never touches the network (flutter run is safe).
///
/// Feed: GET baseUrl/releases.win.json where baseUrl defaults to
/// https://github.com/OoADARSHoO/argus_app/releases/latest/download .
/// HTTPS only, except http://localhost or http://127.0.0.1 for testing.
/// Override baseUrl with the ARGUS_UPDATE_URL environment variable.
///
/// Downloads the Full .nupkg into %LOCALAPPDATA%\Argus\packages\ under a
/// temporary name, verifies SHA-256 (or SHA-1 only if no SHA-256 exists),
/// then renames. If the feed has no hash, refuses. On any mismatch or error
/// deletes the partial file and reports error. Never throws out of the service:
/// catches everything, debugPrints, sets status error. Offline = silent.
///
/// Schedule: first check ~30 seconds after launch, then every 12 hours, only
/// if the setting is on. Does not check or download while the break overlay
/// is showing (phase == breakTime); retries on the next cycle.
///
/// applyAndRestart(): only when status is ready and not in a break. Verifies
/// Update.exe and package exist, flushes settings, starts Update.exe as a
/// DETACHED process, destroys tray icon, releases single instance lock,
/// then exit(0).
class UpdateService extends ChangeNotifier {
  static const Duration _firstCheckDelay = Duration(seconds: 30);
  static const Duration _checkInterval = Duration(hours: 12);
  static const Duration _httpTimeout = Duration(seconds: 30);

  static const String _defaultBaseUrl =
      'https://github.com/OoADARSHoO/argus_app/releases/latest/download';

  final SettingsService settingsService;
  final WindowService windowService;
  final BreakTimerService breakTimerService;
  final TrayService trayService;
  final NotificationService notificationService;
  final VoidCallback onExit;

  UpdateStatus _status = UpdateStatus.idle;
  String? _newVersion;
  String? _errorMessage;
  Timer? _scheduleTimer;
  Timer? _firstCheckTimer;
  HttpClient? _httpClient;
  bool _disposed = false;

  UpdateService({
    required this.settingsService,
    required this.windowService,
    required this.breakTimerService,
    required this.trayService,
    required this.notificationService,
    required this.onExit,
  });

  UpdateStatus get status => _status;
  String? get newVersion => _newVersion;
  String? get errorMessage => _errorMessage;

  /// Initialize the service. Called from main.dart after settings load.
  /// Starts the first-check timer (~30s). If the app is not installed via
  /// Velopack (no Update.exe), stays idle and never touches the network.
  void init() {
    if (_updateExePath() == null) {
      _status = UpdateStatus.idle;
      return;
    }
    _scheduleFirstCheck();
    _schedulePeriodicCheck();
  }

  @override
  void dispose() {
    _disposed = true;
    _scheduleTimer?.cancel();
    _firstCheckTimer?.cancel();
    _httpClient?.close();
    super.dispose();
  }

  /// Manually trigger a check (user tapped "Check for updates").
  Future<void> checkNow() async {
    await _checkForUpdates(manual: true);
  }

  /// Apply the downloaded update and restart.
  ///
  /// Only valid when [status] is [UpdateStatus.ready] and the break timer
  /// is not in [TimerPhase.breakTime]. Verifies Update.exe and package exist,
  /// flushes settings, starts Update.exe as a DETACHED process, destroys
  /// tray icon, releases single instance lock, then exit(0).
  Future<void> applyAndRestart() async {
    if (_status != UpdateStatus.ready) return;
    if (_isInBreak()) return;

    final updateExe = _updateExePath();
    if (updateExe == null || !File(updateExe).existsSync()) {
      _setError('Update.exe not found');
      return;
    }

    final nupkgPath = _downloadedPackagePath();
    if (nupkgPath == null || !File(nupkgPath).existsSync()) {
      _setError('Downloaded package not found');
      return;
    }

    // Flush settings before applying.
    await settingsService.flush();

    // Start Update.exe as a detached process.
    try {
      await Process.start(
        updateExe,
        ['apply', '--package', nupkgPath, '--waitPid', pid.toString()],
        mode: ProcessStartMode.detached,
      );
    } catch (e) {
      debugPrint('Failed to start Update.exe: $e');
      _setError('Failed to start updater');
      return;
    }

    // Destroy the tray icon and release the single instance lock.
    await trayService.destroy();
    onExit();

    // Quit the application.
    exit(0);
  }

  //--------------------------------------------------------------------------
  // Private: update checking
  //--------------------------------------------------------------------------

  void _scheduleFirstCheck() {
    _firstCheckTimer = Timer(_firstCheckDelay, () {
      if (!_disposed) {
        _checkForUpdates();
      }
    });
  }

  void _schedulePeriodicCheck() {
    _scheduleTimer?.cancel();
    _scheduleTimer = Timer.periodic(_checkInterval, (_) {
      if (!_disposed) {
        _checkForUpdates();
      }
    });
  }

  Future<void> _checkForUpdates({bool manual = false}) async {
    if (_disposed) return;

    // Ignore if already checking, downloading, or ready.
    if (_status == UpdateStatus.checking ||
        _status == UpdateStatus.downloading ||
        _status == UpdateStatus.ready) {
      return;
    }

    // Scheduled checks respect the autoUpdate setting.
    // Manual checks (checkNow) work even when the toggle is off.
    if (!manual && !settingsService.settings.autoUpdate) {
      _status = UpdateStatus.idle;
      notifyListeners();
      return;
    }

    // Do not check while in a break overlay.
    if (_isInBreak()) return;

    _setStatus(UpdateStatus.checking);

    try {
      final baseUrl = _baseUrl();
      final feedUrl = '$baseUrl/releases.win.json';
      final feed = await _fetchJson(feedUrl);

      final asset = parseLatestFullAsset(feed);
      if (asset == null) {
        _setStatus(UpdateStatus.upToDate);
        return;
      }

      // Compare with current version.
      final currentVersion = _currentVersion();
      if (compareVersions(asset.version, currentVersion) <= 0) {
        _setStatus(UpdateStatus.upToDate);
        _newVersion = null;
        return;
      }

      _newVersion = asset.version;
      _setStatus(UpdateStatus.available);

      // Download the package.
      await _downloadPackage(asset);
    } catch (e) {
      debugPrint('Update check failed: $e');
      _setError('Check failed: $e');
    }
  }

  Future<void> _downloadPackage(VelopackAsset asset) async {
    _setStatus(UpdateStatus.downloading);

    try {
      final baseUrl = _safeBaseUrl();
      if (baseUrl == null) {
        _setError('Unsafe update URL');
        return;
      }
      final packageUrl = '$baseUrl/${asset.fileName}';

      final exe = Platform.resolvedExecutable;
      final exeDir = Directory(File(exe).path).parent;
      final argusDir = Directory(exeDir.path).parent;
      final packagesDir = Directory('${argusDir.path}\\packages');
      if (!await packagesDir.exists()) {
        await packagesDir.create(recursive: true);
      }

      final tempFile = File('${packagesDir.path}\\.${asset.fileName}.tmp');
      final finalFile = File('${packagesDir.path}\\${asset.fileName}');

      final client = _httpClient ??= _createHttpClient();
      final request = await client.getUrl(Uri.parse(packageUrl));
      final response = await request.close();

      if (response.statusCode != 200) {
        _setError('Download failed: HTTP ${response.statusCode}');
        await tempFile.delete().catchError((_) => tempFile);
        return;
      }

      final sink = tempFile.openWrite();
      await response.forEach((bytes) {
        sink.add(bytes);
      });
      await sink.close();

      // Verify hash (SHA-256 preferred, SHA-1 fallback). Refuse if neither present.
      final valid = await verifyFileHash(
        filePath: tempFile.path,
        expectedSha256: asset.sha256,
        expectedSha1: asset.sha1,
      );
      if (!valid) {
        await tempFile.delete();
        _setError('Hash mismatch: file hash verification failed');
        return;
      }

      // Rename to final name.
      await tempFile.rename(finalFile.path);

      _newVersion = asset.version;
      _setStatus(UpdateStatus.ready);

      // Show notification.
      _showUpdateReadyNotification();
    } catch (e) {
      // Delete temp file on any download error.
      final exe = Platform.resolvedExecutable;
      final exeDir = Directory(File(exe).path).parent;
      final argusDir = Directory(exeDir.path).parent;
      final packagesDir = Directory('${argusDir.path}\\packages');
      final tempFile = File('${packagesDir.path}\\.${asset.fileName}.tmp');
      await tempFile.delete().catchError((_) => tempFile);

      debugPrint('Update download failed: $e');
      _setError('Download failed: $e');
    }
  }

  //--------------------------------------------------------------------------
  // Private: helpers
  //--------------------------------------------------------------------------

  bool _isInBreak() {
    return breakTimerService.phase == TimerPhase.breakTime;
  }

  String _baseUrl() {
    final env = Platform.environment['ARGUS_UPDATE_URL'];
    if (env != null && env.isNotEmpty) {
      return env;
    }
    return _defaultBaseUrl;
  }

  /// Returns the URL if it is safe to use. Returns null if the URL is not
  /// allowed (only HTTPS, except http://localhost and http://127.0.0.1).
  String? _safeBaseUrl() {
    final url = _baseUrl();
    if (update_feed.isSafeUpdateUrl(url)) return url;
    return null;
  }

  /// Public accessor used by tests and callers.
  String? safeBaseUrl() => _safeBaseUrl();

  /// Public URL-safety check (instance form).
  bool isSafeUpdateUrl(String url) => update_feed.isSafeUpdateUrl(url);

  /// Alias for [isSafeUpdateUrl].
  bool isSafeUrl(String url) => update_feed.isSafeUpdateUrl(url);

  /// Alias for [isSafeUpdateUrl].
  bool isAllowedUpdateUrl(String url) => update_feed.isSafeUpdateUrl(url);

  /// Static URL-safety check for callers that do not instantiate the service.
  static bool isSafeUpdateUrlStatic(String url) => update_feed.isSafeUpdateUrl(url);

  static bool isSafeUrlStatic(String url) => update_feed.isSafeUpdateUrl(url);

  static bool isAllowedUpdateUrlStatic(String url) => update_feed.isSafeUpdateUrl(url);

  HttpClient _createHttpClient() {
    final client = HttpClient()
      ..connectionTimeout = _httpTimeout
      ..userAgent = 'Argus-Updater';
    return client;
  }

  Future<Map<String, dynamic>> _fetchJson(String url) async {
    final safe = _safeBaseUrl();
    if (safe == null) {
      throw Exception('Unsafe URL: only HTTPS or localhost HTTP is allowed');
    }
    final client = _httpClient ??= _createHttpClient();
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }
    final contents = await response.transform(Utf8Decoder()).join();
    return jsonDecode(contents) as Map<String, dynamic>;
  }

  String? _updateExePath() {
    final exe = Platform.resolvedExecutable;
    final exeDir = Directory(File(exe).path).parent;
    final argusDir = Directory(exeDir.path).parent;
    final updateExe = File('${argusDir.path}\\Update.exe');
    if (updateExe.existsSync()) return updateExe.path;
    return null;
  }

  String? _downloadedPackagePath() {
    if (_newVersion == null) return null;
    final exe = Platform.resolvedExecutable;
    final exeDir = Directory(File(exe).path).parent;
    final argusDir = Directory(exeDir.path).parent;
    final packagesDir = Directory('${argusDir.path}\\packages');
    if (!packagesDir.existsSync()) return null;
    final fileName = 'Argus-$_newVersion-full.nupkg';
    final file = File('${packagesDir.path}\\$fileName');
    if (file.existsSync()) return file.path;
    return null;
  }

  String _currentVersion() {
    return appVersion;
  }

  void _setStatus(UpdateStatus status) {
    _status = status;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _status = UpdateStatus.error;
    notifyListeners();
  }

  void _showUpdateReadyNotification() {
    notificationService.showUpdateReady(_newVersion ?? 'unknown');
  }
}

// VelopackAsset is defined in lib/utils/update_feed.dart and re-exported here.
