import 'package:admin_app/dependancy_injection.dart';
import 'package:admin_app/staff/events/domain/events_repository.dart';
import 'package:admin_app/staff/events/domain/staff_event.dart';
import 'package:admin_app/staff/events/presentation/event_row.dart';
import 'package:admin_app/staff/shared/staff_attachment.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/theme/staff_theme.dart';
import 'package:admin_app/staff/tickets/widgets/ticket_ui.dart';
import 'package:admin_app/staff/widgets/staff_icons.dart';
import 'package:admin_app/staff/widgets/staff_widgets.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EventDetailPage extends StatefulWidget {
  const EventDetailPage({super.key, required this.event});

  final StaffEvent event;

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  late StaffEvent _event = widget.event;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final full = await locator<EventsRepository>().eventDetail(_event.id);
      if (!mounted) return;
      setState(() {
        _event = full;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final event = _event;
    final when = _when(event);

    return ColoredBox(
      color: p.background,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  StaffIconButton(
                    glyph: StaffGlyphs.chevronLeft,
                    semanticLabel: 'Back',
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Event',
                      style: sora(
                        22,
                        weight: FontWeight.w700,
                        color: p.text,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  if (_loading)
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: p.amberText,
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                children: [
                  Text(
                    event.title,
                    style: sora(
                      24,
                      weight: FontWeight.w700,
                      color: p.text,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (event.category.isNotEmpty)
                        StatusBadge(
                          name: event.category,
                          colorHex: event.color,
                        ),
                      TicketMetaChip(glyph: StaffGlyphs.clock, label: when),
                      if ((event.location ?? '').isNotEmpty)
                        TicketMetaChip(
                          glyph: StaffGlyphs.pin,
                          label: event.location!,
                        ),
                    ],
                  ),
                  if (event.description.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    Text(
                      event.description,
                      style: sora(
                        14,
                        weight: FontWeight.w400,
                        color: p.text,
                        height: 1.5,
                      ),
                    ),
                  ],
                  if (event.audience.isNotEmpty)
                    _Fact(label: 'Who', value: _audience(event.audience)),
                  if (event.createdBy.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    Text(
                      'Added by',
                      style: sora(
                        11.5,
                        weight: FontWeight.w600,
                        color: p.muted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        PersonTile(name: event.createdBy),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            event.createdBy,
                            style: sora(
                              13.5,
                              weight: FontWeight.w600,
                              color: p.text,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (event.attachments.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    Text(
                      'Attachments',
                      style: sora(
                        11.5,
                        weight: FontWeight.w600,
                        color: p.muted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (final file in event.attachments) _FileRow(file: file),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _when(StaffEvent event) {
    final start = eventStartDay(event);
    final end = eventEndDay(event);
    if (event.allDay) {
      final startLabel = eventDateLabel(event.startsAt);
      if (!end.isAfter(start)) return 'All day · $startLabel';
      return 'All day · $startLabel – ${eventDateLabel(end)}';
    }
    return _range(event);
  }

  String _range(StaffEvent event) {
    final start =
        '${eventDateLabel(event.startsAt)} · ${eventClock(event.startsAt)}';
    final end = event.endsAt;
    if (end == null) return start;
    final sameDay =
        end.year == event.startsAt.year &&
        end.month == event.startsAt.month &&
        end.day == event.startsAt.day;
    if (sameDay) return '$start – ${eventClock(end)}';
    return '$start – ${eventDateLabel(end)} · ${eventClock(end)}';
  }

  String _audience(String value) {
    return value.replaceAll('_', ' ');
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: sora(11.5, weight: FontWeight.w600, color: p.muted),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: sora(14, weight: FontWeight.w600, color: p.text),
          ),
        ],
      ),
    );
  }
}

class _FileRow extends StatelessWidget {
  const _FileRow({required this.file});

  final StaffAttachment file;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    return StaffCard(
      radius: 16,
      margin: const EdgeInsets.only(bottom: 8),
      onTap: file.url.isEmpty
          ? null
          : () {
              final uri = Uri.tryParse(file.url);
              if (uri != null) {
                launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          StaffIcon(StaffGlyphs.paperclip, size: 18, color: p.amberText),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              file.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: sora(13, weight: FontWeight.w600, color: p.text),
            ),
          ),
        ],
      ),
    );
  }
}
