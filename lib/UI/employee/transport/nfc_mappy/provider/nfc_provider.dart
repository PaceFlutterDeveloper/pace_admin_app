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
  DateTime? _lastTagScanTime;
  TextEditingController nfcTagController = TextEditingController();

  Future<void> checkNfcAvailability() async {
    nfcStatus = Status.loading;
    notifyListeners();

    try {
      // Stop any existing session before starting a new one
      try {
        await NfcManager.instance.stopSession();
        log("Stopped existing NFC session");
      } catch (e) {
        // Ignore errors if no session exists
        log("No existing session to stop: $e");
      }

      final availability = await NfcManager.instance.checkAvailability();
      log("NFC availability: $availability");

      // Handle different NFC availability states
      if (availability == NfcAvailability.enabled) {
        isNfcAvailable = true;
        log('NFC listener started, approach tag(s)...');

        await NfcManager.instance.startSession(
          alertMessageIos: 'Hold your NFC tag near the device.',
          onDiscovered: (NfcTag tag) async {
            // Debounce: ignore scans within 1 second of each other.
            final now = DateTime.now();
            if (_lastTagScanTime != null &&
                now.difference(_lastTagScanTime!).inMilliseconds < 1000) {
              log("Ignoring rapid tag scan");
              return;
            }
            _lastTagScanTime = now;

            try {
              final tagId = _extractTagId(tag);
              if (tagId != null && tagId.isNotEmpty) {
                log("Card UID: $tagId");
                nfcTagController.text = tagId;
                notifyListeners();
              } else {
                // ignore: invalid_use_of_protected_member
                log("Could not extract tag identifier from: ${tag.data}");
              }
            } catch (e, st) {
              log("Error parsing NFC tag: $e\n$st");
            }
          },
          pollingOptions: const {
            NfcPollingOption.iso14443,
            NfcPollingOption.iso15693,
            NfcPollingOption.iso18092,
          },
        );
      } else {
        isNfcAvailable = false;
        // Log the specific reason NFC is not available
        if (availability == NfcAvailability.disabled) {
          log("NFC is disabled in device settings");
        } else if (availability == NfcAvailability.unsupported) {
          log("NFC hardware is not supported on this device");
        } else {
          log("NFC availability: $availability");
        }
        listenForNFCEvents();
      }

      nfcStatus = Status.loaded;
    } catch (e, st) {
      log("Error checking NFC availability: $e\n$st");
      isNfcAvailable = false;
      nfcStatus = Status.error;
    }
    notifyListeners();
  }

  void listenForNFCEvents() {
    log("NFC not available on this device.");
    notifyListeners();
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

  void clearForm() {
    nfcTagController.clear();
    nfcCardNumber = 0;
    notifyListeners();
  }

  Future<void> stopNfcSession() async {
    try {
      await NfcManager.instance.stopSession();
      log("NFC session stopped");
    } catch (e) {
      // Ignore errors if no session exists or already stopped
      log("Error stopping NFC session (may not exist): $e");
    }
  }

  Future<void> disposeProvider() async {
    await stopNfcSession();
    nfcTagController.dispose();
    log("NfcProvider disposed");
  }
}

enum Status {
  unInitialised,
  loading,
  loaded,
  error,
}
