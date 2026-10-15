/// Centralized route paths and route names for declarative navigation and deep linking.
class AppRoutes {
  AppRoutes._();

  // ---------------------------------------------------------------------------
  // Route Paths
  // ---------------------------------------------------------------------------
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String verifyOtp = '/verify-otp';
  static const String registrationSuccess = '/registration-success';

  static const String forgotPassword = '/forgot-password';
  static const String forgotPasswordVerify = '/forgot-password-verify';
  static const String resetPassword = '/reset-password';
  static const String passwordResetSuccess = '/password-reset-success';

  static const String home = '/home';
  static const String optionalModules = '/optional-modules';

  static const String modules = '/modules';
  static const String selectTime = '/select-time';
  static const String selectQuantity = '/select-quantity';
  static const String quiz = '/quiz';
  static const String quizResult = '/quiz-result';
  static const String quizComplete = '/quiz-complete';

  static const String profile = '/profile';
  static const String editProfileOption = '/edit-profile-option';
  static const String generalSettings = '/general-settings';
  static const String privacySettings = '/privacy-settings';
  static const String aboutApp = '/about-app';
  static const String accountDelete = '/account-delete';

  // ---------------------------------------------------------------------------
  // Route Names
  // ---------------------------------------------------------------------------
  static const String splashName = 'splash';
  static const String loginName = 'login';
  static const String signupName = 'signup';
  static const String verifyOtpName = 'verifyOtp';
  static const String registrationSuccessName = 'registrationSuccess';

  static const String forgotPasswordName = 'forgotPassword';
  static const String forgotPasswordVerifyName = 'forgotPasswordVerify';
  static const String resetPasswordName = 'resetPassword';
  static const String passwordResetSuccessName = 'passwordResetSuccess';

  static const String homeName = 'home';
  static const String optionalModulesName = 'optionalModules';

  static const String modulesName = 'modules';
  static const String selectTimeName = 'selectTime';
  static const String selectQuantityName = 'selectQuantity';
  static const String quizName = 'quiz';
  static const String quizResultName = 'quizResult';
  static const String quizCompleteName = 'quizComplete';

  static const String profileName = 'profile';
  static const String editProfileOptionName = 'editProfileOption';
  static const String generalSettingsName = 'generalSettings';
  static const String privacySettingsName = 'privacySettings';
  static const String aboutAppName = 'aboutApp';
  static const String accountDeleteName = 'accountDelete';

  // ---------------------------------------------------------------------------
  // Helper Path Builders for Deep Links
  // ---------------------------------------------------------------------------
  static String verifyOtpPath({String? email}) {
    if (email != null && email.isNotEmpty) {
      return '$verifyOtp?email=${Uri.encodeComponent(email)}';
    }
    return verifyOtp;
  }

  static String forgotPasswordVerifyPath({String? email}) {
    if (email != null && email.isNotEmpty) {
      return '$forgotPasswordVerify?email=${Uri.encodeComponent(email)}';
    }
    return forgotPasswordVerify;
  }

  static String optionalModulesPath({bool isFirstLogin = false}) {
    return '$optionalModules?firstLogin=$isFirstLogin';
  }

  static String quizPath({
    String? moduleId,
    String? moduleName,
    int? totalQuestions,
    int? timeInMinutes,
  }) {
    final params = <String, String>{};
    if (moduleId != null) params['moduleId'] = moduleId;
    if (moduleName != null) params['moduleName'] = moduleName;
    if (totalQuestions != null) params['totalQuestions'] = totalQuestions.toString();
    if (timeInMinutes != null) params['timeInMinutes'] = timeInMinutes.toString();
    if (params.isEmpty) return quiz;
    return '$quiz?${Uri(queryParameters: params).query}';
  }

  static String profilePath({bool hideSettingsCard = false}) {
    if (hideSettingsCard) {
      return '$profile?hideSettingsCard=true';
    }
    return profile;
  }
}
