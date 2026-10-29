import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';

/// Handles a staff API call that the server rejected because the token is
/// no longer valid (`401` with `TOKEN_INVALID` or `TOKEN_EXPIRED`).
///
/// Register [onExpired] in DI to sign the active staff user out. Careers
/// calls never match: they use another host path and their own handler.
class StaffSessionExpiredHandler {
  static Future<void> Function()? onExpired;

  /// True while a profile switch is moving the active account. Rejections
  /// in that window belong to the call that was already in flight.
  static bool Function()? switching;

  /// Token of the profile that is active right now, if there is one.
  static String? Function()? activeToken;

  static bool _isHandling = false;

  static const _expiredCodes = {'TOKEN_INVALID', 'TOKEN_EXPIRED'};

  static bool isExpiredSessionError(DioException error) {
    if (error.response?.statusCode != 401) return false;
    final url = error.requestOptions.uri.toString();
    if (!url.contains('/erp-api/') || url.contains('/careers/')) return false;
    return _expiredCodes.contains(codeOf(error.response?.data));
  }

  /// Reads the machine-readable `code` from an error body, or ''.
  static String codeOf(dynamic body) {
    try {
      if (body is Map) return (body['code'] ?? '').toString();
      if (body is String) {
        final trimmed = body.trim();
        final start = trimmed.indexOf('{');
        if (start < 0) return '';
        final decoded = jsonDecode(trimmed.substring(start));
        if (decoded is Map) return (decoded['code'] ?? '').toString();
      }
    } catch (_) {}
    return '';
  }

  /// Token this call sent, from the request extra, form body, or header.
  static String? tokenOn(DioException error) {
    final extra = error.requestOptions.extra['staffToken'];
    if (extra is String && extra.isNotEmpty) return extra;
    final data = error.requestOptions.data;
    if (data is FormData) {
      for (final field in data.fields) {
        if (field.key == 'token' && field.value.isNotEmpty) return field.value;
      }
    }
    final header = error.requestOptions.headers['token'];
    if (header is String && header.isNotEmpty) return header;
    return null;
  }

  static Future<void> handleExpired(DioException error) async {
    if (_isHandling || onExpired == null) return;
    if (!expiredTokenShouldSignOut(
      switching: switching?.call() ?? false,
      requestToken: tokenOn(error),
      activeToken: activeToken?.call(),
    )) {
      return;
    }
    _isHandling = true;
    try {
      log('StaffSessionExpiredHandler: token rejected, signing out');
      await onExpired!();
    } catch (e) {
      log('StaffSessionExpiredHandler: sign out failed: $e');
    } finally {
      // Keeps parallel failing calls from signing out twice.
      Future<void>.delayed(const Duration(seconds: 2), () {
        _isHandling = false;
      });
    }
  }
}

/// A rejected token signs the phone out only when it belongs to the profile
/// that is active now. Calls still running for the previous profile, and any
/// rejection while a switch is in progress, must not delete that profile.
bool expiredTokenShouldSignOut({
  required bool switching,
  required String? requestToken,
  required String? activeToken,
}) {
  if (switching) return false;
  if (requestToken == null || requestToken.isEmpty) return true;
  if (activeToken == null || activeToken.isEmpty) return true;
  return requestToken == activeToken;
}
