import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/themes/app_design_tokens.dart';

Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required Widget Function(BuildContext) builder,
  bool isScrollControlled = true,
  bool isDismissible = true,
  bool enableDrag = true,
  bool showDragHandle = true,
  Color? backgroundColor,
  double? maxHeight,
}) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    backgroundColor: backgroundColor ??
        (isDark ? AppColors.cardDark : AppColors.cardLight),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20),
      ),
    ),
    builder: (context) {
      Widget content = builder(context);

      if (showDragHandle) {
        content = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _DragHandle(),
            Flexible(child: content),
          ],
        );
      }

      if (maxHeight != null) {
        content = ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: content,
        );
      }

      return SafeArea(
        top: false,
        child: content,
      );
    },
  );
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 36,
      height: 5,
      decoration: BoxDecoration(
        color: AppColors.iosSystemGray4,
        borderRadius: BorderRadius.circular(2.5),
      ),
    );
  }
}

Future<T?> showAppActionSheet<T>({
  required BuildContext context,
  String? title,
  String? message,
  required List<AppActionSheetAction> actions,
  String cancelLabel = 'Cancel',
}) {
  return showCupertinoModalPopup<T>(
    context: context,
    builder: (context) => CupertinoActionSheet(
      title: title != null ? Text(title) : null,
      message: message != null ? Text(message) : null,
      actions: actions.map((action) {
        return CupertinoActionSheetAction(
          onPressed: () {
            Navigator.of(context).pop(action.value);
            action.onPressed?.call();
          },
          isDefaultAction: action.isDefault,
          isDestructiveAction: action.isDestructive,
          child: Text(action.label),
        );
      }).toList(),
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(cancelLabel),
      ),
    ),
  );
}

class AppActionSheetAction<T> {
  final String label;
  final T? value;
  final VoidCallback? onPressed;
  final bool isDefault;
  final bool isDestructive;

  const AppActionSheetAction({
    required this.label,
    this.value,
    this.onPressed,
    this.isDefault = false,
    this.isDestructive = false,
  });
}

Future<bool?> showAppConfirmDialog({
  required BuildContext context,
  required String title,
  String? message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool isDestructive = false,
}) {
  return showCupertinoDialog<bool>(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: Text(title),
      content: message != null
          ? Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(message),
            )
          : null,
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel),
        ),
        CupertinoDialogAction(
          onPressed: () => Navigator.of(context).pop(true),
          isDestructiveAction: isDestructive,
          isDefaultAction: !isDestructive,
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
}

Future<bool?> showAppDeleteConfirmDialog({
  required BuildContext context,
  String title = 'Delete',
  String? message,
  String confirmLabel = 'Delete',
  String cancelLabel = 'Cancel',
}) {
  return showAppConfirmDialog(
    context: context,
    title: title,
    message: message ?? 'Are you sure you want to delete this? This action cannot be undone.',
    confirmLabel: confirmLabel,
    cancelLabel: cancelLabel,
    isDestructive: true,
  );
}

Future<String?> showAppTextInputDialog({
  required BuildContext context,
  required String title,
  String? message,
  String? initialValue,
  String? placeholder,
  String confirmLabel = 'OK',
  String cancelLabel = 'Cancel',
  TextInputType keyboardType = TextInputType.text,
  int? maxLength,
  bool obscureText = false,
}) {
  String value = initialValue ?? '';

  return showCupertinoDialog<String>(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: Text(title),
      content: Column(
        children: [
          if (message != null) ...[
            const SizedBox(height: 8),
            Text(message),
          ],
          const SizedBox(height: 16),
          CupertinoTextField(
            autofocus: true,
            placeholder: placeholder,
            onChanged: (text) => value = text,
            controller: TextEditingController(text: initialValue),
            keyboardType: keyboardType,
            maxLength: maxLength,
            obscureText: obscureText,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
        ],
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(cancelLabel),
        ),
        CupertinoDialogAction(
          onPressed: () => Navigator.of(context).pop(value),
          isDefaultAction: true,
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
}

Future<T?> showAppDialog<T>({
  required BuildContext context,
  required String title,
  String? subtitle,
  required Widget content,
  List<Widget>? actions,
  bool barrierDismissible = true,
}) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) => Dialog(
      backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.borderRadiusXl,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
            const SizedBox(height: 16),
            content,
            if (actions != null && actions.isNotEmpty) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions
                    .map((action) => Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: action,
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

class AppBottomSheetHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onClose;

  const AppBottomSheetHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onClose != null)
            CupertinoButton(
              padding: EdgeInsets.zero,
              minSize: 44,
              onPressed: onClose,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.iosSystemGray5,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.xmark,
                  size: 14,
                  color: AppColors.iosSystemGray,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
