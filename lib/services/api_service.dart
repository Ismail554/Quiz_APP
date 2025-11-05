class ApiService {
  static String get _baseUrl =>
      "https://dihydric-yael-therianthropic.ngrok-free.dev";
  static String get baseUrl =>
      "https://dihydric-yael-therianthropic.ngrok-free.dev";

  static String get loginUrl => "$_baseUrl/auth/login/";
  static String get signupUrl => "$_baseUrl/auth/register/";
  static String get verifyOtpUrl => "$_baseUrl/auth/verify-otp/";

  static String get moduleListUrl => "$_baseUrl/student/module-list/";
  static String get timeListUrl => "$_baseUrl/student/time-list/";

    //General settings
  static String get updateProfile => "$_baseUrl/auth/profile-update/";
}
