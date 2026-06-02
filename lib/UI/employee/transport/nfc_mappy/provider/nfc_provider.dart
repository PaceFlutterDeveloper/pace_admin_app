// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:admin_app/UI/employee/transport/nfc_mappy/model/transport/nfc_res_model.dart';
import 'package:admin_app/UI/employee/transport/nfc_mappy/repository/repository.dart';
import 'package:admin_app/core/utils/utils.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/nfc_manager_android.dart';
import 'package:nfc_manager/nfc_manager_ios.dart';

class NfcProvider with ChangeNotifier {
  final NfcMappRepository _repository = locator<NfcMappRepository>();

  bool isNfcAvailable = false;
  Status nfcStatus = Status.unInitialised;
  int nfcCardNumber = 0;
  bool isSubmitting = false;
  bool isScanning = false;
  DateTime? _lastTagScanTime;
  TextEditingController nfcTagController = TextEditingController();
  TextEditingController studCodeController = TextEditingController();

  /// Checks whether NFC hardware is available/enabled. This no longer starts
  /// a scan session; scanning is triggered explicitly via [startNfcScan].
  Future<void> checkNfcAvailability() async {
    nfcStatus = Status.loading;
    notifyListeners();

    try {
      // Make sure no leftover session is running.
      await _safeStopSession();

      final availability = await NfcManager.instance.checkAvailability();
      log("NFC availability: $availability");

      if (availability == NfcAvailability.enabled) {
        isNfcAvailable = true;
      } else {
        isNfcAvailable = false;
        if (availability == NfcAvailability.disabled) {
          log("NFC is disabled in device settings");
        } else if (availability == NfcAvailability.unsupported) {
          log("NFC hardware is not supported on this device");
        } else {
          log("NFC availability: $availability");
        }
      }

      nfcStatus = Status.loaded;
    } catch (e, st) {
      log("Error checking NFC availability: $e\n$st");
      isNfcAvailable = false;
      nfcStatus = Status.error;
    }
    notifyListeners();
  }

  /// Starts a single-shot NFC scan. The session is automatically dismissed
  /// once a tag is captured (or an error occurs) so the iOS scan sheet does
  /// not stay on screen.
  Future<void> startNfcScan(BuildContext context) async {
    if (isScanning) {
      log("Scan already in progress");
      return;
    }

    if (!isNfcAvailable) {
      showSnackbar(
        context,
        "NFC is not available. Enter the tag number manually.",
      );
      return;
    }

    isScanning = true;
    _lastTagScanTime = null;
    notifyListeners();

    try {
      await NfcManager.instance.startSession(
        alertMessageIos: 'Hold your NFC tag near the device.',
        onDiscovered: (NfcTag tag) async {
          // Debounce: ignore duplicate reads of the same tap.
          final now = DateTime.now();
          if (_lastTagScanTime != null &&
              now.difference(_lastTagScanTime!).inMilliseconds < 1000) {
            return;
          }
          _lastTagScanTime = now;

          try {
            final tagId = _extractTagId(tag);
            if (tagId != null && tagId.isNotEmpty) {
              log("Card UID: $tagId");
              nfcTagController.text = tagId;
              await _stopSession(
                successMessageIos: 'Tag captured successfully.',
              );
            } else {
              // ignore: invalid_use_of_protected_member
              log("Could not extract tag identifier from: ${tag.data}");
              await _stopSession(
                errorMessageIos: 'Could not read this tag. Try again.',
              );
            }
          } catch (e, st) {
            log("Error parsing NFC tag: $e\n$st");
            await _stopSession(
              errorMessageIos: 'Error reading tag. Try again.',
            );
          }
        },
        pollingOptions: const {
          NfcPollingOption.iso14443,
          NfcPollingOption.iso15693,
        },
      );
    } catch (e, st) {
      log("Error starting NFC session: $e\n$st");
      isScanning = false;
      notifyListeners();
      if (context.mounted) {
        showSnackbar(context, "Could not start NFC scan. Try again.");
      }
    }
  }

  /// Stops the active session and dismisses the iOS scan sheet, optionally
  /// showing a success or error message on the popup.
  Future<void> _stopSession({
    String? successMessageIos,
    String? errorMessageIos,
  }) async {
    try {
      await NfcManager.instance.stopSession(
        alertMessageIos: successMessageIos,
        errorMessageIos: errorMessageIos,
      );
    } catch (e) {
      log("Error stopping NFC session: $e");
    }
    isScanning = false;
    notifyListeners();
  }

  Future<void> _safeStopSession() async {
    try {
      await NfcManager.instance.stopSession();
    } catch (e) {
      log("No existing session to stop: $e");
    }
  }

  /// Extracts the unique tag identifier (UID) for both Android and iOS.
  ///
  /// In nfc_manager 4.x `tag.data` is no longer a `Map`, so the UID must be
  /// read through the platform-specific typed helpers. This covers the common
  /// tag technologies (NfcA/B/F/V, ISO-DEP, MIFARE, ISO 15693, FeliCa, ...).
  String? _extractTagId(NfcTag tag) {
    Uint8List? identifier;

    if (Platform.isAndroid) {
      // NfcTagAndroid.id is the raw UID and is present for every Android tech.
      identifier = NfcTagAndroid.from(tag)?.id;
    } else if (Platform.isIOS) {
      identifier = MiFareIos.from(tag)?.identifier ??
          Iso7816Ios.from(tag)?.identifier ??
          Iso15693Ios.from(tag)?.identifier ??
          FeliCaIos.from(tag)?.currentIDm;
    }

    if (identifier == null || identifier.isEmpty) return null;

    nfcCardNumber = toDec(identifier);
    return nfcCardNumber.toString();
  }

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
