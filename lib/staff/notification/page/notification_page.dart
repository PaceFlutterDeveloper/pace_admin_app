import 'package:admin_app/core/routes/app_routes.dart';
import 'package:admin_app/core/widgets/app_toast.dart';
import 'package:admin_app/staff/notification/components/notification_card.dart';
import 'package:admin_app/staff/notification/components/notification_list.dart';
import 'package:admin_app/staff/notification/cubit/notification_cubit.dart';
import 'package:admin_app/staff/notification/models/notification_model.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/theme/staff_theme.dart';
import 'package:admin_app/staff/widgets/staff_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

/// Full notification centre (the bell panel's "Open notification centre").
class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late final ScrollController _scrollController;
  late final NotificationCubit _cubit;
  bool _hasLoadedNotifications = false;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<NotificationCubit>();
    _scrollController = ScrollController()..addListener(_onScroll);
    _cubit.fetchNotifications(loadMore: false);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        _cubit.hasMore &&
        !_cubit.isFetching) {
      _cubit.fetchNotifications(loadMore: true);
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _open(NotificationModel n) {
    openNotification(GoRouter.of(context), _cubit, n);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.staff;

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Row(
              children: [
                StaffIconButton(
                  glyph: StaffGlyphs.chevronLeft,
                  semanticLabel: 'Back',
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(Routes.home.path);
                    }
                  },
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Notifications',
                    style: sora(
                      22,
                      weight: FontWeight.w700,
                      color: p.text,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _cubit.markAllAsRead,
                  child: const Text('Mark all read'),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocConsumer<NotificationCubit, NotificationState>(
              listener: (context, state) {
                state.whenOrNull(
                  success: (_) => _hasLoadedNotifications = true,
                  failure: (err) {
                    if (_hasLoadedNotifications) AppToast.error(context, err);
                  },
                );
              },
              builder: (context, state) {
                return state.when(
                  initial: () => const _Loading(),
                  loading: () => const _Loading(),
                  failure: (err) => StaffStateMessage(
                    glyph: StaffGlyphs.bell,
                    title: 'Could not load notifications',
                    message: err,
                    actionLabel: 'Try again',
                    onAction: () => _cubit.fetchNotifications(loadMore: false),
                  ),
                  success: _list,
                  readLoader: _list,
                  readed: _list,
                  unreaded: _list,
                  readAllLoader: _list,
                  readAll: _list,
                  unreadAll: _list,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _list(List<NotificationModel> notifications) {
    if (notifications.isEmpty) {
      return const StaffStateMessage(
        glyph: StaffGlyphs.bell,
        title: 'No notifications yet',
        message: 'New alerts for you will appear here.',
      );
    }
    final p = context.staff;
    return RefreshIndicator(
      color: p.amberText,
      backgroundColor: p.surface,
      onRefresh: () => _cubit.fetchNotifications(loadMore: false),
      child: NotificationList(
        notificationsList: notifications,
        controller: _scrollController,
        isLoadingMore: _cubit.isFetching,
        hasMore: _cubit.hasMore,
        onOpen: _open,
        horizontalPadding: 20,
        padding: const EdgeInsets.only(bottom: 16),
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    final p = context.staff;
    return Shimmer.fromColors(
      baseColor: p.surfaceRaised,
      highlightColor: p.surface,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        children: [
          for (var i = 0; i < 7; i++)
            const Padding(
              padding: EdgeInsets.only(bottom: 18),
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
                        StaffSkeleton(width: 180, height: 10),
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
