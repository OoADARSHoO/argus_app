// NOTE: This temporary demo page is created for Phase 2 widget verification.
// It will be deleted in Phase 3 when the actual Settings UI shell and pages are built.

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../models/accent_color.dart';
import '../../widgets/common/accent_swatch.dart';
import '../../widgets/common/app_dropdown.dart';
import '../../widgets/common/app_text_input.dart';
import '../../widgets/common/app_toggle.dart';
import '../../widgets/common/badge_widget.dart';
import '../../widgets/common/card_container.dart';
import '../../widgets/common/icon_button_widget.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/progress_ring.dart';
import '../../widgets/common/secondary_button.dart';
import '../../widgets/common/settings_row.dart';
import '../../widgets/common/theme_option_card.dart';
import '../../widgets/icons/app_icons.dart';

/// Temporary interactive gallery showcasing all Phase 2 shared widgets in all states.
class WidgetDemoPage extends StatefulWidget {
  const WidgetDemoPage({super.key});

  @override
  State<WidgetDemoPage> createState() => _WidgetDemoPageState();
}

class _WidgetDemoPageState extends State<WidgetDemoPage> {
  // Toggle states: _toggleOn begins true (accent track, knob on right), _toggleOff begins false (grey track, knob on left)
  bool _toggleOn = true;
  bool _toggleOff = false;

  // Dropdown state
  String _dropdownValue = '20 minutes';

  // Theme card state
  String _selectedTheme = 'Dark';

  // Accent swatch state
  Color _selectedAccent = AppColors.accentBlue;

  // Text inputs
  late final TextEditingController _textController;
  late final TextEditingController _multilineController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: 'Argus Desktop');
    _multilineController = TextEditingController(
      text: 'Time to rest your eyes. Look at something 20 feet away for 20 seconds.',
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _multilineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.windowPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(
                    AppIcons.eye,
                    size: AppDimensions.iconSize,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  const Expanded(
                    child: Text(
                      'Phase 2: Shared Widgets Gallery',
                      style: AppTypography.heading1,
                    ),
                  ),
                  const BadgeWidget(text: 'DEMO'),
                ],
              ),
              const SizedBox(height: AppSpacing.s8),
              const Text(
                'Demonstrates all 12 common widgets and AppIcons in all interactive states.',
                style: AppTypography.bodySecondary,
              ),
              const SizedBox(height: AppSpacing.sectionGap),

              // SECTION 1: Buttons
              _buildSectionTitle('1 & 2. Buttons (Primary & Secondary) - Exact 40px Height'),
              const SizedBox(height: AppSpacing.elementGap),
              Wrap(
                spacing: AppSpacing.s16,
                runSpacing: AppSpacing.s12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  PrimaryButton(
                    label: 'Primary Button',
                    color: _selectedAccent,
                    onPressed: () {},
                  ),
                  PrimaryButton(
                    label: 'With Icon',
                    icon: AppIcons.heart,
                    color: _selectedAccent,
                    onPressed: () {},
                  ),
                  const PrimaryButton(
                    label: 'Disabled',
                    onPressed: null,
                  ),
                  SecondaryButton(
                    label: 'Secondary Button',
                    onPressed: () {},
                  ),
                  SecondaryButton(
                    label: 'With Icon',
                    icon: AppIcons.settings,
                    onPressed: () {},
                  ),
                  const SecondaryButton(
                    label: 'Disabled',
                    onPressed: null,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sectionGap),

              // SECTION 2: Icon Buttons & Toggles & Badges
              _buildSectionTitle('3, 4 & 8. Icon Buttons, Toggles & Badges'),
              const SizedBox(height: AppSpacing.elementGap),
              Wrap(
                spacing: AppSpacing.s24,
                runSpacing: AppSpacing.s16,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // Icon buttons group
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButtonWidget(
                        icon: AppIcons.home,
                        tooltip: 'Home',
                        onPressed: () {},
                      ),
                      const SizedBox(width: AppSpacing.s8),
                      IconButtonWidget(
                        icon: AppIcons.clock,
                        tooltip: 'Clock',
                        onPressed: () {},
                      ),
                      const SizedBox(width: AppSpacing.s8),
                      IconButtonWidget(
                        icon: AppIcons.lightbulb,
                        tooltip: 'Tip',
                        onPressed: () {},
                      ),
                      const SizedBox(width: AppSpacing.s8),
                      const IconButtonWidget(
                        icon: AppIcons.close,
                        tooltip: 'Disabled Close',
                        onPressed: null,
                      ),
                    ],
                  ),

                  // Toggles group: demonstrates value=true (knob RIGHT, accent track) and value=false (knob LEFT, grey track)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppToggle(
                        value: _toggleOn,
                        accentColor: _selectedAccent,
                        onChanged: (val) => setState(() => _toggleOn = val),
                      ),
                      const SizedBox(width: AppSpacing.s8),
                      Text(_toggleOn ? 'On' : 'Off (toggled)', style: AppTypography.caption),
                      const SizedBox(width: AppSpacing.s16),
                      AppToggle(
                        value: _toggleOff,
                        accentColor: _selectedAccent,
                        onChanged: (val) => setState(() => _toggleOff = val),
                      ),
                      const SizedBox(width: AppSpacing.s8),
                      Text(_toggleOff ? 'On (toggled)' : 'Off', style: AppTypography.caption),
                      const SizedBox(width: AppSpacing.s16),
                      AppToggle(
                        value: false,
                        accentColor: _selectedAccent,
                        onChanged: null,
                      ),
                      const SizedBox(width: AppSpacing.s8),
                      const Text('Disabled Off', style: AppTypography.caption),
                      const SizedBox(width: AppSpacing.s16),
                      AppToggle(
                        value: true,
                        accentColor: _selectedAccent,
                        onChanged: null,
                      ),
                      const SizedBox(width: AppSpacing.s8),
                      const Text('Disabled On', style: AppTypography.caption),
                    ],
                  ),

                  // Badges group
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BadgeWidget(text: 'NEW', accentColor: _selectedAccent),
                      const SizedBox(width: AppSpacing.s8),
                      BadgeWidget(text: 'BETA', accentColor: _selectedAccent),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sectionGap),

              // SECTION 3: Inputs & Dropdown
              _buildSectionTitle('5 & 6. Dropdown (Left-Aligned, Pinned Chevron) & Text Inputs'),
              const SizedBox(height: AppSpacing.elementGap),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 550;
                  final left = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Dropdown', style: AppTypography.bodySemibold),
                      const SizedBox(height: AppSpacing.s8),
                      AppDropdown<String>(
                        value: _dropdownValue,
                        width: double.infinity,
                        items: const [
                          AppDropdownItem(value: '15 minutes', label: '15 minutes'),
                          AppDropdownItem(value: '20 minutes', label: '20 minutes'),
                          AppDropdownItem(value: '25 minutes', label: '25 minutes'),
                          AppDropdownItem(value: '30 minutes', label: '30 minutes'),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _dropdownValue = val);
                        },
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      const Text('Single-line Input', style: AppTypography.bodySemibold),
                      const SizedBox(height: AppSpacing.s8),
                      AppTextInput(
                        controller: _textController,
                        hintText: 'Enter title...',
                      ),
                    ],
                  );

                  final right = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Multiline Input (Break Message)', style: AppTypography.bodySemibold),
                      const SizedBox(height: AppSpacing.s8),
                      AppTextInput(
                        controller: _multilineController,
                        multiline: true,
                        minLines: 3,
                        maxLines: 4,
                        hintText: 'Enter break message...',
                      ),
                    ],
                  );

                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: left),
                        const SizedBox(width: AppSpacing.s24),
                        Expanded(child: right),
                      ],
                    );
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        left,
                        const SizedBox(height: AppSpacing.s16),
                        right,
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: AppSpacing.sectionGap),

              // SECTION 4: Theme Option Cards & Accent Swatches
              _buildSectionTitle('10 & 11. Theme Option Cards & Accent Swatches'),
              const SizedBox(height: AppSpacing.elementGap),
              Wrap(
                spacing: AppSpacing.s24,
                runSpacing: AppSpacing.s16,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ThemeOptionCard(
                        label: 'Dark',
                        isSelected: _selectedTheme == 'Dark',
                        accentColor: _selectedAccent,
                        onTap: () => setState(() => _selectedTheme = 'Dark'),
                      ),
                      const SizedBox(width: AppSpacing.s12),
                      ThemeOptionCard(
                        label: 'Light',
                        isSelected: _selectedTheme == 'Light',
                        accentColor: _selectedAccent,
                        onTap: () => setState(() => _selectedTheme = 'Light'),
                      ),
                      const SizedBox(width: AppSpacing.s12),
                      ThemeOptionCard(
                        label: 'System',
                        isSelected: _selectedTheme == 'System',
                        accentColor: _selectedAccent,
                        onTap: () => setState(() => _selectedTheme = 'System'),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Accent Color', style: AppTypography.bodySemibold),
                      const SizedBox(height: AppSpacing.s12),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: AccentColorOption.all.map((opt) {
                          return Padding(
                            padding: const EdgeInsets.only(right: AppSpacing.s8),
                            child: AccentSwatch(
                              color: opt.color,
                              isSelected: _selectedAccent == opt.color,
                              onTap: () => setState(() => _selectedAccent = opt.color),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sectionGap),

              // SECTION 5: Progress Rings & Cards
              _buildSectionTitle('7 & 9. Progress Rings (120 & 160) & Card Container'),
              const SizedBox(height: AppSpacing.elementGap),
              Wrap(
                spacing: AppSpacing.s24,
                runSpacing: AppSpacing.s24,
                crossAxisAlignment: WrapCrossAlignment.start,
                children: [
                  // 120px ring
                  CardContainer(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('120px Component Ring', style: AppTypography.caption),
                        const SizedBox(height: AppSpacing.s16),
                        ProgressRing(
                          value: 0.75,
                          size: AppDimensions.progressRingComponent,
                          strokeWidth: AppDimensions.progressRingStrokeWidthDefault,
                          color: _selectedAccent,
                          child: const Text('20', style: AppTypography.countdownNumber),
                        ),
                      ],
                    ),
                  ),

                  // 160px ring
                  CardContainer(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('160px Break Ring', style: AppTypography.caption),
                        const SizedBox(height: AppSpacing.s16),
                        ProgressRing(
                          value: 0.60,
                          size: AppDimensions.progressRingBreakScreen,
                          strokeWidth: AppDimensions.progressRingStrokeWidthBreak,
                          color: _selectedAccent,
                          child: const Text('20', style: AppTypography.countdownNumber),
                        ),
                      ],
                    ),
                  ),

                  // Card Container example with Cancel/Confirm buttons
                  SizedBox(
                    width: 320,
                    child: CardContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: const [
                              Icon(AppIcons.info, size: AppDimensions.iconSizeSmall, color: AppColors.info),
                              SizedBox(width: AppSpacing.s8),
                              Expanded(
                                child: Text('Card Container', style: AppTypography.bodySemibold),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.s12),
                          const Text(
                            'Uses surface fill (#16161B), 12px radius, 20px padding, 1px border (#2A2A33), and Shadow 1.',
                            style: AppTypography.caption,
                          ),
                          const SizedBox(height: AppSpacing.s16),
                          Wrap(
                            spacing: AppSpacing.s8,
                            runSpacing: AppSpacing.s8,
                            children: [
                              SecondaryButton(
                                label: 'Cancel',
                                onPressed: () {},
                              ),
                              PrimaryButton(
                                label: 'Confirm',
                                color: _selectedAccent,
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sectionGap),

              // SECTION 6: Settings Rows
              _buildSectionTitle('12. Settings Rows'),
              const SizedBox(height: AppSpacing.elementGap),
              CardContainer(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.cardPadding),
                child: Column(
                  children: [
                    SettingsRow(
                      label: 'Break Interval',
                      description: 'Time between breaks',
                      control: AppDropdown<String>(
                        value: _dropdownValue,
                        width: AppDimensions.dropdownWidth,
                        items: const [
                          AppDropdownItem(value: '15 minutes', label: '15 minutes'),
                          AppDropdownItem(value: '20 minutes', label: '20 minutes'),
                          AppDropdownItem(value: '25 minutes', label: '25 minutes'),
                          AppDropdownItem(value: '30 minutes', label: '30 minutes'),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _dropdownValue = val);
                        },
                      ),
                    ),
                    SettingsRow(
                      label: 'Skip Option',
                      description: 'Allow skipping break with Esc key',
                      control: AppToggle(
                        value: _toggleOn,
                        accentColor: _selectedAccent,
                        onChanged: (val) => setState(() => _toggleOn = val),
                      ),
                    ),
                    SettingsRow(
                      label: 'Enable Sounds',
                      description: 'Play a soft sound before a break',
                      showDivider: false,
                      control: AppToggle(
                        value: _toggleOff,
                        accentColor: _selectedAccent,
                        onChanged: (val) => setState(() => _toggleOff = val),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.heading2),
        const SizedBox(height: AppSpacing.s4),
        Container(
          height: AppDimensions.borderWidth,
          color: AppColors.border,
        ),
      ],
    );
  }
}
