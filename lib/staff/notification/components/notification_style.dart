import 'package:admin_app/staff/notification/models/notification_model.dart';
import 'package:admin_app/staff/theme/staff_palette.dart';
import 'package:admin_app/staff/widgets/staff_icons.dart';
import 'package:flutter/material.dart' show DateUtils;
import 'package:intl/intl.dart';

enum NotificationCategory { tickets, attendance, other }

/// Category used for the filter chips and the tile icon.
NotificationCategory notificationCategory(NotificationModel n) {
  final haystack = '${n.appPage} ${n.head}'.toLowerCase();
  if (haystack.contains('ticket')) return NotificationCategory.tickets;
  if (haystack.contains('attendance')) return NotificationCategory.attendance;
  return NotificationCategory.other;
}

({String glyph, StaffAccent accent}) notificationLook(NotificationModel n) {
  return switch (notificationCategory(n)) {
    NotificationCategory.tickets => (
      glyph: StaffGlyphs.ticket,
      accent: StaffAccent.pink,
    ),
    NotificationCategory.attendance => (
      glyph: StaffGlyphs.cal,
      accent: StaffAccent.green,
    ),
    NotificationCategory.other => (
      glyph: StaffGlyphs.bell,
      accent: StaffAccent.amber,
    ),
  };
}

/// Notifications grouped under "Today", "Yesterday" or a date, newest first
/// in the order the API returned them.
List<({String label, List<NotificationModel> items})> groupNotifications(
  List<NotificationModel> list, {
  DateTime? now,
}) {
  final today = DateUtils.dateOnly(now ?? DateTime.now());
  final groups = <String, List<NotificationModel>>{};

  String labelFor(String raw) {
    DateTime? date;
    try {
      date = DateFormat('dd-MM-yyyy').parseStrict(raw);
    } catch (_) {
      return raw.isEmpty ? 'Earlier' : raw;
    }
    final diff = today.difference(DateUtils.dateOnly(date)).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return DateFormat('d MMMM yyyy').format(date);
  }

  for (final n in list) {
    groups.putIfAbsent(labelFor(n.dateAdded), () => []).add(n);
  }
  return [for (final e in groups.entries) (label: e.key, items: e.value)];
}
