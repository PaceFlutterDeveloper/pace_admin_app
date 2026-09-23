import 'dart:async';
import 'dart:developer';

import 'package:admin_app/core/routes/app_routes.dart';
import 'package:admin_app/core/utils/constants/job_share_links.dart';
import 'package:app_links/app_links.dart';

/// Listens for job Universal Links / App Links / custom-scheme URLs and
/// opens the matching job detail route.
class DeepLinkService {
  DeepLinkService._();

  static final DeepLinkService instance = DeepLinkService._();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;
  bool _started = false;
  Uri? _lastOpened;
  DateTime? _lastOpenedAt;

  Future<void> start() async {
    if (_started) return;
    _started = true;

    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) {
        open(initial);
      }
    } catch (e) {
      log('DeepLinkService: initial link failed $e');
    }

    _subscription = _appLinks.uriLinkStream.listen(
      open,
      onError: (Object e) => log('DeepLinkService: stream error $e'),
    );
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _started = false;
    _lastOpened = null;
    _lastOpenedAt = null;
  }

  void open(Uri uri) {
    final now = DateTime.now();
    if (_lastOpened == uri &&
        _lastOpenedAt != null &&
        now.difference(_lastOpenedAt!) < const Duration(milliseconds: 800)) {
      return;
    }
    final jobId = JobShareLinks.jobIdFromUri(uri);
    if (jobId == null) {
      log('DeepLinkService: ignored $uri');
      return;
    }

    _lastOpened = uri;
    _lastOpenedAt = now;
    log('DeepLinkService: opening job $jobId from $uri');
    AppRoute.router.goNamed(
      Routes.jobDetail.name,
      queryParameters: {'job_id': jobId.toString()},
    );
  }
}
