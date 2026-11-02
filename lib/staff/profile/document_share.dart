import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:admin_app/staff/profile/model/doc_model.dart';
import 'package:admin_app/staff/shared/read_json.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class DocumentShareException implements Exception {
  const DocumentShareException(this.message);

  final String message;
}

/// Local copy of a staff document fetched from its signed download URL.
class StaffDocumentFile {
  const StaffDocumentFile({
    required this.file,
    required this.name,
    this.mimeType,
  });

  final File file;
  final String name;
  final String? mimeType;

  bool get isPdf {
    final mime = mimeType?.toLowerCase();
    if (mime == 'application/pdf') return true;
    return name.toLowerCase().endsWith('.pdf');
  }

  bool get isImage {
    final mime = mimeType?.toLowerCase() ?? '';
    if (mime.startsWith('image/')) return true;
    final lower = name.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.gif');
  }

  bool get canPreview => isPdf || isImage;
}

/// File name used when the document is saved or shared.
String documentFileName(DocModel doc, {String? contentType}) {
  final title = _token(doc.doc.trim().isEmpty ? 'Document' : doc.doc.trim());
  final number = _token(doc.docNo);
  final id = _token(doc.id);
  final stem = [
    if (title.isNotEmpty) title,
    if (number.isNotEmpty) number else if (id.isNotEmpty) id,
  ].join('_');
  final base = stem.isEmpty ? 'document' : stem;
  return '$base${_extension(doc, contentType)}';
}

/// Why a downloaded body cannot be shared, or null when the bytes are a file.
String? staffDocumentBodyError({
  required int? statusCode,
  required List<int> bytes,
  String? contentType,
}) {
  final failed = statusCode == null || statusCode < 200 || statusCode >= 300;
  if (failed) {
    return _jsonMessage(bytes) ?? 'Could not download this document.';
  }
  if (bytes.isEmpty) return 'Could not download this document.';
  if (bytes.length > 25 * 1024 * 1024) {
    return 'This file is too large to open from the app.';
  }

  final mime = _cleanMime(contentType);
  if (mime != null &&
      (mime.startsWith('image/') || mime == 'application/pdf')) {
    return null;
  }

  final start = _firstByte(bytes);
  if (start == 0x7B || (mime != null && mime.contains('json'))) {
    return _jsonMessage(bytes) ?? 'Could not download this document.';
  }
  if (start == 0x3C ||
      (mime != null && (mime.contains('html') || mime.startsWith('text/')))) {
    return 'Could not download this document.';
  }
  return null;
}

/// Downloads the signed document to a temp file for preview or share.
Future<StaffDocumentFile> downloadStaffDocument(DocModel doc) async {
  final url = doc.downloadUrl.trim();
  final uri = Uri.tryParse(url);
  if (uri == null || !(uri.isScheme('https') || uri.isScheme('http'))) {
    throw const DocumentShareException(
      'This document has no file to download.',
    );
  }

  try {
    final response = await Dio().get<dynamic>(
      url,
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: true,
        receiveTimeout: const Duration(seconds: 45),
        headers: const {'Accept': '*/*'},
        validateStatus: (code) => code != null && code < 500,
      ),
    );
    final data = response.data;
    final bytes = data is Uint8List
        ? data
        : data is List<int>
        ? Uint8List.fromList(data)
        : Uint8List(0);
    final contentType = response.headers.value(Headers.contentTypeHeader);
    final error = staffDocumentBodyError(
      statusCode: response.statusCode,
      bytes: bytes,
      contentType: contentType,
    );
    if (error != null) throw DocumentShareException(error);

    final name = documentFileName(doc, contentType: contentType);
    final folder = Directory(
      '${(await getTemporaryDirectory()).path}/staff_documents',
    );
    await folder.create(recursive: true);
    final file = File('${folder.path}/$name');
    await file.writeAsBytes(bytes, flush: true);
    return StaffDocumentFile(
      file: file,
      name: name,
      mimeType: _mimeFor(name, contentType),
    );
  } on DocumentShareException {
    rethrow;
  } on DioException {
    throw const DocumentShareException('Could not download this document.');
  } on FileSystemException {
    throw const DocumentShareException(
      'Could not save this document on the phone.',
    );
  }
}

/// Downloads the signed document, then opens the share sheet so it can be
/// saved to Files or sent to another app.
Future<void> shareStaffDocument(DocModel doc, {Rect? origin}) async {
  final downloaded = await downloadStaffDocument(doc);
  await SharePlus.instance.share(
    ShareParams(
      files: [
        XFile(
          downloaded.file.path,
          mimeType: downloaded.mimeType,
          name: downloaded.name,
        ),
      ],
      subject: doc.doc.trim().isEmpty ? downloaded.name : doc.doc.trim(),
      sharePositionOrigin: origin,
    ),
  );
}

String _token(String raw) {
  final cleaned = raw
      .replaceAll(RegExp(r'[^\w.\-]+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
  if (cleaned.length <= 60) return cleaned;
  return cleaned.substring(0, 60).replaceAll(RegExp(r'_$'), '');
}

String _extension(DocModel doc, String? contentType) {
  final name = readString(doc.fileName);
  final match = RegExp(r'\.([A-Za-z0-9]{1,8})$').firstMatch(name);
  if (match != null) return '.${match.group(1)!.toLowerCase()}';
  return switch (_cleanMime(contentType)) {
    'application/pdf' => '.pdf',
    'image/jpeg' => '.jpg',
    'image/png' => '.png',
    'image/webp' => '.webp',
    'image/gif' => '.gif',
    _ => '',
  };
}

String? _mimeFor(String fileName, String? contentType) {
  final lower = fileName.toLowerCase();
  if (lower.endsWith('.pdf')) return 'application/pdf';
  if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.webp')) return 'image/webp';
  if (lower.endsWith('.gif')) return 'image/gif';
  return _cleanMime(contentType);
}

String? _cleanMime(String? header) {
  if (header == null) return null;
  final mime = header.split(';').first.trim().toLowerCase();
  if (mime.isEmpty || mime == 'application/octet-stream') return null;
  return mime;
}

int _firstByte(List<int> bytes) {
  for (final byte in bytes) {
    if (byte != 0x20 && byte != 0x09 && byte != 0x0A && byte != 0x0D) {
      return byte;
    }
  }
  return -1;
}

String? _jsonMessage(List<int> bytes) {
  if (bytes.isEmpty) return null;
  try {
    final text = utf8.decode(bytes, allowMalformed: true).trimLeft();
    if (!text.startsWith('{')) return null;
    final decoded = jsonDecode(text);
    if (decoded is! Map) return null;
    final status = decoded['status'];
    final failed = status == false || status == 0 || status == 'false';
    if (!failed) return null;
    final message = readString(decoded['message']);
    if (message.isNotEmpty &&
        message.length <= 160 &&
        !message.contains('http')) {
      return message;
    }
    return 'Could not download this document.';
  } catch (_) {
    return null;
  }
}
