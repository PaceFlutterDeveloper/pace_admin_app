import 'package:admin_app/staff/home/models/menu_model.dart';

const staffWebSessionParams = ['token', 'admin_id', 'school_code', 'theme'];

/// Menu label shown on the tile and in the web page title.
String internalWebLabel(MenuModel item) {
  final name = item.menuName.trim();
  if (name.isNotEmpty) return name;
  return item.menuVal.trim();
}

/// Same URL with `token` masked so it is safe to print in debug logs.
String redactInternalWebUrl(String url) {
  final uri = Uri.tryParse(url.trim());
  if (uri == null || !uri.hasQuery) return url;
  final params = Map<String, String>.from(uri.queryParameters);
  if (!params.containsKey('token')) return url;
  final token = params['token'] ?? '';
  params['token'] = token.isEmpty ? '[empty]' : '[redacted]';
  return uri.replace(queryParameters: params).toString();
}

/// [rawUrl] plus the signed-in staff session, overwriting those names.
///
/// [theme] is `light` or `dark` so the backend page can match the app.
String staffInternalWebUrl(
  String rawUrl, {
  required String token,
  required String adminId,
  required String schoolCode,
  required String theme,
}) {
  final uri = Uri.parse(rawUrl.trim());
  return uri
      .replace(
        queryParameters: {
          ...uri.queryParameters,
          'token': token,
          'admin_id': adminId,
          'school_code': schoolCode,
          'theme': theme,
        },
      )
      .toString();
}

/// True for an absolute http(s) address with a host.
bool isHttpUrl(String value) {
  final uri = Uri.tryParse(value.trim());
  if (uri == null || uri.host.isEmpty) return false;
  final scheme = uri.scheme.toLowerCase();
  return scheme == 'http' || scheme == 'https';
}

/// First internal-web item whose URL matches [targetUrl], parent before child.
MenuModel? findInternalWebByUrl(List<MenuModel> menus, String targetUrl) {
  for (final menu in menus) {
    final url = menu.webUrl?.trim() ?? '';
    if (menu.isInternalWeb && url.isNotEmpty && webUrlsMatch(url, targetUrl)) {
      return menu;
    }
    final nested = findInternalWebByUrl(menu.subMenu, targetUrl);
    if (nested != null) return nested;
  }
  return null;
}

bool webUrlsMatch(String a, String b) {
  final normalizedA = normalizeMenuWebUrl(a);
  final normalizedB = normalizeMenuWebUrl(b);
  if (normalizedA.isEmpty || normalizedB.isEmpty) return false;
  if (normalizedA == normalizedB) return true;
  return normalizedA.contains(normalizedB) ||
      normalizedB.contains(normalizedA);
}

/// Scheme and host are case-insensitive. Session query params are ignored.
String normalizeMenuWebUrl(String url) {
  final trimmed = url.trim();
  final uri = Uri.tryParse(trimmed);
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
    return trimmed.toLowerCase();
  }

  final params = Map<String, String>.from(uri.queryParameters)
    ..removeWhere((key, _) => staffWebSessionParams.contains(key));
  return Uri(
    scheme: uri.scheme.toLowerCase(),
    host: uri.host.toLowerCase(),
    port: uri.hasPort ? uri.port : null,
    path: uri.path,
    queryParameters: params.isEmpty ? null : params,
  ).toString();
}

/// Highest-scoring internal-web item for [targets]. Children win a tie.
MenuModel? findInternalWebByLabel(List<MenuModel> menus, List<String> targets) {
  final cleaned = [
    for (final target in targets)
      if (target.trim().isNotEmpty) target.trim(),
  ];
  if (cleaned.isEmpty) return null;

  MenuModel? best;
  var bestScore = 0;

  void walk(List<MenuModel> items) {
    for (final menu in items) {
      if (menu.subMenu.isNotEmpty) walk(menu.subMenu);
      if (!menu.isInternalWeb) continue;
      if ((menu.webUrl?.trim() ?? '').isEmpty) continue;
      final score = internalWebLabelScore(menu, cleaned);
      if (score > bestScore) {
        bestScore = score;
        best = menu;
      }
    }
  }

  walk(menus);
  return best;
}

/// Best of [menuVal] and [menuName] against [targets].
///
/// 100 exact, 80 after stripping non-alphanumeric characters, 60 a shared
/// word, 50 a prefix of at least 6 characters.
int internalWebLabelScore(MenuModel menu, List<String> targets) {
  var best = 0;
  for (final label in [menu.menuVal, menu.menuName]) {
    final score = _labelScore(label, targets);
    if (score > best) best = score;
    if (best == 100) return 100;
  }
  return best;
}

/// Item opened from a push. The payload URL is what loads.
MenuModel internalWebLaunchMenu({
  MenuModel? matched,
  required String url,
  required String title,
}) {
  final label = title.trim().isNotEmpty
      ? title.trim()
      : (matched == null ? '' : internalWebLabel(matched));
  return MenuModel(
    id: matched?.id ?? '0',
    menuKey: 'internalWeb',
    menuVal: label,
    menuName: label,
    page: matched?.page,
    iconUrl: matched?.iconUrl ?? '',
    parentId: matched?.parentId ?? '',
    pos: matched?.pos ?? 0,
    badge: matched?.badge ?? 0,
    subMenu: const [],
    webUrl: url,
  );
}

int _labelScore(String menuValue, List<String> targets) {
  final value = menuValue.trim();
  if (value.isEmpty) return 0;
  final valueNorm = _labelKey(value);
  final valueWords = _labelWords(value);
  var best = 0;

  for (final target in targets) {
    if (value.toLowerCase() == target.toLowerCase()) return 100;

    final targetNorm = _labelKey(target);
    if (valueNorm.isNotEmpty && valueNorm == targetNorm) {
      best = 80;
      continue;
    }

    final targetWords = _labelWords(target);
    for (final word in valueWords) {
      for (final other in targetWords) {
        if (word == other) {
          if (best < 60) best = 60;
        } else if (_labelWordsMatch(word, other) && best < 50) {
          best = 50;
        }
      }
    }
  }
  return best;
}

bool _labelWordsMatch(String a, String b) {
  final shorter = a.length <= b.length ? a : b;
  final longer = a.length <= b.length ? b : a;
  return shorter.length >= 6 && longer.startsWith(shorter);
}

String _labelKey(String value) =>
    value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

List<String> _labelWords(String value) => value
    .toLowerCase()
    .split(RegExp(r'[^a-z0-9]+'))
    .where((word) => word.isNotEmpty)
    .toList();
