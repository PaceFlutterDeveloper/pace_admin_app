import 'dart:io';

import 'package:admin_app/UI/public/user/models/careers_user_model.dart';
import 'package:admin_app/UI/public/user/services/careers_user_service.dart';
import 'package:admin_app/UI/public/user/services/profile_api_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';

/// Subscribes this device to FCM topics returned by get-profile.
class CareersFcmService {
  CareersFcmService._();

  static const _topicsKey = 'careers_fcm_topics';
  static const _legacyCandidateIdKey = 'careers_fcm_candidate_id';
  static const _legacyApplicationIdsKey = 'careers_fcm_application_ids';
  static final _topicName = RegExp(r'^[a-zA-Z0-9\-_.~%]+$');

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final GetIt _getIt = GetIt.instance;

  static final Logger _logger = Logger(
    level: kDebugMode ? Level.debug : Level.off,
    printer: _FcmLogPrinter(),
  );

  static Future<String?> getFcmToken() async {
    if (Platform.isIOS) {
      final apnsToken = await _messaging.getAPNSToken();
      if (apnsToken == null || apnsToken.isEmpty) {
        _log('APNS token unavailable, skipping FCM token.');
        return null;
      }
    }

    try {
      return await _messaging.getToken();
    } catch (e) {
      _log('getToken failed: $e');
      return null;
    }
  }

  /// Fetch get-profile and subscribe to the topics array.
  /// Does not block the UI; call this unawaited from login / app start.
  static Future<void> syncFromProfile({CareersUserModel? user}) async {
    try {
      final currentUser =
          user ?? _getIt<CareersUserService>().getCurrentCareersUser();
      if (currentUser == null || currentUser.id.isEmpty) return;

      final candidateId = int.tryParse(currentUser.id);
      if (candidateId == null) return;

      _log('syncing topics from get-profile for cand_id=$candidateId');
      final result = await _getIt<ProfileApiService>().getProfile(
        candidateId: candidateId,
        token: currentUser.sessionToken,
      );

      await result.fold(
        (error) async {
          _log('get-profile for topics failed: ${error.message}');
        },
        (profile) async {
          await subscribeToTopics(profile.topics);
        },
      );
    } catch (e) {
      _log('syncFromProfile failed: $e');
    }
  }

  /// Reuses cached topics after a restart. FCM subscriptions persist on the
  /// device, so a get-profile round-trip is only needed when nothing is stored.
  static Future<void> restoreSubscriptionsIfLoggedIn() async {
    try {
      final currentUser = _getIt<CareersUserService>().getCurrentCareersUser();
      if (currentUser == null || currentUser.id.isEmpty) return;

      final cached = _loadTopics();
      if (cached.isNotEmpty) {
        _log('using ${cached.length} cached FCM topics (skipped get-profile)');
        return;
      }

      await syncFromProfile(user: currentUser);
    } catch (e) {
      _log('restoreSubscriptionsIfLoggedIn failed: $e');
    }
  }

  /// Subscribe to [topics] from get-profile. Drops any previously stored
  /// topics that are no longer in the list.
  static Future<void> subscribeToTopics(List<String> topics) async {
    try {
      if (Platform.isIOS) {
        final apnsToken = await _waitForApnsToken();
        if (apnsToken == null || apnsToken.isEmpty) {
          _log('skip topic subscribe until APNS is ready.');
          return;
        }
      }

      await _unsubscribeLegacyTopics();

      final next = _sanitizeTopics(topics);
      final previous = _loadTopics().toSet();
      final nextSet = next.toSet();

      for (final topic in nextSet.difference(previous)) {
        await _subscribe(topic);
      }
      for (final topic in previous.difference(nextSet)) {
        await _unsubscribe(topic);
      }

      if (nextSet.isEmpty) {
        _log('no topics returned from get-profile.');
      } else if (nextSet.difference(previous).isEmpty &&
          previous.difference(nextSet).isEmpty) {
        _log('already subscribed to ${nextSet.join(', ')}');
      }

      await _saveTopics(nextSet.toList());
    } catch (e) {
      _log('subscribeToTopics failed: $e');
    }
  }

  /// Unsubscribe from every stored topic. Called on logout / session expiry.
  /// Uninstall cannot run app code; FCM invalidates the device token instead.
  ///
  /// Topic unsubscribes run in parallel and are bounded so logout cannot hang
  /// on a slow FCM round-trip. Cached topic keys are always cleared.
  static Future<void> unsubscribeForCurrentUser() async {
    final topics = _loadTopics();
    try {
      await Future.wait([
        _unsubscribeLegacyTopics(),
        ...topics.map(_unsubscribe),
      ]).timeout(const Duration(seconds: 2));
    } catch (e) {
      _log('unsubscribe failed: $e');
    } finally {
      await _box().delete(_topicsKey);
    }
  }

  static Future<String?> _waitForApnsToken() async {
    for (var i = 0; i < 10; i++) {
      final apnsToken = await _messaging.getAPNSToken();
      if (apnsToken != null && apnsToken.isNotEmpty) return apnsToken;
      await Future.delayed(const Duration(milliseconds: 500));
    }
    return null;
  }

  static List<String> _sanitizeTopics(Iterable<String> topics) {
    final unique = <String>{};
    for (final raw in topics) {
      final topic = raw.trim();
      if (topic.isEmpty) continue;
      if (!_topicName.hasMatch(topic)) {
        _log('ignoring invalid topic "$topic"');
        continue;
      }
      unique.add(topic);
    }
    return unique.toList();
  }

  static Future<void> _subscribe(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      _log('subscribed to $topic');
    } catch (e) {
      _log('subscribe $topic failed: $e');
    }
  }

  static Future<void> _unsubscribe(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      _log('unsubscribed from $topic');
    } catch (e) {
      _log('unsubscribe $topic failed: $e');
    }
  }

  static Future<void> _unsubscribeLegacyTopics() async {
    final box = _box();
    final hadLegacy =
        box.containsKey(_legacyCandidateIdKey) ||
        box.containsKey(_legacyApplicationIdsKey);
    if (!hadLegacy) return;

    await _unsubscribe('careers_all');
    await _unsubscribe('careers_jobs');

    final candidateId = box.get(_legacyCandidateIdKey)?.toString();
    if (candidateId != null && candidateId.isNotEmpty) {
      final sanitized = candidateId.replaceAll(
        RegExp(r'[^a-zA-Z0-9\-_.~%]'),
        '_',
      );
      await _unsubscribe('careers_candidate_$sanitized');
    }

    final raw = box.get(_legacyApplicationIdsKey);
    if (raw is List) {
      for (final value in raw) {
        final id = int.tryParse(value.toString()) ?? 0;
        if (id > 0) {
          await _unsubscribe('careers_application_$id');
        }
      }
    }

    await box.delete(_legacyCandidateIdKey);
    await box.delete(_legacyApplicationIdsKey);
  }

  static Box _box() => Hive.box('settingsBox');

  static List<String> _loadTopics() {
    final raw = _box().get(_topicsKey);
    if (raw is! List) return [];
    return raw
        .map((value) => value.toString().trim())
        .where((topic) => topic.isNotEmpty)
        .toList();
  }

  static Future<void> _saveTopics(List<String> topics) async {
    await _box().put(_topicsKey, topics);
  }

  static void logMessage(String message) => _log(message);

  static void _log(String message) => _logger.i(message);
}

class _FcmLogPrinter extends LogPrinter {
  static const _green = '\x1B[32m';
  static const _reset = '\x1B[0m';

  @override
  List<String> log(LogEvent event) {
    return ['$_green[FCM] ${event.message}$_reset'];
  }
}
