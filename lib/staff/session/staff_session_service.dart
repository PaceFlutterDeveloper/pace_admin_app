import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:admin_app/core/const/db_names.dart';
import 'package:admin_app/core/services/api_service.dart';
import 'package:admin_app/core/utils/constants/api_constant.dart';
import 'package:admin_app/staff/auth/data_source/auth_data.dart';
import 'package:admin_app/staff/auth/models/auth_model.dart';
import 'package:admin_app/staff/shared/read_json.dart';
import 'package:admin_app/careers/notification/careers_fcm_service.dart';
import 'package:admin_app/staff/notification/services/staff_fcm.dart';
import 'package:admin_app/staff/shared/staff_post.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Server side of a staff sign-in: push-token registration, sign out and the
/// password flows (`registerDevice`, `logout`, `changePassword`,
/// `forgotPassword`, `resetPassword`).
class StaffSessionService {
  StaffSessionService({
    required this.apiService,
    Future<String?> Function()? pushToken,
    Future<String> Function()? appVersion,
  }) : _pushToken = pushToken ?? _firebaseToken,
       _appVersion = appVersion ?? _packageVersion;

  final ApiService apiService;
  final Future<String?> Function() _pushToken;
  final Future<String> Function() _appVersion;

  /// `userId@schoolCode:token` of the last registration this run, so Home
  /// does not register again on every visit.
  String? _lastRegistered;

  /// Tells the server which phone belongs to the active user so pushes reach
  /// it. Safe to call often; repeats for the same user and token are skipped.
  Future<void> registerDevice({bool force = false}) async {
    try {
      final auth = await AuthData.getActiveUser();
      if (auth == null) return;
      final fcm = (await _pushToken())?.trim() ?? '';
      if (fcm.isEmpty) return;
      final key = '${auth.userId}@${auth.schoolCode}:$fcm';
      if (!force && key == _lastRegistered) return;
      await postStaffPage(
        api: apiService,
        url: ApiConstants.staffPage('registerDevice'),
        fields: {
          'fcm_token': fcm,
          'device_id': deviceId(),
          'platform': Platform.isIOS ? 'ios' : 'android',
          'app_version': await _appVersion(),
        },
      );
      _lastRegistered = key;
    } catch (e) {
      debugPrint('registerDevice skipped: $e');
    }
  }

  /// Revokes the active token and removes this phone's push token. Never
  /// throws: a phone that cannot reach the server still signs out locally.
  Future<void> signOutOnServer() async {
    try {
      final auth = await AuthData.getActiveUser();
      if (auth == null) return;
      await signOutAccount(auth);
    } finally {
      _lastRegistered = null;
      unawaited(StaffFcm.clearTopics());
    }
  }

  /// Revokes every saved profile. Each school has its own host, so the calls
  /// run one after another. Never throws.
  Future<void> signOutAllOnServer() async {
    try {
      final users = Hive.box<AuthModel>(LoginBox).values.toList();
      for (final user in users) {
        await signOutAccount(user);
      }
    } catch (e) {
      debugPrint('logout call skipped: $e');
    } finally {
      _lastRegistered = null;
      unawaited(StaffFcm.clearTopics());
    }
  }

  /// Revokes [auth] on that profile's school. Never throws.
  Future<void> signOutAccount(AuthModel auth) async {
    try {
      String fcm = '';
      try {
        fcm = (await _pushToken())?.trim() ?? '';
      } catch (_) {}
      await _onSchool(auth.schoolCode, () {
        return postStaffPage(
          api: apiService,
          url: ApiConstants.staffPage('logout'),
          asUser: auth,
          fields: {'fcm_token': fcm, 'device_id': deviceId()},
        ).timeout(const Duration(seconds: 4));
      });
    } catch (e) {
      debugPrint('logout call skipped: $e');
    }
  }

  /// Returns a new token when the server rotates it, else null.
  Future<String?> changePassword({
    required String current,
    required String next,
  }) async {
    final body = await postStaffPage(
      api: apiService,
      url: ApiConstants.staffPage('changePassword'),
      fields: {'current_password': current, 'new_password': next},
    );
    final data = objectPayload(body);
    final token = readString(data?['token']);
    return token.isEmpty ? null : token;
  }

  /// The server answers the same way whether or not the user exists.
  Future<String> forgotPassword({
    required String username,
    required String schoolCode,
  }) async {
    final body = await _onSchool(
      schoolCode,
      () => postStaffPage(
        api: apiService,
        url: ApiConstants.staffPage('forgotPassword'),
        authenticated: false,
        fields: {'username': username, 'school_code': schoolCode},
      ),
    );
    final message = readString(body['message']);
    return message.isEmpty
        ? 'If the account exists, reset instructions have been sent.'
        : message;
  }

  Future<void> resetPassword({
    required String username,
    required String schoolCode,
    required String code,
    required String newPassword,
  }) async {
    await _onSchool(
      schoolCode,
      () => postStaffPage(
        api: apiService,
        url: ApiConstants.staffPage('resetPassword'),
        authenticated: false,
        fields: {
          'username': username,
          'school_code': schoolCode,
          'otp': code,
          'new_password': newPassword,
        },
      ),
    );
  }

  /// Signed-out calls go to the host of the school picked on the login page.
  /// The previous school is restored so a saved session keeps its own host.
  Future<T> _onSchool<T>(String schoolCode, Future<T> Function() run) async {
    final box = await Hive.openBox('settingsBox');
    final previous = box.get('schoolCode');
    await box.put('schoolCode', schoolCode.toLowerCase());
    try {
      return await run();
    } finally {
      if (previous == null) {
        await box.delete('schoolCode');
      } else {
        await box.put('schoolCode', previous);
      }
    }
  }

  /// Stable id of this install, created on first use.
  static String deviceId() {
    final box = Hive.box('settingsBox');
    final saved = box.get('staffDeviceId') as String?;
    if (saved != null && saved.isNotEmpty) return saved;
    final random = Random.secure();
    final id = List.generate(
      16,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    box.put('staffDeviceId', id);
    return id;
  }

  static Future<String?> _firebaseToken() => CareersFcmService.getFcmToken();

  static Future<String> _packageVersion() async {
    return (await PackageInfo.fromPlatform()).version;
  }
}
