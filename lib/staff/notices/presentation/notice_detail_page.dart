import 'package:admin_app/core/widgets/app_toast.dart';
import 'package:admin_app/staff/notices/domain/notice_models.dart';
import 'package:admin_app/staff/notices/domain/notices_repository.dart';
import 'package:admin_app/staff/shared/read_json.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/theme/staff_theme.dart';
import 'package:admin_app/staff/widgets/staff_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class NoticeDetailPage extends StatefulWidget {
  const NoticeDetailPage({
    super.key,
    required this.notice,
    required this.repository,
  });

  final StaffNotice notice;
  final NoticesRepository repository;

  @override
  State<NoticeDetailPage> createState() => _NoticeDetailPageState();
}

class _NoticeDetailPageState extends State<NoticeDetailPage> {
  late StaffNotice _notice = widget.notice;
  bool _loading = true;
  String? _error;
  bool _acknowledging = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final full = await widget.repository.detail(widget.notice.id);
      if (!mounted) return;
      setState(() {
        _notice = full;
        _loading = false;
      });
      if (!full.isRead) {
        // Fire and forget: reading must not fail because the flag did.
        widget.repository.markRead(full.id).catchError((_) {});
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = staffErrorMessage(e);
        });
      }
    }
  }

  Future<void> _acknowledge() async {
    setState(() => _acknowledging = true);
    try {
      await widget.repository.acknowledge(_notice.id);
      if (!mounted) return;
      setState(() {
        _notice = _notice.copyWith(acknowledged: true);
        _acknowledging = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _acknowledging = false);
      AppToast.error(context, staffErrorMessage(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final n = _notice;
    final looksLikeHtml = RegExp(r'<[a-zA-Z][^>]*>').hasMatch(n.body);
    return StaffPage(
      child: Column(
        children: [
          StaffPageHeader(title: 'Notice'),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 32),
              children: [
                Text(
                  n.title,
                  style: sora(
                    22,
                    weight: FontWeight.w700,
                    color: p.text,
                    letterSpacing: -0.5,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  [
                    if (n.publishedAt != null)
                      DateFormat('EEE, d MMM yyyy').format(n.publishedAt!),
                    if (n.category.isNotEmpty) n.category,
                  ].join(' · '),
                  style: sora(12, color: p.muted),
                ),
                const SizedBox(height: 18),
                if (_loading && n.body.isEmpty)
                  const StaffSkeleton(height: 120, radius: 18)
                else if (_error != null && n.body.isEmpty)
                  Text(_error!, style: sora(13, color: p.dangerText))
                else if (looksLikeHtml)
                  HtmlWidget(
                    n.body,
                    textStyle: sora(14, color: p.text, height: 1.55),
                    onTapUrl: (url) => launchUrl(
                      Uri.parse(url),
                      mode: LaunchMode.externalApplication,
                    ),
                  )
                else
                  Text(
                    n.body.isEmpty ? n.summary : n.body,
                    style: sora(14, color: p.text, height: 1.55),
                  ),
                if (n.attachments.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  Text(
                    'ATTACHMENTS',
                    style: sora(
                      10.5,
                      weight: FontWeight.w700,
                      color: p.muted,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final file in n.attachments)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: StaffCard(
                        radius: 16,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        onTap: file.url.isEmpty
                            ? null
                            : () => launchUrl(
                                Uri.parse(file.url),
                                mode: LaunchMode.externalApplication,
                              ),
                        child: Row(
                          children: [
                            StaffIcon(
                              StaffGlyphs.paperclip,
                              size: 18,
                              color: p.amberText,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                file.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: sora(
                                  13,
                                  weight: FontWeight.w600,
                                  color: p.text,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
                if (n.needsAcknowledgement) ...[
                  const SizedBox(height: 22),
                  AmberButton(
                    label: n.acknowledged ? 'Acknowledged' : 'I have read this',
                    loading: _acknowledging,
                    onPressed: n.acknowledged || _acknowledging
                        ? null
                        : _acknowledge,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
