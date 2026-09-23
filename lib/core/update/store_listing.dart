import 'package:flutter/foundation.dart';

/// Numeric App Store id. Empty until the listing exists, which falls back
/// to the App Store home page.
const String kIosAppStoreId = '';

String storeListingUrl({
  required TargetPlatform platform,
  required String packageName,
  String iosAppStoreId = kIosAppStoreId,
}) {
  if (platform == TargetPlatform.iOS) {
    final appId = iosAppStoreId.trim();
    if (appId.isNotEmpty) {
      return 'https://apps.apple.com/app/id$appId';
    }
    return 'https://apps.apple.com';
  }

  final applicationId = packageName.trim();
  if (applicationId.isNotEmpty) {
    return 'https://play.google.com/store/apps/details?id=$applicationId';
  }
  return 'https://play.google.com';
}
