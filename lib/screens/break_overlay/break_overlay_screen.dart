import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../services/break_timer_service.dart';
import '../../services/settings_service.dart';
import '../../widgets/common/progress_ring.dart';
import '../../widgets/icons/app_icons.dart';

/// Fullscreen break overlay screen for Argus.
///
/// Shown when [BreakTimerService] enters [TimerPhase.breakTime].
/// Displays the break message (split into headline/body), a progress ring
/// with the countdown number inside, a tip row, and an optional Skip (Esc)
/// button. Covers the entire window including the debug panel.
///
/// Single window, two modes: this replaces the SettingsShell as the
/// MaterialApp home while in breakTime.
class BreakOverlayScreen extends StatefulWidget {
  const BreakOverlayScreen({
    super.key,
    required this.settings,
    required this.timer,
  });

  final SettingsService settings;
  final BreakTimerService timer;

  @override
  State<BreakOverlayScreen> createState() => _BreakOverlayScreenState();
}

class _BreakOverlayScreenState extends State<BreakOverlayScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ringController;

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(vsync: this);
    _startRingAnimation();
  }

  /// Start the smooth ring animation ONCE: from the current remaining
  /// fraction down to 0 over the remaining break time.
  /// Never restarted on rebuilds — the animation runs continuously for the
  /// entire break.
  void _startRingAnimation() {
    final durationSeconds = widget.settings.settings.breakDurationSeconds;
    final currentSeconds = widget.timer.secondsLeftInBreak;
    if (durationSeconds <= 0 || currentSeconds <= 0) {
      _ringController.value = 0.0;
      return;
    }
    final startValue = currentSeconds / durationSeconds;
    _ringController
      ..duration = Duration(seconds: currentSeconds)
      ..value = startValue
      ..reverse(from: startValue);
  }

  @override
  void dispose() {
    _ringController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final breakSettings = widget.settings.settings.breakSettings;
    final backgroundColor = AppColors.breakBackgroundForId(
      breakSettings.backgroundId,
    );
    final textColor = Color(breakSettings.textColor);
    final showRing = breakSettings.showProgressRing;
    final skipEnabled = widget.settings.settings.skipEnabled;

    // Split the break message at the first sentence.
    final message = breakSettings.message;
    final firstPeriod = message.indexOf('. ');
    String headline;
    String body;
    if (firstPeriod == -1) {
      headline = message.trim();
      body = '';
    } else {
      headline = message.substring(0, firstPeriod + 1).trim();
      body = message.substring(firstPeriod + 2).trim();
    }

    // Font size scaling from the setting.
    final fontSizeId = breakSettings.fontSizeId;
    double headlineSize;
    double bodySize;
    switch (fontSizeId) {
      case 'small':
        headlineSize = 28;
        bodySize = 14;
        break;
      case 'medium':
        headlineSize = 34;
        bodySize = 16;
        break;
      case 'large':
      default:
        headlineSize = 40;
        bodySize = 17;
        break;
    }

    return ListenableBuilder(
      listenable: widget.timer,
      builder: (context, _) {
        final currentSecondsLeft = widget.timer.secondsLeftInBreak;

        return Material(
          color: backgroundColor,
          child: Focus(
            autofocus: true,
            child: KeyboardListener(
              focusNode: FocusNode(),
              onKeyEvent: (event) {
                // Esc to skip — only when Skip Option is on.
                if (skipEnabled &&
                    event.logicalKey == LogicalKeyboardKey.escape) {
                  widget.timer.skipBreak();
                }
              },
              child: Stack(
                children: [
                  // Centered content column
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Eye icon
                        Icon(
                          AppIcons.eye,
                          size: AppDimensions.iconSize * 2.5,
                          color: textColor,
                        ),
                        const SizedBox(height: AppSpacing.s24),

                        // Headline (first sentence of break message)
                        Text(
                          headline,
                          style: AppTypography.breakHeadline.copyWith(
                            fontSize: headlineSize,
                            color: textColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (body.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.s16),
                          // Body (rest of break message)
                          Text(
                            body,
                            style: AppTypography.breakBody.copyWith(
                              fontSize: bodySize,
                              color: textColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        const SizedBox(height: AppSpacing.s32),

                        // Progress ring with countdown number inside
                        if (showRing)
                          AnimatedBuilder(
                            animation: _ringController,
                            builder: (context, child) {
                              return RepaintBoundary(
                                child: ProgressRing(
                                  value: _ringController.value,
                                  size: AppDimensions
                                      .progressRingBreakScreen,
                                  strokeWidth:
                                      AppDimensions.progressRingStrokeWidthBreak,
                                  color: textColor,
                                  child: Text(
                                    currentSecondsLeft.toString(),
                                    style: AppTypography.countdownNumber
                                        .copyWith(
                                          color: textColor,
                                        ),
                                  ),
                                ),
                              );
                            },
                          )
                        else
                          // Countdown number without the ring
                          Text(
                            currentSecondsLeft.toString(),
                            style: AppTypography.countdownNumber.copyWith(
                              color: textColor,
                            ),
                          ),
                        const SizedBox(height: AppSpacing.s32),

                        // Tip row
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              AppIcons.lightbulb,
                              size: AppDimensions.iconSizeSmall,
                              color: textColor.withValues(alpha: 0.7),
                            ),
                            const SizedBox(width: AppSpacing.s8),
                            Text(
                              'Tip: Blink slowly and relax your eyes.',
                              style: AppTypography.body.copyWith(
                                color: textColor.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Skip (Esc) button top-right — only when Skip Option is on
                  if (skipEnabled)
                    Positioned(
                      top: AppSpacing.s24,
                      right: AppSpacing.s24,
                      child: _SkipButton(
                        onTap: widget.timer.skipBreak,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Small outlined Skip button shown in the top-right of the break overlay.
class _SkipButton extends StatelessWidget {
  const _SkipButton({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: BorderSide(
          color: AppColors.border,
          width: AppDimensions.borderWidth,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s12,
          vertical: AppSpacing.s8,
        ),
      ),
      child: const Text(
        'Skip (Esc)',
        style: TextStyle(fontSize: 11),
      ),
    );
  }
}
