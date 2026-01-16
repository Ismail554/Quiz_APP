import 'package:flutter/foundation.dart';

class AppLogger {
  static void log(String message) {
    if (kDebugMode) {
      debugPrint('[LOG]: $message');
    }
  }

  static void debug(String message) {
    if (kDebugMode) {
      debugPrint('[DEBUG]: $message');
    }
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[ERROR]: $message');
      if (error != null) {
        debugPrint('Error details: $error');
      }
      if (stackTrace != null) {
        debugPrint('Stack trace: $stackTrace');
      }
    }
  }

  static String getSafeErrorMessage(String message) {
    if (message.contains('Exception') ||
        message.contains('SocketException') ||
        message.contains('HandshakeException') ||
        message.contains('ClientException')) {
      error('Sanitized error for user', message);
      return 'An unexpected error occurred. Please check your connection and try again.';
    }
    return message;
  }
}
