import 'package:flutter/material.dart';

/// Camera barcode scanning is omitted from the careers App Store build.
class BarcodeScannerPage extends StatelessWidget {
  const BarcodeScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan student code')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Barcode scanning is not available in this version. Enter the student code manually.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
