import 'dart:convert';
import 'dart:developer';

import 'package:admin_app/UI/auth/data_source/auth_data.dart';
import 'package:admin_app/UI/auth/models/auth_model.dart';
import 'package:admin_app/UI/students/models/student_att_model.dart';
import 'package:admin_app/UI/students/models/student_response_model.dart';
import 'package:admin_app/core/error/error_exception.dart';
import 'package:admin_app/core/services/api_service.dart';
import 'package:admin_app/core/utils/constants/api_constant.dart';
import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class StudentsRepository {
  final ApiService apiService;

  StudentsRepository({required this.apiService});
  // Add your repository methods and properties here
  Future<Either<MyError, StudenstsResponseModel>> getStudents(
      {required String grade, required String section}) async {
    AuthModel? authModel = await AuthData.getActiveUser();
    final now = DateTime.now();

    final formattedDate = DateFormat('dd/MM/yyyy').format(now);
    // Create FormData with App Version
    FormData formData = FormData.fromMap({
      'admin_id': authModel!.userId,
      "gr": grade,
      "sec": section,
      "date": formattedDate,
      'token': authModel.token,
    });

    if (kDebugMode) {
      log('Form Data:');
      for (MapEntry<String, dynamic> entry in formData.fields) {
        log('${entry.key}: ${entry.value}');
      }
    }

    var response = await apiService.postAPI(
      url: await ApiConstants.getclassAttendance(),
      body: formData,
      authorization: "",
    );

    if (response.isLeft) {
      log("staateStudentsState \n${response.left}");
      return Left(response.left);
    } else {
      log("staateStudentsState \n${jsonEncode(response.right)}");
      return Right(StudenstsResponseModel.fromJson(jsonEncode(response.right)));
    }
  }

  Future<Either<MyError, StudenstsResponseModel>> markAttedance(
      {required String grade,
      required String section,
      required String status,
      required List<StudentAttModel> attList}) async {
    AuthModel? authModel = await AuthData.getActiveUser();
    final now = DateTime.now();

    final formattedDate = DateFormat('dd/MM/yyyy').format(now);
    // Create FormData with App Version
    FormData formData = FormData.fromMap({
      'admin_id': authModel!.userId,
      "gr": grade,
      "sec": section,
      'status': status,
      "date": formattedDate,
      'token': authModel.token,
      'attList': List<dynamic>.from(attList.map((x) => x)),
    });

    if (kDebugMode) {
      log('Form Data:');
      for (MapEntry<String, dynamic> entry in formData.fields) {
        log('${entry.key}: ${entry.value}');
      }
    }

    var response = await apiService.postAPI(
      url: await ApiConstants.getclassAttendance(),
      body: formData,
      authorization: "",
    );

    if (response.isLeft) {
      log("staateStudentsState \n${response.left}");
      return Left(response.left);
    } else {
      log("staateStudentsState \n${jsonEncode(response.right)}");
      return Right(StudenstsResponseModel.fromJson(jsonEncode(response.right)));
    }
  }
}
