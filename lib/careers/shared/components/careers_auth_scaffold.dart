import 'dart:ui' show ImageFilter;

import 'package:admin_app/careers/shared/theme/careers_tokens.dart';
import 'package:admin_app/core/utils/dismiss_keyboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Palette for the auth screens: a deep midnight backdrop with frosted glass
/// surfaces. Scoped here because nothing else in careers uses a dark surface.
class _AuthColors {
  _AuthColors._();

  static const Color midnight = Color(0xFF0A0D29);
  static const Color indigoNight = Color(0xFF191A52);
  static const Color indigoDusk = Color(0xFF2A2880);

  static const Color text = Color(0xFFFFFFFF);
  static Color textMuted = Colors.white.withValues(alpha: 0.68);
  static Color textSubtle = Colors.white.withValues(alpha: 0.44);

  static Color fieldFill = Colors.white.withValues(alpha: 0.07);
  static Color fieldFillFocused = Colors.white.withValues(alpha: 0.12);
  static Color fieldBorder = Colors.white.withValues(alpha: 0.14);
  static Color fieldBorderFocused = Colors.white.withValues(alpha: 0.6);

  static const Color error = Color(0xFFFCA5A5);
  static const Color onCta = CareersColors.primaryDeep;
}

const _fieldRadius = BorderRadius.all(Radius.circular(14));
const _panelRadius = BorderRadius.all(Radius.circular(28));

/// Shared shell for the careers and staff auth screens: midnight backdrop
/// with the form on a frosted glass panel.
///
/// Content fills the viewport when it fits. When it is taller than the screen,
/// including while the keyboard is open, the page scrolls.
class CareersAuthScaffold extends StatelessWidget {
  static const double _maxContentWidth = 440;

  final String title;
  final String subtitle;

  /// The form fields and primary action.
  final Widget form;

  /// Links shown below the panel (sign up / sign in, continue as guest).
  final List<Widget> footer;

  /// Hidden on the cold-start login gate, where there is no previous page.
  final bool showBackButton;

  /// Replaces the default pop. Staff login closes its overlay instead.
  final VoidCallback? onBack;

  /// Pinned to the top-right of the screen, opposite the back button.
  final Widget? headerAction;

  const CareersAuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.form,
    this.footer = const [],
    this.showBackButton = true,
    this.onBack,
    this.headerAction,
  });

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.sizeOf(context).width < 360;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _AuthColors.midnight,
        body: Stack(
          fit: StackFit.expand,
          children: [
            const _Backdrop(),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const topPad = 8.0;
                  const bottomPad = 12.0;
                  final horizontal = isNarrow ? 16.0 : 20.0;
                  final minContentHeight = (constraints.maxHeight -
                          topPad -
                          bottomPad)
                      .clamp(0.0, double.infinity);

                  return SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontal,
                          topPad,
                          horizontal,
                          bottomPad,
                        ),
                        child: Center(
                          heightFactor: 1,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: _maxContentWidth,
                              minHeight: minContentHeight,
                            ),
                            child: _AuthContent(
                              title: title,
                              subtitle: subtitle,
                              form: form,
                              footer: footer,
                              isNarrow: isNarrow,
                              showBackButton: showBackButton,
                              onBack: onBack,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (headerAction != null)
              Positioned(
                top: MediaQuery.paddingOf(context).top + 8,
                right: isNarrow ? 16 : 20,
                child: headerAction!,
              ),
          ],
        ),
      ),
    );
  }
}

/// Frosted action pinned to the top of the auth screens.
class CareersAuthHeaderButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const CareersAuthHeaderButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Material(
            color: Colors.white.withValues(alpha: 0.1),
            shape: StadiumBorder(
              side: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onPressed,
              child: SizedBox(
                height: 40,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 15, color: _AuthColors.text),
                      const SizedBox(width: 6),
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.1,
                          color: _AuthColors.text,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthContent extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget form;
  final List<Widget> footer;
  final bool isNarrow;
  final bool showBackButton;
  final VoidCallback? onBack;

  const _AuthContent({
    required this.title,
    required this.subtitle,
    required this.form,
    required this.footer,
    required this.isNarrow,
    required this.showBackButton,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showBackButton)
          Align(
            alignment: Alignment.centerLeft,
            child: _BackButton(
              onPressed: () {
                dismissKeyboard();
                final back = onBack;
                if (back != null) {
                  back();
                  return;
                }
                Navigator.of(context).pop();
              },
            ),
          )
        else
          const SizedBox.shrink(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Image.asset(
                'assets/logo/group.png',
                height: isNarrow ? 36 : 42,
                fit: BoxFit.contain,
                semanticLabel: 'Pace Group',
              ),
            ),
            SizedBox(height: isNarrow ? 16 : 20),
            Text(
              title,
              style: TextStyle(
                fontSize: isNarrow ? 25 : 28,
                fontWeight: FontWeight.w700,
                color: _AuthColors.text,
                letterSpacing: -0.9,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: _AuthColors.textMuted,
              ),
            ),
            SizedBox(height: isNarrow ? 18 : 22),
            _GlassPanel(child: form),
          ],
        ),
        if (footer.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [const SizedBox(height: 16), ...footer],
          )
        else
          const SizedBox.shrink(),
      ],
    );
  }
}

class _Backdrop extends StatelessWidget {
  const _Backdrop();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _AuthColors.midnight,
            _AuthColors.indigoNight,
            _AuthColors.indigoDusk,
          ],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -140,
            right: -120,
            child: _Aura(size: 380, color: Color(0x994F46E5)),
          ),
          Positioned(
            top: 60,
            left: -150,
            child: _Aura(size: 300, color: Color(0x33F97316)),
          ),
          Positioned(
            bottom: -160,
            left: -80,
            child: _Aura(size: 420, color: Color(0x6606B6D4)),
          ),
          Positioned(
            bottom: 120,
            right: -140,
            child: _Aura(size: 280, color: Color(0x40EC4899)),
          ),
        ],
      ),
    );
  }
}

class _Aura extends StatelessWidget {
  final double size;
  final Color color;

  const _Aura({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withAlpha(0)]),
        ),
      ),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  final Widget child;

  const _GlassPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: _panelRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 48,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: _panelRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: _panelRadius,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.13),
                  Colors.white.withValues(alpha: 0.05),
                ],
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact text field for the glass auth panel.
///
/// Set [isPassword] for a field that obscures its input and shows its own
/// visibility toggle.
class CareersAuthField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final IconData? icon;

  /// Fixed text shown before the input, e.g. a dialling code.
  final String? prefixText;

  final bool isPassword;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;

  const CareersAuthField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.icon,
    this.prefixText,
    this.isPassword = false,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.autofillHints,
    this.onSubmitted,
    this.validator,
  });

  @override
  State<CareersAuthField> createState() => _CareersAuthFieldState();
}

class _CareersAuthFieldState extends State<CareersAuthField> {
  bool _obscured = true;

  OutlineInputBorder _border(Color color, [double width = 1]) {
    return OutlineInputBorder(
      borderRadius: _fieldRadius,
      borderSide: BorderSide(color: color, width: width),
    );
  }

  Widget? _buildPrefix() {
    if (widget.prefixText != null) {
      return Padding(
        padding: const EdgeInsets.only(left: 14, right: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.prefixText!,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _AuthColors.text,
              ),
            ),
            const SizedBox(width: 10),
            Container(width: 1, height: 18, color: _AuthColors.fieldBorder),
          ],
        ),
      );
    }
    if (widget.icon != null) {
      return Padding(
        padding: const EdgeInsets.only(left: 14, right: 10),
        child: Icon(widget.icon, size: 18, color: _AuthColors.textMuted),
      );
    }
    return null;
  }

  Widget? _buildSuffix() {
    if (!widget.isPassword) return null;
    return IconButton(
      onPressed: () => setState(() => _obscured = !_obscured),
      tooltip: _obscured ? 'Show password' : 'Hide password',
      visualDensity: VisualDensity.compact,
      splashRadius: 18,
      icon: Icon(
        _obscured ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
        size: 18,
        color: _AuthColors.textMuted,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 7),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
              color: _AuthColors.textMuted,
            ),
          ),
        ),
        TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword && _obscured,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          textCapitalization: widget.textCapitalization,
          inputFormatters: widget.inputFormatters,
          autofillHints: widget.autofillHints,
          onFieldSubmitted: widget.onSubmitted,
          validator: widget.validator,
          cursorColor: _AuthColors.text,
          cursorWidth: 1.6,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            height: 1.3,
            color: _AuthColors.text,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: _AuthColors.textSubtle,
            ),
            isDense: true,
            filled: true,
            fillColor: WidgetStateColor.resolveWith(
              (states) => states.contains(WidgetState.focused)
                  ? _AuthColors.fieldFillFocused
                  : _AuthColors.fieldFill,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            prefixIcon: _buildPrefix(),
            prefixIconConstraints: const BoxConstraints(minHeight: 0),
            suffixIcon: _buildSuffix(),
            suffixIconConstraints: const BoxConstraints(
              minWidth: 44,
              minHeight: 0,
            ),
            border: _border(_AuthColors.fieldBorder),
            enabledBorder: _border(_AuthColors.fieldBorder),
            focusedBorder: _border(_AuthColors.fieldBorderFocused, 1.2),
            errorBorder: _border(_AuthColors.error.withValues(alpha: 0.7)),
            focusedErrorBorder: _border(_AuthColors.error, 1.2),
            errorStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _AuthColors.error,
            ),
            errorMaxLines: 2,
          ),
        ),
      ],
    );
  }
}

class CareersAuthDropdownItem<T> {
  final T value;
  final String label;

  const CareersAuthDropdownItem({required this.value, required this.label});
}

/// Glass select that matches [CareersAuthField], including loading and error.
class CareersAuthDropdown<T> extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final T? value;
  final List<CareersAuthDropdownItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final FormFieldValidator<T>? validator;
  final bool isLoading;
  final String? loadError;
  final VoidCallback? onRetry;
  final String loadingLabel;

  const CareersAuthDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    this.isLoading = false,
    this.loadError,
    this.onRetry,
    this.loadingLabel = 'Loading...',
  });

  OutlineInputBorder _border(Color color, [double width = 1]) {
    return OutlineInputBorder(
      borderRadius: _fieldRadius,
      borderSide: BorderSide(color: color, width: width),
    );
  }

  Widget _fieldLabel() {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 7),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          color: _AuthColors.textMuted,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _fieldLabel(),
        if (isLoading)
          _StatusShell(
            child: Row(
              children: [
                CupertinoActivityIndicator(color: _AuthColors.textMuted),
                const SizedBox(width: 10),
                Text(
                  loadingLabel,
                  style: TextStyle(fontSize: 15, color: _AuthColors.textMuted),
                ),
              ],
            ),
          )
        else if (loadError != null)
          _StatusShell(
            borderColor: _AuthColors.error.withValues(alpha: 0.7),
            child: Row(
              children: [
                const Icon(
                  CupertinoIcons.exclamationmark_circle,
                  size: 18,
                  color: _AuthColors.error,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    loadError!,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: _AuthColors.error,
                    ),
                  ),
                ),
                if (onRetry != null)
                  CareersAuthTextAction(
                    label: 'Retry',
                    emphasized: true,
                    onPressed: onRetry!,
                  ),
              ],
            ),
          )
        else
          DropdownButtonFormField<T>(
            key: ValueKey<Object?>(value),
            initialValue: value,
            isExpanded: true,
            menuMaxHeight: 280,
            borderRadius: _fieldRadius,
            dropdownColor: _AuthColors.indigoNight,
            icon: Icon(
              CupertinoIcons.chevron_down,
              size: 16,
              color: _AuthColors.textMuted,
            ),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: _AuthColors.text,
            ),
            hint: Text(
              hint,
              style: TextStyle(fontSize: 15, color: _AuthColors.textSubtle),
            ),
            items: [
              for (final item in items)
                DropdownMenuItem<T>(
                  value: item.value,
                  child: Text(
                    item.label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: _AuthColors.text,
                    ),
                  ),
                ),
            ],
            onChanged: onChanged,
            validator: validator,
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: WidgetStateColor.resolveWith(
                (states) => states.contains(WidgetState.focused)
                    ? _AuthColors.fieldFillFocused
                    : _AuthColors.fieldFill,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 14, right: 10),
                child: Icon(icon, size: 18, color: _AuthColors.textMuted),
              ),
              prefixIconConstraints: const BoxConstraints(minHeight: 0),
              border: _border(_AuthColors.fieldBorder),
              enabledBorder: _border(_AuthColors.fieldBorder),
              focusedBorder: _border(_AuthColors.fieldBorderFocused, 1.2),
              errorBorder: _border(_AuthColors.error.withValues(alpha: 0.7)),
              focusedErrorBorder: _border(_AuthColors.error, 1.2),
              errorStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _AuthColors.error,
              ),
              errorMaxLines: 2,
            ),
          ),
      ],
    );
  }
}

class _StatusShell extends StatelessWidget {
  final Widget child;
  final Color? borderColor;

  const _StatusShell({required this.child, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _AuthColors.fieldFill,
        borderRadius: _fieldRadius,
        border: Border.all(color: borderColor ?? _AuthColors.fieldBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: child,
      ),
    );
  }
}

/// Primary call to action on the glass auth panel.
class CareersAuthButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const CareersAuthButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  State<CareersAuthButton> createState() => _CareersAuthButtonState();
}

class _CareersAuthButtonState extends State<CareersAuthButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.isLoading;

  void _setPressed(bool value) {
    if (!_enabled || _pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.label,
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: _enabled ? widget.onPressed : null,
        child: AnimatedScale(
          scale: _pressed ? 0.98 : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: AnimatedOpacity(
            opacity: widget.onPressed == null && !widget.isLoading ? 0.6 : 1,
            duration: const Duration(milliseconds: 150),
            child: Container(
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: _fieldRadius,
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFFFFFF), Color(0xFFE9EAFB)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.22),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: widget.isLoading
                  ? const CupertinoActivityIndicator(color: _AuthColors.onCta)
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.label,
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                            color: _AuthColors.onCta,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          CupertinoIcons.arrow_right,
                          size: 16,
                          color: _AuthColors.onCta,
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

/// Quiet text action used on the auth screens (forgot password, guest mode).
class CareersAuthTextAction extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool emphasized;

  const CareersAuthTextAction({
    super.key,
    required this.label,
    required this.onPressed,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: CareersRadius.chipAll,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: emphasized ? FontWeight.w600 : FontWeight.w500,
            color: emphasized ? _AuthColors.text : _AuthColors.textMuted,
          ),
        ),
      ),
    );
  }
}

/// Glass checkbox with a rich label, used for consent rows.
class CareersAuthCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final InlineSpan label;

  const CareersAuthCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
  });

  static TextStyle get linkStyle =>
      const TextStyle(color: _AuthColors.text, fontWeight: FontWeight.w600);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: value,
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: CareersRadius.chipAll,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: value ? _AuthColors.text : _AuthColors.fieldFill,
                  borderRadius: const BorderRadius.all(Radius.circular(6)),
                  border: Border.all(
                    color: value
                        ? _AuthColors.text
                        : Colors.white.withValues(alpha: 0.36),
                  ),
                ),
                child: value
                    ? const Icon(
                        CupertinoIcons.check_mark,
                        size: 13,
                        color: _AuthColors.onCta,
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text.rich(
                  label,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.35,
                    color: _AuthColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Footer link under the auth panel, e.g. "Don't have an account? Sign up".
class CareersAuthLink extends StatelessWidget {
  final String leading;
  final String action;
  final VoidCallback onPressed;

  const CareersAuthLink({
    super.key,
    required this.leading,
    required this.action,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: onPressed,
        borderRadius: CareersRadius.pillAll,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text.rich(
            TextSpan(
              style: TextStyle(fontSize: 14, color: _AuthColors.textMuted),
              children: [
                TextSpan(text: '$leading '),
                TextSpan(
                  text: action,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _AuthColors.text,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _BackButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Back',
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Material(
            color: Colors.white.withValues(alpha: 0.1),
            shape: CircleBorder(
              side: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onPressed,
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Icon(
                  CupertinoIcons.chevron_back,
                  size: 18,
                  color: _AuthColors.text,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
