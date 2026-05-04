import 'package:admin_app/UI/notification/components/notification_list.dart';
import 'package:admin_app/UI/notification/cubit/notification_cubit.dart';
import 'package:admin_app/config/themes/app_design_tokens.dart';
import 'package:admin_app/core/widgets/app_app_bar.dart';
import 'package:admin_app/core/widgets/app_empty_state.dart';
import 'package:admin_app/core/widgets/app_error_state.dart';
import 'package:admin_app/core/widgets/app_refresh_indicator.dart';
import 'package:admin_app/core/widgets/app_shimmer.dart';
import 'package:admin_app/core/widgets/app_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.surfaceContainerLight,
      appBar: AppAppBar(
        title: 'Notifications',
        actions: [
          TextButton.icon(
            onPressed: () => _cubit.markAllAsRead(),
            icon: Icon(
              CupertinoIcons.checkmark_circle,
              color: theme.colorScheme.primary,
              size: 18,
            ),
            label: Text(
              'Read All',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocListener<NotificationCubit, NotificationState>(
          listener: (context, state) {
            state.whenOrNull(
              success: (_) => _hasLoadedNotifications = true,
            );

            state.whenOrNull(
              failure: (err) {
                if (_hasLoadedNotifications) {
                  AppToast.error(context, err);
                }
              },
            );
          },
          child: BlocBuilder<NotificationCubit, NotificationState>(
            builder: (context, state) {
              return state.when(
                initial: () => _buildLoadingState(),
                loading: () => _buildLoadingState(),
                failure: (err) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: AppErrorState.generic(
                      message: err,
                      onRetry: () => _cubit.fetchNotifications(loadMore: false),
                    ),
                  ),
                ),
                success: (list) => _buildList(list),
                readLoader: (list) => _buildList(list),
                readed: (list) => _buildList(list),
                unreaded: (list) => _buildList(list),
                readAllLoader: (list) => _buildList(list),
                readAll: (list) => _buildList(list),
                unreadAll: (list) => _buildList(list),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: ShimmerList(
        itemCount: 8,
        showAvatar: true,
        showSubtitle: true,
      ),
    );
  }

  Widget _buildList(List notifications) {
    if (notifications.isEmpty) {
      return Center(
        child: AppEmptyState.noNotifications(),
      );
    }

    return AppRefreshIndicator(
      onRefresh: () async {
        await _cubit.fetchNotifications(loadMore: false);
      },
      child: NotificationList(
        notificationsList: notifications.cast(),
        controller: _scrollController,
        isLoadingMore: _cubit.isFetching,
        hasMore: _cubit.hasMore,
      ),
    );
  }
}
