import 'package:admin_app/staff/events/domain/staff_event.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/theme/staff_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String eventDayHeading(DateTime day) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final date = DateTime(day.year, day.month, day.day);
  if (date == today) return 'TODAY';
  if (date == today.add(const Duration(days: 1))) return 'TOMORROW';
  return DateFormat('EEE, d MMM').format(date).toUpperCase();
}

String eventDateLabel(DateTime value) {
  return DateFormat('EEE, d MMM yyyy').format(value.toLocal());
}

String eventClock(DateTime value) =>
    DateFormat('h:mm a').format(value.toLocal());

Color? eventColor(String hex) {
  var raw = hex.trim().replaceFirst('#', '');
  if (raw.length == 3) raw = raw.split('').map((part) => '$part$part').join();
  if (raw.length != 6) return null;
  final value = int.tryParse(raw, radix: 16);
  return value == null ? null : Color(0xFF000000 | value);
}

/// One event in a day card: time, colour bar, title and place.
class StaffEventRow extends StatelessWidget {
  const StaffEventRow({super.key, required this.event, this.onTap});

  final StaffEvent event;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final place = event.location?.trim() ?? '';
    final category = event.category.trim();
    final detail = [
      if (place.isNotEmpty) place,
      if (category.isNotEmpty) category,
    ].join(' · ');
    final bar = eventColor(event.color) ?? p.amber;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 72,
              child: event.allDay
                  ? Text(
                      'All day',
                      style: sora(
                        12,
                        weight: FontWeight.w700,
                        color: p.amberText,
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          eventClock(event.startsAt),
                          style: sora(
                            12,
                            weight: FontWeight.w700,
                            color: p.amberText,
                          ),
                        ),
                        if (event.endsAt != null)
                          Text(
                            eventClock(event.endsAt!),
                            style: sora(
                              11,
                              weight: FontWeight.w500,
                              color: p.muted,
                            ),
                          ),
                      ],
                    ),
            ),
            Container(
              width: 3,
              height: 34,
              decoration: BoxDecoration(
                color: bar,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: sora(13.5, weight: FontWeight.w600, color: p.text),
                  ),
                  if (detail.isNotEmpty)
                    Text(
                      detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: sora(
                        11.5,
                        weight: FontWeight.w400,
                        color: p.muted,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
