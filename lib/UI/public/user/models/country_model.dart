class CountryModel {
  final int id;
  final String name;
  final String code;
  final int jobCount;

  const CountryModel({
    required this.id,
    required this.name,
    this.code = '',
    this.jobCount = 0,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      id:
          int.tryParse((json['id'] ?? json['country_id'] ?? '0').toString()) ??
          0,
      name:
          (json['name'] ??
                  json['country_name'] ??
                  json['nicename'] ??
                  json['country'] ??
                  '')
              .toString(),
      code: (json['code'] ?? '').toString(),
      jobCount: json['job_count'] is int
          ? json['job_count'] as int
          : int.tryParse(json['job_count']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (code.isNotEmpty) 'code': code,
      'job_count': jobCount,
    };
  }
}
