import 'dart:io';

import 'package:admin_app/core/utils/debug_logger.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Pick, crop, and compress a photo the same way parent photos are processed
/// in the school app: Gallery or Files → UAE passport 3.5:4.5 → ≤ 250 KB.
class ImageProcessingHelper {
  ImageProcessingHelper._();

  static const List<String> allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];

  static const int maxFileSizeBytes = 250 * 1024;

  /// UAE passport aspect ratio: width 3.5, height 4.5.
  static const double aspectRatioX = 3.5;
  static const double aspectRatioY = 4.5;

  static String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  static String _extension(String filePath) {
    final normalized = filePath.replaceAll('\\', '/');
    final dot = normalized.lastIndexOf('.');
    if (dot == -1 || dot == normalized.length - 1) return '';
    return normalized.substring(dot + 1).toLowerCase();
  }

  static String _basenameWithoutExtension(String filePath) {
    final normalized = filePath.replaceAll('\\', '/');
    final slash = normalized.lastIndexOf('/');
    final name = slash == -1 ? normalized : normalized.substring(slash + 1);
    final dot = name.lastIndexOf('.');
    return dot == -1 ? name : name.substring(0, dot);
  }

  static Future<int> getFileSize(String filePath) async {
    return File(filePath).length();
  }

  static bool isValidImageFormat(String filePath) {
    return allowedExtensions.contains(_extension(filePath));
  }

  static Future<ImageSourceOption?> showImageSourceDialog(
    BuildContext context,
  ) {
    return showDialog<ImageSourceOption>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () => Navigator.of(
                  dialogContext,
                ).pop(ImageSourceOption.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.folder),
                title: const Text('Files'),
                onTap: () =>
                    Navigator.of(dialogContext).pop(ImageSourceOption.files),
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<String?> pickImageFromGallery() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );
      if (image == null) return null;
      DebugLogger.log(
        '[Image Processing] Gallery: ${image.path} '
        '(${_formatFileSize(await getFileSize(image.path))})',
      );
      return image.path;
    } catch (e) {
      DebugLogger.log('[Image Processing] Gallery pick failed: $e');
      return null;
    }
  }

  static Future<String?> pickImageFromFiles() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
      );
      final filePath = result?.files.single.path;
      if (filePath == null) return null;
      if (!isValidImageFormat(filePath)) {
        DebugLogger.log(
          '[Image Processing] Invalid file format: ${_extension(filePath)}',
        );
        return null;
      }
      DebugLogger.log(
        '[Image Processing] Files: $filePath '
        '(${_formatFileSize(await getFileSize(filePath))})',
      );
      return filePath;
    } catch (e) {
      DebugLogger.log('[Image Processing] Files pick failed: $e');
      return null;
    }
  }

  /// Crops to UAE passport ratio 3.5 : 4.5 with a locked aspect-ratio UI.
  static Future<String?> cropImage(
    String imagePath,
    BuildContext context,
  ) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imagePath,
        aspectRatio: const CropAspectRatio(
          ratioX: aspectRatioX,
          ratioY: aspectRatioY,
        ),
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Adjust Crop Area - UAE Passport Ratio (3.5 : 4.5)',
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: true,
            hideBottomControls: false,
            showCropGrid: true,
            cropFrameColor: Colors.blue,
            cropGridColor: Colors.white.withValues(alpha: 0.5),
            cropGridStrokeWidth: 2,
            backgroundColor: Colors.black,
            activeControlsWidgetColor: Colors.blue,
            dimmedLayerColor: Colors.black.withValues(alpha: 0.8),
            cropFrameStrokeWidth: 3,
          ),
          IOSUiSettings(
            title: 'Adjust Crop Area',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
            aspectRatioLockDimensionSwapEnabled: false,
            rotateButtonsHidden: false,
            rotateClockwiseButtonHidden: false,
            hidesNavigationBar: false,
            doneButtonTitle: 'Done',
            cancelButtonTitle: 'Cancel',
            showActivitySheetOnDone: false,
            showCancelConfirmationDialog: false,
          ),
        ],
      );
      return croppedFile?.path;
    } catch (e) {
      DebugLogger.log('[Image Processing] Crop failed: $e');
      return null;
    }
  }

  /// Compresses to ≤ 250 KB. Returns the original path when already small.
  static Future<String?> compressImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) return null;

      final originalSize = await getFileSize(imagePath);
      if (originalSize <= maxFileSizeBytes) {
        DebugLogger.log(
          '[Image Processing] Already under 250 KB '
          '(${_formatFileSize(originalSize)})',
        );
        return imagePath;
      }

      final tempDir = await getTemporaryDirectory();
      final targetPath =
          '${tempDir.path}/${_basenameWithoutExtension(imagePath)}_compressed.jpg';

      var quality = 85;
      var minWidth = 800;
      var minHeight = 600;
      var lastSize = originalSize;
      var currentSize = originalSize;

      while (quality >= 30 && currentSize > maxFileSizeBytes) {
        final compressedFile = await FlutterImageCompress.compressAndGetFile(
          imagePath,
          targetPath,
          quality: quality,
          minWidth: minWidth,
          minHeight: minHeight,
        );
        if (compressedFile == null) return null;

        currentSize = await getFileSize(compressedFile.path);
        DebugLogger.log(
          '[Image Processing] Compress q=$quality '
          '${minWidth}x$minHeight → ${_formatFileSize(currentSize)}',
        );

        if (currentSize <= maxFileSizeBytes) {
          return compressedFile.path;
        }

        if (currentSize >= lastSize) {
          quality -= 15;
          minWidth = (minWidth * 0.75).round();
          minHeight = (minHeight * 0.75).round();
        } else {
          quality -= 10;
          if (quality < 50) {
            minWidth = (minWidth * 0.8).round();
            minHeight = (minHeight * 0.8).round();
          }
        }
        lastSize = currentSize;
      }

      if (await File(targetPath).exists()) return targetPath;
      return imagePath;
    } catch (e) {
      DebugLogger.log('[Image Processing] Compress failed: $e');
      return null;
    }
  }

  /// Pick → validate → crop 3.5:4.5 → compress ≤ 250 KB.
  static Future<String?> processImage({
    required BuildContext context,
    required ImageSourceOption source,
  }) async {
    try {
      final imagePath = source == ImageSourceOption.gallery
          ? await pickImageFromGallery()
          : await pickImageFromFiles();
      if (imagePath == null) return null;
      if (!isValidImageFormat(imagePath)) return null;

      final croppedPath = await cropImage(imagePath, context);
      if (croppedPath == null) return null;

      return await compressImage(croppedPath) ?? croppedPath;
    } catch (e) {
      DebugLogger.log('[Image Processing] Pipeline failed: $e');
      return null;
    }
  }

  static Future<String?> pickAndProcessImage(BuildContext context) async {
    final source = await showImageSourceDialog(context);
    if (source == null) return null;
    return processImage(context: context, source: source);
  }
}

enum ImageSourceOption { gallery, files }
