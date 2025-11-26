import 'dart:convert';

class NotificationModel {
  final int id;
  final String notification;
  final int? pageId;
  final String link;
  final int readStat;
  final String dateTimeAdded;
  final String dateAdded;
  final String logTime;
  final int days;
  final String timeAgo;
  final String appPage;
  final String head;
  NotificationModel({
    required this.id,
    required this.notification,
    required this.pageId,
    required this.link,
    required this.readStat,
    required this.dateTimeAdded,
    required this.dateAdded,
    required this.logTime,
    required this.days,
    required this.timeAgo,
    required this.appPage,
    required this.head,
  });

  factory NotificationModel.fromJson(String str) =>
      NotificationModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory NotificationModel.fromMap(Map<String, dynamic> json) =>
      NotificationModel(
          id: json["id"],
          notification: json["notification"],
          pageId: json["page_id"],
          link: json["link"],
          readStat: json["read_stat"],
          dateTimeAdded: json["date_time_added"],
          dateAdded: json["date_added"],
          logTime: json["log_time"],
          days: json["days"],
          timeAgo: json["time_ago"],
          appPage: json['app_page'] ?? "",
          head: json['head'] ?? "");

  Map<String, dynamic> toMap() => {
        "id": id,
        "notification": notification,
        "page_id": pageId,
        "link": link,
        "read_stat": readStat,
        "date_time_added": dateTimeAdded,
        "date_added": dateAdded,
        "log_time": logTime,
        "days": days,
        "time_ago": timeAgo,
      };
  NotificationModel copyWith({
    int? id,
    String? notification,
    int? pageId,
    String? link,
    int? readStat,
    String? dateTimeAdded,
    String? dateAdded,
    String? logTime,
    int? days,
    String? timeAgo,
    String? appPage,
    String? head,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      head: head ?? this.head,
      appPage: appPage ?? this.appPage,
      notification: notification ?? this.notification,
      pageId: pageId ?? this.pageId,
      link: link ?? this.link,
      readStat: readStat ?? this.readStat,
      dateTimeAdded: dateTimeAdded ?? this.dateTimeAdded,
      dateAdded: dateAdded ?? this.dateAdded,
      logTime: logTime ?? this.logTime,
      days: days ?? this.days,
      timeAgo: timeAgo ?? this.timeAgo,
    );
  }
}
