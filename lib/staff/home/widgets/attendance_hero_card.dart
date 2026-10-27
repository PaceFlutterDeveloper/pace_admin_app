import 'package:admin_app/staff/home/widgets/home_dashboard_models.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/theme/staff_theme.dart';
import 'package:admin_app/staff/widgets/staff_widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Hero card (ink in dark, white in light): today's attendance clock, status and month stats. Tapping
/// the stats opens the attendance history.
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
    final shown = todayAttendance.markedAt ?? clock;
    final raw = todayAttendance.timeDisplayRaw?.trim();
    final useRaw =
        todayAttendance.markedAt == null && raw != null && raw.isNotEmpty;

    return HeroSurface(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "TODAY'S ATTENDANCE",
                      style: sora(
                        11,
                        weight: FontWeight.w700,
                        color: p.heroSubtle,
                        letterSpacing: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (useRaw)
                      Text(
                        raw,
                        style: sora(
                          30,
                          weight: FontWeight.w800,
                          color: p.heroTitle,
                          letterSpacing: -1,
                        ),
                      )
                    else
                      Text.rich(
                        TextSpan(
                          text: DateFormat('hh:mm').format(shown),
                          children: [
                            TextSpan(
                              text: ' ${DateFormat('a').format(shown)}',
                              style: sora(
                                15,
                                weight: FontWeight.w700,
                                color: p.heroTitle,
                              ),
                            ),
                          ],
                        ),
                        style: sora(
                          34,
                          weight: FontWeight.w800,
                          color: p.heroTitle,
                          letterSpacing: -1.2,
                        ),
                      ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('EEEE, d MMMM yyyy').format(clock),
                      style: sora(
                        12.5,
                        weight: FontWeight.w400,
                        color: p.heroSubtle,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusPill(
                label: todayAttendance.pillLabel,
                dot: todayAttendance.pillDotColor,
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onStats,
            child: Row(
              children: [
                Expanded(
                  child: HeroStat(
                    value: '${monthlyStats.percentage.round()}%',
                    label: 'This month',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: HeroStat(
                    value: '${monthlyStats.absences}',
                    label: 'Absences',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: HeroStat(
                    value: '${monthlyStats.presentDays}',
                    label: 'Days present',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
