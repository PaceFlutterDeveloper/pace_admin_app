class StatusOption {
  final int statusId;
  final String statusName;
  final String color;

  StatusOption({
    required this.statusId,
    required this.statusName,
    required this.color,
  });

  factory StatusOption.fromJson(Map<String, dynamic> json) => StatusOption(
        statusId: json['status_id'] as int,
        statusName: json['status_name'] as String,
        color: json['color'] as String,
      );

  Map<String, dynamic> toJson() => {
        'status_id': statusId,
        'status_name': statusName,
        'color': color,
      };
}
