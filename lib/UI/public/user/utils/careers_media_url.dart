import 'dart:convert';
import 'dart:typed_data';

import 'package:admin_app/core/utils/constants/api_constant.dart';

/// Resolves careers API file fields returned as text: relative paths,
/// absolute URLs, or embedded base64 / data-URI content.
class CareersMediaUrl {
  CareersMediaUrl._();

  /// True when [value] is a device filesystem path, not a server media path.
  static bool isLocalFilePath(String? value) {
    if (value == null || value.trim().isEmpty) return false;
    final trimmed = value.trim();
    if (trimmed.startsWith('file://')) return true;
    if (trimmed.contains('/careers_avatars/')) return true;
    if (trimmed.startsWith('/var/') ||
        trimmed.startsWith('/private/') ||
        trimmed.startsWith('/data/') ||
        trimmed.startsWith('/Users/') ||
        trimmed.startsWith('/tmp/') ||
        trimmed.startsWith('/storage/')) {
      return true;
    }
    return RegExp(r'^[a-zA-Z]:[\\/]').hasMatch(trimmed);
  }

  /// Server-backed avatar values that are safe to display.
  static bool isDisplayableRemote(String? value) {
    if (value == null || value.trim().isEmpty) return false;
    if (isLocalFilePath(value)) return false;
    if (isEmbeddedFileData(value)) return true;
    return resolve(value) != null;
  }

  /// Returns a fully-qualified URL, or `null` when [path] is not a URL/path.
  static String? resolve(String? path) {
    if (path == null || path.trim().isEmpty) return null;

    final trimmed = path.trim();
    if (isLocalFilePath(trimmed)) return null;
    // Never try to resolve embedded/truncated base64 as a URL.
    if (_looksLikeBase64(trimmed)) return null;
    if (isEmbeddedFileData(trimmed)) return null;

    final uri = Uri.tryParse(trimmed);
    if (uri != null && uri.hasScheme && uri.host.isNotEmpty) {
      return trimmed;
    }

    var normalized = trimmed.startsWith('/') ? trimmed.substring(1) : trimmed;
    normalized = normalized.replaceFirst(RegExp(r'^\.\./'), '');

    // Backend stores files under the careers site root, e.g.
    // https://paceeducation.com/careers/uploads/profile_photos/cand_123.jpg
    return '${ApiConstants.careersMediaBaseUrl}$normalized';
  }

  /// True when [value] is inline base64 image/file data rather than a path/URL.
  static bool isEmbeddedFileData(String? value) {
    if (value == null || value.trim().isEmpty) return false;
    final trimmed = value.trim();
    if (trimmed.startsWith('data:')) return true;
    if (!_looksLikeBase64(trimmed)) return false;
    // Truncated base64 from API — not a usable image
    if (trimmed.length < 1000) return false;
    return true;
  }

  /// Decodes base64 or `data:*;base64,...` content from API text fields.
  static Uint8List? decodeEmbeddedBytes(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    final trimmed = value.trim();

    if (trimmed.startsWith('data:')) {
      final commaIndex = trimmed.indexOf(',');
      if (commaIndex == -1) return null;
      return _tryDecodeBase64(trimmed.substring(commaIndex + 1));
    }

    if (!_looksLikeBase64(trimmed)) return null;
    return _tryDecodeBase64(trimmed);
  }

  static Uint8List? _tryDecodeBase64(String payload) {
    try {
      return base64Decode(_normalizeBase64(payload));
    } catch (_) {
      return null;
    }
  }

  /// API payloads sometimes omit trailing `=` padding required by [base64Decode].
  static String _normalizeBase64(String value) {
    final stripped = value.replaceAll(RegExp(r'\s+'), '');
    final remainder = stripped.length % 4;
    if (remainder == 0) return stripped;
    return stripped + ('=' * (4 - remainder));
  }

  /// Human-readable label for avatar/CV text values in forms.
  static String displayFileLabel(String? value) {
    if (value == null || value.trim().isEmpty) return 'No file selected';
    if (isLocalFilePath(value)) return 'No file selected';
    if (isEmbeddedFileData(value)) return 'File on record';
    final normalized = value.replaceAll('\\', '/');
    if (normalized.contains('/')) {
      return normalized.split('/').last;
    }
    return value;
  }

  static bool _looksLikeBase64(String value) {
    if (value.length < 64) return false;
    if (value.contains(' ') || value.contains('\n')) return false;
    if (value.startsWith('uploads/') || value.contains('.php')) return false;
    if (RegExp(r'\.(jpg|jpeg|png|gif|webp|pdf|doc|docx)$', caseSensitive: false)
        .hasMatch(value)) {
      return false;
    }
    return RegExp(r'^[A-Za-z0-9+/=\r\n]+$').hasMatch(value);
  }
}
