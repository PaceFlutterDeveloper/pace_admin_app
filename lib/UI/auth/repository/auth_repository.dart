import 'dart:convert';
import 'dart:developer';

import 'package:admin_app/core/error/error_exception.dart';
import 'package:admin_app/core/services/api_service.dart';
import 'package:admin_app/core/utils/constants/api_constant.dart';
import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/foundation.dart';

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
  }) async {
    // Create FormData object and add form fields
    FormData formData = FormData.fromMap({
      'username': userName,
      'password': password,
      'action': "login",
      'fcm_token': fcmToken,
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
      url: await ApiConstants.getLoginUrl(),
      body: formData,
      authorization: "",
    );

    if (response.isLeft) {
      log("Login error \n${response.left}");
      return Left(response.left);
    } else {
      log("Login response \n${jsonDecode(response.right)}");
      return Right(jsonDecode(response.right));
    }
  }
}
