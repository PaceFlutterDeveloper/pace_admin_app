class SchoolModel {
  final int id;
  final String name;
  final String code;
  final String baseUrl;
  final String color;
  final int jobCount;

  SchoolModel({
    required this.id,
    required this.name,
    required this.code,
    required this.baseUrl,
    required this.color,
    required this.jobCount,
  });

  factory SchoolModel.fromMap(Map<String, dynamic> json) => SchoolModel(
        id: json["id"] ?? 0,
        name: json["name"] ?? "",
        code: json["code"] ?? "",
        baseUrl: json["base_url"] ?? "",
        color: json["color"] ?? "#000000",
        jobCount: json["job_count"] ?? 0,
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "code": code,
        "base_url": baseUrl,
        "color": color,
        "job_count": jobCount,
      };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SchoolModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class SchoolResponseModel {
  final List<SchoolModel> data;
  final int count;

  SchoolResponseModel({
    required this.data,
    required this.count,
  });

  factory SchoolResponseModel.fromMap(Map<String, dynamic> json) =>
      SchoolResponseModel(
        data: json["data"] == null
            ? []
            : List<SchoolModel>.from(
                json["data"].map((x) => SchoolModel.fromMap(x))),
        count: json["count"] ?? 0,
      );
}
