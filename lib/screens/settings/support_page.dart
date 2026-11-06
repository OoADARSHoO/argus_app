import 'package:flutter/material.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../services/settings_service.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/progress_ring.dart';
import '../../widgets/common/secondary_button.dart';
import '../../widgets/icons/app_icons.dart';

/// Support page in Argus.
/// Displays the monthly community funding progress ring and donation actions.
class SupportPage extends StatelessWidget {
  const SupportPage({
    super.key,
    required this.settings,
  });

  final SettingsService settings;

  // Hardcoded local values for Phase 3 static UI
  static const double currentDonation = 128.0;
  static const double targetDonation = 200.0;
  static const double progressFraction = currentDonation / targetDonation; // 0.64

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Page header
        const Text(
          'Support Argus',
          style: AppTypography.heading2,
        ),
        const SizedBox(height: AppSpacing.s4),
        const Text(
          'Your support keeps Argus alive.',
          style: AppTypography.caption,
        ),
        const SizedBox(height: AppSpacing.s24),

        // Donation progress ring and actions, horizontally centered but top-aligned.
        // No vertical centering so the page starts at the same position as other tabs.
        SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              ProgressRing(
                value: progressFraction,
                size: AppDimensions.progressRingSupport,
                strokeWidth: AppDimensions.progressRingStrokeWidthSupport,
                color: settings.accentColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Money needed\nfor the month',
                      textAlign: TextAlign.center,
                      style: AppTypography.caption,
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    const Text(
                      r'$128 / $200',
                      style: AppTypography.heading2,
                    ),
                    const SizedBox(height: AppSpacing.s4),
                    Text(
                      '64%',
                      style: AppTypography.bodySemibold.copyWith(
                        color: settings.accentColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s24),
              const Text(
                'Every donation helps keep Argus free, independent and ad-free.',
                style: AppTypography.caption,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.s20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PrimaryButton(
                    label: 'Donate Now',
                    icon: AppIcons.heart,
                    color: settings.accentColor,
                    onPressed: () {},
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  SecondaryButton(
                    label: 'Learn More',
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
