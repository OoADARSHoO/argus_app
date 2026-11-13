import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../services/settings_service.dart';
import '../../services/update_service.dart';
import '../../utils/version.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/secondary_button.dart';
import '../../widgets/icons/app_icons.dart';

/// About page in Argus.
/// Displays branding, version, description, legal links, and publisher copyright.
class AboutPage extends StatelessWidget {
  const AboutPage({
    super.key,
    required this.settings,
    required this.updateService,
  });

  final SettingsService settings;
  final UpdateService updateService;

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
        const SizedBox(height: AppSpacing.s24),

        // Branding & information, horizontally centered but top-aligned.
        // No vertical centering so the page starts at the same position as other tabs.
        SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Large Eye Logo
              Icon(
                AppIcons.eye,
                size: 56,
                color: settings.accentColor,
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
                'Version $appVersion',
                style: AppTypography.caption.copyWith(
                  color: settings.accentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.s4),

              // Tagline
              const Text(
                '20-20-20 made simple.',
                style: AppTypography.bodySecondary,
              ),
              const SizedBox(height: AppSpacing.s4),

              // Update status line
              ListenableBuilder(
                listenable: updateService,
                builder: (context, _) {
                  final status = updateService.status;
                  if (status == UpdateStatus.idle) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    _statusText(updateService),
                    style: AppTypography.caption.copyWith(
                      color: settings.accentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.s16),

              // Update button
              ListenableBuilder(
                listenable: updateService,
                builder: (context, _) {
                  final status = updateService.status;
                  if (status == UpdateStatus.ready) {
                    return PrimaryButton(
                      label: 'Restart to update',
                      onPressed: () async {
                        await updateService.applyAndRestart();
                      },
                    );
                  } else {
                    return SecondaryButton(
                      label: 'Check for updates',
                      onPressed: status == UpdateStatus.checking ||
                              status == UpdateStatus.downloading
                          ? null
                          : () async {
                              await updateService.checkNow();
                            },
                    );
                  }
                },
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

  String _statusText(UpdateService updateService) {
    switch (updateService.status) {
      case UpdateStatus.idle:
        return 'Updates not available in this build';
      case UpdateStatus.checking:
        return 'Checking for updates...';
      case UpdateStatus.upToDate:
        return 'Up to date';
      case UpdateStatus.available:
        return 'Update available: ${updateService.newVersion}';
      case UpdateStatus.downloading:
        return 'Downloading...';
      case UpdateStatus.ready:
        return 'Update ready';
      case UpdateStatus.error:
        return updateService.errorMessage ?? 'Couldn\'t check for updates';
    }
  }
}
