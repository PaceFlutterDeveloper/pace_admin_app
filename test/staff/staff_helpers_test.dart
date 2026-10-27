import 'package:admin_app/staff/notification/components/notification_style.dart';
import 'package:admin_app/staff/notification/models/notification_model.dart';
import 'package:admin_app/staff/profile/components/document_section.dart';
import 'package:admin_app/staff/profile/model/doc_model.dart';
import 'package:flutter_test/flutter_test.dart';

NotificationModel _n(
  int id,
  String date, {
  String appPage = '',
  String head = '',
}) => NotificationModel(
  id: id,
  notification: 'n$id',
  pageId: null,
  link: '',
  readStat: 0,
  dateTimeAdded: '',
  dateAdded: date,
  logTime: '',
  days: 0,
  timeAgo: '',
  appPage: appPage,
  head: head,
);

DocModel _doc(String expiry, {String alert = '30'}) => DocModel(
  id: '1',
  doc: 'Passport',
  issueStat: '1',
  expiryStat: '1',
  alertDays: alert,
  stat: '1',
  alias: '',
  docNo: '',
  fileName: null,
  expiryDate: expiry,
  issueDate: '',
);

void main() {
  group('groupNotifications', () {
    final now = DateTime(2026, 10, 26, 9);

    test('labels Today, Yesterday and older dates, keeping order', () {
      final groups = groupNotifications([
        _n(1, '26-10-2026'),
        _n(2, '26-10-2026'),
        _n(3, '25-10-2026'),
        _n(4, '01-10-2026'),
      ], now: now);

      expect(groups.map((g) => g.label), [
        'Today',
        'Yesterday',
        '1 October 2026',
      ]);
      expect(groups.first.items.map((n) => n.id), [1, 2]);
    });

    test('unparseable or empty dates do not throw', () {
      final groups = groupNotifications([_n(1, ''), _n(2, 'soon')], now: now);
      expect(groups.map((g) => g.label), ['Earlier', 'soon']);
    });
  });

  group('NotificationModel.fromMap', () {
    test('accepts page_id and other numbers sent as strings', () {
      final model = NotificationModel.fromMap({
        'id': '90331',
        'notification': 'Leave approved',
        'page_id': '12',
        'link': '',
        'read_stat': '0',
        'date_time_added': '2026-10-27 10:00:00',
        'date_added': '27-10-2026',
        'log_time': '10:00',
        'days': '1',
        'time_ago': '1 hour ago',
        'app_page': '/ticketDetailPage/4',
        'head': 'Leave',
      });

      expect(model.id, 90331);
      expect(model.pageId, 12);
      expect(model.readStat, 0);
      expect(model.days, 1);
      expect(model.head, 'Leave');
    });

    test('treats a blank page_id as no page', () {
      final model = NotificationModel.fromMap({
        'id': 1,
        'notification': 'Hello',
        'page_id': '',
        'link': null,
        'read_stat': 1,
        'date_time_added': '',
        'date_added': '',
        'log_time': '',
        'days': 0,
        'time_ago': '',
      });

      expect(model.pageId, isNull);
      expect(model.link, isEmpty);
      expect(model.appPage, isEmpty);
    });
  });

  group('notificationCategory', () {
    test('uses appPage and head', () {
      expect(
        notificationCategory(_n(1, '', appPage: 'ticketDetail')),
        NotificationCategory.tickets,
      );
      expect(
        notificationCategory(_n(1, '', head: 'Attendance marked')),
        NotificationCategory.attendance,
      );
      expect(
        notificationCategory(_n(1, '', head: 'Welcome')),
        NotificationCategory.other,
      );
    });
  });

  group('documentHealth', () {
    final now = DateTime(2026, 10, 26);

    test('no expiry', () {
      expect(documentHealth(_doc(''), now: now), DocumentHealth.noExpiry);
      expect(
        documentHealth(_doc('garbage'), now: now),
        DocumentHealth.noExpiry,
      );
    });

    test('expired, expiring and ok', () {
      expect(
        documentHealth(_doc('2026-10-01'), now: now),
        DocumentHealth.expired,
      );
      expect(
        documentHealth(_doc('2026-11-10'), now: now),
        DocumentHealth.expiring,
      );
      expect(documentHealth(_doc('2027-06-01'), now: now), DocumentHealth.ok);
    });
  });
}
