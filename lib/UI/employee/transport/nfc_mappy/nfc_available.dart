import 'package:admin_app/UI/components/button_component.dart';
import 'package:admin_app/UI/employee/transport/nfc_mappy/provider/nfc_provider.dart';
import 'package:admin_app/UI/employee/transport/nfc_mappy/widgets/barcode_scanner_page.dart';
import 'package:admin_app/core/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class NfcAvailable extends StatefulWidget {
  const NfcAvailable({super.key});

  @override
  State<NfcAvailable> createState() => _NfcAvailableState();
}

class _NfcAvailableState extends State<NfcAvailable> {
  final _formKey = GlobalKey<FormState>();

  Future<void> _scanStudentCode() async {
    // Ensure camera permission before opening the scanner.
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }
    if (!status.isGranted) {
      if (!mounted) return;
      showSnackbar(
        context,
        status.isPermanentlyDenied
            ? 'Camera permission is required. Enable it in Settings.'
            : 'Camera permission is required to scan barcodes.',
      );
      if (status.isPermanentlyDenied) {
        await openAppSettings();
      }
      return;
    }

    if (!mounted) return;
    final raw = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const BarcodeScannerPage()),
    );
    if (raw == null) return;

    // Digits-only transform: strip every non-numeric character.
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (!mounted) return;
    if (digits.isEmpty) {
      showSnackbar(context, 'No numeric value found in the scanned barcode.');
      return;
    }
    context.read<NfcProvider>().studCodeController.text = digits;
    showSnackbar(context, 'Student code captured.');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NfcProvider>(
      builder: (context, nfcProvider, _) {
        final nfcTagController = nfcProvider.nfcTagController;
        final studCodeController = nfcProvider.studCodeController;

        return SafeArea(
          child: Scaffold(
            body: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.nfc, size: 64),
                            const SizedBox(height: 12),
                            Text(
                              'Student NFC Mapping',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            // Show NFC availability status
                            if (!nfcProvider.isNfcAvailable) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.orange.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: 16,
                                      color: Colors.orange.shade700,
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        'NFC hardware not available. You can still enter the NFC tag number manually.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.orange.shade700,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),

                            // Student Code
                            TextFormField(
                              controller: studCodeController,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: 'Student Code',
                                hintText: 'Enter or scan student code',
                                prefixIcon: const Icon(Icons.badge_outlined),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.qr_code_scanner),
                                  tooltip: 'Scan barcode',
                                  onPressed: _scanStudentCode,
                                ),
                                border: const OutlineInputBorder(),
                                isDense: true,
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Student code is required'
                                  : null,
                            ),
                            const SizedBox(height: 14),

                            // NFC Tag
                            TextFormField(
                              controller: nfcTagController,
                              textInputAction: TextInputAction.done,
                              decoration: const InputDecoration(
                                labelText: 'NFC Tag Number',
                                hintText: 'Tap or enter NFC tag',
                                prefixIcon: Icon(Icons.tag_outlined),
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'NFC tag number is required'
                                  : null,
                            ),
                            const SizedBox(height: 14),

                            // Scan NFC card
                            if (nfcProvider.isNfcAvailable)
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: nfcProvider.isScanning
                                      ? null
                                      : () =>
                                          nfcProvider.startNfcScan(context),
                                  icon: nfcProvider.isScanning
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.nfc),
                                  label: Text(
                                    nfcProvider.isScanning
                                        ? 'Scanning... Tap your card'
                                        : 'Scan NFC Card',
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 20),

                            // Loading indicator
                            if (nfcProvider.isSubmitting)
                              const Padding(
                                padding: EdgeInsets.only(bottom: 8.0),
                                child: LinearProgressIndicator(),
                              ),

                            // Submit
                            ButtonComponent(
                              buttonText: nfcProvider.isSubmitting
                                  ? "Updating..."
                                  : "Update",
                              onTap: nfcProvider.isSubmitting
                                  ? () {} // No-op when submitting
                                  : () {
                                      if (_formKey.currentState?.validate() !=
                                          true) {
                                        return;
                                      }
                                      nfcProvider.upinsert(
                                        studCodeController.text.trim(),
                                        nfcTagController.text.trim(),
                                        context,
                                      );
                                    },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
