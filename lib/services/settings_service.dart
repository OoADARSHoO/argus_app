import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import '../models/app_settings.dart';
import '../models/accent_color.dart';

/// Service that persists Argus settings to disk as JSON.
///
/// File path: %APPDATA%\Argus\settings.json
///
/// Uses only `dart:io` and `dart:convert` — no extra packages.
/// All saves are debounced (~400 ms) and written atomically (temp file + rename)
/// so a crash can never leave a half-written settings file.
class SettingsService extends ChangeNotifier {
  static const String _fileName = 'settings.json';
  static const Duration _saveDebounceDuration = Duration(milliseconds: 400);

  AppSettings _settings = AppSettings.defaults;

  /// Current settings. Listeners are notified whenever [update] is called.
  AppSettings get settings => _settings;

  /// Accent color derived from the saved accent id, used to recolor the UI live.
  Color get accentColor =>
      AccentColorOption.fromId(_settings.appearanceSettings.accentId).color;

  Directory? _appDataDir;
  File? _settingsFile;
  Timer? _saveDebounce;

  /// Load settings from disk.
  ///
  /// If the file is missing, empty, or contains invalid JSON, uses defaults
  /// and does not crash. Never leaves the app without valid settings.
  Future<void> load() async {
    final appData = Platform.environment['APPDATA'];
    if (appData == null || appData.isEmpty) {
      debugPrint('APPDATA environment variable not found, using defaults');
      _settings = AppSettings.defaults;
      notifyListeners();
      return;
    }

    _appDataDir = Directory('$appData\\Argus');
    if (!await _appDataDir!.exists()) {
      await _appDataDir!.create(recursive: true);
    }

    _settingsFile = File('${_appDataDir!.path}\\$_fileName');

    if (!await _settingsFile!.exists()) {
      _settings = AppSettings.defaults;
      await save();
      notifyListeners();
      return;
    }

    try {
      final contents = await _settingsFile!.readAsString();
      if (contents.trim().isEmpty) {
        _settings = AppSettings.defaults;
      } else {
        final decoded = jsonDecode(contents);
        if (decoded is Map<String, dynamic>) {
          _settings = AppSettings.fromJson(decoded);
        } else {
          _settings = AppSettings.defaults;
        }
      }
    } catch (e) {
      debugPrint('Failed to load settings: $e');
      _settings = AppSettings.defaults;
    }

    notifyListeners();
  }

  /// Update settings and notify listeners. Schedules a debounced save.
  void update(AppSettings newSettings) {
    _settings = newSettings;
    notifyListeners();
    _scheduleSave();
  }

  void _scheduleSave() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(_saveDebounceDuration, () {
      _saveDebounce = null;
      save();
    });
  }

  /// Save settings to disk.
  ///
  /// Writes pretty-printed JSON to a temp file then renames over settings.json
  /// so a crash can't leave a half-written file. Catches and debugPrints any
  /// IO error; never crashes.
  Future<void> save() async {
    if (_settingsFile == null) return;
    try {
      final json = _settings.toJson();
      final contents = JsonEncoder.withIndent('  ').convert(json);
      final tempFile = File('${_settingsFile!.path}.tmp');
      await tempFile.writeAsString(contents);
      await tempFile.rename(_settingsFile!.path);
    } catch (e) {
      debugPrint('Failed to save settings: $e');
    }
  }

  /// Flush any pending debounced save immediately.
  Future<void> flush() async {
    _saveDebounce?.cancel();
    _saveDebounce = null;
    await save();
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    super.dispose();
  }
}
