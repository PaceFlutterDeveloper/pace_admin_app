import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';

/// Handles careers API session expiry (401 + invalid/expired token).
///
/// Register [onExpired] in DI to clear the careers user and navigate home.
class CareersSessionExpiredHandler {
  static Future<void> Function()? onExpired;

  static bool _isHandling = false;

  static bool isExpiredSessionError(DioException error) {
    if (error.response?.statusCode != 401) return false;

    final message = _extractErrorMessage(error).toLowerCase();
    return message.contains('session token') ||
        message.contains('invalid or expired token') ||
        message.contains('please login again');
  }

  static String _extractErrorMessage(DioException error) {
    final responseData = error.response?.data;
    if (responseData == null) return '';

    try {
      if (responseData is Map<String, dynamic>) {
        return (responseData['message'] ?? responseData['error'] ?? '')
            .toString();
      }
      if (responseData is String) {
        final trimmed = responseData.trim();
        final start = trimmed.indexOf('{');
        final jsonPayload = start >= 0 ? trimmed.substring(start) : trimmed;
        final decoded = jsonDecode(jsonPayload);
        if (decoded is Map<String, dynamic>) {
          return (decoded['message'] ?? decoded['error'] ?? '').toString();
        }
      }
    } catch (_) {}

    return '';
  }

  static Future<void> handleExpired() async {
    if (_isHandling || onExpired == null) return;
    _isHandling = true;
    try {
      log('CareersSessionExpiredHandler: session expired — logging out');
      await onExpired!();
    } catch (e) {
      log('CareersSessionExpiredHandler: error during logout — $e');
    } finally {
      _isHandling = false;
    }
  }
}
