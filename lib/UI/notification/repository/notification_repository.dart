// lib/UI/notification/repository/notification_repository.dart

import 'dart:developer';

import 'package:admin_app/UI/auth/data_source/auth_data.dart';
import 'package:admin_app/UI/notification/models/notification_repsonse_model.dart';
import 'package:admin_app/core/error/error_exception.dart';
import 'package:admin_app/core/services/api_service.dart';
import 'package:admin_app/core/utils/constants/api_constant.dart';
import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/foundation.dart';

class NotificationRepository {
  final ApiService apiService;

  NotificationRepository({required this.apiService});

  /// 1) FETCH PAGINATED NOTIFICATIONS
  Future<Either<MyError, NotificationResponseModel>> fetchNotifications({
    int limit2 = 20,
    int pageNo = 0,
  }) async {
    final auth = await AuthData.getActiveUser();
    if (auth == null) {
      return Left(
          MyError(key: AppError.unauthorized, message: 'Not authenticated'));
    }

    final formData = FormData.fromMap({
      'admin_id': auth.userId,
      'token': auth.token,
      'limit2': limit2,
      'pageNo': pageNo,
    });

    if (kDebugMode) {
      log('🔔 fetchNotifications payload:');
      formData.fields.forEach((f) => log('${f.key}: ${f.value}'));
    }

    final res = await apiService.postAPI(
      url: await ApiConstants.adminNotifications(),
      body: formData,
    );

    if (res.isLeft) {
      log('🔔 fetchNotifications error: ${res.left}');
      return Left(res.left);
    }

    return Right(NotificationResponseModel.fromJson(res.right));
  }

  /// 2) MARK A SINGLE NOTIFICATION AS READ
  Future<Either<MyError, NotificationResponseModel>> markNotificationAsRead(
      int notificationId) async {
    final auth = await AuthData.getActiveUser();
    if (auth == null) {
      return Left(
          MyError(key: AppError.unauthorized, message: 'Not authenticated'));
    }

    final formData = FormData.fromMap({
      'notificationId': notificationId,
      'admin_id': auth.userId,
      'token': auth.token,
    });

    if (kDebugMode) {
      log('🔔 markNotificationAsRead payload:');
      formData.fields.forEach((f) => log('${f.key}: ${f.value}'));
    }

    final res = await apiService.postAPI(
      url: await ApiConstants.adminNotifications(),
      body: formData,
    );

    if (res.isLeft) {
      log('🔔 markNotificationAsRead error: ${res.left}');
      return Left(res.left);
    }

    return Right(NotificationResponseModel.fromJson(res.right));
  }

  /// 3) MARK ALL NOTIFICATIONS AS READ
  Future<Either<MyError, NotificationResponseModel>>
      markAllNotificationsAsRead() {
    // per API: notificationId = 0 marks all as read
    return markNotificationAsRead(0);
  }
}
