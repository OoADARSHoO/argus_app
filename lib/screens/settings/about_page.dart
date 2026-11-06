import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../widgets/icons/app_icons.dart';
import 'settings_shell.dart';

/// About page in Argus.
/// Displays branding, version, description, legal links, and publisher copyright.
class AboutPage extends StatelessWidget {
  const AboutPage({
    super.key,
    required this.settings,
  });

  final TempSettingsState settings;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Page header
        const Text(
          'About Argus',
          style: AppTypography.heading2,
        ),
        const SizedBox(height: AppSpacing.s4),
        const Text(
          'Know more about the app.',
          style: AppTypography.caption,
        ),
        const SizedBox(height: AppSpacing.s32),

        // Centered branding & information
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Large Eye Logo
              Icon(
                AppIcons.eye,
                size: 56,
                color: settings.selectedAccentColor,
              ),
              const SizedBox(height: AppSpacing.s12),

              // Product Wordmark
              const Text(
                'ARGUS',
                style: AppTypography.wordmark,
              ),
              const SizedBox(height: AppSpacing.s4),

              // Version badge
              Text(
                'Version 1.0.0',
                style: AppTypography.caption.copyWith(
                  color: settings.selectedAccentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.s4),

              // Tagline
              const Text(
                '20-20-20 made simple.',
                style: AppTypography.bodySecondary,
              ),
              const SizedBox(height: AppSpacing.s24),

              // Description paragraph
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Text(
                  'Argus helps you follow the 20-20-20 rule by blocking your screen for 20 seconds every 20 minutes so you can rest your eyes, refocus, and stay productive.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySecondary.copyWith(
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s24),

              // Policy links
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {},
                      child: const Text(
                        'Privacy Policy',
                        style: AppTypography.caption,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.s8),
                    child: Text('•', style: AppTypography.caption),
                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {},
                      child: const Text(
                        'Terms of Use',
                        style: AppTypography.caption,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s32),

              // Footer
              Text(
                '© 2025 BITEKOI LABS. All rights reserved.',
                style: AppTypography.small.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
            ],
          ),
        ),
      ],
    );
  }
}
