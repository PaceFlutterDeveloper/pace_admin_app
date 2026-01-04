// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

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
  TextEditingController nfcTagController = TextEditingController();

  Future<void> checkNfcAvailability() async {
    nfcStatus = Status.loading;
    notifyListeners();

    try {
      final availability = await NfcManager.instance.checkAvailability();
      log("NFC availability: $availability");

      if (availability == NfcAvailability.enabled) {
        isNfcAvailable = true;
        log('NFC listener started, approach tag(s)...');

        await NfcManager.instance.startSession(
          alertMessageIos: 'Hold your NFC tag near the device.',
          onDiscovered: (NfcTag tag) async {
            log("Tag discovered: ${tag.data}");

            final nfcA = NfcAAndroid.from(tag);
            if (nfcA != null) {
              final identifier = (tag.data as Map)['nfc-a']['identifier'];
              final number = toDec(identifier);
              log("Card UID: $number");
              nfcCardNumber = number;
              nfcTagController.text = number.toString();
              notifyListeners();
            } else {
              log("Unsupported tag type");
            }
          },
          pollingOptions: {
            NfcPollingOption.iso14443,
            NfcPollingOption.iso15693
          },
        );
      } else {
        isNfcAvailable = false;
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
    final res = await _repository.addNfctag(
      studcode: studCode,
      nfcTag: nfcTag,
      isAdd: true,
    );

    res.fold(
      (error) {
        // 🔴 Left case (failure)
        log("Error adding NFC tag: ${error.message}");
        showSnackbar(
          context,
          error.message.isNotEmpty ? error.message : "Failed to add NFC tag",
        );
      },
      (right) {
        // 🟢 Right case (success)
        final model = NfcResModel.fromAny(right);
        showSnackbar(context, model.remark);

        log("Successfully added NFC tag");
      },
    );
  }

  void disposeProvider() {
    NfcManager.instance.stopSession();
    nfcTagController.dispose();
  }
}

enum Status {
  unInitialised,
  loading,
  loaded,
  error,
}
