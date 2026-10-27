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

  static Future<void> handleExpired() async {
    if (_isHandling || onExpired == null) return;
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
