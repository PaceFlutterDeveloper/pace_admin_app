import 'package:admin_app/UI/public/shared/theme/careers_tokens.dart';
import 'package:admin_app/UI/public/user/utils/careers_api_dates.dart';
import 'package:admin_app/core/widgets/app_button.dart';
import 'package:admin_app/core/widgets/app_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Shared bordered input decoration for profile dropdowns.
class ProfileFieldDecorations {
  ProfileFieldDecorations._();

  static InputDecoration bordered(ThemeData theme, {String? errorText}) {
    final hasError = errorText != null && errorText.isNotEmpty;
    final palette = theme.extension<CareersPalette>() ?? CareersPalette.light;

    return InputDecoration(
      filled: true,
      fillColor: palette.surface,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      border: _border(palette.border),
      enabledBorder: hasError
          ? _border(CareersColors.error, 1.4)
          : _border(palette.border),
      focusedBorder: _border(
        hasError ? CareersColors.error : palette.accentText,
        1.4,
      ),
      errorBorder: _border(CareersColors.error),
      focusedErrorBorder: _border(CareersColors.error, 1.4),
      errorStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: CareersColors.error,
      ),
    );
  }

  static OutlineInputBorder _border(Color color, [double width = 1]) {
    return OutlineInputBorder(
      borderRadius: CareersRadius.inputAll,
      borderSide: BorderSide(color: color, width: width),
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

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DateTime? _parseDate(String dateStr) {
    if (dateStr.isEmpty) return null;
    return CareersApiDates.parseFlexible(dateStr);
  }

  String? _validateDateRange(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    final parsed = _parseDate(value.trim());
    if (parsed == null) return 'Please enter a valid date';

    final date = _dateOnly(parsed);
    final min = firstDate != null ? _dateOnly(firstDate!) : null;
    final max = lastDate != null ? _dateOnly(lastDate!) : null;

    if (min != null && date.isBefore(min)) {
      return '$label must be on or after ${_formatDisplay(min)}';
    }
    if (max != null && date.isAfter(max)) {
      return '$label must be on or before ${_formatDisplay(max)}';
    }

    return null;
  }

  String _formatDisplay(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  Future<void> _pickDate(BuildContext context) async {
    final min = _dateOnly(firstDate ?? DateTime(1950));
    final max = _dateOnly(
      lastDate ?? DateTime.now().add(const Duration(days: 365 * 5)),
    );
    var initial = _dateOnly(_parseDate(controller.text) ?? DateTime.now());
    if (initial.isBefore(min)) initial = min;
    if (initial.isAfter(max)) initial = max;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: min,
      lastDate: max,
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
        return _validateDateRange(value);
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
    final palette = context.careers;
    final effectiveValue = _valueInItems(value) ? value : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          isRequired ? '$label *' : label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
            color: palette.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          key: ValueKey('$label-$effectiveValue-${items.length}'),
          initialValue: effectiveValue,
          items: items,
          onChanged: onChanged,
          isExpanded: true,
          borderRadius: CareersRadius.inputAll,
          dropdownColor: palette.surface,
          icon: Icon(
            CupertinoIcons.chevron_down,
            size: 16,
            color: palette.textTertiary,
          ),
          hint: hint != null
              ? Text(
                  hint!,
                  style: TextStyle(fontSize: 15, color: palette.textTertiary),
                )
              : null,
          style: TextStyle(fontSize: 15, color: palette.textPrimary),
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
    final palette = context.careers;
    return Semantics(
      container: true,
      toggled: value,
      label: label,
      child: GestureDetector(
        onTap: () => onChanged(!value),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: CareersRadius.inputAll,
            border: Border.fromBorderSide(BorderSide(color: palette.border)),
          ),
          child: Row(
            children: [
              Expanded(
                child: ExcludeSemantics(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w500,
                      color: palette.textPrimary,
                      height: 1.35,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _CareersSwitch(value: value),
            ],
          ),
        ),
      ),
    );
  }
}

/// Solid track and thumb with no elevation shadow. Material's adaptive switch
/// paints a blurred thumb shadow and ink overlay that looks soft on Android.
class _CareersSwitch extends StatelessWidget {
  final bool value;

  const _CareersSwitch({required this.value});

  static const double _width = 46;
  static const double _height = 28;
  static const double _thumb = 22;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      width: _width,
      height: _height,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: value
            ? CareersColors.primary
            : (context.careers.isDark
                  ? const Color(0xFF3F446E)
                  : const Color(0xFFCBD5E1)),
        borderRadius: BorderRadius.circular(_height / 2),
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: const DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: SizedBox.square(dimension: _thumb),
        ),
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
    final media = MediaQuery.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          // Leave room for the keyboard so fields stay reachable.
          maxHeight: (media.size.height - media.viewInsets.bottom - 48).clamp(
            240.0,
            media.size.height,
          ),
          maxWidth: 480,
        ),
        child: Padding(
          padding: const EdgeInsets.all(CareersSpacing.section),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.headlineSmall),
                  CareersSpacing.gap24,
                  for (final field in fields) ...[field, CareersSpacing.gap16],
                  CareersSpacing.gap8,
                  Row(
                    children: [
                      Expanded(
                        child: AppButton.ghost(
                          label: 'Cancel',
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton.primary(
                          label: 'Save',
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              onSave();
                            }
                          },
                        ),
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
