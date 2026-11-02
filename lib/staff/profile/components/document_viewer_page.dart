import 'package:admin_app/staff/profile/document_share.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/theme/staff_theme.dart';
import 'package:admin_app/staff/widgets/staff_widgets.dart';
import 'package:flutter/material.dart';

/// Full-screen preview for a downloaded staff image document.
class DocumentViewerPage extends StatelessWidget {
  const DocumentViewerPage({
    super.key,
    required this.title,
    required this.document,
  });

  final String title;
  final StaffDocumentFile document;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        backgroundColor: p.surface,
        foregroundColor: p.text,
        elevation: 0,
        title: Text(
          title.trim().isEmpty ? document.name : title.trim(),
          style: sora(16, weight: FontWeight.w700, color: p.text),
        ),
        leading: IconButton(
          tooltip: 'Close',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: StaffIcon(StaffGlyphs.close, size: 20, color: p.text),
        ),
      ),
      body: document.isImage
          ? ColoredBox(
              color: p.background,
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 5,
                child: Center(
                  child: Image.file(
                    document.file,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const _Unsupported(
                      message: 'Could not open this image.',
                    ),
                  ),
                ),
              ),
            )
          : const _Unsupported(
              message: 'This file type cannot be previewed in the app.',
            ),
    );
  }
}

class _Unsupported extends StatelessWidget {
  const _Unsupported({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: sora(14, weight: FontWeight.w600, color: p.muted, height: 1.4),
        ),
      ),
    );
  }
}
