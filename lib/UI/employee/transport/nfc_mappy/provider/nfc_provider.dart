// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:admin_app/UI/employee/transport/nfc_mappy/model/transport/nfc_res_model.dart';
import 'package:admin_app/UI/employee/transport/nfc_mappy/repository/repository.dart';
import 'package:admin_app/core/utils/utils.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:flutter/material.dart';

// NFC hardware (nfc_manager) is omitted from the careers App Store build.
// Restore the scan session in this provider when the admin transport module ships.

class NfcProvider with ChangeNotifier {
  final NfcMappRepository _repository = locator<NfcMappRepository>();

  bool isNfcAvailable = false;
  Status nfcStatus = Status.unInitialised;
  int nfcCardNumber = 0;
  bool isSubmitting = false;
  bool isScanning = false;
  TextEditingController nfcTagController = TextEditingController();
  TextEditingController studCodeController = TextEditingController();

  /// Hardware NFC is disabled in the careers App Store build.
  Future<void> checkNfcAvailability() async {
    isNfcAvailable = false;
    isScanning = false;
    nfcStatus = Status.loaded;
    notifyListeners();
  }

  Future<void> startNfcScan(BuildContext context) async {
    showSnackbar(
      context,
      "NFC scanning is not available in this version.",
    );
  }

  Future<void> _safeStopSession() async {}

  Future<void> upinsert(
    String studCode,
    String nfcTag,
    BuildContext context,
  ) async {
    // Prevent multiple simultaneous submissions
    if (isSubmitting) {
      log("Already submitting, ignoring duplicate request");
      return;
    }

    // Check if context is still mounted
    if (!context.mounted) {
      log("Context not mounted, aborting");
      return;
    }

    isSubmitting = true;
    notifyListeners();

    try {
      final res = await _repository.addNfctag(
        studcode: studCode,
        nfcTag: nfcTag,
        isAdd: true,
      );

      // Check context again after async operation
      if (!context.mounted) {
        log("Context not mounted after API call");
        isSubmitting = false;
        notifyListeners();
        return;
      }

      res.fold(
        (error) {
          // 🔴 Left case (failure)
          log("Error adding NFC tag: ${error.message}");
          showSnackbar(
            context,
            error.message.isNotEmpty
                ? error.message
                : "Failed to add NFC tag",
          );
        },
        (right) {
          // 🟢 Right case (success)
          try {
            final model = NfcResModel.fromAny(right);
            showSnackbar(context, model.remark);
            log("Successfully added NFC tag");
            
            // Clear form after successful mapping
            clearForm();
          } catch (e) {
            log("Error parsing response: $e");
            showSnackbar(context, "NFC tag mapped successfully");
            clearForm();
          }
        },
      );
    } catch (e, st) {
      log("Unexpected error in upinsert: $e\n$st");
      if (context.mounted) {
        showSnackbar(context, "An unexpected error occurred");
      }
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  /// Clears all entered/scanned data so the next student can be mapped
  /// immediately. Called after a successful mapping.
  void clearForm() {
    studCodeController.clear();
    nfcTagController.clear();
    nfcCardNumber = 0;
    notifyListeners();
  }

  Future<void> stopNfcSession() async {
    await _safeStopSession();
    isScanning = false;
    log("NFC session stopped");
  }

  /// Resets everything when leaving the page: stops any active session and
  /// clears all data. Mapping is a continuous process, so re-entering the
  /// page must start with a clean form. Does not notify, since the UI is
  /// being torn down.
  Future<void> resetOnExit() async {
    await _safeStopSession();
    isScanning = false;
    studCodeController.clear();
    nfcTagController.clear();
    nfcCardNumber = 0;
  }

  Future<void> disposeProvider() async {
    await stopNfcSession();
    nfcTagController.dispose();
    studCodeController.dispose();
    log("NfcProvider disposed");
  }
}

enum Status {
  unInitialised,
  loading,
  loaded,
  error,
}
