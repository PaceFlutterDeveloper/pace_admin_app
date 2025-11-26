import 'package:hive/hive.dart';

part 'auth_model.g.dart';

@HiveType(typeId: 0) // Replace with the appropriate typeId
class AuthModel {
  @HiveField(0)
  final String schoolCode;
  @HiveField(1)
  final int id;
  @HiveField(2)
  final String userName;
  @HiveField(3)
  final String password;
  @HiveField(4)
  final String token;
  @HiveField(5)
  final bool isActive;
  @HiveField(6)
  final String profilePicture;
  @HiveField(7)
  final String designation;
  @HiveField(8)
  final String name;
  @HiveField(9)
  final String userId;
  @HiveField(10)
  final int notificationCount;
  @HiveField(11)
  final String logo;
  @HiveField(12)
  final String schoolName;
  AuthModel({
    required this.schoolCode,
    required this.id,
    required this.userName,
    required this.password,
    required this.token,
    required this.isActive,
    required this.profilePicture,
    required this.designation,
    required this.name,
    required this.userId,
    required this.notificationCount,
    required this.logo,
    required this.schoolName,
  });

  // The copyWith method allows creating a modified copy of this instance
  AuthModel copyWith({
    String? schoolCode,
    int? id,
    String? userName,
    String? password,
    String? token,
    bool? isActive,
    String? profilePicture,
    String? designation,
    String? name,
    String? userId,
    int? notificationCount,
    String? logo,
    String? schoolName,
  }) {
    return AuthModel(
        schoolCode: schoolCode ?? this.schoolCode,
        id: id ?? this.id,
        userName: userName ?? this.userName,
        password: password ?? this.password,
        token: token ?? this.token,
        isActive: isActive ?? this.isActive,
        profilePicture: profilePicture ?? this.profilePicture,
        designation: designation ?? this.designation,
        name: name ?? this.name,
        userId: userId ?? this.userId,
        logo: logo ?? this.logo,
        schoolName: schoolName ?? this.schoolName,
        notificationCount: notificationCount ?? this.notificationCount);
  }

  @override
  String toString() {
    return 'AuthModel(id: $id, userName: $userName, userId: $userId, '
        'schoolCode: $schoolCode, isActive: $isActive, '
        'designation: $designation, name: $name, '
        'notificationCount: $notificationCount)'
        'logo: $logo)';
  }

  factory AuthModel.empty() => AuthModel(
      schoolCode: '',
      id: 0,
      userName: '',
      password: '',
      token: '',
      isActive: false,
      profilePicture: '',
      designation: '',
      name: '',
      userId: '',
      notificationCount: 0,
      logo: "",
      schoolName: "");
}
