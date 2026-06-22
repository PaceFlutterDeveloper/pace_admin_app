import 'package:admin_app/config/themes/app_design_tokens.dart';
import 'package:admin_app/core/widgets/app_button.dart';
import 'package:admin_app/core/widgets/app_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shared bordered input decoration for profile dropdowns.
class ProfileFieldDecorations {
  ProfileFieldDecorations._();

  static InputDecoration bordered(ThemeData theme, {String? errorText}) {
    final isDark = theme.brightness == Brightness.dark;
    final fillColor = isDark
        ? theme.colorScheme.surfaceContainerHigh
        : AppColors.iosSystemGray6;
    final idleBorder = isDark
        ? AppColors.iosSystemGray4Dark
        : AppColors.iosSystemGray3;
    final errorColor = isDark ? AppColors.iosRedDark : AppColors.iosRed;
    final hasError = errorText != null && errorText.isNotEmpty;

    return InputDecoration(
      filled: true,
      fillColor: fillColor,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: AppRadius.borderRadiusMd,
        borderSide: BorderSide(color: idleBorder, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.borderRadiusMd,
        borderSide: BorderSide(
          color: hasError ? errorColor : idleBorder,
          width: hasError ? 2 : 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.borderRadiusMd,
        borderSide: BorderSide(
          color: hasError ? errorColor : theme.colorScheme.primary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppRadius.borderRadiusMd,
        borderSide: BorderSide(color: errorColor, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppRadius.borderRadiusMd,
        borderSide: BorderSide(color: errorColor, width: 2),
      ),
      errorStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: errorColor,
      ),
    );
  }
}

/// Plain text form field used across the complete-profile tabs.
class ProfileTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isRequired;
  final bool enabled;
  final bool readOnly;
  final String? helperText;
  final TextInputType? keyboardType;
  final int? maxLength;
  final int maxLines;
  final FormFieldValidator<String>? validator;

  const ProfileTextField({
    super.key,
    required this.label,
    required this.controller,
    this.isRequired = false,
    this.enabled = true,
    this.readOnly = false,
    this.helperText,
    this.keyboardType,
    this.maxLength,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: isRequired ? '$label *' : label,
      controller: controller,
      enabled: enabled,
      readOnly: readOnly,
      helperText: helperText,
      outlined: true,
      keyboardType: keyboardType,
      maxLength: maxLength,
      maxLines: maxLines,
      validator:
          validator ??
          (isRequired
              ? (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter $label';
                  }
                  return null;
                }
              : null),
    );
  }
}

/// Numeric form field (optionally with currency prefix in the label).
class ProfileNumericField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isCurrency;
  final double? maxValue;

  const ProfileNumericField({
    super.key,
    required this.label,
    required this.controller,
    this.isCurrency = false,
    this.maxValue,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: isCurrency ? '$label (AED)' : label,
      controller: controller,
      outlined: true,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final number = double.tryParse(value);
          if (number == null) {
            return 'Please enter a valid ${isCurrency ? "amount" : "number"}';
          }
          if (number < 0) {
            return 'Please enter a positive ${isCurrency ? "amount" : "number"}';
          }
          if (maxValue != null && number > maxValue!) {
            return 'Please enter a value between 0 and $maxValue';
          }
        }
        return null;
      },
    );
  }
}

/// Read-only date picker field.
class ProfileDateField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isRequired;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const ProfileDateField({
    super.key,
    required this.label,
    required this.controller,
    this.isRequired = false,
    this.firstDate,
    this.lastDate,
  });

  DateTime? _parseDate(String dateStr) {
    if (dateStr.isEmpty) return null;
    return DateTime.tryParse(dateStr);
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _parseDate(controller.text) ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(1950),
      lastDate: lastDate ?? DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      controller.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: isRequired ? '$label *' : label,
      controller: controller,
      outlined: true,
      readOnly: true,
      suffixIcon: CupertinoIcons.calendar,
      onTap: () => _pickDate(context),
      validator: (value) {
        if (isRequired && (value == null || value.trim().isEmpty)) {
          return 'Please select $label';
        }
        if (value != null && value.isNotEmpty && _parseDate(value) == null) {
          return 'Please enter a valid date';
        }
        return null;
      },
    );
  }
}

/// Dropdown styled to match [AppTextField].
class ProfileDropdownField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final bool isRequired;
  final String? hint;

  const ProfileDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.isRequired = false,
    this.hint,
  });

  bool _valueInItems(T? selected) {
    if (selected == null) return false;
    return items.any((item) => item.value == selected);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveValue = _valueInItems(value) ? value : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          isRequired ? '$label *' : label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
        AppSpacing.vGapSm,
        DropdownButtonFormField<T>(
          key: ValueKey('$label-$effectiveValue-${items.length}'),
          initialValue: effectiveValue,
          items: items,
          onChanged: onChanged,
          isExpanded: true,
          hint: hint != null
              ? Text(
                  hint!,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                )
              : null,
          style: GoogleFonts.inter(
            fontSize: 16,
            color: theme.colorScheme.onSurface,
          ),
          decoration: ProfileFieldDecorations.bordered(theme),
          validator: isRequired
              ? (v) => v == null ? 'Please select $label' : null
              : null,
        ),
      ],
    );
  }
}

/// Labeled switch row used for the yes/no questions on the basic tab.
class ProfileSwitchField extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const ProfileSwitchField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fillColor = isDark
        ? theme.colorScheme.surfaceContainerHigh
        : AppColors.iosSystemGray6;
    final idleBorder = isDark
        ? AppColors.iosSystemGray4Dark
        : AppColors.iosSystemGray3;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(color: idleBorder, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            activeThumbColor: theme.colorScheme.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

/// Shared dialog shell for add/edit record forms.
///
/// Wrap the fields in a [Form] keyed by [formKey]; [onSave] is invoked only
/// after validation passes.
class RecordEditorDialog extends StatelessWidget {
  final String title;
  final GlobalKey<FormState> formKey;
  final List<Widget> fields;
  final VoidCallback onSave;

  const RecordEditorDialog({
    super.key,
    required this.title,
    required this.formKey,
    required this.fields,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      insetPadding: const EdgeInsets.all(AppSpacing.md),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
          maxWidth: AppSizes.maxCardWidth,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: -0.3,
                    ),
                  ),
                  AppSpacing.vGapLg,
                  for (final field in fields) ...[field, AppSpacing.vGapMd],
                  AppSpacing.vGapSm,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AppButton.ghost(
                        label: 'Cancel',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      AppSpacing.hGapSm,
                      AppButton.primary(
                        label: 'Save',
                        isFullWidth: false,
                        size: AppButtonSize.small,
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            onSave();
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
