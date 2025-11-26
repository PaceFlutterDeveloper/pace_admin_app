import 'package:admin_app/UI/components/button_component.dart';
import 'package:admin_app/UI/employee/transport/nfc_mappy/provider/nfc_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NfcAvailable extends StatefulWidget {
  const NfcAvailable({super.key});

  @override
  State<NfcAvailable> createState() => _NfcAvailableState();
}

class _NfcAvailableState extends State<NfcAvailable> {
  final _formKey = GlobalKey<FormState>();
  final _studCodeController = TextEditingController();

  @override
  void dispose() {
    _studCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NfcProvider>(
      builder: (context, nfcProvider, _) {
        final nfcTagController = nfcProvider.nfcTagController;

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
                            const SizedBox(height: 24),

                            // Student Code
                            TextFormField(
                              controller: _studCodeController,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Student Code',
                                hintText: 'Enter student code',
                                prefixIcon: Icon(Icons.badge_outlined),
                                border: OutlineInputBorder(),
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
                            const SizedBox(height: 20),

                            // Submit
                            ButtonComponent(
                              buttonText: "Update",
                              onTap: () {
                                if (_formKey.currentState?.validate() != true) {
                                  return;
                                }
                                nfcProvider.upinsert(
                                  _studCodeController.text.trim(),
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
