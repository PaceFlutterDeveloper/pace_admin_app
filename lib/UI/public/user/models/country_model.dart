class CountryModel {
  final int id;
  final String name;

  const CountryModel({required this.id, required this.name});

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
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
