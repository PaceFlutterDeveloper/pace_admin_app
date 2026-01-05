// lib/UI/notification/pages/notification_page.dart

import 'package:admin_app/UI/components/failure_widget.dart';
import 'package:admin_app/UI/notification/components/notification_list.dart';
import 'package:admin_app/UI/notification/cubit/notification_cubit.dart';
import 'package:admin_app/core/themes/const_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

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
    return Scaffold(
      backgroundColor: ConstColors.backgroundColor,
      appBar: AppBar(
        elevation: 1,
        title: const Text("Notifications"),
        actions: [
          TextButton.icon(
            onPressed: () => _cubit.markAllAsRead(),
            icon: const Icon(Icons.mark_email_read, color: Colors.black),
            label:
                const Text('Read All', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocListener<NotificationCubit, NotificationState>(
          listener: (context, state) {
            // Track when we successfully load notifications
            state.whenOrNull(
              success: (_) => _hasLoadedNotifications = true,
            );

            // Show snackbar for errors only if we already have loaded notifications
            // (meaning it's an error during mark as read or load more, not initial load)
            state.whenOrNull(
              failure: (err) {
                if (_hasLoadedNotifications) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(err),
                      backgroundColor: Colors.red,
                      action: SnackBarAction(
                        label: 'Retry',
                        textColor: Colors.white,
                        onPressed: () {
                          // Retry loading more if available
                          if (_cubit.hasMore) {
                            _cubit.fetchNotifications(loadMore: true);
                          } else {
                            // Otherwise retry initial load
                            _cubit.fetchNotifications(loadMore: false);
                          }
                        },
                      ),
                      duration: const Duration(seconds: 4),
                    ),
                  );
                }
              },
            );
          },
          child: BlocBuilder<NotificationCubit, NotificationState>(
            builder: (context, state) {
              return state.when(
                initial: () => const Center(child: CircularProgressIndicator()),
                loading: () => const Center(child: CircularProgressIndicator()),
                failure: (err) => Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FailureWidget(
                    message: err,
                    onRetry: () => _cubit.fetchNotifications(loadMore: false),
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

  Widget _buildList(List notifications) {
    return NotificationList(
      notificationsList: notifications.cast(),
      controller: _scrollController,
      isLoadingMore: _cubit.isFetching,
      hasMore: _cubit.hasMore,
    );
  }
}
