import 'dart:io';

import 'package:admin_app/UI/public/user/managers/careers_user_manager.dart';
import 'package:admin_app/UI/public/user/utils/careers_media_url.dart';
import 'package:path_provider/path_provider.dart';

/// Persists a picked profile photo locally so the profile tab can display it
/// even when the API has not yet returned `avatar_file`.
class CareersAvatarCache {
  CareersAvatarCache._();

  static const _prefKey = 'avatar_local_path';

  /// Persists an API `avatar_file` base64 payload locally for display.
  static Future<File?> saveFromBase64(String base64) async {
    final bytes = CareersMediaUrl.decodeEmbeddedBytes(base64);
    if (bytes == null || bytes.isEmpty) return null;

    final candidateId = CareersUserManager.getCurrentUser()?.id ?? 'unknown';
    final dir = await getApplicationDocumentsDirectory();
    final avatarsDir = Directory('${dir.path}/careers_avatars');
    if (!await avatarsDir.exists()) {
      await avatarsDir.create(recursive: true);
    }

    final dest = File('${avatarsDir.path}/avatar_$candidateId.png');
    await dest.writeAsBytes(bytes, flush: true);

    final user = CareersUserManager.getCurrentUser();
    if (user != null) {
      final prefs = Map<String, dynamic>.from(user.preferences);
      prefs[_prefKey] = dest.path;
      await CareersUserManager.updatePreferences(prefs);
    }

    return dest;
  }

  static Future<String?> saveFromFile(String sourcePath) async {
    final source = File(sourcePath);
    if (!await source.exists()) return null;

    final candidateId = CareersUserManager.getCurrentUser()?.id ?? 'unknown';
    final dir = await getApplicationDocumentsDirectory();
    final avatarsDir = Directory('${dir.path}/careers_avatars');
    if (!await avatarsDir.exists()) {
      await avatarsDir.create(recursive: true);
    }

    final extension = _extension(sourcePath);
    final dest = File('${avatarsDir.path}/avatar_$candidateId.$extension');
    await source.copy(dest.path);

    final user = CareersUserManager.getCurrentUser();
    if (user != null) {
      final prefs = Map<String, dynamic>.from(user.preferences);
      prefs[_prefKey] = dest.path;
      await CareersUserManager.updatePreferences(prefs);
    }

    return dest.path;
  }

  static File? getCachedFile() {
    final path = _cachedPath();
    if (path == null) return null;

    final file = File(path);
    if (!file.existsSync()) return null;
    return file;
  }

  static String? _cachedPath() {
    final prefs = CareersUserManager.getCurrentUser()?.preferences;
    final path = prefs?[_prefKey]?.toString().trim();
    if (path == null || path.isEmpty) return null;
    return path;
  }

  static String _extension(String filePath) {
    final normalized = filePath.replaceAll('\\', '/');
    final dotIndex = normalized.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == normalized.length - 1) {
      return 'jpg';
    }
    return normalized.substring(dotIndex + 1).toLowerCase();
  }
}
