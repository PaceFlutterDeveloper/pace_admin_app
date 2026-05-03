import 'dart:async';

import 'package:admin_app/features/attendance/utils/attendance_logger.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FaceCaptureWidget extends StatefulWidget {
  final bool useAutoCapture;
  final ValueChanged<bool> onCaptureModeChanged;
  /// Second argument is [CameraDescription.sensorOrientation] (0/90/180/270).
  final void Function(XFile file, int sensorOrientation) onCapture;
  final VoidCallback onCancel;

  const FaceCaptureWidget({
    super.key,
    required this.useAutoCapture,
    required this.onCaptureModeChanged,
    required this.onCapture,
    required this.onCancel,
  });

  @override
  State<FaceCaptureWidget> createState() => _FaceCaptureWidgetState();
}

class _FaceCaptureWidgetState extends State<FaceCaptureWidget>
    with WidgetsBindingObserver {
  CameraController? _controller;
  bool _isBusy = false;
  String _feedback = 'Align your face inside the oval guide.';
  int _countdown = 3;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null) {
      return;
    }
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      AttendanceLogger.log('camera UI: lifecycle paused — disposing controller');
      controller.dispose();
      _controller = null;
      _timer?.cancel();
    } else if (state == AppLifecycleState.resumed) {
      AttendanceLogger.log('camera UI: lifecycle resumed — re-init camera');
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    AttendanceLogger.log('camera UI: initializing front camera…');
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) {
        return;
      }
      AttendanceLogger.log(
        'camera UI: preview ready (autoCapture=${widget.useAutoCapture})',
      );
      setState(() {
        _controller = controller;
        _feedback = 'Face detected mode ready';
      });
      if (widget.useAutoCapture) {
        _startCountdown();
      }
    } catch (e) {
      AttendanceLogger.log('camera UI: init failed — $e');
      if (!mounted) {
        return;
      }
      setState(() {
        _feedback = 'Camera initialization failed. Contact support.';
      });
    }
  }

  void _startCountdown() {
    AttendanceLogger.log('camera UI: auto-capture countdown 3s');
    _timer?.cancel();
    _countdown = 3;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_countdown == 1) {
        timer.cancel();
        await _capture();
        return;
      }
      setState(() => _countdown--);
    });
  }

  Future<void> _capture() async {
    if (_isBusy) {
      return;
    }
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    setState(() {
      _isBusy = true;
      _feedback = 'Capturing image...';
    });
    try {
      final file = await controller.takePicture();
      final sensorOrientation = controller.description.sensorOrientation;
      AttendanceLogger.log(
        'camera UI: photo captured → ${file.path.split('/').last} '
        'sensorOrientation=$sensorOrientation',
      );
      if (!mounted) {
        return;
      }
      widget.onCapture(file, sensorOrientation);
    } catch (e) {
      AttendanceLogger.log('camera UI: takePicture failed — $e');
      if (!mounted) {
        return;
      }
      setState(() {
        _feedback = 'Capture failed. Please retry.';
        _isBusy = false;
      });
    }
  }

  @override
  void didUpdateWidget(covariant FaceCaptureWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.useAutoCapture != widget.useAutoCapture && mounted) {
      if (widget.useAutoCapture) {
        _startCountdown();
      } else {
        _timer?.cancel();
      }
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final initialized = controller?.value.isInitialized == true;
    return Stack(
      children: [
        Positioned.fill(
          child: initialized
              ? CameraPreview(controller!)
              : const ColoredBox(
                  color: Colors.black87,
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _FaceGuidePainter(),
            ),
          ),
        ),
        Positioned(
          top: 50,
          left: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _feedback,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
        Positioned(
          bottom: 30,
          left: 16,
          right: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: widget.onCancel,
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Row(
                    children: [
                      const Text(
                        'Auto Capture',
                        style: TextStyle(color: Colors.white),
                      ),
                      Switch(
                        value: widget.useAutoCapture,
                        onChanged: widget.onCaptureModeChanged,
                      ),
                    ],
                  ),
                ],
              ),
              if (widget.useAutoCapture)
                Text(
                  'Capturing in $_countdown',
                  style: const TextStyle(color: Colors.white70),
                ),
              const SizedBox(height: 12),
              if (!widget.useAutoCapture)
                FloatingActionButton(
                  onPressed: _capture,
                  child: const Icon(Icons.camera_alt_rounded),
                ),
              const SizedBox(height: 8),
              const Text(
                'Ensure good lighting and look directly at the camera',
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FaceGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.62,
      height: size.height * 0.45,
    );
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    const dashWidth = 14.0;
    const dashSpace = 8.0;
    final path = Path()..addOval(rect);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
