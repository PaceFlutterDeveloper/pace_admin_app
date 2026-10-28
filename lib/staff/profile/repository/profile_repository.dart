import 'dart:async';

import 'package:admin_app/staff/auth/data_source/auth_data.dart';
import 'package:admin_app/staff/notification/services/staff_fcm.dart';
import 'package:admin_app/staff/auth/models/auth_model.dart';
import 'package:admin_app/staff/profile/model/employee_response_model.dart';
import 'package:admin_app/core/error/error_exception.dart';
import 'package:admin_app/core/services/api_service.dart';
import 'package:admin_app/core/utils/constants/api_constant.dart';
import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';

class ProfileRepository {
  final ApiService apiService;

  ProfileRepository({required this.apiService});

  Future<Either<MyError, ProfileResponseModel>> getEmpProfile() async {
    AuthModel? authModel = await AuthData.getActiveUser();
    // Create FormData with App Version
    FormData formData = FormData.fromMap({
      'admin_id': authModel!.userId,
      'token': authModel.token,
    });

    var response = await apiService.postAPI(
      url: await ApiConstants.getEmpProfile(),
      body: formData,
      authorization: "",
    );

    if (response.isLeft) {
      return Left(response.left);
    }
    try {
      final profile = ProfileResponseModel.fromJson(response.right);
      unawaited(StaffFcm.subscribeIfPresent(response.right));
      return Right(profile);
    } catch (_) {
      return const Left(
        MyError(key: AppError.unknown, message: 'Could not read profile'),
      );
    }
  }
}
