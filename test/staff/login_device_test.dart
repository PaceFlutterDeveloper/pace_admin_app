import 'package:admin_app/staff/session/device_snapshot.dart';
import 'package:admin_app/staff/sessions/domain/login_session.dart';
import 'package:device_marketing_names/device_marketing_names.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('iPhone 12 Pro is sent under its marketing name', () {
    final raw = DeviceMarketingNames().getSingleNameFromModel(
      DeviceType.ios,
      'iPhone13,3',
    );
    expect(presentableDeviceName(raw, fallback: 'iPhone'), 'iPhone 12 Pro');
  });

  test('a raw Apple code is not sent as the device name', () {
    expect(presentableDeviceName('iPhone13,3', fallback: 'Android'), 'iPhone');
    expect(presentableDeviceName('iPad14,1', fallback: 'iPhone'), 'iPad');
    expect(presentableDeviceName('arm64', fallback: 'iPhone'), 'iPhone');
    expect(
      presentableDeviceName('Galaxy S21', fallback: 'Android'),
      'Galaxy S21',
    );
  });

  test('login fields leave out a place the phone could not find', () {
    const snapshot = DeviceSnapshot(
      deviceId: 'abc',
      platform: 'ios',
      deviceName: 'iPhone 12 Pro',
      appVersion: '1.0.4',
    );
    expect(snapshot.fields, {
      'device_id': 'abc',
      'platform': 'ios',
      'device_name': 'iPhone 12 Pro',
      'app_version': '1.0.4',
    });
  });

  test('an IP lookup becomes a city and country', () {
    expect(
      placeLabel(
        city: 'Dubai',
        region: 'Dubai',
        country: 'United Arab Emirates',
      ),
      'Dubai, United Arab Emirates',
    );
    expect(placeLabel(city: 'Singapore', country: 'Singapore'), 'Singapore');
    expect(
      placeFromIpLookup({
        'success': true,
        'ip': '1.2.3.4',
        'city': 'Dubai',
        'region': 'Dubai',
        'country': 'United Arab Emirates',
      }),
      {'ip': '1.2.3.4', 'location': 'Dubai, United Arab Emirates'},
    );
    expect(placeFromIpLookup({'success': false, 'message': 'no'}), isEmpty);
  });

  test('this phone is separated from older sessions', () {
    final here = LoginSession.fromMap({
      'id': 7,
      'device_id': 'phone-a',
      'device_name': 'iPhone 12 Pro',
      'platform': 'ios',
      'location': 'Dubai, United Arab Emirates',
      'ip': '1.2.3.4',
      'last_seen': '2026-10-29 11:40:00',
      'is_current': 1,
    });
    final other = LoginSession.fromMap({
      'session_id': '9',
      'device_id': 'phone-b',
      'device': 'Galaxy S21',
      'platform': 'Android',
      'place': 'Abu Dhabi, United Arab Emirates',
      'last_active': '2026-10-20T08:00:00',
      'current': false,
    });
    final activity = groupLoginSessions([other, here], deviceId: 'phone-a');

    expect(here.lastSeen, isNotNull);
    expect(activity.here.map((s) => s.id), ['7']);
    expect(activity.others.map((s) => s.deviceName), ['Galaxy S21']);
    expect(sessionTitle(here), 'iPhone 12 Pro');
    expect(
      sessionDetail(here, now: DateTime(2026, 10, 29, 11, 41), here: true),
      'Dubai, United Arab Emirates · Active now',
    );
    expect(
      sessionWhen(
        DateTime(2026, 10, 28, 11, 0),
        now: DateTime(2026, 10, 29, 12, 0),
        here: false,
      ),
      'Yesterday',
    );
    expect(
      sessionWhen(
        DateTime(2024, 3, 2),
        now: DateTime(2026, 10, 29),
        here: false,
      ),
      '2 Mar 2024',
    );
  });

  test('a current flag stands in when the server omits the device id', () {
    final session = LoginSession.fromMap({
      'id': '1',
      'device_name': 'iPhone 12 Pro',
      'is_current': true,
    });
    final activity = groupLoginSessions([session], deviceId: 'phone-a');
    expect(activity.here, hasLength(1));
    expect(activity.others, isEmpty);
  });
}
