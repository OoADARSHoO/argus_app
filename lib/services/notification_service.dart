import 'package:flutter/foundation.dart';
import 'package:local_notifier/local_notifier.dart';

/// Service that shows native desktop notifications using [local_notifier].
///
/// Plain class created once in [main] and passed down through the widget
/// tree like the other services. Wraps [localNotifier.setup] and
/// [LocalNotification.show]. Any failure is caught and [debugPrint]ed so
/// notifications never crash the app.
class NotificationService {
  /// Set up the native notification subsystem.
  ///
  /// Must be called before [showBreakWarning]. On Windows this registers the
  /// app name and creates a Start Menu shortcut (required for toasts to
  /// appear on unpackaged apps).
  Future<void> setup() async {
    try {
      await localNotifier.setup(
        appName: 'Argus',
        // requireCreate makes Windows create a Start Menu shortcut for the
        // app, which is required for toast notifications to display.
        shortcutPolicy: ShortcutPolicy.requireCreate,
      );
    } catch (e) {
      debugPrint('Failed to set up notification service: $e');
    }
  }

  /// Show the pre-break warning notification.
  ///
  /// [secondsLeft] is the number of seconds remaining until the break starts.
  /// Any failure is caught and debugPrint-ed so a notification problem never
  /// crashes the app.
  void showBreakWarning(int secondsLeft) {
    try {
      final notification = LocalNotification(
        title: 'Break in $secondsLeft seconds',
        body: 'Look away from your screen soon. Argus will rest your eyes.',
      );
      notification.show();
    } catch (e) {
      debugPrint('Failed to show break warning notification: $e');
    }
  }

  /// Show the update-ready notification.
  ///
  /// [newVersion] is the version string of the available update.
  /// Any failure is caught and [debugPrint]ed so a notification problem never
  /// crashes the app.
  void showUpdateReady(String newVersion) {
    try {
      final notification = LocalNotification(
        title: 'Argus update ready',
        body: 'Open Settings > About to restart and install version $newVersion.',
      );
      notification.show();
    } catch (e) {
      debugPrint('Failed to show update notification: $e');
    }
  }
}
