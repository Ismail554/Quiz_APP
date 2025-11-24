class ApiService {
  static String get _baseUrl => "https://honeybee-one-octopus.ngrok-free.app";
  static String get baseUrl => "https://honeybee-one-octopus.ngrok-free.app";

  static String get loginUrl => "$_baseUrl/auth/login/";
  static String get signupUrl => "$_baseUrl/auth/register/";
  static String get verifyOtpUrl => "$_baseUrl/auth/verify-otp/";

  //General settings
  static String get updateProfile => "$_baseUrl/auth/profile-update/";
  //Privacy settings
  static String get updatePrivacy => "$_baseUrl/auth/password-update/";

  // Homepage
  static String get getProfile => "$_baseUrl/auth/profile-update/";
  static String get userState => "$_baseUrl/student/student-state/";

  // Module section
  static String get timeListUrl => "$_baseUrl/student/time-list/";
  static String get moduleListUrl => "$_baseUrl/student/module-list/";
  static String get quizStartUrl => "$_baseUrl/student/quiz-start/";
  static String get quizFinishUrl => "$_baseUrl/student/quiz-finish/";
  static String get deleteXpUrl => "$_baseUrl/student/delete-xp/";

  // Auth section
  static String get deleteAccount => "$_baseUrl/auth/delete-account/";
  // Profile section
  static String get userPerformance => "$_baseUrl/student/user-performance/";
}
