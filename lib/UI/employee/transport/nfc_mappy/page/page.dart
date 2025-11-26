import 'package:admin_app/UI/employee/transport/nfc_mappy/nfc_available.dart';
import 'package:admin_app/UI/employee/transport/nfc_mappy/provider/nfc_provider.dart';
import 'package:admin_app/core/themes/const_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NfcMapyScreen extends StatefulWidget {
  const NfcMapyScreen({super.key});

  @override
  State<NfcMapyScreen> createState() => _NfcMapyScreenState();
}

class _NfcMapyScreenState extends State<NfcMapyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ConstColors.backgroundColor,
        appBar: AppBar(
          elevation: 1,
          title: const Text("Nfc Mapping"),
        ),
        body: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Consumer<NfcProvider>(
              builder: (context, nfcProvider, child) {
                switch (nfcProvider.nfcStatus) {
                  case Status.unInitialised:
                  case Status.loading:
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  case Status.loaded:
                    if (nfcProvider.isNfcAvailable) {
                      return NfcAvailable();
                    } else {
                      return const Center(
                        child: Text("No NFC available in your device"),
                      );
                    }
                  case Status.error:
                    return const Center(
                      child: Text("No NFC available in your device"),
                    );
                }
              },
            )));
  }

  @override
  void initState() {
    Future(() => Provider.of<NfcProvider>(context, listen: false)
        .checkNfcAvailability());
    // TODO: implement initState
    super.initState();
  }
}
