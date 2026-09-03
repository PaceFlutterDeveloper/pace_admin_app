import 'dart:convert';

import 'package:dio/dio.dart';

/// Builds multipart form data for Careers `POST /update-profile-photo`.
class ProfileFileMultipart {
  ProfileFileMultipart._();

  static bool hasFiles({String? avatarFilePath}) {
    return _hasPath(avatarFilePath);
  }

  /// Verifies the selected photo can be read before sending the request.
  static Future<void> ensureReadable({String? avatarFilePath}) async {
    if (!hasFiles(avatarFilePath: avatarFilePath)) return;

    await buildFormData(
      fields: const {},
      avatarFilePath: avatarFilePath,
    );
  }

  static Future<FormData> buildFormData({
    required Map<String, dynamic> fields,
    String? avatarFilePath,
  }) async {
    final formData = FormData.fromMap(_stringFields(fields));
    if (_hasPath(avatarFilePath)) {
      final name = _fileName(avatarFilePath!);
      formData.files.add(
        MapEntry(
          'photo',
          await MultipartFile.fromFile(
            avatarFilePath,
            filename: name,
            contentType: _contentTypeFor(name),
          ),
        ),
      );
    }
    return formData;
  }

  static Map<String, dynamic> _stringFields(Map<String, dynamic> fields) {
    final encoded = <String, dynamic>{};
    fields.forEach((key, value) {
      if (value == null) return;
      if (value is MultipartFile) {
        encoded[key] = value;
      } else if (value is Map || value is List) {
        encoded[key] = jsonEncode(value);
      } else {
        encoded[key] = value.toString();
      }
    });
    return encoded;
  }

  static bool _hasPath(String? path) {
    return path != null && path.trim().isNotEmpty;
  }

  static String _fileName(String filePath) {
    final normalized = filePath.replaceAll('\\', '/');
    final index = normalized.lastIndexOf('/');
    var name = index == -1 ? normalized : normalized.substring(index + 1);
    if (!name.contains('.')) {
      name = '$name.jpg';
    }
    return name;
  }

  static DioMediaType _contentTypeFor(String fileName) {
    switch (_extension(fileName)) {
      case 'png':
        return DioMediaType('image', 'png');
      case 'webp':
        return DioMediaType('image', 'webp');
      case 'gif':
        return DioMediaType('image', 'gif');
      default:
        return DioMediaType('image', 'jpeg');
    }
  }

  static String _extension(String fileName) {
    final dot = fileName.lastIndexOf('.');
    if (dot == -1 || dot == fileName.length - 1) return 'jpg';
    return fileName.substring(dot + 1).toLowerCase();
  }
}
