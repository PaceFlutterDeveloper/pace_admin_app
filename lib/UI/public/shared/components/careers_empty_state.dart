import 'package:admin_app/core/widgets/app_button.dart';
import 'package:flutter/material.dart';

import '../theme/careers_tokens.dart';

/// Compact empty state used by every careers list.
///
/// Deliberately small: icon, one-line title, one-line explanation and at most
/// one action, so it never dominates the screen.
class CareersEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const CareersEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hasAction = actionLabel != null && onAction != null;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(CareersSpacing.section),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                gradient: CareersGradients.accentWash,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 30, color: context.careers.accentText),
            ),
            CareersSpacing.gap16,
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium,
              ),
            ),
            if (hasAction) ...[
              CareersSpacing.gap24,
              AppButton.primary(
                label: actionLabel!,
                isFullWidth: false,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Error state with a retry action. Keeps user-facing copy generic; the
/// technical message stays out of the UI.
class CareersErrorState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const CareersErrorState({
    super.key,
    this.title = 'Something went wrong',
    this.message = 'Please check your connection and try again.',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return CareersEmptyState(
      icon: Icons.wifi_tethering_error_rounded,
      title: title,
      message: message,
      actionLabel: onRetry == null ? null : 'Try again',
      onAction: onRetry,
    );
  }
}
