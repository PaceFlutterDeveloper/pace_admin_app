import 'dart:developer';

import 'package:admin_app/staff/auth/data_source/auth_data.dart';
import 'package:admin_app/staff/auth/models/auth_model.dart';
import 'package:admin_app/staff/attendance_calendar/models/attendance_response_model.dart';
import 'package:admin_app/core/error/error_exception.dart';
import 'package:admin_app/core/services/api_service.dart';
import 'package:admin_app/core/utils/constants/api_constant.dart';
import 'package:admin_app/staff/shared/read_json.dart';
import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';

class AttendanceRepository {
  final ApiService apiService;

  AttendanceRepository({required this.apiService});
  Future<Either<MyError, AttendanceResponseModel>> getAttendance(
    int month,
    int year,
  ) async {
    AuthModel? authModel = await AuthData.getActiveUser();
    if (authModel == null || authModel.userId.isEmpty) {
      return const Left(
        MyError(key: AppError.apiError, message: 'Please sign in again'),
      );
    }
    // Create FormData object and add form fields
    FormData formData = FormData.fromMap({
      'admin_id': authModel.userId,
      'month': month,
      'year': year,
      'token': authModel.token,
    });

    var response = await apiService.postAPI(
      url: await ApiConstants.getAttendance(),
      body: formData,
      authorization: "",
    );

    if (response.isLeft) {
      return Left(response.left);
    }

    final raw = response.right?.toString() ?? '';
    try {
      final model = AttendanceResponseModel.fromJson(raw);
      if (!model.status) {
        return Left(
          MyError(
            key: AppError.apiError,
            message: model.message.isNotEmpty
                ? model.message
                : 'Request failed',
          ),
        );
      }
      // Row `user_id` is the employee id. The login id can be different
      // (this account is 755, the rows say 772), so the token's payload
      // is shown as returned.
      return Right(model);
    } on FormatException {
      // HTTP 200 with an HTML error page. json.decode would otherwise
      // escape the cubit and show up as an unhandled exception.
      log('userAttendance non-JSON: ${plainText(raw)}');
      return Left(
        MyError(key: AppError.apiError, message: attendanceFailureMessage(raw)),
      );
    }
  }
}

/// Readable copy for a `userAttendance` body that is not JSON.
String attendanceFailureMessage(String raw) {
  var text = _dedupe(plainText(raw));
  if (text.isEmpty) return 'Could not load attendance';
  if (text.contains('/var/') ||
      text.contains('require_once') ||
      text.contains('Uncaught') ||
      text.length > 240) {
    return 'Could not load attendance';
  }
  return text;
}

String _dedupe(String text) {
  final trimmed = text.trim();
  final mid = trimmed.length ~/ 2;
  for (var cut = mid - 8; cut <= mid + 8; cut++) {
    if (cut <= 0 || cut >= trimmed.length) continue;
    final left = trimmed.substring(0, cut).trim();
    final right = trimmed.substring(cut).trim();
    if (left.isNotEmpty && left == right) return left;
  }
  return trimmed;
}
