import 'package:admin_app/dependancy_injection.dart';
import 'package:admin_app/staff/events/domain/staff_event.dart';
import 'package:admin_app/staff/home/utils/menu_route_helper.dart';
import 'package:admin_app/staff/events/presentation/event_detail_page.dart';
import 'package:admin_app/staff/events/presentation/event_row.dart';
import 'package:admin_app/staff/events/presentation/events_agenda_cubit.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/theme/staff_theme.dart';
import 'package:admin_app/staff/widgets/staff_icons.dart';
import 'package:admin_app/staff/widgets/staff_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Events tab: the next 30 days, grouped by day.
class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  late final EventsAgendaCubit _cubit = locator<EventsAgendaCubit>();

  @override
  void initState() {
    super.initState();
    _cubit.load(quiet: _cubit.isFresh);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    return BlocProvider.value(
      value: _cubit,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 20, 4),
              child: Row(
                children: [
                  ?staffOriginBack(context),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Events',
                          style: sora(
                            28,
                            weight: FontWeight.w700,
                            color: p.text,
                            letterSpacing: -0.8,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'The next $kEventsAgendaDays days',
                          style: sora(
                            12.5,
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
            Expanded(
              child: BlocBuilder<EventsAgendaCubit, EventsAgendaState>(
                builder: (context, state) {
                  return RefreshIndicator(
                    color: p.amberText,
                    backgroundColor: p.surface,
                    onRefresh: () => _cubit.load(),
                    child: switch (state) {
                      EventsAgendaLoading() => const _AgendaSkeleton(),
                      EventsAgendaFailed(:final message) => ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: 420,
                            child: StaffStateMessage(
                              glyph: StaffGlyphs.events,
                              title: 'Could not load events',
                              message: message,
                              actionLabel: 'Try again',
                              onAction: _cubit.load,
                              accent: StaffAccent.pink,
                            ),
                          ),
                        ],
                      ),
                      EventsAgendaLoaded(:final events) when events.isEmpty =>
                        ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            const SizedBox(
                              height: 420,
                              child: StaffStateMessage(
                                glyph: StaffGlyphs.events,
                                title: 'Nothing scheduled',
                                message:
                                    'Events for the next 30 days will show up here.',
                                accent: StaffAccent.violet,
                              ),
                            ),
                          ],
                        ),
                      EventsAgendaLoaded(:final events) => _AgendaList(
                        events: events,
                      ),
                    },
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

class _AgendaList extends StatelessWidget {
  const _AgendaList({required this.events});

  final List<StaffEvent> events;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final now = DateTime.now();
    final from = DateTime(now.year, now.month, now.day);
    final to = from.add(const Duration(days: kEventsAgendaDays));
    final grouped = <DateTime, List<EventOnDay>>{};
    for (final row in expandEventDays(events, from: from, to: to)) {
      grouped.putIfAbsent(row.day, () => []).add(row);
    }
    final days = grouped.keys.toList()..sort();
    for (final day in days) {
      grouped[day]!.sort((a, b) => compareStaffEvents(a.event, b.event));
    }

    return ListView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        for (final day in days) ...[
          SectionLabel(eventDayHeading(day)),
          StaffCard(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            radius: 24,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Column(
              children: [
                for (var i = 0; i < grouped[day]!.length; i++) ...[
                  StaffEventRow(
                    event: grouped[day]![i].event,
                    span: grouped[day]![i].span,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              EventDetailPage(event: grouped[day]![i].event),
                        ),
                      );
                    },
                  ),
                  if (i != grouped[day]!.length - 1)
                    Divider(height: 1, color: p.border),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _AgendaSkeleton extends StatelessWidget {
  const _AgendaSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      children: const [
        StaffSkeleton(width: 72, height: 10),
        SizedBox(height: 12),
        StaffCard(
          radius: 24,
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              StaffSkeleton(width: double.infinity, height: 36),
              SizedBox(height: 12),
              StaffSkeleton(width: double.infinity, height: 36),
            ],
          ),
        ),
      ],
    );
  }
}
