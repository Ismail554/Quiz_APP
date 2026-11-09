import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  /// Raw base host URL from environment (default: https://geographygeyser.tech)
  static String get _rawBaseUrl {
    final envUrl =
        (dotenv.env['API_BASE_URL'] ?? "https://geographygeyser.tech").trim();
    return envUrl.endsWith('/')
        ? envUrl.substring(0, envUrl.length - 1)
        : envUrl;
  }

  /// Base URL for authentication endpoints (Spec Section 1 & 3)
  /// Resolves to https://geographygeyser.tech/api/v1/auth with support for local /auth/ alias
  static String get authBaseUrl {
    final base = _rawBaseUrl;
    if (base.endsWith('/api/v1/auth') || base.endsWith('/auth')) {
      return base;
    }
    if (base.endsWith('/api/v1')) {
      return "$base/auth";
    }
    return "$base/api/v1/auth";
  }

  /// Base URL for student and quiz endpoints
  static String get apiBaseUrl {
    final base = _rawBaseUrl;
    if (base.endsWith('/api/v1/auth')) {
      return base.substring(0, base.length - '/api/v1/auth'.length);
    }
    if (base.endsWith('/auth')) {
      return base.substring(0, base.length - '/auth'.length);
    }
    return base;
  }

  // Backward compatibility getters
  static String get baseUrl => _rawBaseUrl;
  static String get _baseUrl => apiBaseUrl;

  // ---------------------------------------------------------------------------
  // Auth Endpoints (Spec 3.1 - 3.13)
  // ---------------------------------------------------------------------------
  static String get loginUrl => "$authBaseUrl/login/";
  static String get signupUrl => "$authBaseUrl/register/";
  static String get verifyOtpUrl => "$authBaseUrl/verify-otp/";
  static String get googleLoginUrl => "$authBaseUrl/email/";
  static String get appleLoginUrl => "$authBaseUrl/apple/";
  static String get refreshToken => "$authBaseUrl/access-token/";
  static String get meUrl => "$authBaseUrl/me/";
  static String get logoutUrl => "$authBaseUrl/logout/";
  static String get deleteAccount => "$authBaseUrl/delete-account/";

  // Forgot Password Flow (Spec 3.4 - 3.6)
  static String get forgotPassUrl => "$authBaseUrl/forget-password/";
  static String get verifyForgotPassOtpUrl =>
      "$authBaseUrl/forget-password-otp-verify/";
  static String get newPasswordSet => "$authBaseUrl/forget-password-set/";

  // Settings / Profile
  static String get updatePrivacy => "$authBaseUrl/password-update/";
  static String get updateProfile => "$authBaseUrl/profile-update/";
  static String get getProfile => "$authBaseUrl/profile-update/";

  // ---------------------------------------------------------------------------
  // Student & Module Section
  // ---------------------------------------------------------------------------
  static String get userState => "$apiBaseUrl/student/student-state/";
  static String get timeListUrl => "$apiBaseUrl/student/time-list/";
  static String get moduleListUrl => "$apiBaseUrl/student/module-list/";
  static String get quizStartUrl => "$apiBaseUrl/student/quiz-start/";
  static String get quizFinishUrl => "$apiBaseUrl/student/quiz-finish/";
  static String get deleteXpUrl => "$apiBaseUrl/student/delete-xp/";
  static String get optionalModuleUrl => "$apiBaseUrl/student/optional-module/";
  static String get updateOptionalModuleUrl =>
      "$apiBaseUrl/student/optional-module/";
  static String get synopticQuizStartUrl =>
      "$apiBaseUrl/student/synoptic-quiz-start/";
  static String get userPerformance => "$apiBaseUrl/student/user-performance/";
}
