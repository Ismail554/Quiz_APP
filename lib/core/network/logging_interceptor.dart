import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Clean console logging interceptor with ANSI color formatting.
class LoggingInterceptor extends Interceptor {
  const LoggingInterceptor();

  // ANSI Escape Codes for colored terminal output
  static const String _ansiReset = '\x1B[0m';
  static const String _ansiCyan = '\x1B[36m';
  static const String _ansiGreen = '\x1B[32m';
  static const String _ansiRed = '\x1B[31m';

  static void _log(String message, {String color = _ansiReset}) {
    if (kDebugMode) {
      for (final line in message.split('\n')) {
        debugPrint('$color$line$_ansiReset');
      }
    }
  }

  static String _prettyFormat(dynamic data) {
    if (data == null) return 'null';
    try {
      if (data is Map || data is List) {
        return const JsonEncoder.withIndent('  ').convert(data);
      }
      if (data is String) {
        try {
          final decoded = jsonDecode(data);
          return const JsonEncoder.withIndent('  ').convert(decoded);
        } catch (_) {
          return data;
        }
      }
      if (data is FormData) {
        final fields = {for (var entry in data.fields) entry.key: entry.value};
        final files = data.files
            .map((e) => {
                  'field': e.key,
                  'filename': e.value.filename,
                  'length': e.value.length,
                  'contentType': e.value.contentType?.toString(),
                })
            .toList();
        return const JsonEncoder.withIndent('  ').convert({
          'fields': fields,
          'files': files,
        });
      }
      return data.toString();
    } catch (_) {
      return data.toString();
    }
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final method = options.method.toUpperCase();
    final url = options.uri.toString();

    _log('╔══════════════════════ [API REQUEST] ══════════════════════', color: _ansiCyan);
    _log('║ METHOD: $method', color: _ansiCyan);
    _log('║ URL: $url', color: _ansiCyan);

    if (options.headers.isNotEmpty) {
      final sanitizedHeaders = Map<String, dynamic>.from(options.headers);
      if (sanitizedHeaders.containsKey('Authorization')) {
        final auth = sanitizedHeaders['Authorization'].toString();
        sanitizedHeaders['Authorization'] = auth.length > 25
            ? '${auth.substring(0, 15)}... (token protected)'
            : 'Bearer ***';
      }
      _log('║ Headers: ${_prettyFormat(sanitizedHeaders)}', color: _ansiCyan);
    }

    if (options.queryParameters.isNotEmpty) {
      _log('║ Query Params: ${_prettyFormat(options.queryParameters)}', color: _ansiCyan);
    }

    if (options.data != null) {
      _log('║ Body:\n${_prettyFormat(options.data)}', color: _ansiCyan);
    }

    _log('╚══════════════════════════════════════════════════════════════', color: _ansiCyan);
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final url = response.requestOptions.uri.toString();
    final statusCode = response.statusCode;
    final method = response.requestOptions.method.toUpperCase();

    _log('╔══════════════════════ [API RESPONSE] ══════════════════════', color: _ansiGreen);
    _log('║ [$statusCode] $method $url', color: _ansiGreen);
    _log('║ Response Body:\n${_prettyFormat(response.data)}', color: _ansiGreen);
    _log('╚══════════════════════════════════════════════════════════════', color: _ansiGreen);

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final url = err.requestOptions.uri.toString();
    final statusCode = err.response?.statusCode ?? 'NO STATUS';
    final method = err.requestOptions.method.toUpperCase();

    _log('╔═══════════════════════ [API ERROR] ═══════════════════════', color: _ansiRed);
    _log('║ [$statusCode] $method $url', color: _ansiRed);
    _log('║ Type: ${err.type.name}', color: _ansiRed);
    _log('║ Message: ${err.message}', color: _ansiRed);

    if (err.response?.data != null) {
      _log('║ Response Error Body:\n${_prettyFormat(err.response?.data)}', color: _ansiRed);
    }

    _log('╚══════════════════════════════════════════════════════════════', color: _ansiRed);
    super.onError(err, handler);
  }
}
