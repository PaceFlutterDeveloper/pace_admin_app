import 'package:flutter/material.dart';

/// Camera face capture is omitted from the careers App Store build.
class FaceCaptureWidget extends StatelessWidget {
  final VoidCallback onCancel;

  const FaceCaptureWidget({
    super.key,
    required bool useAutoCapture,
    required ValueChanged<bool> onCaptureModeChanged,
    required void Function(String file, int sensorOrientation) onCapture,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.face_retouching_off_outlined, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Face verification is not available in this version.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextButton(onPressed: onCancel, child: const Text('Go back')),
          ],
        ),
      ),
    );
  }
}
