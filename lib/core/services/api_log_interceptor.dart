import 'dart:convert';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Logs outbound HTTP calls made through the shared [Dio] instance.
///
/// Enabled only in debug builds ([kDebugMode]) so tokens and payloads are not
/// printed in release.
class ApiLogInterceptor extends Interceptor {
  static const _maxBodyChars = 12000;

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

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!kDebugMode) {
      handler.next(options);
      return;
    }

    options.extra['_api_log_started_at'] = DateTime.now();

    final uri = options.uri;

    final buffer = StringBuffer()
      ..writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
      ..writeln('➜ REQUEST  ${options.method} $uri')
      ..writeln('  headers: ${_prettyEncode(_sanitizeHeaders(Map<String, dynamic>.from(options.headers)))}')
      ..writeln('  query: ${_prettyEncode(_deepRedactMap(Map<String, dynamic>.from(options.queryParameters)))}')
      ..writeln('  body: ${_formatData(options.data)}');

    developer.log(buffer.toString(), name: 'ApiHttp');

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      _logResponse(response, error: null);
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      final response = err.response;
      if (response != null) {
        _logResponse(response, error: err);
      } else {
        final started = err.requestOptions.extra['_api_log_started_at'] as DateTime?;
        final elapsed = started != null
            ? DateTime.now().difference(started).inMilliseconds
            : null;
        final buffer = StringBuffer()
          ..writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
          ..writeln('✖ ERROR  ${err.requestOptions.method} ${err.requestOptions.uri}')
          ..writeln('  type: ${err.type}')
          ..writeln('  message: ${err.message}')
          ..writeln(
            '  elapsed_ms: ${elapsed ?? 'n/a'}',
          );
        if (err.response?.statusCode != null) {
          buffer.writeln('  status: ${err.response!.statusCode}');
        }
        buffer.writeln('  request_body: ${_formatData(err.requestOptions.data)}');
        developer.log(buffer.toString(), name: 'ApiHttp');
      }
    }
    handler.next(err);
  }

  void _logResponse(Response response, {DioException? error}) {
    final opts = response.requestOptions;
    final started = opts.extra['_api_log_started_at'] as DateTime?;
    final elapsedMs =
        started != null ? DateTime.now().difference(started).inMilliseconds : null;

    final buffer = StringBuffer()
      ..writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    if (error != null) {
      buffer.writeln(
        '✖ RESPONSE (error)  ${opts.method} ${opts.uri}',
      );
      buffer.writeln('  dio_type: ${error.type}');
      buffer.writeln('  dio_message: ${error.message}');
    } else {
      buffer.writeln(
        '✔ RESPONSE  ${opts.method} ${opts.uri}',
      );
    }

    final respHeaderMap = <String, dynamic>{};
    response.headers.map.forEach((key, values) {
      respHeaderMap[key] = values.join(', ');
    });

    buffer
      ..writeln('  status: ${response.statusCode}')
      ..writeln('  elapsed_ms: ${elapsedMs ?? 'n/a'}')
      ..writeln(
        '  response_headers: ${_prettyEncode(_sanitizeHeaders(respHeaderMap))}',
      )
      ..writeln('  body: ${_truncate(_formatData(response.data))}');

    developer.log(buffer.toString(), name: 'ApiHttp');
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
      } else if (val is Map<String, dynamic>) {
        out[key] = _deepRedactMap(val);
      } else if (val is Map) {
        out[key] = _deepRedactMap(Map<String, dynamic>.from(val));
      } else if (val is List) {
        out[key] = val
            .map((e) =>
                e is Map ? _deepRedactMap(Map<String, dynamic>.from(e)) : e)
            .toList();
      } else {
        out[key] = val;
      }
    });
    return out;
  }

  static String _formatData(dynamic data) {
    if (data == null) return '(empty)';

    if (data is FormData) {
      final buf = StringBuffer('FormData:\n');
      for (final e in data.fields) {
        buf.writeln(
          '    ${_redactField(e.key, e.value)}',
        );
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
    return '$key: $value';
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
