import 'dart:developer';

import 'package:admin_app/UI/auth/data_source/auth_data.dart';
import 'package:admin_app/UI/auth/models/auth_model.dart';
import 'package:admin_app/UI/employee/attendance/models/attendance_response_model.dart';
import 'package:admin_app/core/error/error_exception.dart';
import 'package:admin_app/core/services/api_service.dart';
import 'package:admin_app/core/utils/constants/api_constant.dart';
import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/foundation.dart';

class AttendanceRepository {
  final ApiService apiService;

  AttendanceRepository({required this.apiService});
  Future<Either<MyError, AttendanceResponseModel>> getAttendance(
      int month, int year) async {
    AuthModel? authModel = await AuthData.getActiveUser();
    // Create FormData object and add form fields
    FormData formData = FormData.fromMap({
      'admin_id': authModel!.userId,
      'month': month,
      'year': year,
      'token': authModel.token,
    });
    if (kDebugMode) {
      log('Form Data:');
    }
    for (MapEntry<String, dynamic> entry in formData.fields) {
      if (kDebugMode) {
        log('${entry.key}: ${entry.value}');
      }
    }

    var response = await apiService.postAPI(
      url: await ApiConstants.getAttendance(),
      body: formData,
      authorization: "",
    );

    if (response.isLeft) {
      log("Notification error \n${response.left}");
      return Left(response.left);
    } else {
      log("Notification response \n${(response.right)}");
      return Right(AttendanceResponseModel.fromJson((response.right)));
    }
  }
}
