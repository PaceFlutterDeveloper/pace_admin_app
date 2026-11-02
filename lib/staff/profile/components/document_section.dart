import 'package:admin_app/staff/profile/components/document_viewer_page.dart';
import 'package:admin_app/staff/profile/document_share.dart';
import 'package:admin_app/staff/profile/model/doc_model.dart';
import 'package:admin_app/staff/profile/personal_details.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/theme/staff_theme.dart';
import 'package:admin_app/staff/widgets/staff_widgets.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

enum DocumentHealth { ok, expiring, expired, noExpiry }

/// Health of a document against its alert window.
DocumentHealth documentHealth(DocModel doc, {DateTime? now}) {
  if (doc.expiryDate.trim().isEmpty) return DocumentHealth.noExpiry;
  final expiry = DateTime.tryParse(doc.expiryDate);
  if (expiry == null) return DocumentHealth.noExpiry;
  final today = now ?? DateTime.now();
  if (expiry.isBefore(today)) return DocumentHealth.expired;
  final alert = int.tryParse(doc.alertDays) ?? 0;
  if (expiry.isBefore(today.add(Duration(days: alert)))) {
    return DocumentHealth.expiring;
  }
  return DocumentHealth.ok;
}

/// Staff documents with expiry status, view, and download actions.
class DocumentSection extends StatefulWidget {
  final int documentStatus;
  final List<DocModel> documents;

  /// Replaces the real download/share in tests.
  final Future<void> Function(DocModel doc, {Rect? origin})? shareDocument;

  /// Replaces the real preview open in tests.
  final Future<void> Function(BuildContext context, DocModel doc)? viewDocument;

  const DocumentSection({
    super.key,
    required this.documents,
    required this.documentStatus,
    this.shareDocument,
    this.viewDocument,
  });

  @override
  State<DocumentSection> createState() => _DocumentSectionState();
}

class _DocumentSectionState extends State<DocumentSection> {
  String? _busyId;
  String? _errorFor;
  String? _error;

  Future<void> _run(
    DocModel doc,
    Future<void> Function() action,
  ) async {
    if (_busyId != null) return;
    setState(() {
      _busyId = doc.id;
      _errorFor = null;
      _error = null;
    });
    try {
      await action();
    } on DocumentShareException catch (error) {
      _fail(doc.id, error.message);
    } catch (_) {
      _fail(doc.id, 'Could not open this document.');
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  Future<void> _share(DocModel doc, Rect? origin) {
    return _run(
      doc,
      () => (widget.shareDocument ?? shareStaffDocument)(doc, origin: origin),
    );
  }

  Future<void> _view(DocModel doc) {
    return _run(doc, () async {
      if (widget.viewDocument != null) {
        await widget.viewDocument!(context, doc);
        return;
      }
      final downloaded = await downloadStaffDocument(doc);
      if (!downloaded.canPreview) {
        throw const DocumentShareException(
          'This file type cannot be previewed in the app. Use Download instead.',
        );
      }
      if (!mounted) return;

      // PDFs use the system viewer — avoids a native PDFium dependency that
      // crashed the screen when the library was not linked after hot restart.
      if (downloaded.isPdf) {
        final result = await OpenFilex.open(
          downloaded.file.path,
          type: 'application/pdf',
          uti: 'com.adobe.pdf',
        );
        if (result.type != ResultType.done) {
          throw DocumentShareException(
            result.message.trim().isEmpty
                ? 'Could not open this PDF.'
                : result.message.trim(),
          );
        }
        return;
      }

      await Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) => DocumentViewerPage(
            title: doc.doc,
            document: downloaded,
          ),
        ),
      );
    });
  }

  void _fail(String id, String message) {
    if (!mounted) return;
    setState(() {
      _errorFor = id;
      _error = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final documents = widget.documents;

    if (documents.isEmpty) {
      return const StaffStateMessage(
        glyph: StaffGlyphs.doc,
        title: 'No documents',
        message: 'Documents on your file will appear here.',
        accent: StaffAccent.blue,
      );
    }

    final canOpen = documents.any((doc) => doc.downloadUrl.trim().isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (canOpen) ...[
          Text(
            'View opens the file for preview. Download opens the share sheet so you can save it or send it elsewhere.',
            style: sora(
              12,
              weight: FontWeight.w500,
              color: p.muted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (widget.documentStatus != 0)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: p.amberSoft,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: p.amberLine),
            ),
            child: Row(
              children: [
                StaffIcon(StaffGlyphs.bell, size: 18, color: p.amberText),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Some documents are about to expire. Please renew them soon.',
                    style: sora(
                      12,
                      weight: FontWeight.w600,
                      color: p.amberText,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        for (final doc in documents)
          _DocumentTile(
            doc: doc,
            busy: _busyId == doc.id,
            enabled: _busyId == null,
            error: _errorFor == doc.id ? _error : null,
            onView: _view,
            onDownload: _share,
          ),
      ],
    );
  }
}

class _DocumentTile extends StatelessWidget {
  const _DocumentTile({
    required this.doc,
    required this.busy,
    required this.enabled,
    required this.error,
    required this.onView,
    required this.onDownload,
  });

  final DocModel doc;
  final bool busy;
  final bool enabled;
  final String? error;
  final Future<void> Function(DocModel doc) onView;
  final Future<void> Function(DocModel doc, Rect? origin) onDownload;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final health = documentHealth(doc);
    final (label, color) = switch (health) {
      DocumentHealth.expired => ('Expired', p.dangerText),
      DocumentHealth.expiring => ('Expiring soon', p.amberText),
      DocumentHealth.ok => ('Valid', const Color(0xFF34D399)),
      DocumentHealth.noExpiry => ('No expiry', p.muted),
    };
    final canOpen = doc.downloadUrl.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: p.surfaceRaised,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: p.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const GlassIconTile(
                glyph: StaffGlyphs.doc,
                accent: StaffAccent.blue,
                size: 38,
                radius: 13,
                iconSize: 19,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.doc,
                      style: sora(13.5, weight: FontWeight.w600, color: p.text),
                    ),
                    if (doc.docNo.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'No. ${doc.docNo}',
                        style: sora(
                          11.5,
                          weight: FontWeight.w400,
                          color: p.muted,
                        ),
                      ),
                    ],
                    if (doc.issueDate.trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Issued ${formatStaffDate(doc.issueDate)}',
                        style: sora(
                          11.5,
                          weight: FontWeight.w400,
                          color: p.muted,
                        ),
                      ),
                    ],
                    const SizedBox(height: 2),
                    Text(
                      'Expires ${formatStaffDate(doc.expiryDate)}',
                      style: sora(
                        11.5,
                        weight: FontWeight.w400,
                        color: p.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  label,
                  style: sora(10.5, weight: FontWeight.w700, color: color),
                ),
              ),
            ],
          ),
          if (canOpen) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AmberButton(
                    label: 'View',
                    glyph: StaffGlyphs.eye,
                    height: 40,
                    soft: true,
                    loading: busy,
                    onPressed: !enabled ? null : () => onView(doc),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Builder(
                    builder: (buttonContext) {
                      return Semantics(
                        button: true,
                        label: 'Download ${doc.doc}',
                        child: AmberButton(
                          label: 'Download',
                          glyph: StaffGlyphs.download,
                          height: 40,
                          soft: true,
                          loading: busy,
                          onPressed: !enabled
                              ? null
                              : () {
                                  final box =
                                      buttonContext.findRenderObject()
                                          as RenderBox?;
                                  final origin = box != null && box.hasSize
                                      ? box.localToGlobal(Offset.zero) &
                                            box.size
                                      : null;
                                  onDownload(doc, origin);
                                },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
          if (error != null) ...[
            const SizedBox(height: 8),
            Text(
              error!,
              style: sora(
                12,
                weight: FontWeight.w600,
                color: p.dangerText,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
