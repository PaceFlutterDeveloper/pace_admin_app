import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/themes/app_design_tokens.dart';

class AppTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final FormFieldValidator<String>? validator;
  final Widget? prefix;
  final Widget? suffix;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final bool showClearButton;
  final AutovalidateMode? autovalidateMode;

  /// When true, shows a subtle 1px border when idle (used on profile forms).
  final bool outlined;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.focusNode,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
    this.prefix,
    this.suffix,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.showClearButton = false,
    this.autovalidateMode,
    this.outlined = false,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late FocusNode _focusNode;
  late TextEditingController _controller;
  bool _isFocused = false;
  bool _obscureText = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _controller = widget.controller ?? TextEditingController();
    _obscureText = widget.obscureText;
    _focusNode.addListener(_handleFocusChange);
    _controller.addListener(_handleTextChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _controller.removeListener(_handleTextChange);
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _handleTextChange() {
    setState(() {});
  }

  void _toggleObscure() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  /// Parent-controlled when a custom [suffix] is provided; otherwise internal.
  bool get _effectiveObscureText =>
      widget.suffix != null ? widget.obscureText : _obscureText;

  void _clearText() {
    _controller.clear();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final hasError =
        widget.errorText != null ||
        (_errorText != null && _errorText!.isNotEmpty);

    final fillColor = isDark
        ? theme.colorScheme.surfaceContainerHigh
        : AppColors.iosSystemGray6;

    final adaptiveErrorColor = isDark ? AppColors.iosRedDark : AppColors.iosRed;

    final idleBorderColor = isDark
        ? AppColors.iosSystemGray4Dark
        : AppColors.iosSystemGray3;

    Color borderColor;
    if (hasError) {
      borderColor = adaptiveErrorColor;
    } else if (_isFocused) {
      borderColor = primaryColor;
    } else if (widget.outlined) {
      borderColor = idleBorderColor;
    } else {
      borderColor = Colors.transparent;
    }

    final borderWidth = _isFocused || hasError
        ? 2.0
        : widget.outlined
        ? 1.0
        : 0.0;

    final grayColor = isDark
        ? AppColors.iosSystemGrayDark
        : AppColors.iosSystemGray;
    final gray3Color = isDark
        ? AppColors.iosSystemGray3Dark
        : AppColors.iosSystemGray3;

    Widget? suffixWidget;
    if (widget.suffix != null) {
      suffixWidget = widget.suffix;
    } else if (widget.obscureText) {
      suffixWidget = GestureDetector(
        onTap: _toggleObscure,
        child: Icon(
          _obscureText ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
          color: grayColor,
          size: 22,
        ),
      );
    } else if (widget.showClearButton && _controller.text.isNotEmpty) {
      suffixWidget = GestureDetector(
        onTap: _clearText,
        child: Icon(
          CupertinoIcons.clear_circled_solid,
          color: gray3Color,
          size: 20,
        ),
      );
    } else if (widget.suffixIcon != null) {
      suffixWidget = GestureDetector(
        onTap: widget.onSuffixTap,
        child: Icon(widget.suffixIcon, color: grayColor, size: 22),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: hasError
                  ? adaptiveErrorColor
                  : theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          AppSpacing.vGapSm,
        ],
        AnimatedContainer(
          duration: AppDurations.fast,
          curve: AppCurves.standard,
          decoration: BoxDecoration(
            color: widget.enabled
                ? fillColor
                : fillColor.withValues(alpha: 0.5),
            borderRadius: AppRadius.borderRadiusMd,
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          child: TextFormField(
            controller: _controller,
            focusNode: _focusNode,
            obscureText: _effectiveObscureText,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            autofocus: widget.autofocus,
            maxLines: widget.obscureText ? 1 : widget.maxLines,
            minLines: widget.minLines,
            maxLength: widget.maxLength,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            textCapitalization: widget.textCapitalization,
            inputFormatters: widget.inputFormatters,
            autovalidateMode: widget.autovalidateMode,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: theme.colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: grayColor,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              filled: false,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 14,
              ),
              prefixIcon: widget.prefixIcon != null || widget.prefix != null
                  ? Padding(
                      padding: const EdgeInsets.only(left: 12, right: 8),
                      child:
                          widget.prefix ??
                          Icon(widget.prefixIcon, color: grayColor, size: 22),
                    )
                  : null,
              prefixIconConstraints: const BoxConstraints(
                minWidth: 0,
                minHeight: 0,
              ),
              suffixIcon: suffixWidget != null
                  ? Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: suffixWidget,
                    )
                  : null,
              suffixIconConstraints: const BoxConstraints(
                minWidth: 0,
                minHeight: 0,
              ),
              counterText: '',
              errorStyle: const TextStyle(height: 0, fontSize: 0),
            ),
            onChanged: widget.onChanged,
            onFieldSubmitted: widget.onSubmitted,
            onTap: widget.onTap,
            validator: (value) {
              final error = widget.validator?.call(value);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _errorText = error;
                  });
                }
              });
              return error;
            },
          ),
        ),
        if (hasError || widget.helperText != null) ...[
          AppSpacing.vGapXs,
          Text(
            widget.errorText ?? _errorText ?? widget.helperText ?? '',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: hasError
                  ? adaptiveErrorColor
                  : theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ],
    );
  }
}

class AppSearchField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool autofocus;
  final bool enabled;

  const AppSearchField({
    super.key,
    this.controller,
    this.hint,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.autofocus = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      hint: hint ?? 'Search...',
      prefixIcon: CupertinoIcons.search,
      showClearButton: true,
      autofocus: autofocus,
      enabled: enabled,
      textInputAction: TextInputAction.search,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
    );
  }
}
