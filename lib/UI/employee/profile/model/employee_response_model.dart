// lib/UI/employee/profile/model/profile_response_model.dart

import 'dart:convert';

import 'package:admin_app/UI/employee/profile/model/profile_data_model.dart';

class ProfileResponseModel {
  final bool status;
  final String message;
  final ProfileDataModel data;

  ProfileResponseModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ProfileResponseModel.fromJson(String str) =>
      ProfileResponseModel.fromMap(json.decode(str) as Map<String, dynamic>);

  factory ProfileResponseModel.fromMap(Map<String, dynamic> map) =>
      ProfileResponseModel(
        status: map['status'] as bool,
        message: map['message'] as String,
        data: ProfileDataModel.fromMap(map['data'] as Map<String, dynamic>),
      );

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() => {
        'status': status,
        'message': message,
        'data': data.toMap(),
      };
}
