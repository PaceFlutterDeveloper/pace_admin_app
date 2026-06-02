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
  NfcProvider? _nfcProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Store provider reference while widget is active
    _nfcProvider ??= Provider.of<NfcProvider>(context, listen: false);
  }

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
                    // Always show the form, even if NFC hardware isn't available
                    // This allows manual entry for testing or when using external NFC readers
                    return NfcAvailable();
                  case Status.error:
                    // Show form even on error - allows manual entry
                    return NfcAvailable();
                }
              },
            )));
  }

  @override
  void initState() {
    super.initState();
    Future(() {
      if (mounted) {
        _nfcProvider ??= Provider.of<NfcProvider>(context, listen: false);
        _nfcProvider?.checkNfcAvailability();
      }
    });
  }

  @override
  void dispose() {
    // Leaving the page clears all data and stops any active NFC session.
    // Mapping is a continuous process, so re-entering must start fresh.
    _nfcProvider?.resetOnExit();
    super.dispose();
  }
}
