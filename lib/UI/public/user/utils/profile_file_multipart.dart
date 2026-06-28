import 'package:dio/dio.dart';

/// Builds multipart form data for Careers `update-profile` file uploads.
class ProfileFileMultipart {
  ProfileFileMultipart._();

  static bool hasFiles({
    String? avatarFilePath,
    String? cvFilePath,
  }) {
    return _hasPath(avatarFilePath) || _hasPath(cvFilePath);
  }

  /// Verifies selected files can be read before sending the request.
  static Future<void> ensureReadable({
    String? avatarFilePath,
    String? cvFilePath,
  }) async {
    if (!hasFiles(
      avatarFilePath: avatarFilePath,
      cvFilePath: cvFilePath,
    )) {
      return;
    }

    await buildFormData(
      fields: const {},
      avatarFilePath: avatarFilePath,
      cvFilePath: cvFilePath,
    );
  }

  static Future<FormData> buildFormData({
    required Map<String, dynamic> fields,
    String? avatarFilePath,
    String? cvFilePath,
  }) async {
    final formData = FormData.fromMap(Map<String, dynamic>.from(fields));
    await _attachFiles(
      formData: formData,
      avatarFilePath: avatarFilePath,
      cvFilePath: cvFilePath,
    );
    return formData;
  }

  static Future<void> _attachFiles({
    required FormData formData,
    String? avatarFilePath,
    String? cvFilePath,
  }) async {
    if (_hasPath(avatarFilePath)) {
      final name = _fileName(avatarFilePath!);
      formData.files.add(
        MapEntry(
          'avatar_file',
          await MultipartFile.fromFile(avatarFilePath, filename: name),
        ),
      );
      formData.fields.add(MapEntry('avatar_file_name', name));
    }

    if (_hasPath(cvFilePath)) {
      final name = _fileName(cvFilePath!);
      formData.files.add(
        MapEntry(
          'cv_file',
          await MultipartFile.fromFile(cvFilePath, filename: name),
        ),
      );
      formData.fields.add(MapEntry('cv_file_name', name));
    }
  }

  static bool _hasPath(String? path) {
    return path != null && path.trim().isNotEmpty;
  }

  static String _fileName(String filePath) {
    final normalized = filePath.replaceAll('\\', '/');
    final index = normalized.lastIndexOf('/');
    return index == -1 ? normalized : normalized.substring(index + 1);
  }
}
