import 'dart:io';

import 'package:admin_app/core/error/failures.dart';
import 'package:dartz/dartz.dart';

/// Face detection is omitted from the careers App Store build.
///
/// Restore `google_mlkit_face_detection` and the previous pipeline when admin
/// attendance ships.
class CaptureAndVerifyFaceUseCase {
  CaptureAndVerifyFaceUseCase();

  Future<Either<Failure, File>> call(
    String imagePath, {
    int sensorOrientation = 0,
  }) async {
    return const Left(
      Failure('Face verification is not available in this version.'),
    );
  }
}
