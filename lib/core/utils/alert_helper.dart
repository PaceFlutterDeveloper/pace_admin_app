// lib/core/utils/alert_helper.dart

import 'package:flutter/material.dart';

/// Shows a success dialog with:
///  • a green check icon
///  • your [message]
///  • a button (default text “Close”) that pops the dialog and then calls [onPressed]
Future<void> showSuccessAlert(
  BuildContext context, {
  required String message,
  String title = 'Success',
  String buttonText = 'Close',
  VoidCallback? onPressed,
}) {
  return showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            if (onPressed != null) onPressed();
          },
          child: Text(buttonText),
        ),
      ],
    ),
  );
}

/// Shows an error dialog with:
///  • a red error icon
///  • your [message]
///  • a button (default text “Close”) that pops the dialog and then calls [onPressed]
Future<void> showErrorAlert(
  BuildContext context, {
  required String message,
  String title = 'Error',
  String buttonText = 'Close',
  VoidCallback? onPressed,
}) {
  return showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            if (onPressed != null) onPressed();
          },
          child: Text(buttonText),
        ),
      ],
    ),
  );
}
