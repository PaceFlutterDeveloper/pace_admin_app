import 'package:admin_app/core/routes/app_routes.dart';
import 'package:admin_app/staff/notification/components/notification_card.dart';
import 'package:admin_app/staff/notification/components/notification_group.dart';
import 'package:admin_app/staff/notification/components/notification_style.dart';
import 'package:admin_app/staff/notification/cubit/notification_cubit.dart';
import 'package:admin_app/staff/notification/models/notification_model.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/theme/staff_theme.dart';
import 'package:admin_app/staff/widgets/staff_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

/// Opens the bell panel: a rounded sheet over a scrim, with filters, grouped
/// notifications and a shortcut to the full centre.
Future<void> showStaffNotificationPanel(BuildContext context) {
  final cubit = context.read<NotificationCubit>();
  final theme = Theme.of(context);
  final p = StaffPalette.of(context);

  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close notifications',
    barrierColor: p.scrim,
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (dialogContext, _, __) {
      return Theme(
        data: theme,
        child: BlocProvider.value(
          value: cubit,
          child: const _NotificationPanel(),
        ),
      );
    },
    transitionBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -0.03),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

enum _Filter {
  all('All'),
  unread('Unread'),
  tickets('Tickets'),
  attendance('Attendance');

  const _Filter(this.label);
  final String label;

  bool matches(NotificationModel n) => switch (this) {
    _Filter.all => true,
    _Filter.unread => n.readStat == 0,
    _Filter.tickets => notificationCategory(n) == NotificationCategory.tickets,
    _Filter.attendance =>
      notificationCategory(n) == NotificationCategory.attendance,
  };
}

class _NotificationPanel extends StatefulWidget {
  const _NotificationPanel();

  @override
  State<_NotificationPanel> createState() => _NotificationPanelState();
}

class _NotificationPanelState extends State<_NotificationPanel> {
  final ScrollController _scroll = ScrollController();
  late final NotificationCubit _cubit;
  List<NotificationModel>? _last;
  _Filter _filter = _Filter.all;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<NotificationCubit>();
    _scroll.addListener(_onScroll);
    _cubit.fetchNotifications(loadMore: false);
  }

  @override
  void dispose() {
    _scroll
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 160 &&
        _cubit.hasMore &&
        !_cubit.isFetching) {
      _cubit.fetchNotifications(loadMore: true);
    }
  }

  void _close() => Navigator.of(context).pop();

  void _openItem(NotificationModel n) {
    _close();
    openNotification(AppRoute.router, _cubit, n);
  }

  void _openCentre() {
    _close();
    AppRoute.router.push(Routes.getNotifications.path);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final media = MediaQuery.of(context);

    return Stack(
      children: [
        Positioned(
          left: 12,
          right: 12,
          top: media.padding.top + 64,
          bottom: media.padding.bottom + 16,
          child: Material(
            color: p.surface,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
              side: BorderSide(color: p.borderStrong),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 8, 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Notifications',
                          style: sora(
                            19,
                            weight: FontWeight.w700,
                            color: p.text,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _cubit.markAllAsRead,
                        style: TextButton.styleFrom(
                          minimumSize: const Size(44, 44),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: Text(
                          'Mark all read',
                          style: sora(
                            12.5,
                            weight: FontWeight.w700,
                            color: p.amberText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 48,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
                    itemCount: _Filter.values.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final f = _Filter.values[i];
                      return _FilterChip(
                        label: f.label,
                        selected: f == _filter,
                        onTap: () => setState(() => _filter = f),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: BlocBuilder<NotificationCubit, NotificationState>(
                    builder: (context, state) {
                      final list = state.maybeWhen(
                        success: (l) => l,
                        readLoader: (l) => l,
                        readed: (l) => l,
                        unreaded: (l) => l,
                        readAllLoader: (l) => l,
                        readAll: (l) => l,
                        unreadAll: (l) => l,
                        orElse: () => _last,
                      );
                      if (list != null) _last = list;

                      if (list == null) {
                        return state.maybeWhen(
                          failure: (err) => StaffStateMessage(
                            glyph: StaffGlyphs.bell,
                            title: 'Could not load notifications',
                            message: err,
                            actionLabel: 'Try again',
                            onAction: () =>
                                _cubit.fetchNotifications(loadMore: false),
                          ),
                          orElse: () => const _PanelSkeleton(),
                        );
                      }
                      return _PanelList(
                        all: list,
                        filter: _filter,
                        controller: _scroll,
                        loadingMore: _cubit.isFetching,
                        onOpen: _openItem,
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: p.border)),
                  ),
                  child: AmberButton(
                    label: 'Open notification centre',
                    soft: true,
                    height: 46,
                    onPressed: _openCentre,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? p.amber : p.surfaceRaised,
            borderRadius: BorderRadius.circular(19),
          ),
          child: Text(
            label,
            style: sora(
              12,
              weight: FontWeight.w600,
              color: selected ? p.onAmber : p.text,
            ),
          ),
        ),
      ),
    );
  }
}

class _PanelList extends StatelessWidget {
  const _PanelList({
    required this.all,
    required this.filter,
    required this.controller,
    required this.loadingMore,
    required this.onOpen,
  });

  final List<NotificationModel> all;
  final _Filter filter;
  final ScrollController controller;
  final bool loadingMore;
  final ValueChanged<NotificationModel> onOpen;

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    final items = all.where(filter.matches).toList();

    if (items.isEmpty) {
      return StaffStateMessage(
        glyph: StaffGlyphs.bell,
        title: filter == _Filter.all ? 'No notifications yet' : 'Nothing here',
        message: filter == _Filter.all
            ? 'New alerts for you will appear here.'
            : 'No ${filter.label.toLowerCase()} notifications right now.',
      );
    }

    final groups = groupNotifications(items);
    return ListView(
      controller: controller,
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: EdgeInsets.zero,
      children: [
        for (final g in groups)
          NotificationGroup(
            date: g.label,
            notifications: g.items,
            onOpen: onOpen,
          ),
        if (loadingMore)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: p.amberText,
                ),
              ),
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _PanelSkeleton extends StatelessWidget {
  const _PanelSkeleton();

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    return Shimmer.fromColors(
      baseColor: p.surfaceRaised,
      highlightColor: p.surface,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
        children: [
          for (var i = 0; i < 5; i++)
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  StaffSkeleton(width: 42, height: 42, radius: 15),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StaffSkeleton(height: 12),
                        SizedBox(height: 8),
                        StaffSkeleton(width: 150, height: 10),
                      ],
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
