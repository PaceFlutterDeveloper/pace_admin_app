import 'dart:convert';

import 'package:admin_app/core/error/error_exception.dart';
import 'package:admin_app/core/services/api_service.dart';
import 'package:admin_app/core/utils/constants/api_constant.dart';
import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';

class AuthRepository {
  final ApiService apiService;

  AuthRepository({required this.apiService});
  // login function
  // passing user name and password and school code (school code using for the api end point)
  // return the response getting from the backend
  Future<Either<MyError, dynamic>> login({
    required String userName,
    required String password,
    required String fcmToken,
    Map<String, String> device = const {},
  }) async {
    // Create FormData object and add form fields.
    // [device] carries device_name, platform, and the public IP place
    // when the phone could resolve them.
    FormData formData = FormData.fromMap({
      'username': userName,
      'password': password,
      'action': "login",
      if (fcmToken.isNotEmpty) 'fcm_token': fcmToken,
      ...device,
    });

    var response = await apiService.postAPI(
      url: await ApiConstants.getLoginUrl(),
      body: formData,
      authorization: "",
    );

    if (response.isLeft) {
      return Left(response.left);
    } else {
      return Right(jsonDecode(response.right));
    }
  }
}
