import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';

/// Text input field for Argus.
/// 36px high in single-line mode, with 10px vertical x 14px horizontal padding.
/// Turns border to accent color on focus.
/// Also supports multiline mode for the Break Message field.
class AppTextInput extends StatelessWidget {
  const AppTextInput({
    super.key,
    this.controller,
    this.initialValue,
    this.hintText,
    this.onChanged,
    this.multiline = false,
    this.minLines,
    this.maxLines,
    this.enabled = true,
    this.focusNode,
    this.width,
  });

  final TextEditingController? controller;
  final String? initialValue;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final bool multiline;
  final int? minLines;
  final int? maxLines;
  final bool enabled;
  final FocusNode? focusNode;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final effectiveMinLines = multiline ? (minLines ?? 3) : 1;
    final effectiveMaxLines = multiline ? (maxLines ?? 5) : 1;

    final inputDecoration = InputDecoration(
      isDense: true,
      filled: true,
      fillColor: AppColors.surfaceElevated,
      hintText: hintText,
      hintStyle: AppTypography.inputHint,
      contentPadding: multiline
          ? AppSpacing.inputPadding
          : const EdgeInsets.symmetric(
              horizontal: AppSpacing.inputPaddingHorizontal,
              vertical: AppSpacing.s8,
            ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: AppRadius.inputRadius,
        borderSide: BorderSide(
          color: AppColors.border,
          width: AppDimensions.borderWidth,
        ),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: AppRadius.inputRadius,
        borderSide: BorderSide(
          color: AppColors.primary,
          width: AppDimensions.borderWidth,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.inputRadius,
        borderSide: BorderSide(
          color: AppColors.border.withValues(alpha: 0.5),
          width: AppDimensions.borderWidth,
        ),
      ),
    );

    final inputField = TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      focusNode: focusNode,
      enabled: enabled,
      minLines: effectiveMinLines,
      maxLines: effectiveMaxLines,
      onChanged: onChanged,
      style: enabled
          ? AppTypography.input
          : AppTypography.input.copyWith(color: AppColors.textDisabled),
      cursorColor: AppColors.primary,
      decoration: inputDecoration,
    );

    if (multiline) {
      return SizedBox(
        width: width,
        child: inputField,
      );
    }

    return SizedBox(
      width: width,
      height: AppDimensions.inputHeight,
      child: inputField,
    );
  }
}
