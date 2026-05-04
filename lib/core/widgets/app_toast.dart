import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/themes/app_design_tokens.dart';

enum AppToastType {
  success,
  error,
  warning,
  info,
}

class AppToast {
  static OverlayEntry? _currentEntry;
  static Timer? _dismissTimer;

  static void show(
    BuildContext context, {
    required String message,
    AppToastType type = AppToastType.info,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
  }) {
    dismiss();

    final overlay = Overlay.of(context);

    _currentEntry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        type: type,
        onDismiss: dismiss,
        onTap: onTap,
      ),
    );

    overlay.insert(_currentEntry!);

    _dismissTimer = Timer(duration, dismiss);
  }

  static void success(BuildContext context, String message) {
    show(context, message: message, type: AppToastType.success);
  }

  static void error(BuildContext context, String message) {
    show(context, message: message, type: AppToastType.error);
  }

  static void warning(BuildContext context, String message) {
    show(context, message: message, type: AppToastType.warning);
  }

  static void info(BuildContext context, String message) {
    show(context, message: message, type: AppToastType.info);
  }

  static void dismiss() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    if (_currentEntry != null && _currentEntry!.mounted) {
      _currentEntry!.remove();
    }
    _currentEntry = null;
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final AppToastType type;
  final VoidCallback onDismiss;
  final VoidCallback? onTap;

  const _ToastWidget({
    required this.message,
    required this.type,
    required this.onDismiss,
    this.onTap,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDurations.normal,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppCurves.standard,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppCurves.standard,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  Color get _backgroundColor {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (widget.type) {
      case AppToastType.success:
        return isDark ? AppColors.iosGreenDark : AppColors.iosGreen;
      case AppToastType.error:
        return isDark ? AppColors.iosRedDark : AppColors.iosRed;
      case AppToastType.warning:
        return isDark ? AppColors.iosOrangeDark : AppColors.iosOrange;
      case AppToastType.info:
        return Theme.of(context).colorScheme.primary;
    }
  }

  IconData get _icon {
    switch (widget.type) {
      case AppToastType.success:
        return CupertinoIcons.checkmark_circle_fill;
      case AppToastType.error:
        return CupertinoIcons.xmark_circle_fill;
      case AppToastType.warning:
        return CupertinoIcons.exclamationmark_triangle_fill;
      case AppToastType.info:
        return CupertinoIcons.info_circle_fill;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Positioned(
      top: mediaQuery.padding.top + AppSpacing.md,
      left: AppSpacing.md,
      right: AppSpacing.md,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: GestureDetector(
            onTap: () {
              widget.onTap?.call();
              _dismiss();
            },
            onVerticalDragEnd: (details) {
              if (details.primaryVelocity != null &&
                  details.primaryVelocity! < 0) {
                _dismiss();
              }
            },
            child: Material(
              color: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(maxWidth: AppSizes.maxContentWidth),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm + 2,
                ),
                decoration: BoxDecoration(
                  color: _backgroundColor,
                  borderRadius: AppRadius.borderRadiusPill,
                  boxShadow: AppShadows.medium,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _icon,
                      size: 20,
                      color: Colors.white,
                    ),
                    AppSpacing.hGapSm,
                    Flexible(
                      child: Text(
                        widget.message,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                onPressed: onAction ?? () {},
              )
            : null,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderRadiusMd,
        ),
        margin: const EdgeInsets.all(AppSpacing.md),
      ),
    );
  }
}
