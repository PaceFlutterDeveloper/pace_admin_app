import 'dart:convert';

import 'package:admin_app/staff/shared/read_json.dart';

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
  final String action;
  final String actionName;
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
    this.action = '',
    this.actionName = '',
  });

  factory NotificationModel.fromJson(String str) =>
      NotificationModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory NotificationModel.fromMap(Map<String, dynamic> json) =>
      NotificationModel(
        id: readInt(json["id"]),
        notification: readString(json["notification"]),
        pageId: _pageId(json["page_id"]),
        link: readString(json["link"]),
        readStat: readInt(json["read_stat"]),
        dateTimeAdded: readString(json["date_time_added"]),
        dateAdded: readString(json["date_added"]),
        logTime: readString(json["log_time"]),
        days: readInt(json["days"]),
        timeAgo: readString(json["time_ago"]),
        appPage: readString(json['app_page']),
        head: readString(json['head']),
        action: readString(json['action']),
        actionName: readString(json['action_name']),
      );

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
    String? action,
    String? actionName,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      head: head ?? this.head,
      appPage: appPage ?? this.appPage,
      action: action ?? this.action,
      actionName: actionName ?? this.actionName,
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

/// `page_id` is null or "" when a notification has no screen, and the API
/// sometimes sends the id as a string.
int? _pageId(dynamic value) {
  if (value == null) return null;
  final text = readString(value);
  if (text.isEmpty) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(text);
}
