import 'package:admin_app/UI/home/widgets/hero_stat.dart';
import 'package:admin_app/config/themes/app_design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

/// Indigo hero summary card — matches [AttendanceHeroCard] on the home dashboard.
class ManageTicketsSummaryCard extends StatelessWidget {
  final int toDoCount;
  final int inProgressCount;
  final int doneCount;

  const ManageTicketsSummaryCard({
    super.key,
    required this.toDoCount,
    required this.inProgressCount,
    required this.doneCount,
  });

  static const _heroGradient = LinearGradient(
    colors: [
      Color(0xFF1A237E),
      Color(0xFF283593),
      Color(0xFF3949AB),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: _heroGradient,
        borderRadius: BorderRadius.circular(AppRadius.hero),
      ),
      child: Stack(
        children: [
          const Positioned(
            right: -25,
            top: -25,
            child: _DecorCircle(diameter: 110),
          ),
          const Positioned(
            right: 25,
            bottom: -35,
            child: _DecorCircle(diameter: 90, opacity: 0.04),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TICKET SUMMARY',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.6),
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Gap(AppSpacing.xs),
              Text(
                'Your ticket workload',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const Gap(AppSpacing.sm + 6),
              Row(
                children: [
                  HeroStat(
                    value: '$toDoCount',
                    label: 'To Do',
                  ),
                  const Gap(AppSpacing.sm),
                  HeroStat(
                    value: '$inProgressCount',
                    label: 'In Progress',
                  ),
                  const Gap(AppSpacing.sm),
                  HeroStat(
                    value: '$doneCount',
                    label: 'Done',
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
