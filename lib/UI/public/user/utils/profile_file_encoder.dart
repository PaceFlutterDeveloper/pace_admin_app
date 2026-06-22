import 'dart:convert';
import 'dart:io';

/// Encodes local avatar/CV files for Careers API v2 `update-profile`, which
/// accepts JSON bodies only (not multipart).
class ProfileFileEncoder {
  ProfileFileEncoder._();

  static Future<Map<String, dynamic>> encodeFiles({
    String? avatarFilePath,
    String? cvFilePath,
  }) async {
    final encoded = <String, dynamic>{};

    if (avatarFilePath != null && avatarFilePath.isNotEmpty) {
      encoded['avatar_file'] = await _encodeFile(avatarFilePath);
      encoded['avatar_file_name'] = _fileName(avatarFilePath);
    }
    if (cvFilePath != null && cvFilePath.isNotEmpty) {
      encoded['cv_file'] = await _encodeFile(cvFilePath);
      encoded['cv_file_name'] = _fileName(cvFilePath);
    }

    return encoded;
  }

  /// API expects raw base64 (not a data-URI prefix).
  static Future<String> _encodeFile(String filePath) async {
    final bytes = await File(filePath).readAsBytes();
    return base64Encode(bytes);
  }

  static String _fileName(String filePath) {
    final normalized = filePath.replaceAll('\\', '/');
    final index = normalized.lastIndexOf('/');
    return index == -1 ? normalized : normalized.substring(index + 1);
  }
}
