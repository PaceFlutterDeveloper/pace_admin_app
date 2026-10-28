import 'package:admin_app/core/routes/app_routes.dart';
import 'package:admin_app/staff/events/domain/staff_event.dart';
import 'package:admin_app/staff/events/presentation/event_row.dart';
import 'package:admin_app/staff/events/presentation/today_events_cubit.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/theme/staff_theme.dart';
import 'package:admin_app/staff/widgets/staff_icons.dart';
import 'package:admin_app/staff/widgets/staff_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// How many events Home lists before "+N more".
const int kHomeEventLimit = 3;

/// Home section: today's events, or a calm empty state.
class TodayEventsSection extends StatelessWidget {
  const TodayEventsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: "Today's events",
          action: 'See all',
          onAction: () => context.push(Routes.events.path),
        ),
        BlocBuilder<TodayEventsCubit, TodayEventsState>(
          builder: (context, state) => switch (state) {
            TodayEventsLoading() => const _EventsSkeleton(),
            TodayEventsFailed(:final message) => _EventsMessage(
              title: "Couldn't load events",
              body: message,
            ),
            TodayEventsLoaded(:final events) when events.isEmpty =>
              const _EventsMessage(
                title: 'No events today',
                body: 'Nothing is scheduled for today.',
              ),
            TodayEventsLoaded(:final events) => _EventsList(events: events),
          },
        ),
      ],
    );
  }
}

class _EventsList extends StatelessWidget {
  const _EventsList({required this.events});

  final List<StaffEvent> events;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final shown = events.take(kHomeEventLimit).toList();
    final more = events.length - shown.length;
    return StaffCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      radius: 24,
      onTap: () => context.push(Routes.events.path),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        children: [
          for (var i = 0; i < shown.length; i++) ...[
            StaffEventRow(
              event: shown[i],
              span: eventSpanOn(shown[i], DateTime.now()),
            ),
            if (i != shown.length - 1) Divider(height: 1, color: p.border),
          ],
          if (more > 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                '+$more more',
                style: sora(12, weight: FontWeight.w700, color: p.amberText),
              ),
            ),
        ],
      ),
    );
  }
}

class _EventsMessage extends StatelessWidget {
  const _EventsMessage({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    return StaffCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      radius: 24,
      onTap: () => context.push(Routes.events.path),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const GlassIconTile(
            glyph: StaffGlyphs.events,
            accent: StaffAccent.violet,
            size: 42,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: sora(13.5, weight: FontWeight.w700, color: p.text),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: sora(12, weight: FontWeight.w400, color: p.muted),
                ),
              ],
            ),
          ),
          StaffIcon(
            StaffGlyphs.chevronRight,
            size: 18,
            color: p.muted,
            strokeWidth: 2,
          ),
        ],
      ),
    );
  }
}

class _EventsSkeleton extends StatelessWidget {
  const _EventsSkeleton();

  @override
  Widget build(BuildContext context) {
    return const StaffCard(
      margin: EdgeInsets.symmetric(horizontal: 16),
      radius: 24,
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          StaffSkeleton(width: 42, height: 42, radius: 14),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StaffSkeleton(width: 140, height: 13),
                SizedBox(height: 8),
                StaffSkeleton(width: 200, height: 11),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
