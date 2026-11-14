import 'dart:io';

import 'package:flutter/foundation.dart';

/// File logger for the break overlay window lifecycle.
///
/// Release builds have no console, so every line also goes to
/// `%APPDATA%\Argus\overlay.log`. The file is trimmed once per process when it
/// grows past [_maxBytes] so a long-running install cannot fill the disk.
class OverlayLog {
  OverlayLog._();

  static const int _maxBytes = 1024 * 1024;
  static bool _checkedSize = false;
  static String? _filePath;

  static String? get _path {
    if (_filePath != null) return _filePath;
    final appData = Platform.environment['APPDATA'];
    if (appData == null || appData.isEmpty) return null;
    _filePath = '$appData\\Argus\\overlay.log';
    return _filePath;
  }

  /// Writes [message] to the debug console and appends it to the overlay log.
  ///
  /// Logging must never take the app down, so every file error is swallowed.
  static void write(String message) {
    final line = '${DateTime.now().toIso8601String()} $message';
    debugPrint('OVERLAY $message');

    final path = _path;
    if (path == null) return;
    try {
      final file = File(path);
      if (!_checkedSize) {
        _checkedSize = true;
        if (file.existsSync() && file.lengthSync() > _maxBytes) {
          file.deleteSync();
        }
      }
      file.parent.createSync(recursive: true);
      file.writeAsStringSync(
        '$line${Platform.lineTerminator}',
        mode: FileMode.append,
        flush: true,
      );
    } catch (_) {
      // Ignore: logging is diagnostic only.
    }
  }
}
