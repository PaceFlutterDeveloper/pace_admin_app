// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:admin_app/UI/employee/transport/nfc_mappy/model/transport/nfc_res_model.dart';
import 'package:admin_app/UI/employee/transport/nfc_mappy/repository/repository.dart';
import 'package:admin_app/core/utils/utils.dart';
import 'package:admin_app/dependancy_injection.dart';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/nfc_manager_android.dart';

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
            // Debounce: ignore scans within 1 second of each other
            final now = DateTime.now();
            if (_lastTagScanTime != null &&
                now.difference(_lastTagScanTime!).inSeconds < 1) {
              log("Ignoring rapid tag scan");
              return;
            }
            _lastTagScanTime = now;

            // ignore: invalid_use_of_protected_member
            log("Tag discovered: ${tag.data}");

            try {
              String? tagId;
              
              // Handle Android NFC tags
              if (Platform.isAndroid) {
                final nfcA = NfcAAndroid.from(tag);
                if (nfcA != null) {
                  try {
                    // ignore: invalid_use_of_protected_member
                    final tagData = tag.data;
                    if (tagData is Map) {
                      final nfcAData = tagData['nfc-a'];
                      if (nfcAData is Map) {
                        final identifier = nfcAData['identifier'];
                        if (identifier != null && identifier is List<int>) {
                          final number = toDec(identifier);
                          log("Card UID: $number");
                          nfcCardNumber = number;
                          tagId = number.toString();
                        }
                      }
                    }
                  } catch (e) {
                    log("Error extracting Android NFC identifier: $e");
                  }
                }
              } else if (Platform.isIOS) {
                // iOS NFC tag handling - try to extract identifier from tag data
                try {
                  // ignore: invalid_use_of_protected_member
                  final tagData = tag.data;
                  if (tagData is Map) {
                    // Try common iOS NFC tag identifier keys
                    final identifier = tagData['identifier'] ?? 
                                     tagData['ID'] ?? 
                                     tagData['id'];
                    if (identifier != null) {
                      if (identifier is List<int>) {
                        final number = toDec(identifier);
                        tagId = number.toString();
                        nfcCardNumber = number;
                      } else if (identifier is String) {
                        tagId = identifier;
                        nfcCardNumber = int.tryParse(identifier) ?? 0;
                      }
                    }
                  }
                } catch (e) {
                  log("Error extracting iOS NFC identifier: $e");
                }
              }

              if (tagId != null && tagId.isNotEmpty) {
                nfcTagController.text = tagId;
                notifyListeners();
              } else {
                log("Could not extract tag identifier");
              }
            } catch (e, st) {
              log("Error parsing NFC tag: $e\n$st");
            }
          },
          pollingOptions: {
            NfcPollingOption.iso14443,
            NfcPollingOption.iso15693
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
