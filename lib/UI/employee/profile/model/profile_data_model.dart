import 'dart:convert';

import 'package:admin_app/UI/employee/profile/model/doc_model.dart';
import 'package:admin_app/UI/employee/profile/model/emp_profile_model.dart';
import 'package:admin_app/UI/employee/profile/model/user_profile_model.dart';

class ProfileDataModel {
  final UserProfileModel user;
  final EmpProfileModel? emp;
  final int documentStatus;
  final String photo;
  final List<DocModel> doc;

  ProfileDataModel({
    required this.user,
    required this.emp,
    required this.photo,
    required this.doc,
    required this.documentStatus,
  });

  factory ProfileDataModel.fromJson(String str) =>
      ProfileDataModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ProfileDataModel.fromMap(Map<String, dynamic> json) =>
      ProfileDataModel(
        user: UserProfileModel.fromMap(json["user"]),
        emp: json["emp"] == null ? null : EmpProfileModel.fromMap(json["emp"]),
        documentStatus: int.tryParse(json['alert']?.toString() ?? '') ?? 0,
        photo: json["photo"] ?? "",
        doc: json["doc"] == null
            ? []
            : List<DocModel>.from(json["doc"].map((x) => DocModel.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "user": user.toMap(),
        "emp": emp!.toMap(),
        "photo": photo,
        "doc": List<dynamic>.from(doc.map((x) => x.toMap())),
      };
}
