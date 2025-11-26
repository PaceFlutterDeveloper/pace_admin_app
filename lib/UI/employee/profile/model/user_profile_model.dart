import 'dart:convert';

class UserProfileModel {
  final String id;
  final String adUsername;
  final String name;
  final String designation;
  final String gender;
  final String adGroup;
  final String stat;
  final dynamic photo;
  final String title;
  final String alias;
  final String academicStat;
  final String phone;
  final String email;

  UserProfileModel({
    required this.id,
    required this.adUsername,
    required this.name,
    required this.designation,
    required this.gender,
    required this.adGroup,
    required this.stat,
    required this.photo,
    required this.title,
    required this.alias,
    required this.academicStat,
    required this.phone,
    required this.email,
  });

  factory UserProfileModel.fromJson(String str) =>
      UserProfileModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory UserProfileModel.fromMap(Map<String, dynamic> json) =>
      UserProfileModel(
        id: json["id"],
        adUsername: json["ad_username"],
        name: json["name"],
        designation: json["designation"],
        gender: json["gender"],
        adGroup: json["ad_group"],
        stat: json["stat"],
        photo: json["photo"],
        title: json["title"],
        alias: json["alias"],
        academicStat: json["academic_stat"],
        phone: json["phone"],
        email: json["email"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "ad_username": adUsername,
        "name": name,
        "designation": designation,
        "gender": gender,
        "ad_group": adGroup,
        "stat": stat,
        "photo": photo,
        "title": title,
        "alias": alias,
        "academic_stat": academicStat,
        "phone": phone,
        "email": email,
      };
}
