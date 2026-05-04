import 'package:admin_app/config/themes/app_design_tokens.dart';
import 'package:admin_app/UI/home/widgets/hero_stat.dart';
import 'package:admin_app/UI/home/widgets/home_dashboard_models.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AttendanceHeroCard extends StatelessWidget {
  const AttendanceHeroCard({
    super.key,
    required this.todayAttendance,
    required this.monthlyStats,
  });

  final TodayAttendanceSummary todayAttendance;
  final MonthlyAttendanceSummary monthlyStats;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeText = todayAttendance.markedAt != null
        ? DateFormat('hh:mm a').format(todayAttendance.markedAt!)
        : (todayAttendance.timeDisplayRaw != null &&
                todayAttendance.timeDisplayRaw!.trim().isNotEmpty)
            ? todayAttendance.timeDisplayRaw!.trim()
            : DateFormat('hh:mm a').format(now);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1A237E),
            Color(0xFF283593),
            Color(0xFF3949AB),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.hero),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -25,
            top: -25,
            child: _DecorCircle(diameter: 110),
          ),
          Positioned(
            right: 25,
            bottom: -35,
            child: _DecorCircle(
              diameter: 90,
              opacity: 0.04,
            ),
          ),
          Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "TODAY'S ATTENDANCE",
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: Colors.white.withValues(alpha: 0.6),
                            letterSpacing: 0.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Gap(AppSpacing.xs),
                        Text(
                          timeText,
                          style: GoogleFonts.inter(
                            fontSize: 26,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -1,
                          ),
                        ),
                        Text(
                          DateFormat('EEEE, d MMMM yyyy').format(now),
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _AttendanceStatusPill(
                    label: todayAttendance.pillLabel,
                    dotColor: todayAttendance.pillDotColor,
                  ),
                ],
              ),
              const Gap(AppSpacing.sm + 6),
              Row(
                children: [
                  HeroStat(
                    value: '${monthlyStats.percentage.round()}%',
                    label: 'This month',
                  ),
                  const Gap(AppSpacing.sm),
                  HeroStat(
                    value: '${monthlyStats.absences}',
                    label: 'Absences',
                  ),
                  const Gap(AppSpacing.sm),
                  HeroStat(
                    value: '${monthlyStats.presentDays}',
                    label: 'Days present',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DecorCircle extends StatelessWidget {
  const _DecorCircle({
    required this.diameter,
    this.opacity = 0.07,
  });

  final double diameter;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: opacity),
        ),
      ),
    );
  }
}

class _AttendanceStatusPill extends StatelessWidget {
  const _AttendanceStatusPill({
    required this.label,
    required this.dotColor,
  });

  final String label;
  final Color dotColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: AppSpacing.sm - 2,
            height: AppSpacing.sm - 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dotColor,
            ),
          ),
          const Gap(AppSpacing.sm - 2),
          Text(
            label,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
