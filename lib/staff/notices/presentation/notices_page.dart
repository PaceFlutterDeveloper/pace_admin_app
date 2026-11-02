import 'package:admin_app/dependancy_injection.dart';
import 'package:admin_app/staff/notices/domain/notice_models.dart';
import 'package:admin_app/staff/notices/domain/notices_repository.dart';
import 'package:admin_app/staff/notices/presentation/notice_detail_page.dart';
import 'package:admin_app/staff/shared/load_cubit.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/theme/staff_theme.dart';
import 'package:admin_app/staff/widgets/staff_form.dart';
import 'package:admin_app/staff/widgets/staff_load_view.dart';
import 'package:admin_app/staff/widgets/staff_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

/// Menu > Circulars: school announcements, pinned first.
class NoticesPage extends StatefulWidget {
  const NoticesPage({super.key, this.title = 'Circulars'});

  final String title;

  @override
  State<NoticesPage> createState() => _NoticesPageState();
}

class _NoticesPageState extends State<NoticesPage> {
  late final NoticesRepository _repository = locator<NoticesRepository>();
  late final LoadCubit<List<StaffNotice>> _cubit = LoadCubit(_repository.list)
    ..load();
  int _filter = 0;

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _open(StaffNotice notice) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) =>
            NoticeDetailPage(notice: notice, repository: _repository),
      ),
    );
    if (mounted) _cubit.load(quiet: true);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: StaffPage(
        child: Column(
          children: [
            StaffPageHeader(
              title: widget.title,
              subtitle: 'From the school office',
            ),
            StaffFilterRow(
              labels: const ['All', 'Unread'],
              selected: _filter,
              onSelect: (i) => setState(() => _filter = i),
            ),
            Expanded(
              child: StaffLoadView<List<StaffNotice>>(
                errorGlyph: StaffGlyphs.mega,
                errorTitle: 'Could not load circulars',
                builder: (context, all) {
                  final shown =
                      [
                        for (final n in all)
                          if (_filter == 0 || !n.isRead) n,
                      ]..sort((a, b) {
                        if (a.isPinned != b.isPinned)
                          return a.isPinned ? -1 : 1;
                        final ad = a.publishedAt ?? DateTime(1970);
                        final bd = b.publishedAt ?? DateTime(1970);
                        return bd.compareTo(ad);
                      });
                  if (shown.isEmpty) {
                    return StaffEmptyList(
                      glyph: StaffGlyphs.mega,
                      title:
                          _filter == 1 ? 'Nothing unread' : 'No circulars yet',
                      message: _filter == 1
                          ? 'You have read every circular.'
                          : 'School circulars and announcements will appear here.',
                    );
                  }
                  return ListView.separated(
                    physics: staffScrollPhysics,
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                    itemCount: shown.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) => _NoticeCard(
                      notice: shown[i],
                      onTap: () => _open(shown[i]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({required this.notice, required this.onTap});

  final StaffNotice notice;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    return StaffCard(
      radius: 20,
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassIconTile(
            glyph: notice.isPinned ? StaffGlyphs.flag : StaffGlyphs.mega,
            accent: StaffAccent.amber,
            size: 42,
            radius: 14,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (!notice.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: 7),
                        decoration: BoxDecoration(
                          color: p.amber,
                          shape: BoxShape.circle,
                        ),
                      ),
                    Expanded(
                      child: Text(
                        notice.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: sora(
                          14,
                          weight: notice.isRead
                              ? FontWeight.w600
                              : FontWeight.w700,
                          color: p.text,
                        ),
                      ),
                    ),
                  ],
                ),
                if (notice.summary.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    notice.summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: sora(12.5, color: p.muted, height: 1.4),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  [
                    if (notice.publishedAt != null)
                      DateFormat('d MMM yyyy').format(notice.publishedAt!),
                    if (notice.category.isNotEmpty) notice.category,
                    if (notice.hasAttachments) 'Attachment',
                  ].join(' · '),
                  style: sora(11, color: p.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
