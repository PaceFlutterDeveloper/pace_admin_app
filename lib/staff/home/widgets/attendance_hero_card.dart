import 'package:admin_app/staff/home/widgets/home_dashboard_models.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/theme/staff_theme.dart';
import 'package:admin_app/staff/widgets/staff_widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Hero card (ink in dark, white in light): today's in and out times, status
/// and this month's attendance counts. Tapping the card opens history.
class AttendanceHeroCard extends StatelessWidget {
  const AttendanceHeroCard({
    super.key,
    required this.todayAttendance,
    required this.monthlyStats,
    required this.onStats,
    this.now,
  });

  final TodayAttendanceSummary todayAttendance;
  final MonthlyAttendanceSummary monthlyStats;

  /// Opens the attendance history.
  final VoidCallback onStats;

  /// Clock source for tests; defaults to [DateTime.now].
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final clock = now ?? DateTime.now();
    final punchIn = _punchLabel(
      todayAttendance.markedAt,
      todayAttendance.timeDisplayRaw,
    );
    final punchOut = _punchLabel(
      todayAttendance.checkedOutAt,
      todayAttendance.checkOutRaw,
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onStats,
      child: HeroSurface(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    "TODAY'S ATTENDANCE",
                    style: sora(
                      11,
                      weight: FontWeight.w700,
                      color: p.heroSubtle,
                      letterSpacing: 1.3,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _StatusPill(
                  label: todayAttendance.pillLabel,
                  dot: todayAttendance.pillDotColor,
                ),
              ],
            ),
            const SizedBox(height: 10),
            _PunchLine(label: 'In', time: punchIn),
            const SizedBox(height: 2),
            _PunchLine(
              label: 'Out',
              time: punchOut,
              note: _earlyOutNote(todayAttendance.earlyMinutes),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('EEEE, d MMMM yyyy').format(clock),
              style: sora(12.5, weight: FontWeight.w400, color: p.heroSubtle),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _MonthStat(
                    value: '${monthlyStats.presentDays}',
                    label: 'Days present',
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _MonthStat(
                    value: '${monthlyStats.absences}',
                    label: 'Absences',
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _MonthStat(
                    value: '${monthlyStats.lateArrivals}',
                    label: 'Late In',
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _MonthStat(
                    value: '${monthlyStats.earlyDepartures}',
                    label: 'Early Out',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// One month count in the single row under today's punches.
class _MonthStat extends StatelessWidget {
  const _MonthStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    return Container(
      padding: const EdgeInsets.fromLTRB(2, 9, 2, 8),
      decoration: BoxDecoration(
        color: p.isDark
            ? Colors.white.withValues(alpha: 0.06)
            : p.surface.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: p.isDark ? Colors.white.withValues(alpha: 0.08) : p.border,
        ),
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: sora(18, weight: FontWeight.w800, color: p.heroTitle),
            ),
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              softWrap: false,
              textAlign: TextAlign.center,
              style: sora(
                12,
                weight: FontWeight.w700,
                color: p.heroTitle,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "25 min early" when today has an early out. Zero stays off the card.
String? _earlyOutNote(int? minutes) {
  if (minutes == null || minutes <= 0) return null;
  return minutes == 1 ? '1 min early' : '$minutes min early';
}

/// "08:02 AM", the API text when it could not be parsed, or an em dash.
String _punchLabel(DateTime? at, String? raw) {
  if (at != null) return DateFormat('hh:mm a').format(at);
  final text = raw?.trim() ?? '';
  if (text.isEmpty) return '—';
  return text;
}

class _PunchLine extends StatelessWidget {
  const _PunchLine({required this.label, required this.time, this.note});

  final String label;
  final String time;

  /// Extra fact after the clock, such as an early out.
  final String? note;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final missing = time == '—';
    return Row(
      children: [
        SizedBox(
          width: 32,
          child: Text(
            label,
            style: sora(13, weight: FontWeight.w700, color: p.heroSubtle),
          ),
        ),
        Flexible(
          child: Text(
            time,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: sora(
              26,
              weight: FontWeight.w800,
              color: missing ? p.heroSubtle : p.heroTitle,
              letterSpacing: -0.8,
            ),
          ),
        ),
        if (note != null) ...[
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              note!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: sora(12.5, weight: FontWeight.w700, color: p.amberText),
            ),
          ),
        ],
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.dot});

  final String label;
  final Color dot;

  @override
  Widget build(BuildContext context) {
    // The default "Not marked" pill uses the brand amber, as in the design.
    final color = label == 'Not marked' ? StaffPalette.dark.amber : dot;
    final p = context.staff;
    // Light surfaces need a deeper text colour than the dot.
    final textColor = p.isDark
        ? color
        : (label == 'Not marked'
              ? p.amberText
              : Color.lerp(color, Colors.black, 0.35)!);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            maxLines: 1,
            style: sora(11.5, weight: FontWeight.w700, color: textColor),
          ),
        ],
      ),
    );
  }
}
