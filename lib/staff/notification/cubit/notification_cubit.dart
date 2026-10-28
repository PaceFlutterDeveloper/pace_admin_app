// lib/staff/notification/cubit/notification_cubit.dart

import 'package:admin_app/staff/auth/data_source/auth_data.dart';
import 'package:admin_app/staff/auth/models/auth_model.dart';
import 'package:admin_app/staff/notification/models/notification_model.dart';
import 'package:admin_app/staff/notification/repository/notification_repository.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:admin_app/staff/utils/load_marker.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_cubit.freezed.dart';
part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository _repo = locator<NotificationRepository>();

  // internal state
  final List<NotificationModel> _all = [];
  int _page = 0;
  bool _hasMore = true;
  bool _isFetching = false;
  static const int _perPage = 10;
  final SessionScope _scope = SessionScope();

  NotificationCubit() : super(const NotificationState.initial());

  bool get hasMore => _hasMore;
  bool get isFetching => _isFetching;

  /// Drops the inbox so the next account cannot see it.
  void dropSession() {
    _scope.invalidate();
    _all.clear();
    _page = 0;
    _hasMore = true;
    _isFetching = false;
    if (!isClosed) emit(const NotificationState.initial());
  }

  /// Fetch (or load more) notifications.
  ///
  /// [quiet] replaces the list when the response arrives and leaves the
  /// current rows on screen while that request runs. A push uses this so the
  /// inbox does not flash empty.
  Future<void> fetchNotifications({
    bool loadMore = false,
    bool quiet = false,
  }) async {
    if (_isFetching) return;
    if (loadMore && !_hasMore) return;

    final stamp = _scope.begin();
    _isFetching = true;
    if (!loadMore) {
      _page = 0;
      _hasMore = true;
      if (!quiet) {
        _all.clear();
        emit(const NotificationState.loading());
      }
    }

    final res = await _repo.fetchNotifications(limit2: _perPage, pageNo: _page);
    if (isClosed || !_scope.current(stamp)) {
      _isFetching = false;
      return;
    }

    res.fold(
      (err) {
        _isFetching = false;
        // If we're loading more and have existing data, preserve it.
        // A quiet refresh keeps the list the person is already looking at.
        if ((loadMore || quiet) && _all.isNotEmpty) {
          emit(NotificationState.success(List.unmodifiable(_all)));
        } else {
          emit(NotificationState.failure(err.message));
        }
      },
      (resp) async {
        final fetched = resp.data;
        if (fetched.length < _perPage) {
          _hasMore = false;
        }
        if (loadMore) {
          _all.addAll(fetched);
          _page++;
        } else {
          _all
            ..clear()
            ..addAll(fetched);
          _page = 1;
        }
        _isFetching = false;

        emit(NotificationState.success(List.unmodifiable(_all)));
      },
    );
  }

  /// Mark a single notification read (updates local list)
  Future<void> markAsRead(int notificationId) async {
    final current = List<NotificationModel>.from(_all);
    emit(NotificationState.readLoader(current));
    final res = await _repo.markNotificationAsRead(notificationId);
    res.fold((err) => emit(NotificationState.failure(err.message)), (_) async {
      // update locally
      for (var i = 0; i < _all.length; i++) {
        if (_all[i].id == notificationId) {
          _all[i] = _all[i].copyWith(readStat: 1);
          break;
        }
      }
      AuthModel? auth = await AuthData.getActiveUser();
      if (auth != null) {
        await AuthData.updateNotificationCount(
          appCode: auth.schoolCode,
          userId: auth.userId.toString(),
          notificationCount: 1,
          mode: NotificationUpdateMode.decrease,
        );
      }
      emit(NotificationState.readed(List.unmodifiable(_all)));
    });
  }

  /// Mark all read
  Future<void> markAllAsRead() async {
    final current = List<NotificationModel>.from(_all);
    emit(NotificationState.readAllLoader(current));
    final res = await _repo.markAllNotificationsAsRead();
    res.fold((err) => emit(NotificationState.failure(err.message)), (_) async {
      for (var i = 0; i < _all.length; i++) {
        _all[i] = _all[i].copyWith(readStat: 1);
      }
      AuthModel? auth = await AuthData.getActiveUser();
      if (auth != null) {
        // ❌ Clear count
        await AuthData.updateNotificationCount(
          appCode: auth.schoolCode,
          userId: auth.userId.toString(),
          notificationCount: 0,
          mode: NotificationUpdateMode.clear,
        );
      }
      emit(NotificationState.readAll(List.unmodifiable(_all)));
    });
  }
}
