import 'dart:convert';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Debug-only logger for outbound POST requests via [ApiService.postAPI].
class ApiPostLogger {
  ApiPostLogger._();

  static const _maxBodyChars = 12000;
  static const _largeValueChars = 500;
  static const _consolePreviewLines = 40;
  static const _consoleLineChars = 1000;

  static int _requestCounter = 0;

  static final _sensitiveHeaderKeys = {
    'token',
    'authorization',
    'x-session-token',
    'cookie',
    'set-cookie',
  };

  static final _sensitiveFieldKeys = {
    'token',
    'password',
    'fcm_token',
    'fcmtoken',
    'authorization',
    'refresh_token',
    'secret',
    'api_key',
    'apikey',
  };

  static final _largePayloadFieldKeys = {
    'avatar_file',
    'profile_image',
    'cv_file',
    'cover_letter',
    'file',
    'image',
    'photo',
    'document',
    'attachment',
  };

  /// Logs a POST request and returns a request id for matching responses.
  static int logRequest({
    required String url,
    required Map<String, dynamic> headers,
    dynamic body,
  }) {
    if (!kDebugMode) return 0;

    final requestId = ++_requestCounter;
    final startedAt = DateTime.now();

    debugPrint('[ApiHttp] → POST #$requestId $url');

    try {
      final buffer = StringBuffer()
        ..writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
        ..writeln('➜ REQUEST #$requestId  POST $url')
        ..writeln('  at: ${startedAt.toIso8601String()}')
        ..writeln('  headers: ${_prettyEncode(_sanitizeHeaders(headers))}')
        ..writeln('  payload: ${_formatData(body)}');

      _emitLog(buffer.toString());
    } catch (e, stackTrace) {
      debugPrint('[ApiHttp] POST #$requestId $url — request log failed: $e');
      developer.log(
        'POST request log failed: $e\n$stackTrace',
        name: 'ApiHttp',
      );
    }

    return requestId;
  }

  static void logResponse({
    required int requestId,
    required String url,
    required int? statusCode,
    required dynamic body,
    required int elapsedMs,
    Map<String, List<String>>? responseHeaders,
  }) {
    if (!kDebugMode || requestId == 0) return;

    debugPrint(
      '[ApiHttp] ← POST #$requestId $statusCode ${elapsedMs}ms $url',
    );

    try {
      final respHeaderMap = <String, dynamic>{};
      responseHeaders?.forEach((key, values) {
        respHeaderMap[key] = values.join(', ');
      });

      final buffer = StringBuffer()
        ..writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
        ..writeln('✔ RESPONSE #$requestId  POST $url')
        ..writeln('  status: $statusCode')
        ..writeln('  elapsed_ms: $elapsedMs')
        ..writeln(
          '  response_headers: ${_prettyEncode(_sanitizeHeaders(respHeaderMap))}',
        )
        ..writeln('  body: ${_truncate(_formatData(body))}');

      _emitLog(buffer.toString());
    } catch (e, stackTrace) {
      debugPrint('[ApiHttp] POST #$requestId $url — response log failed: $e');
      developer.log(
        'POST response log failed: $e\n$stackTrace',
        name: 'ApiHttp',
      );
    }
  }

  static void logError({
    required int requestId,
    required String url,
    required DioException error,
    required int elapsedMs,
    dynamic requestBody,
  }) {
    if (!kDebugMode || requestId == 0) return;

    debugPrint('[ApiHttp] ✖ POST #$requestId $url — ${error.type}');

    try {
      final response = error.response;
      final buffer = StringBuffer()
        ..writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
        ..writeln('✖ ERROR #$requestId  POST $url')
        ..writeln('  type: ${error.type}')
        ..writeln('  message: ${error.message}')
        ..writeln('  underlying: ${_formatUnderlyingError(error)}')
        ..writeln('  elapsed_ms: $elapsedMs');

      if (response != null) {
        buffer
          ..writeln('  status: ${response.statusCode}')
          ..writeln('  body: ${_truncate(_formatData(response.data))}');
      }

      buffer.writeln('  request_payload: ${_formatData(requestBody)}');
      _emitLog(buffer.toString());
    } catch (e, stackTrace) {
      debugPrint('[ApiHttp] POST #$requestId $url — error log failed: $e');
      developer.log(
        'POST error log failed: $e\n$stackTrace',
        name: 'ApiHttp',
      );
    }
  }

  /// Safe one-line summary for service-level logs.
  static String summarizePayload(dynamic data) {
    try {
      return _formatData(data).replaceAll('\n', ' ');
    } catch (e) {
      return '(unable to summarize payload: $e)';
    }
  }

  static void _emitLog(String message) {
    developer.log(message, name: 'ApiHttp');

    if (!kDebugMode) return;

    final lines = message.split('\n');
    final previewCount = lines.length > _consolePreviewLines
        ? _consolePreviewLines
        : lines.length;

    for (var i = 0; i < previewCount; i++) {
      final line = lines[i];
      final clipped = line.length > _consoleLineChars
          ? '${line.substring(0, _consoleLineChars)}…'
          : line;
      debugPrint('[ApiHttp] $clipped');
    }

    if (lines.length > previewCount) {
      debugPrint(
        '[ApiHttp] … ${lines.length - previewCount} more lines (DevTools filter: ApiHttp)',
      );
    }
  }

  static Map<String, dynamic> _sanitizeHeaders(Map<String, dynamic> raw) {
    final out = <String, dynamic>{};
    raw.forEach((key, value) {
      final lower = key.toLowerCase();
      final display = _headerValueToString(value);
      if (_sensitiveHeaderKeys.contains(lower)) {
        out[key] = _maskSecret(display);
      } else {
        out[key] = display;
      }
    });
    return out;
  }

  static String _headerValueToString(dynamic value) {
    if (value == null) return '';
    if (value is Iterable && value is! String) {
      return value.map((e) => e.toString()).join(', ');
    }
    return value.toString();
  }

  static String _prettyEncode(Object? value) {
    if (value == null || (value is Map && value.isEmpty)) {
      return '{}';
    }
    try {
      const encoder = JsonEncoder.withIndent('  ');
      if (value is Map) {
        return encoder.convert(_deepRedactMap(Map<String, dynamic>.from(value)));
      }
      return encoder.convert(value);
    } catch (_) {
      return value.toString();
    }
  }

  static Map<String, dynamic> _deepRedactMap(Map<String, dynamic> map) {
    final out = <String, dynamic>{};
    map.forEach((key, val) {
      final lower = key.toLowerCase();
      if (_sensitiveFieldKeys.contains(lower)) {
        out[key] = _maskSecret(val?.toString());
      } else if (_shouldSummarizeField(key, val)) {
        out[key] = _summarizeLargeValue(val);
      } else if (val is Map<String, dynamic>) {
        out[key] = _deepRedactMap(val);
      } else if (val is Map) {
        out[key] = _deepRedactMap(Map<String, dynamic>.from(val));
      } else if (val is List) {
        out[key] = val.map(_deepRedactValue).toList();
      } else if (val is String && val.length > _largeValueChars) {
        out[key] = _summarizeLargeValue(val);
      } else {
        out[key] = val;
      }
    });
    return out;
  }

  static dynamic _deepRedactValue(dynamic value) {
    if (value is Map) {
      return _deepRedactMap(Map<String, dynamic>.from(value));
    }
    if (value is String && value.length > _largeValueChars) {
      return _summarizeLargeValue(value);
    }
    return value;
  }

  static String _formatData(dynamic data) {
    if (data == null) return '(empty)';

    if (data is FormData) {
      final buf = StringBuffer('FormData:\n');
      for (final e in data.fields) {
        buf.writeln('    ${_redactField(e.key, e.value)}');
      }
      for (final e in data.files) {
        final file = e.value;
        buf.writeln(
          '    ${e.key}: [MultipartFile filename=${file.filename ?? '?'}]',
        );
      }
      return buf.toString().trimRight();
    }

    if (data is Map) {
      return _prettyEncode(Map<String, dynamic>.from(data));
    }

    if (data is String) {
      final trimmed = data.trim();
      if ((trimmed.startsWith('{') && trimmed.endsWith('}')) ||
          (trimmed.startsWith('[') && trimmed.endsWith(']'))) {
        try {
          final decoded = jsonDecode(data);
          return _prettyEncode(
            decoded is Map ? Map<String, dynamic>.from(decoded) : decoded,
          );
        } catch (_) {
          /* fall through */
        }
      }
      return _truncate(data);
    }

    return _truncate(data.toString());
  }

  static String _redactField(String key, String value) {
    if (_sensitiveFieldKeys.contains(key.toLowerCase())) {
      return '$key: ${_maskSecret(value)}';
    }
    if (_shouldSummarizeField(key, value)) {
      return '$key: ${_summarizeLargeValue(value)}';
    }
    return '$key: $value';
  }

  static bool _shouldSummarizeField(String key, dynamic value) {
    if (value is! String) return false;
    final lower = key.toLowerCase();
    if (_largePayloadFieldKeys.contains(lower)) return true;
    if (lower.contains('file') ||
        lower.contains('image') ||
        lower.contains('photo') ||
        lower.contains('avatar')) {
      return true;
    }
    return value.length > _largeValueChars;
  }

  static String _summarizeLargeValue(dynamic value) {
    final text = value?.toString() ?? '';
    if (text.isEmpty) return '[empty]';
    if (text.length <= _largeValueChars) return text;

    final previewLength = text.length < 120 ? text.length : 120;
    final preview = text.substring(0, previewLength);
    return '[${text.length} chars] $preview…';
  }

  static String _formatUnderlyingError(DioException err) {
    final underlying = err.error;
    if (underlying == null) return '(none)';
    return '${underlying.runtimeType}: $underlying';
  }

  static String _maskSecret(String? raw) {
    if (raw == null || raw.isEmpty) return '[empty]';
    if (raw.length <= 8) return '***';
    return '${raw.substring(0, 4)}…${raw.substring(raw.length - 4)} (${raw.length} chars)';
  }

  static String _truncate(String text) {
    if (text.length <= _maxBodyChars) return text;
    return '${text.substring(0, _maxBodyChars)}\n… [truncated, ${text.length - _maxBodyChars} more chars]';
  }
}
