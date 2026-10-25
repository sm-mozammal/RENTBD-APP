import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Next-Gen ANSI Colored Dio Logger tailored for RentBD.
/// Features vibrant Emerald Green styling for requests and responses,
/// JSON pretty-printing, elapsed roundtrip timing, and formatted box borders.
class RentBdDioLogger extends Interceptor {
  RentBdDioLogger({
    this.enabled = kDebugMode,
    this.printHeaders = true,
    this.printRequestBody = true,
    this.printResponseBody = true,
  });

  final bool enabled;
  final bool printHeaders;
  final bool printRequestBody;
  final bool printResponseBody;

  static const String _kStartTimeKey = 'rentbd_request_start_time';

  // ANSI Color Codes
  static const String _reset = '\x1B[0m';
  static const String _bold = '\x1B[1m';
  static const String _dim = '\x1B[2m';

  // Emerald Green palette (#059669 / #10B981)
  static const String _green = '\x1B[38;2;16;185;129m';
  static const String _brightGreen = '\x1B[92;1m';
  static const String _lightGreen = '\x1B[38;2;110;231;183m';

  // Accent Colors
  static const String _cyan = '\x1B[38;2;6;182;212m';
  static const String _yellow = '\x1B[38;2;245;158;11m';
  static const String _red = '\x1B[38;2;239;68;68m';
  static const String _gray = '\x1B[38;2;156;163;175m';

  final JsonEncoder _prettyJson = const JsonEncoder.withIndent('  ');

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!enabled) return handler.next(options);

    options.extra[_kStartTimeKey] = DateTime.now().millisecondsSinceEpoch;

    final buffer = StringBuffer();
    buffer.writeln('$_brightGreen╔═══════════════════════════════════════════════════════════════════════════$_reset');
    buffer.writeln('$_brightGreen║ 🌐 [RENTBD DIO REQUEST]$_reset $_bold$_lightGreen${options.method.toUpperCase()} ➔ ${options.uri}$_reset');
    buffer.writeln('$_green║ ⏱️  Timestamp: $_gray${DateTime.now().toIso8601String()}$_reset');

    if (printHeaders && options.headers.isNotEmpty) {
      final sanitizedHeaders = Map<String, dynamic>.from(options.headers);
      if (sanitizedHeaders.containsKey('Authorization')) {
        final authVal = sanitizedHeaders['Authorization'].toString();
        if (authVal.length > 25) {
          sanitizedHeaders['Authorization'] = '${authVal.substring(0, 18)}...[PROTECTED_JWT]';
        }
      }
      buffer.writeln('$_green║ 🔑 Headers: $_cyan$sanitizedHeaders$_reset');
    }

    if (options.queryParameters.isNotEmpty) {
      buffer.writeln('$_green║ 🔍 Query Params: $_cyan${options.queryParameters}$_reset');
    }

    if (printRequestBody && options.data != null) {
      buffer.writeln('$_green║ 📦 Request Body:$_reset');
      _formatBody(options.data, buffer, _lightGreen);
    }

    buffer.writeln('$_brightGreen╚═══════════════════════════════════════════════════════════════════════════$_reset');
    _log(buffer.toString());

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (!enabled) return handler.next(response);

    final durationMs = _calculateDuration(response.requestOptions);
    final status = response.statusCode ?? 200;
    final statusColor = status >= 200 && status < 300
        ? _brightGreen
        : status >= 300 && status < 400
            ? _yellow
            : _red;

    final buffer = StringBuffer();
    buffer.writeln('$statusColor╔═══════════════════════════════════════════════════════════════════════════$_reset');
    buffer.writeln('$statusColor║ ✅ [RENTBD DIO RESPONSE] ➔ $status ${response.statusMessage ?? 'OK'} ($_bold${durationMs}ms$_reset$statusColor)$_reset');
    buffer.writeln('$_green║ 🌐 URL: $_lightGreen${response.requestOptions.method.toUpperCase()} ${response.requestOptions.uri}$_reset');

    if (printResponseBody && response.data != null) {
      buffer.writeln('$_green║ 📦 Response Body:$_reset');
      _formatBody(response.data, buffer, _lightGreen);
    }

    buffer.writeln('$statusColor╚═══════════════════════════════════════════════════════════════════════════$_reset');
    _log(buffer.toString());

    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!enabled) return handler.next(err);

    final durationMs = _calculateDuration(err.requestOptions);
    final status = err.response?.statusCode;
    final statusStr = status != null ? '$status ' : '';

    final buffer = StringBuffer();
    buffer.writeln('$_red╔═══════════════════════════════════════════════════════════════════════════$_reset');
    buffer.writeln('$_red║ ❌ [RENTBD DIO ERROR] ➔ $statusStr${err.type} ($_bold${durationMs}ms$_reset$_red)$_reset');
    final detailMsg = (err.message != null && err.message!.isNotEmpty)
        ? err.message
        : (err.error?.toString() ?? 'Network error');
    buffer.writeln('$_red║ ⚠️ Message: $_yellow$detailMsg$_reset');

    if (err.response?.data != null) {
      buffer.writeln('$_red║ 📦 Error Response:$_reset');
      _formatBody(err.response!.data, buffer, _red);
    }

    buffer.writeln('$_red╚═══════════════════════════════════════════════════════════════════════════$_reset');
    _log(buffer.toString());

    return handler.next(err);
  }

  int _calculateDuration(RequestOptions options) {
    final startTime = options.extra[_kStartTimeKey] as int?;
    if (startTime == null) return 0;
    return DateTime.now().millisecondsSinceEpoch - startTime;
  }

  void _formatBody(dynamic data, StringBuffer buffer, String color) {
    if (data == null) {
      buffer.writeln('$_green║    $_dim<null>$_reset');
      return;
    }

    try {
      if (data is Map || data is List) {
        final formatted = _prettyJson.convert(data);
        for (final line in formatted.split('\n')) {
          buffer.writeln('$_green║    $color$line$_reset');
        }
      } else if (data is String) {
        try {
          final decoded = json.decode(data);
          final formatted = _prettyJson.convert(decoded);
          for (final line in formatted.split('\n')) {
            buffer.writeln('$_green║    $color$line$_reset');
          }
        } catch (_) {
          for (final line in data.split('\n')) {
            buffer.writeln('$_green║    $color$line$_reset');
          }
        }
      } else if (data is FormData) {
        buffer.writeln('$_green║    $color[FormData: ${data.fields.length} fields, ${data.files.length} files]$_reset');
        for (final field in data.fields) {
          buffer.writeln('$_green║      $color- ${field.key}: ${field.value}$_reset');
        }
        for (final file in data.files) {
          buffer.writeln('$_green║      $color- File: ${file.key} (${file.value.filename}, ${file.value.length} bytes)$_reset');
        }
      } else {
        buffer.writeln('$_green║    $color$data$_reset');
      }
    } catch (_) {
      buffer.writeln('$_green║    $color$data$_reset');
    }
  }

  void _log(String message) {
    // debugPrint avoids Android 1024-char log truncation
    debugPrint(message);
  }
}
