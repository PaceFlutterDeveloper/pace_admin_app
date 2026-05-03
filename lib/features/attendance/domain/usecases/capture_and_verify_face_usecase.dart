import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:admin_app/core/error/failures.dart';
import 'package:admin_app/features/attendance/utils/attendance_logger.dart';
import 'package:camera/camera.dart';
import 'package:dartz/dartz.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;

class CaptureAndVerifyFaceUseCase {
  CaptureAndVerifyFaceUseCase();

  /// [sensorOrientation] is [CameraDescription.sensorOrientation] (for logs / future tuning).
  Future<Either<Failure, File>> call(
    XFile imageFile, {
    int sensorOrientation = 0,
  }) async {
    AttendanceLogger.log(
      'face pipeline: start (${imageFile.path.split('/').last}) '
      'sensorOrientation=$sensorOrientation',
    );
    try {
      final bytes = await imageFile.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) {
        AttendanceLogger.log('face pipeline: reject — decodeImage failed');
        return const Left(Failure('Unable to process captured image'));
      }

      final upright = img.bakeOrientation(decoded);
      AttendanceLogger.log(
        'face pipeline: baked orientation → ${upright.width}x${upright.height}',
      );

      final mlPath =
          '${Directory.systemTemp.path}/attendance_ml_${DateTime.now().millisecondsSinceEpoch}.jpg';
      File(mlPath).writeAsBytesSync(img.encodeJpg(upright, quality: 92));

      final inputImage = InputImage.fromFilePath(mlPath);
      final detector = FaceDetector(
        options: FaceDetectorOptions(
          performanceMode: FaceDetectorMode.fast,
          enableContours: false,
          enableLandmarks: false,
          minFaceSize: 0.12,
        ),
      );

      var faces = await detector.processImage(inputImage);
      await detector.close();

      if (faces.isEmpty) {
        AttendanceLogger.log(
          'face pipeline: 0 faces on upright JPEG — retry original file path',
        );
        final fallback = FaceDetector(
          options: FaceDetectorOptions(
            performanceMode: FaceDetectorMode.fast,
            enableContours: false,
            enableLandmarks: false,
            minFaceSize: 0.1,
          ),
        );
        faces = await fallback.processImage(
          InputImage.fromFilePath(imageFile.path),
        );
        await fallback.close();
      }

      AttendanceLogger.log('face pipeline: ML Kit found ${faces.length} face(s)');
      if (faces.isEmpty) {
        AttendanceLogger.log('face pipeline: reject — no face');
        try {
          File(mlPath).deleteSync();
        } catch (_) {}
        return const Left(
          Failure('No face detected. Please look directly at the camera.'),
        );
      }
      if (faces.length > 1) {
        AttendanceLogger.log('face pipeline: reject — multiple faces');
        try {
          File(mlPath).deleteSync();
        } catch (_) {}
        return const Left(
          Failure(
            'Multiple faces detected. Please ensure only you are in frame.',
          ),
        );
      }

      if (_isLowLight(upright)) {
        AttendanceLogger.log('face pipeline: reject — low light');
        try {
          File(mlPath).deleteSync();
        } catch (_) {}
        return const Left(
            Failure('Low light detected. Move to brighter light.'));
      }

      final face = faces.first;
      final faceBox = face.boundingBox;
      if (!_isCentered(
        faceBox,
        upright.width.toDouble(),
        upright.height.toDouble(),
      )) {
        AttendanceLogger.log('face pipeline: reject — face not centered in guide');
        try {
          File(mlPath).deleteSync();
        } catch (_) {}
        return const Left(
          Failure('Center your face inside the oval guide and try again.'),
        );
      }

      final processed = _compress(upright);
      final tempPath =
          '${Directory.systemTemp.path}/attendance_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final compressedFile = File(tempPath)
        ..writeAsBytesSync(img.encodeJpg(processed, quality: 85));

      try {
        File(mlPath).deleteSync();
      } catch (_) {}

      AttendanceLogger.log(
        'face pipeline: OK → compressed ${compressedFile.path.split('/').last} '
        '(${processed.width}x${processed.height})',
      );
      return Right(compressedFile);
    } catch (e, st) {
      AttendanceLogger.log('face pipeline: exception $e');
      AttendanceLogger.log('face pipeline stack: $st');
      return const Left(Failure('Face verification failed. Please retry.'));
    }
  }

  img.Image _compress(img.Image source) {
    if (source.width <= 800) {
      return source;
    }
    return img.copyResize(source, width: 800);
  }

  bool _isCentered(
    Rect box,
    double imageWidth,
    double imageHeight,
  ) {
    final centerX = box.left + (box.width / 2);
    final centerY = box.top + (box.height / 2);
    final expectedCenterX = imageWidth / 2;
    final expectedCenterY = imageHeight / 2;
    final xTolerance = imageWidth * 0.2;
    final yTolerance = imageHeight * 0.2;
    final minSize = imageWidth * 0.18;

    final notTooCloseToEdge = box.left > imageWidth * 0.05 &&
        box.right < imageWidth * 0.95 &&
        box.top > imageHeight * 0.05 &&
        box.bottom < imageHeight * 0.95;

    return (centerX - expectedCenterX).abs() <= xTolerance &&
        (centerY - expectedCenterY).abs() <= yTolerance &&
        box.width > minSize &&
        box.height > minSize &&
        notTooCloseToEdge;
  }

  bool _isLowLight(img.Image image) {
    var total = 0.0;
    var count = 0;
    final stepX = math.max(1, image.width ~/ 40);
    final stepY = math.max(1, image.height ~/ 40);
    for (var y = 0; y < image.height; y += stepY) {
      for (var x = 0; x < image.width; x += stepX) {
        final pixel = image.getPixel(x, y);
        total += (0.299 * pixel.r) + (0.587 * pixel.g) + (0.114 * pixel.b);
        count++;
      }
    }
    final brightness = count == 0 ? 255.0 : total / count;
    return brightness < 40;
  }
}
