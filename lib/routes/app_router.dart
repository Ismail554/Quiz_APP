import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/data/static_curriculum_data.dart';
import 'package:geography_geyser/core/data/static_youtube_data.dart';
import 'package:geography_geyser/core/font_manager.dart';
import 'package:geography_geyser/main.dart';
import 'package:geography_geyser/routes/app_routes.dart';
import 'package:geography_geyser/secure_storage/secure_storage_helper.dart';
import 'package:geography_geyser/services/pending_deep_link_service.dart';
import 'package:geography_geyser/splash/splash_screen.dart';
import 'package:geography_geyser/views/auth/forgot_pass/congratulations.dart';
import 'package:geography_geyser/views/auth/forgot_pass/forget_pass_screen.dart';
import 'package:geography_geyser/views/auth/forgot_pass/new_pass.dart';
import 'package:geography_geyser/views/auth/forgot_pass/verify_screen.dart';
import 'package:geography_geyser/views/auth/login/login.dart';
import 'package:geography_geyser/views/auth/sign_up/geo_sign_up.dart';
import 'package:geography_geyser/views/auth/sign_up/reg_congratulations.dart';
import 'package:geography_geyser/views/auth/sign_up/verify_otp.dart';
import 'package:geography_geyser/views/home/homepage.dart';
import 'package:geography_geyser/views/home/op_mod_settings.dart';
import 'package:geography_geyser/views/modules/module_home.dart';
import 'package:geography_geyser/views/modules/quiz_complete.dart';
import 'package:geography_geyser/views/modules/quiz_result.dart';
import 'package:geography_geyser/views/modules/quiz_screen.dart';
import 'package:geography_geyser/views/modules/select_quantity.dart';
import 'package:geography_geyser/views/modules/select_time.dart';
import 'package:geography_geyser/views/modules/specification/eq_selection_screen.dart';
import 'package:geography_geyser/views/modules/specification/spec_module_list_screen.dart';
import 'package:geography_geyser/views/modules/specification/sub_quiz_selection_screen.dart';
import 'package:geography_geyser/views/modules/youtube/youtube_quiz_list_screen.dart';
import 'package:geography_geyser/views/profile/account_delete.dart';
import 'package:geography_geyser/views/profile/edit_profile_op.dart';
import 'package:geography_geyser/views/profile/profile_screen.dart';
import 'package:geography_geyser/views/profile/settings/app_info.dart';
import 'package:geography_geyser/views/profile/settings/general_settings.dart';
import 'package:geography_geyser/views/profile/settings/privacy_settings.dart';

CustomTransitionPage<void> _buildSlideTransition({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 240),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.04, 0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// Global GoRouter instance configured with deep linking, auth preservation, and V2 routes
final GoRouter appRouter = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: true,
  redirect: (context, state) async {
    final path = state.uri.path;
    final isQuizDeepLink =
        path == AppRoutes.quiz || path.startsWith('${AppRoutes.quiz}/');

    if (isQuizDeepLink) {
      final token = await SecureStorageHelper.getToken();
      final refreshToken = await SecureStorageHelper.getRefreshToken();
      final isAuthenticated =
          (token != null && token.isNotEmpty) ||
          (refreshToken != null && refreshToken.isNotEmpty);

      if (!isAuthenticated) {
        await PendingDeepLinkService.setPendingRoute(state.uri.toString());
        return AppRoutes.login;
      }
    }
    return null;
  },
  routes: [
    // -------------------------------------------------------------------------
    // Splash & Auth Routes
    // -------------------------------------------------------------------------
    GoRoute(
      path: AppRoutes.splash,
      name: AppRoutes.splashName,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      name: AppRoutes.loginName,
      pageBuilder: (context, state) => _buildSlideTransition(
        key: state.pageKey,
        child: const LoginScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.signup,
      name: AppRoutes.signupName,
      pageBuilder: (context, state) => _buildSlideTransition(
        key: state.pageKey,
        child: const GeoSignUpScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.verifyOtp,
      name: AppRoutes.verifyOtpName,
      pageBuilder: (context, state) {
        final email =
            state.uri.queryParameters['email'] ??
            (state.extra is String
                ? state.extra as String
                : (state.extra as Map?)?['email'] as String?);
        return _buildSlideTransition(
          key: state.pageKey,
          child: VerifyOtpScreen(email: email),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.registrationSuccess,
      name: AppRoutes.registrationSuccessName,
      pageBuilder: (context, state) => _buildSlideTransition(
        key: state.pageKey,
        child: const RegCongratulations_Screen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      name: AppRoutes.forgotPasswordName,
      pageBuilder: (context, state) => _buildSlideTransition(
        key: state.pageKey,
        child: const PassResetScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.forgotPasswordVerify,
      name: AppRoutes.forgotPasswordVerifyName,
      pageBuilder: (context, state) {
        final email =
            state.uri.queryParameters['email'] ??
            (state.extra is String
                ? state.extra as String
                : (state.extra as Map?)?['email'] as String?);
        return _buildSlideTransition(
          key: state.pageKey,
          child: VerifyScreen(email: email),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.resetPassword,
      name: AppRoutes.resetPasswordName,
      pageBuilder: (context, state) => _buildSlideTransition(
        key: state.pageKey,
        child: const NewPass_screen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.passwordResetSuccess,
      name: AppRoutes.passwordResetSuccessName,
      pageBuilder: (context, state) => _buildSlideTransition(
        key: state.pageKey,
        child: const CongratulationsScreen(),
      ),
    ),

    // -------------------------------------------------------------------------
    // Main App & Dashboard
    // -------------------------------------------------------------------------
    GoRoute(
      path: AppRoutes.home,
      name: AppRoutes.homeName,
      pageBuilder: (context, state) => _buildSlideTransition(
        key: state.pageKey,
        child: const HomePageScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.optionalModules,
      name: AppRoutes.optionalModulesName,
      pageBuilder: (context, state) {
        final isFirstLogin =
            state.uri.queryParameters['firstLogin'] == 'true' ||
            state.extra == true ||
            (state.extra as Map?)?['isFirstLogin'] == true;
        return _buildSlideTransition(
          key: state.pageKey,
          child: OptionalModuleSettings(isFirstLogin: isFirstLogin),
        );
      },
    ),

    // -------------------------------------------------------------------------
    // Tab 2: Quizzes Discovery Hub (Option A Spec Flow & Option B YouTube Flow)
    // -------------------------------------------------------------------------
    GoRoute(
      path: AppRoutes.modules,
      name: AppRoutes.modulesName,
      pageBuilder: (context, state) => _buildSlideTransition(
        key: state.pageKey,
        child: const ModuleHomeScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.specModules,
      name: AppRoutes.specModulesName,
      pageBuilder: (context, state) => _buildSlideTransition(
        key: state.pageKey,
        child: const SpecModuleListScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.specEqSelection,
      name: AppRoutes.specEqSelectionName,
      pageBuilder: (context, state) {
        final extraMap = state.extra is Map ? state.extra as Map : {};
        final moduleId =
            state.uri.queryParameters['moduleId'] ??
            extraMap['moduleId']?.toString() ??
            'tectonics';
        return _buildSlideTransition(
          key: state.pageKey,
          child: EqSelectionScreen(moduleId: moduleId),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.specSubQuizzes,
      name: AppRoutes.specSubQuizzesName,
      pageBuilder: (context, state) {
        final extraMap = state.extra is Map ? state.extra as Map : {};
        final moduleId =
            state.uri.queryParameters['moduleId'] ??
            extraMap['moduleId']?.toString() ??
            'tectonics';
        final eqNumber =
            int.tryParse(state.uri.queryParameters['eq'] ?? '') ??
            (extraMap['eqNumber'] as int?) ??
            1;
        return _buildSlideTransition(
          key: state.pageKey,
          child: SubQuizSelectionScreen(
            moduleId: moduleId,
            eqNumber: eqNumber,
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.youtubeQuizzes,
      name: AppRoutes.youtubeQuizzesName,
      pageBuilder: (context, state) => _buildSlideTransition(
        key: state.pageKey,
        child: const YouTubeQuizListScreen(),
      ),
    ),

    // -------------------------------------------------------------------------
    // Shared Quiz Configuration, Engine & Deep Link Entrypoints
    // -------------------------------------------------------------------------
    GoRoute(
      path: AppRoutes.selectTime,
      name: AppRoutes.selectTimeName,
      pageBuilder: (context, state) {
        final extraMap = state.extra is Map ? state.extra as Map : {};
        final selectedQuantityIndex =
            int.tryParse(
              state.uri.queryParameters['selectedQuantityIndex'] ?? '',
            ) ??
            extraMap['selectedQuantityIndex'] as int?;
        final moduleId =
            state.uri.queryParameters['moduleId'] ??
            extraMap['moduleId'] as String?;
        final moduleName =
            state.uri.queryParameters['moduleName'] ??
            extraMap['moduleName'] as String?;

        return _buildSlideTransition(
          key: state.pageKey,
          child: SelectTime_screen(
            selectedQuantityIndex: selectedQuantityIndex,
            moduleId: moduleId,
            moduleName: moduleName,
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.selectQuantity,
      name: AppRoutes.selectQuantityName,
      pageBuilder: (context, state) {
        final extraMap = state.extra is Map ? state.extra as Map : {};
        final selectedTimeInMinutes =
            int.tryParse(
              state.uri.queryParameters['selectedTimeInMinutes'] ?? '',
            ) ??
            extraMap['selectedTimeInMinutes'] as int?;
        final moduleId =
            state.uri.queryParameters['moduleId'] ??
            extraMap['moduleId'] as String?;

        return _buildSlideTransition(
          key: state.pageKey,
          child: SelectQuantityScreen(
            selectedTimeInMinutes: selectedTimeInMinutes,
            moduleId: moduleId,
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.quiz,
      name: AppRoutes.quizName,
      pageBuilder: (context, state) {
        final extraMap = state.extra is Map ? state.extra as Map : {};
        final totalQuestions =
            int.tryParse(state.uri.queryParameters['totalQuestions'] ?? '') ??
            extraMap['totalQuestions'] as int?;
        final timeInMinutes =
            int.tryParse(state.uri.queryParameters['timeInMinutes'] ?? '') ??
            extraMap['timeInMinutes'] as int?;
        final moduleId =
            state.uri.queryParameters['moduleId'] ??
            extraMap['moduleId'] as String?;
        final moduleName =
            state.uri.queryParameters['moduleName'] ??
            extraMap['moduleName'] as String?;
        final initialQuestionIndex = extraMap['initialQuestionIndex'] as int?;
        final initialCorrectCount = extraMap['initialCorrectCount'] as int?;
        final initialTimeRemainingSeconds =
            extraMap['initialTimeRemainingSeconds'] as int?;

        return _buildSlideTransition(
          key: state.pageKey,
          child: QuizScreen(
            totalQuestions: totalQuestions,
            timeInMinutes: timeInMinutes,
            moduleId: moduleId,
            moduleName: moduleName,
            initialQuestionIndex: initialQuestionIndex,
            initialCorrectCount: initialCorrectCount,
            initialTimeRemainingSeconds: initialTimeRemainingSeconds,
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.quizById,
      name: AppRoutes.quizByIdName,
      pageBuilder: (context, state) {
        final rawQuizId = state.pathParameters['quizId'] ?? '';
        final quizId = Uri.decodeComponent(rawQuizId).trim();
        final extraMap = state.extra is Map ? state.extra as Map : {};

        final ytQuiz = StaticYouTubeData.findByQuizId(quizId);
        final subQuiz = StaticCurriculumData.findSubQuizById(quizId);
        final specMod = StaticCurriculumData.findModuleById(quizId);
        final isSynoptic = quizId.toUpperCase() == 'SYNOPTIC';

        final isKnownQuiz =
            ytQuiz != null ||
            subQuiz != null ||
            specMod != null ||
            isSynoptic;

        final moduleName =
            state.uri.queryParameters['moduleName'] ??
            extraMap['moduleName'] as String? ??
            ytQuiz?.title ??
            subQuiz?.title ??
            specMod?.title ??
            (isSynoptic ? 'Synoptic Paper 3 Linkages' : null);

        final totalQuestions =
            int.tryParse(state.uri.queryParameters['totalQuestions'] ?? '') ??
            extraMap['totalQuestions'] as int? ??
            ytQuiz?.questionCount ??
            subQuiz?.questionCount ??
            10;

        final timeInMinutes =
            int.tryParse(state.uri.queryParameters['timeInMinutes'] ?? '') ??
            extraMap['timeInMinutes'] as int? ??
            ytQuiz?.estimatedMinutes ??
            subQuiz?.estimatedMinutes ??
            10;

        return _buildSlideTransition(
          key: state.pageKey,
          child: QuizScreen(
            moduleId: quizId,
            moduleName: moduleName,
            totalQuestions: totalQuestions,
            timeInMinutes: timeInMinutes,
            isInvalidQuizId: !isKnownQuiz,
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.quizResult,
      name: AppRoutes.quizResultName,
      pageBuilder: (context, state) => _buildSlideTransition(
        key: state.pageKey,
        child: const QuizResult_Screen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.quizComplete,
      name: AppRoutes.quizCompleteName,
      pageBuilder: (context, state) => _buildSlideTransition(
        key: state.pageKey,
        child: const QuizCompleteScreen(),
      ),
    ),

    // -------------------------------------------------------------------------
    // Profile & Settings
    // -------------------------------------------------------------------------
    GoRoute(
      path: AppRoutes.profile,
      name: AppRoutes.profileName,
      pageBuilder: (context, state) => _buildSlideTransition(
        key: state.pageKey,
        child: const ProfileScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.editProfileOption,
      name: AppRoutes.editProfileOptionName,
      pageBuilder: (context, state) => _buildSlideTransition(
        key: state.pageKey,
        child: const EditProfileOption(),
      ),
    ),
    GoRoute(
      path: AppRoutes.generalSettings,
      name: AppRoutes.generalSettingsName,
      pageBuilder: (context, state) => _buildSlideTransition(
        key: state.pageKey,
        child: const GeneralSettings_Screen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.privacySettings,
      name: AppRoutes.privacySettingsName,
      pageBuilder: (context, state) => _buildSlideTransition(
        key: state.pageKey,
        child: const PrivacySettings_Screen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.aboutApp,
      name: AppRoutes.aboutAppName,
      pageBuilder: (context, state) => _buildSlideTransition(
        key: state.pageKey,
        child: const AboutAppScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.accountDelete,
      name: AppRoutes.accountDeleteName,
      pageBuilder: (context, state) => _buildSlideTransition(
        key: state.pageKey,
        child: const AccountDelete(),
      ),
    ),
  ],

  // ---------------------------------------------------------------------------
  // 404 Error Screen
  // ---------------------------------------------------------------------------
  errorBuilder: (context, state) => Scaffold(
    backgroundColor: AppColors.bgColor,
    appBar: AppBar(
      title: const Text('Page Not Found'),
      backgroundColor: AppColors.bgColor,
    ),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.explore_off_rounded,
              size: 80,
              color: AppColors.primaryAzure.withValues(alpha: 0.8),
            ),
            const SizedBox(height: 16),
            Text(
              '404 - Page Not Found',
              style: FontManager.boldHeading(color: AppColors.neutralDark),
            ),
            const SizedBox(height: 8),
            Text(
              'The requested route "${state.uri.toString()}" could not be located.',
              textAlign: TextAlign.center,
              style: FontManager.subtitleText(),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go(AppRoutes.home),
              icon: const Icon(Icons.home_rounded),
              label: const Text('Go to Home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryAzure,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  ),
);
