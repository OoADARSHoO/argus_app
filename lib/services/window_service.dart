import 'package:window_manager/window_manager.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimensions.dart';

/// Service managing desktop window properties, frameless title bar,
/// sizing, and window actions using [windowManager].
class WindowService {
  const WindowService();

  /// Initializes the main settings window at 960x640, centered, frameless.
  Future<void> initializeSettingsWindow() async {
    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      size: AppDimensions.windowSize,
      minimumSize: AppDimensions.windowSize,
      maximumSize: AppDimensions.windowSize,
      center: true,
      backgroundColor: AppColors.background,
      skipTaskbar: false,
      title: 'Argus',
      titleBarStyle: TitleBarStyle.hidden,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.setResizable(false);
      await windowManager.show();
      await windowManager.focus();
    });
  }

  /// Minimizes the application window.
  Future<void> minimize() async {
    await windowManager.minimize();
  }

  /// Closes the application window (quits the app in Phase 3).
  Future<void> close() async {
    await windowManager.close();
  }
}
