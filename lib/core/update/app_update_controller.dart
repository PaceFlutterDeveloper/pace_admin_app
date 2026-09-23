import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:admin_app/core/services/api_service.dart';
import 'package:admin_app/core/update/app_version_policy.dart';
import 'package:admin_app/core/utils/constants/api_constant.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppUpdateController extends ChangeNotifier {
  AppUpdateController({required ApiService apiService})
    : _apiService = apiService;

  final ApiService _apiService;

  bool updateRequired = false;

  bool _settled = false;
  bool _checkStarted = false;
  int _epoch = 0;
  Future<void>? _loadingInstalled;
  _InstalledApp? _installed;

  /// Applies a successful jobs payload. A missing version object leaves the
  /// current block unchanged. Parse errors fail open.
  void evaluate(Map<String, dynamic> json) {
    final epoch = ++_epoch;
    unawaited(_apply(json, epoch));
  }

  /// One jobs request for cold starts that never load the jobs list.
  /// Skipped once any jobs payload has already been evaluated.
  Future<void> check() async {
    if (_settled || _checkStarted) return;
    _checkStarted = true;
    try {
      await _ensureInstalled();
      if (_settled) return;
      if (_installed == null) {
        _settled = true;
        return;
      }

      final result = await _apiService.getRequest(
        ApiConstants.jobsUrl,
        null,
        queryParameters: const {'page': 1, 'limit': 1},
      );
      if (_settled) return;

      result.fold((_) {}, (body) {
        if (_settled || body is! String || body.isEmpty) return;
        final decoded = json.decode(body);
        if (decoded is! Map || decoded['status'] != true) return;
        evaluate(Map<String, dynamic>.from(decoded));
      });
    } catch (error) {
      log('[FORCE_UPDATE] Version check failed open: $error');
    }
  }

  Future<void> _apply(Map<String, dynamic> json, int epoch) async {
    try {
      await _ensureInstalled();
      if (epoch != _epoch) return;

      final installed = _installed;
      if (installed == null) {
        _settled = true;
        return;
      }

      final decision = decideAppUpdate(
        payload: json,
        platform: installed.platform,
        installedVersion: installed.version,
        installedBuild: installed.build,
      );
      if (epoch != _epoch) return;
      _settled = true;
      if (!decision.applicable) return;
      _setRequired(decision.updateRequired);
    } catch (error) {
      if (epoch == _epoch) _settled = true;
      log('[FORCE_UPDATE] Version check failed open: $error');
    }
  }

  void _setRequired(bool required) {
    if (updateRequired == required) return;
    updateRequired = required;
    if (required) {
      log('[FORCE_UPDATE] App access blocked - showing ForceUpdateScreen');
    }
    notifyListeners();
  }

  Future<void> _ensureInstalled() {
    return _loadingInstalled ??= _loadInstalled();
  }

  Future<void> _loadInstalled() async {
    if (kIsWeb) return;
    final platform = switch (defaultTargetPlatform) {
      TargetPlatform.iOS => AppUpdatePlatform.ios,
      TargetPlatform.android => AppUpdatePlatform.android,
      _ => null,
    };
    if (platform == null) return;

    final info = await PackageInfo.fromPlatform();
    _installed = _InstalledApp(
      version: info.version,
      build: int.tryParse(info.buildNumber) ?? 0,
      platform: platform,
    );
  }
}

class _InstalledApp {
  const _InstalledApp({
    required this.version,
    required this.build,
    required this.platform,
  });

  final String version;
  final int build;
  final AppUpdatePlatform platform;
}
