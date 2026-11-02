import 'package:admin_app/core/routes/app_routes.dart';
import 'package:admin_app/staff/home/models/menu_model.dart';
import 'package:admin_app/staff/internal_web/internal_web_url.dart';
import 'package:admin_app/staff/notification/services/notification_router.dart';
import 'package:flutter_test/flutter_test.dart';

MenuModel _web(
  String value, {
  String name = '',
  String url = 'https://example.com/page',
  List<MenuModel> subMenu = const [],
}) => MenuModel(
  id: value,
  menuKey: 'internalWeb',
  menuVal: value,
  menuName: name,
  page: null,
  iconUrl: '',
  parentId: '',
  subMenu: subMenu,
  webUrl: url,
);

void main() {
  test('redactInternalWebUrl masks the token', () {
    final uri = Uri.parse(
      redactInternalWebUrl(
        'https://example.com/fee?token=secret&theme=dark&admin_id=42',
      ),
    );
    expect(uri.queryParameters['token'], '[redacted]');
    expect(uri.queryParameters['theme'], 'dark');
    expect(uri.queryParameters['admin_id'], '42');
  });

  test('session query parameters overwrite the same names', () {
    final uri = Uri.parse(
      staffInternalWebUrl(
        'https://example.com/fee?token=old&x=1&school_code=OLD&theme=light',
        token: 'new token',
        adminId: '42',
        schoolCode: 'SCH',
        theme: 'dark',
      ),
    );

    expect(uri.queryParameters['token'], 'new token');
    expect(uri.queryParameters['admin_id'], '42');
    expect(uri.queryParameters['school_code'], 'SCH');
    expect(uri.queryParameters['theme'], 'dark');
    expect(uri.queryParameters['x'], '1');
    expect(uri.queryParameters.length, 5);
  });

  test('url match ignores session params and case of scheme and host', () {
    expect(
      webUrlsMatch(
        'https://Example.com/fee?token=a&admin_id=1&theme=dark',
        'HTTPS://example.com/fee?school_code=SCH&theme=light',
      ),
      isTrue,
    );
    expect(
      webUrlsMatch('https://example.com/fee/pay', 'https://example.com/fee'),
      isTrue,
    );
    expect(
      webUrlsMatch('https://example.com/fee', 'https://other.example/fee'),
      isFalse,
    );
  });

  test('url search finds a nested internal web item', () {
    final match = findInternalWebByUrl(
      [
        _web(
          'Group',
          url: 'https://example.com/other',
          subMenu: [_web('Consent', url: 'https://example.com/consent')],
        ),
      ],
      'https://example.com/consent?token=abc',
    );
    expect(match?.menuVal, 'Consent');
  });

  test('label scores follow the school app scale', () {
    expect(internalWebLabelScore(_web('Consent'), ['consent']), 100);
    expect(
      internalWebLabelScore(_web('portal consent'), ['portal_consent']),
      80,
    );
    expect(internalWebLabelScore(_web('Activity fee'), ['fee payment']), 60);
    expect(
      internalWebLabelScore(_web('consentform extra'), ['consentformpage']),
      50,
    );
    expect(internalWebLabelScore(_web('Fee'), ['feedback']), 0);
  });

  test('menu name can match when menu value does not', () {
    final match = findInternalWebByLabel(
      [_web('Temporary', name: 'Consent', url: 'https://example.com/c')],
      ['consent'],
    );
    expect(match?.menuName, 'Consent');
  });

  test('a push with no menu match still carries the payload url', () {
    final item = internalWebLaunchMenu(
      url: 'https://example.com/new',
      title: 'New page',
    );
    expect(item.id, '0');
    expect(item.isInternalWeb, isTrue);
    expect(item.webUrl, 'https://example.com/new');
    expect(internalWebLabel(item), 'New page');
  });

  test('native notification pages stay in the app', () {
    expect(NotificationRouter.isKnownStaffPage('/tickets'), isTrue);
    expect(
      NotificationRouter.isKnownStaffPage('/ticketDetailPage/4'),
      isTrue,
    );
    expect(NotificationRouter.isKnownStaffPage(Routes.internalWeb.path), isFalse);
    expect(NotificationRouter.isKnownStaffPage('portal_consent'), isFalse);
    expect(NotificationRouter.isKnownStaffPage(''), isFalse);
  });
}
