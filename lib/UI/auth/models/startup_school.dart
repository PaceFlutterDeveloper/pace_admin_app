// lib/UI/auth/models/startup_school.dart
class StartupSchool {
  final String schoolCode;
  final String rgb;
  final String baseUrl;

  StartupSchool({
    required this.schoolCode,
    required this.rgb,
    required this.baseUrl,
  });

  factory StartupSchool.fromJson(Map<String, dynamic> json) => StartupSchool(
        schoolCode: json['school_code'] as String,
        rgb: json['rgb'] as String,
        baseUrl: json['base_url'] as String,
      );
}
