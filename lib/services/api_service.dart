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
  static String get optionalModuleUrl => "$_baseUrl/student/optional-module/";
  static String get updateOptionalModuleUrl =>
      "$_baseUrl/student/optional-module/"; // it's a patch request

  // Auth section
  static String get deleteAccount => "$_baseUrl/auth/delete-account/";
  // Profile section
  static String get userPerformance => "$_baseUrl/student/user-performance/";

  // Forgot Password
  static String get forgotPassUrl =>
      "$_baseUrl/auth/forget-password/"; //pass the "email" to get the "passResetToken"
  static String get verifyForgotPassOtpUrl =>
      "$_baseUrl/auth/forget-password-otp-verify/"; // pass the "passResetToken" and otp and get "passwordResetVerified"
  static String get newPasswordSet =>
      "$_baseUrl/auth/forget-password-set/"; // pass the "passwordResetVerified" and "new_password" to reset password
  static String get resendOtpUrl =>
      "$_baseUrl/auth/forget-password-resend/"; // pass the "passResetToken" to resend otp
}
