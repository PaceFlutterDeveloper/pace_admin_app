enum AppUpdatePlatform { ios, android }

class AppVersionDecision {
  const AppVersionDecision({
    required this.updateRequired,
    required this.applicable,
  });

  /// True when the installed build is below the platform minimum.
  final bool updateRequired;

  /// False when the payload has no version object. The caller should leave
  /// the current block unchanged.
  final bool applicable;
}

/// Decides whether [installedVersion] / [installedBuild] is below the minimum
/// in a jobs `app_version` (or `appVersion`) object.
///
/// Missing object: not applicable. A non-object platform block, an empty
/// minimum version, or any parse problem: applicable and not required.
/// `forceUpdate` / `force_update` is ignored.
AppVersionDecision decideAppUpdate({
  required Map<String, dynamic> payload,
  required AppUpdatePlatform platform,
  required String installedVersion,
  required int installedBuild,
}) {
  try {
    final raw = payload['app_version'] ?? payload['appVersion'];
    final versionMap = _asStringKeyMap(raw);
    if (versionMap == null) {
      return const AppVersionDecision(updateRequired: false, applicable: false);
    }

    final minimum = _readMinimum(versionMap, platform);
    if (minimum == null || minimum.version == null) {
      return const AppVersionDecision(updateRequired: false, applicable: true);
    }

    final comparison = compareVersionNames(installedVersion, minimum.version!);
    final blocked =
        comparison < 0 || (comparison == 0 && installedBuild < minimum.build);
    return AppVersionDecision(updateRequired: blocked, applicable: true);
  } catch (_) {
    return const AppVersionDecision(updateRequired: false, applicable: true);
  }
}

/// Negative when [installed] is older, 0 when equal, positive when newer.
/// A missing or non-numeric segment counts as 0.
int compareVersionNames(String installed, String minimum) {
  final installedParts = installed.split('.');
  final minimumParts = minimum.split('.');
  final length = installedParts.length > minimumParts.length
      ? installedParts.length
      : minimumParts.length;

  for (var i = 0; i < length; i++) {
    final installedSegment = i < installedParts.length
        ? _segment(installedParts[i])
        : 0;
    final minimumSegment = i < minimumParts.length
        ? _segment(minimumParts[i])
        : 0;
    if (installedSegment != minimumSegment) {
      return installedSegment.compareTo(minimumSegment);
    }
  }
  return 0;
}

class _PlatformMinimum {
  const _PlatformMinimum({required this.version, required this.build});

  final String? version;
  final int build;
}

_PlatformMinimum? _readMinimum(
  Map<String, dynamic> versionMap,
  AppUpdatePlatform platform,
) {
  final nestedKey = platform == AppUpdatePlatform.ios ? 'ios' : 'android';
  if (versionMap.containsKey(nestedKey)) {
    final nested = _asStringKeyMap(versionMap[nestedKey]);
    if (nested == null) return null;
    return _PlatformMinimum(
      version: _versionText(
        nested['minimumVersion'] ?? nested['minimum_version'],
      ),
      build: _buildNumber(nested['minimumBuild'] ?? nested['minimum_build']),
    );
  }

  final prefix = nestedKey;
  return _PlatformMinimum(
    version: _versionText(versionMap['${prefix}_minimum_version']),
    build: _buildNumber(versionMap['${prefix}_minimum_build']),
  );
}

Map<String, dynamic>? _asStringKeyMap(dynamic value) {
  if (value is! Map) return null;
  return value.map((key, entry) => MapEntry(key.toString(), entry));
}

String? _versionText(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  if (text.isEmpty) return null;
  return text;
}

int _buildNumber(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString().trim()) ?? 0;
}

int _segment(String raw) => int.tryParse(raw.trim()) ?? 0;
