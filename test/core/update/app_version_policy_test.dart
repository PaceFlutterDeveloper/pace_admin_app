import 'package:admin_app/core/update/app_version_policy.dart';
import 'package:admin_app/core/update/store_listing.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const minimum = '1.1.13';
  const minimumBuild = 40;

  AppVersionDecision decide({
    required String installed,
    required int build,
    Object? version,
    String key = 'app_version',
    AppUpdatePlatform platform = AppUpdatePlatform.android,
  }) {
    return decideAppUpdate(
      payload: {if (version != null) key: version},
      platform: platform,
      installedVersion: installed,
      installedBuild: build,
    );
  }

  Map<String, dynamic> nested({
    String? version = minimum,
    int? build = minimumBuild,
  }) {
    return {
      'android': {'minimumVersion': version, 'minimumBuild': build},
      'forceUpdate': false,
    };
  }

  test('blocks a lower version at any build', () {
    final decision = decide(installed: '1.1.12', build: 999, version: nested());
    expect(decision.applicable, isTrue);
    expect(decision.updateRequired, isTrue);
  });

  test('blocks an equal version with a lower build', () {
    final decision = decide(installed: '1.1.13', build: 39, version: nested());
    expect(decision.updateRequired, isTrue);
  });

  test('allows an equal version at the minimum build or higher', () {
    expect(
      decide(installed: '1.1.13', build: 40, version: nested()).updateRequired,
      isFalse,
    );
    expect(
      decide(installed: '1.1.13', build: 41, version: nested()).updateRequired,
      isFalse,
    );
  });

  test('allows a higher version', () {
    expect(
      decide(installed: '1.2.0', build: 0, version: nested()).updateRequired,
      isFalse,
    );
  });

  test('treats a shorter version as equal and then compares builds', () {
    expect(
      decide(
        installed: '1.1',
        build: 0,
        version: {
          'android': {'minimum_version': '1.1.0', 'minimum_build': 0},
        },
      ).updateRequired,
      isFalse,
    );
    expect(
      decide(
        installed: '1.1',
        build: 3,
        version: {
          'android': {'minimum_version': '1.1.0', 'minimum_build': 4},
        },
      ).updateRequired,
      isTrue,
    );
  });

  test('reads the live flat jobs payload', () {
    final decision = decide(
      installed: '1.0.2',
      build: 1,
      platform: AppUpdatePlatform.ios,
      version: {
        'ios_minimum_version': '1.1.12',
        'ios_minimum_build': 106,
        'android_minimum_version': '1.1.12',
        'android_minimum_build': 126,
      },
    );
    expect(decision.updateRequired, isTrue);

    final current = decide(
      installed: '1.1.12',
      build: 126,
      version: {
        'ios_minimum_version': '1.1.12',
        'ios_minimum_build': 106,
        'android_minimum_version': '1.1.12',
        'android_minimum_build': '126',
      },
    );
    expect(current.updateRequired, isFalse);
  });

  test('accepts the appVersion alias and ignores forceUpdate', () {
    final blocked = decide(
      key: 'appVersion',
      installed: '1.0.0',
      build: 1,
      version: {
        'android': {'minimumVersion': '1.1.12', 'minimumBuild': 1},
        'force_update': false,
      },
    );
    expect(blocked.updateRequired, isTrue);

    final allowed = decide(
      key: 'appVersion',
      installed: '2.0.0',
      build: 1,
      version: {
        'android': {'minimumVersion': '1.1.12', 'minimumBuild': 1},
        'forceUpdate': true,
      },
    );
    expect(allowed.updateRequired, isFalse);
  });

  test('does not block when the version object or minimum is unusable', () {
    expect(decide(installed: '1.0.0', build: 1).applicable, isFalse);
    expect(
      decide(installed: '1.0.0', build: 1, version: 'nope').applicable,
      isFalse,
    );
    expect(
      decide(
        installed: '1.0.0',
        build: 1,
        version: {'android': '1.1.12'},
      ).updateRequired,
      isFalse,
    );
    expect(
      decide(
        installed: '1.0.0',
        build: 1,
        version: {
          'android': {'minimumVersion': '', 'minimumBuild': 9},
        },
      ).updateRequired,
      isFalse,
    );
    expect(
      decide(
        installed: '1.0.0',
        build: 1,
        version: {
          'android': {'minimumVersion': '1.1.12'},
        },
      ).updateRequired,
      isTrue,
    );
  });

  test('non-numeric segments count as zero', () {
    expect(compareVersionNames('1.1.beta', '1.1.0'), 0);
    expect(compareVersionNames('1.2', '1.1.9'), greaterThan(0));
  });

  test('store links fall back when the listing id is missing', () {
    expect(
      storeListingUrl(
        platform: TargetPlatform.android,
        packageName: 'com.paceEducation.erp',
      ),
      'https://play.google.com/store/apps/details?id=com.paceEducation.erp',
    );
    expect(
      storeListingUrl(platform: TargetPlatform.android, packageName: ' '),
      'https://play.google.com',
    );
    expect(
      storeListingUrl(platform: TargetPlatform.iOS, packageName: 'ignored'),
      'https://apps.apple.com',
    );
    expect(
      storeListingUrl(
        platform: TargetPlatform.iOS,
        packageName: 'ignored',
        iosAppStoreId: '123',
      ),
      'https://apps.apple.com/app/id123',
    );
  });
}
