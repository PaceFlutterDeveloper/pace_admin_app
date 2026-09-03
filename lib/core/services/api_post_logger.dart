import 'dart:convert';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Debug-only structured HTTP logger.
///
/// Filter the debug console / DevTools by the log name `API`.
/// Each call is tagged with a monotonic id so request, response, and error
/// lines can be matched even when calls overlap.
class ApiPostLogger {
  ApiPostLogger._();

  static const logName = 'API';

  static const _maxBodyChars = 12000;
  static const _largeValueChars = 500;
  static const _rule =
      '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
  static const _thinRule =
      '────────────────────────────────────────────────────────────';

  static const _extraRequestId = 'api_http_log_id';
  static const _extraStartedAt = 'api_http_log_started_at';

  static int _requestCounter = 0;

  static final _sensitiveHeaderKeys = {
    'cookie',
    'set-cookie',
  };

  static final _authHeaderKeys = {
    'authorization',
    'token',
    'x-session-token',
    'x-api-key',
    'api-key',
  };

  static final _sensitiveFieldKeys = {
    'password',
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

  /// Attach to the shared [Dio] instance so every method is logged the same way.
  static Interceptor get interceptor => _ApiHttpInterceptor();

  /// Logs an outbound request and returns a request id for matching responses.
  static int logRequest({
    required String method,
    required String url,
    required Map<String, dynamic> headers,
    dynamic body,
    Map<String, dynamic>? queryParameters,
    String? contentType,
    String? formBoundary,
  }) {
    if (!kDebugMode) return 0;

    final requestId = ++_requestCounter;
    final startedAt = DateTime.now();
    final endpoint = _shortEndpoint(url);

    try {
      final buffer = StringBuffer()
        ..writeln(_rule)
        ..writeln(
          '▶ API REQUEST  ${_idLabel(requestId)}  ${method.toUpperCase()}  $endpoint',
        )
        ..writeln(_rule)
        ..writeln('Time:     ${startedAt.toIso8601String()}')
        ..writeln('Method:   ${method.toUpperCase()}')
        ..writeln('URL:      $url')
        ..writeln('Content:  ${_contentSummary(headers, contentType, body)}')
        ..writeln('Auth:     ${_authSummary(headers)}');

      if (queryParameters != null && queryParameters.isNotEmpty) {
        buffer
          ..writeln(_thinRule)
          ..writeln('Query (${queryParameters.length}):');
        queryParameters.forEach((key, value) {
          buffer.writeln('  $key = $value');
        });
      }

      buffer
        ..writeln(_thinRule)
        ..write(
          _formatHeadersBlock(
            'Request headers',
            headers,
            contentType: contentType,
            formBoundary: formBoundary,
          ),
        )
        ..writeln(_thinRule)
        ..writeln('Request body:')
        ..writeln(_indentBlock(_formatData(body)))
        ..writeln(_rule);

      _emitLog(buffer.toString());
    } catch (e, stackTrace) {
      developer.log(
        'API request log failed: $e\n$stackTrace',
        name: logName,
      );
    }

    return requestId;
  }

  static void logResponse({
    required int requestId,
    required String method,
    required String url,
    required int? statusCode,
    required dynamic body,
    required int elapsedMs,
    String? statusMessage,
    Map<String, List<String>>? responseHeaders,
  }) {
    if (!kDebugMode || requestId == 0) return;

    try {
      final endpoint = _shortEndpoint(url);
      final ok = statusCode != null && statusCode >= 200 && statusCode < 300;
      final marker = ok ? '◀' : '!';
      final bodyText = _truncate(_formatData(body));

      final buffer = StringBuffer()
        ..writeln(_rule)
        ..writeln(
          '$marker API RESPONSE  ${_idLabel(requestId)}  ${method.toUpperCase()}  $endpoint  →  ${_statusLine(statusCode, statusMessage)}  (${elapsedMs}ms)',
        )
        ..writeln(_rule)
        ..writeln('URL:      $url')
        ..writeln('Status:   ${_statusLine(statusCode, statusMessage)}')
        ..writeln('Elapsed:  ${elapsedMs}ms')
        ..writeln('Size:     ${_sizeLabel(bodyText)}')
        ..writeln(_thinRule)
        ..write(_formatHeadersBlock('Response headers', _flattenHeaders(responseHeaders)))
        ..writeln(_thinRule)
        ..writeln('Response body:')
        ..writeln(_indentBlock(bodyText))
        ..writeln(_rule);

      _emitLog(buffer.toString());
    } catch (e, stackTrace) {
      developer.log(
        'API response log failed: $e\n$stackTrace',
        name: logName,
      );
    }
  }

  static void logError({
    required int requestId,
    required String method,
    required String url,
    required DioException error,
    required int elapsedMs,
    dynamic requestBody,
    Map<String, dynamic>? requestHeaders,
  }) {
    if (!kDebugMode || requestId == 0) return;

    try {
      final endpoint = _shortEndpoint(url);
      final response = error.response;
      final respHeaders = response?.headers.map;

      final buffer = StringBuffer()
        ..writeln(_rule)
        ..writeln(
          '✖ API ERROR  ${_idLabel(requestId)}  ${method.toUpperCase()}  $endpoint  (${elapsedMs}ms)',
        )
        ..writeln(_rule)
        ..writeln('URL:         $url')
        ..writeln('Elapsed:     ${elapsedMs}ms')
        ..writeln('Dio type:    ${error.type}')
        ..writeln('Message:     ${error.message}')
        ..writeln('Underlying:  ${_formatUnderlyingError(error)}');

      if (requestHeaders != null) {
        buffer
          ..writeln(_thinRule)
          ..write(_formatHeadersBlock('Request headers', requestHeaders));
      }

      buffer
        ..writeln(_thinRule)
        ..writeln('Request body:')
        ..writeln(_indentBlock(_formatData(requestBody)));

      if (response != null) {
        buffer
          ..writeln(_thinRule)
          ..writeln(
            'HTTP status: ${_statusLine(response.statusCode, response.statusMessage)}',
          )
          ..write(
            _formatHeadersBlock(
              'Response headers',
              _flattenHeaders(respHeaders),
            ),
          )
          ..writeln('Response body:')
          ..writeln(_indentBlock(_truncate(_formatData(response.data))));
      } else {
        buffer
          ..writeln(_thinRule)
          ..writeln('No HTTP response (request did not reach a usable reply).');
      }

      buffer.writeln(_rule);
      _emitLog(buffer.toString());
    } catch (e, stackTrace) {
      developer.log(
        'API error log failed: $e\n$stackTrace',
        name: logName,
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

  static void captureRequest(RequestOptions options) {
    if (!kDebugMode) return;

    String? boundary;
    final data = options.data;
    if (data is FormData) {
      boundary = data.boundary;
    }

    final id = logRequest(
      method: options.method,
      url: options.uri.toString(),
      headers: Map<String, dynamic>.from(options.headers),
      body: data,
      queryParameters: options.queryParameters,
      contentType: options.contentType,
      formBoundary: boundary,
    );
    options.extra[_extraRequestId] = id;
    options.extra[_extraStartedAt] = DateTime.now();
  }

  static void captureResponse(Response<dynamic> response) {
    if (!kDebugMode) return;

    final options = response.requestOptions;
    final requestId = options.extra[_extraRequestId] as int? ?? 0;
    logResponse(
      requestId: requestId,
      method: options.method,
      url: options.uri.toString(),
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      body: response.data,
      elapsedMs: _elapsedMs(options),
      responseHeaders: response.headers.map,
    );
  }

  static void captureError(DioException error) {
    if (!kDebugMode) return;

    final options = error.requestOptions;
    final requestId = options.extra[_extraRequestId] as int? ?? 0;
    logError(
      requestId: requestId,
      method: options.method,
      url: options.uri.toString(),
      error: error,
      elapsedMs: _elapsedMs(options),
      requestBody: options.data,
      requestHeaders: Map<String, dynamic>.from(options.headers),
    );
  }

  static int _elapsedMs(RequestOptions options) {
    final started = options.extra[_extraStartedAt];
    if (started is DateTime) {
      return DateTime.now().difference(started).inMilliseconds;
    }
    return 0;
  }

  static void _emitLog(String message) {
    developer.log(message.trimRight(), name: logName);
  }

  static String _idLabel(int requestId) =>
      '#${requestId.toString().padLeft(4, '0')}';

  static String _shortEndpoint(String url) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
      var label = segments.isEmpty ? uri.host : segments.last;
      if (label == 'index.php' && uri.queryParameters.containsKey('page')) {
        label = 'index.php?page=${uri.queryParameters['page']}';
      } else if (uri.queryParameters.containsKey('page')) {
        label = '$label?page=${uri.queryParameters['page']}';
      }
      return label;
    } catch (_) {
      return url;
    }
  }

  static String _statusLine(int? statusCode, String? statusMessage) {
    if (statusCode == null) return '(no status)';
    final phrase = (statusMessage != null && statusMessage.trim().isNotEmpty)
        ? statusMessage.trim()
        : _statusPhrase(statusCode);
    return phrase.isEmpty ? '$statusCode' : '$statusCode $phrase';
  }

  static String _statusPhrase(int code) {
    switch (code) {
      case 200:
        return 'OK';
      case 201:
        return 'Created';
      case 204:
        return 'No Content';
      case 400:
        return 'Bad Request';
      case 401:
        return 'Unauthorized';
      case 403:
        return 'Forbidden';
      case 404:
        return 'Not Found';
      case 409:
        return 'Conflict';
      case 422:
        return 'Unprocessable Entity';
      case 500:
        return 'Internal Server Error';
      case 502:
        return 'Bad Gateway';
      case 503:
        return 'Service Unavailable';
      default:
        return '';
    }
  }

  static String _sizeLabel(String text) {
    if (text == '(empty)') return 'empty';
    return '${text.length} chars';
  }

  static String _contentSummary(
    Map<String, dynamic> headers,
    String? contentType,
    dynamic body,
  ) {
    final headerType = _headerValue(headers, 'content-type');
    if (contentType != null && contentType.isNotEmpty) return contentType;
    if (headerType != null && headerType.isNotEmpty) return headerType;
    if (body is FormData) {
      return 'multipart/form-data; boundary=${body.boundary}';
    }
    if (body is Map) return 'application/json (inferred from Map body)';
    if (body == null) return '(none)';
    return body.runtimeType.toString();
  }

  static String _authSummary(Map<String, dynamic> headers) {
    final found = <String>[];
    headers.forEach((key, value) {
      if (!_authHeaderKeys.contains(key.toLowerCase())) return;
      final raw = _headerValueToString(value);
      if (raw.isEmpty) {
        found.add('$key=(empty)');
      } else {
        found.add('$key (${raw.length} chars)');
      }
    });
    if (found.isEmpty) return '(none)';
    return found.join(' | ');
  }

  static String? _headerValue(Map<String, dynamic> headers, String name) {
    for (final entry in headers.entries) {
      if (entry.key.toLowerCase() == name) {
        final value = _headerValueToString(entry.value);
        if (value.isNotEmpty) return value;
      }
    }
    return null;
  }

  static Map<String, dynamic> _flattenHeaders(
    Map<String, List<String>>? headers,
  ) {
    final out = <String, dynamic>{};
    headers?.forEach((key, values) {
      out[key] = values.join(', ');
    });
    return out;
  }

  static String _formatHeadersBlock(
    String title,
    Map<String, dynamic> raw, {
    String? contentType,
    String? formBoundary,
  }) {
    final merged = <String, dynamic>{};
    raw.forEach((key, value) {
      merged[key] = _headerValueToString(value);
    });
    if (contentType != null && contentType.isNotEmpty) {
      final hasContentType =
          merged.keys.any((key) => key.toLowerCase() == 'content-type');
      if (!hasContentType) {
        merged['Content-Type'] = contentType;
      }
    }

    final buffer = StringBuffer()..writeln('$title (${merged.length}):');
    if (merged.isEmpty) {
      buffer.writeln('  (none)');
    } else {
      final keys = merged.keys.toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      var width = 0;
      for (final key in keys) {
        if (key.length > width) width = key.length;
      }
      if (width > 28) width = 28;

      for (final key in keys) {
        final label = key.length > width ? key : key.padRight(width);
        buffer.writeln('  $label  ${_displayHeaderValue(key, merged[key])}');
      }
    }

    if (formBoundary != null && formBoundary.isNotEmpty) {
      buffer.writeln('  FormData boundary: $formBoundary');
    }
    return buffer.toString();
  }

  static String _displayHeaderValue(String key, dynamic value) {
    final display = _headerValueToString(value);
    if (display.isEmpty) return '(empty)';
    if (_sensitiveHeaderKeys.contains(key.toLowerCase())) {
      return _maskSecret(display);
    }
    return display;
  }

  static String _headerValueToString(dynamic value) {
    if (value == null) return '';
    if (value is Iterable && value is! String) {
      return value.map((e) => e.toString()).join(', ');
    }
    return value.toString();
  }

  static String _indentBlock(String text) {
    if (text.isEmpty) return '  (empty)';
    return text.split('\n').map((line) => '  $line').join('\n');
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
      final buf = StringBuffer('FormData:');
      buf.writeln();
      if (data.fields.isEmpty && data.files.isEmpty) {
        buf.writeln('    (no fields or files)');
      }
      for (final e in data.fields) {
        buf.writeln('    ${_redactField(e.key, e.value)}');
      }
      for (final e in data.files) {
        final file = e.value;
        final contentType =
            file.contentType?.mimeType ?? file.contentType?.toString() ?? '?';
        buf.writeln(
          '    ${e.key}: MultipartFile  filename=${file.filename ?? '?'}  '
          'bytes=${file.length}  contentType=$contentType',
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

class _ApiHttpInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    ApiPostLogger.captureRequest(options);
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    ApiPostLogger.captureResponse(response);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    ApiPostLogger.captureError(err);
    handler.next(err);
  }
}
