import 'package:hive/hive.dart';

part 'careers_user_model.g.dart';

@HiveType(typeId: 10) // Use a unique typeId
class CareersUserModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String? phone;

  @HiveField(4)
  final String? profileImage;

  @HiveField(5)
  final String? resumeUrl;

  @HiveField(6)
  final List<String> skills;

  @HiveField(7)
  final String? preferredLocation;

  @HiveField(8)
  final String? experienceLevel;

  @HiveField(9)
  final List<int> preferredSchoolIds;

  @HiveField(10)
  final DateTime? lastLoginAt;

  @HiveField(11)
  final bool isProfileComplete;

  @HiveField(12)
  final Map<String, dynamic> preferences;

  @HiveField(13)
  final String? sessionToken;

  @HiveField(14)
  final String? nationality;

  @HiveField(15)
  final String? location;

  @HiveField(16)
  final bool isEmailVerified;

  @HiveField(17)
  final String? verificationToken;

  CareersUserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profileImage,
    this.resumeUrl,
    this.skills = const [],
    this.preferredLocation,
    this.experienceLevel,
    this.preferredSchoolIds = const [],
    this.lastLoginAt,
    this.isProfileComplete = false,
    this.preferences = const {},
    this.sessionToken,
    this.nationality,
    this.location,
    this.isEmailVerified = false,
    this.verificationToken,
  });

  factory CareersUserModel.fromJson(Map<String, dynamic> json) {
    return CareersUserModel(
      id: json['cand_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      profileImage: json['profile_image'],
      resumeUrl: json['resume_url'],
      skills: List<String>.from(json['skills'] ?? []),
      preferredLocation: json['preferred_location'] ?? json['location'],
      experienceLevel: json['experience_level'],
      preferredSchoolIds: List<int>.from(json['preferred_school_ids'] ?? []),
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'])
          : json['login_time'] != null
          ? DateTime.parse(json['login_time'])
          : null,
      isProfileComplete: json['is_profile_complete'] ?? false,
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
      sessionToken: json['session_token'],
      nationality: json['nationality'],
      location: json['location'],
      isEmailVerified: json['is_email_verified'] ?? false,
      verificationToken: json['verification_token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cand_id': id,
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profile_image': profileImage,
      'resume_url': resumeUrl,
      'skills': skills,
      'preferred_location': preferredLocation,
      'location': location,
      'experience_level': experienceLevel,
      'preferred_school_ids': preferredSchoolIds,
      'last_login_at': lastLoginAt?.toIso8601String(),
      'login_time': lastLoginAt?.toIso8601String(),
      'is_profile_complete': isProfileComplete,
      'preferences': preferences,
      'session_token': sessionToken,
      'nationality': nationality,
      'is_email_verified': isEmailVerified,
      'verification_token': verificationToken,
    };
  }

  CareersUserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    String? resumeUrl,
    List<String>? skills,
    String? preferredLocation,
    String? experienceLevel,
    List<int>? preferredSchoolIds,
    DateTime? lastLoginAt,
    bool? isProfileComplete,
    Map<String, dynamic>? preferences,
    String? sessionToken,
    String? nationality,
    String? location,
    bool? isEmailVerified,
    String? verificationToken,
  }) {
    return CareersUserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      resumeUrl: resumeUrl ?? this.resumeUrl,
      skills: skills ?? this.skills,
      preferredLocation: preferredLocation ?? this.preferredLocation,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      preferredSchoolIds: preferredSchoolIds ?? this.preferredSchoolIds,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      preferences: preferences ?? this.preferences,
      sessionToken: sessionToken ?? this.sessionToken,
      nationality: nationality ?? this.nationality,
      location: location ?? this.location,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      verificationToken: verificationToken ?? this.verificationToken,
    );
  }
}
