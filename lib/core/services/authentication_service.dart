import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class AuthenticationService {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Checks if the device supports biometrics or passcode authentication
  Future<bool> canAuthenticate() async {
    try {
      bool hasBiometrics = await _auth.canCheckBiometrics;
      bool hasDeviceSupport = await _auth.isDeviceSupported();
      return hasBiometrics || hasDeviceSupport;
    } catch (e) {
      log("Error checking authentication support: $e");
      return false; // Assume no authentication support
    }
  }

  /// Authenticates the user using biometrics or passcode, but allows fallback if unavailable
  Future<bool> authenticate() async {
    try {
      bool canAuth = await canAuthenticate();

      if (!canAuth) {
        log("🔹 No authentication methods available. Allowing access.");
        return true; // Allow access if authentication is not supported
      }

      return await _auth.authenticate(
        localizedReason: 'Please authenticate to access this feature',
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
    } on PlatformException catch (e) {
      log("❌ Authentication error: ${e.message}");
      return true; // Allow access if authentication fails
    }
  }
}
