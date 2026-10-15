import 'package:animate_do/animate_do.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_logger.dart';
import 'package:geography_geyser/core/app_spacing.dart';
import 'package:geography_geyser/core/app_strings.dart';
import 'package:geography_geyser/provider/auth_provider/login_provider.dart';
import 'package:geography_geyser/routes/app_routes.dart';
import 'package:geography_geyser/views/custom_widgets/apple_login_btn.dart';
import 'package:geography_geyser/views/custom_widgets/buildTextField.dart';
import 'package:geography_geyser/views/custom_widgets/custom_login_button.dart';
import 'package:geography_geyser/views/custom_widgets/google_login_btn.dart';
import 'package:geography_geyser/views/custom_widgets/custom_snackbar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      CustomSnackBar.show(
        context,
        message: 'Please enter both email and password',
        isError: true,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await LoginProvider.login(email, password);

      if (!mounted) return;

      CustomSnackBar.show(
        context,
        message: 'Welcome back to Geography Geyser!',
        isError: false,
      );

      final isOptionalModuleSelected =
          response['is_optional_module_selected'] == true ||
          response['is_optional_module_selected'] == 'true';

      if (isOptionalModuleSelected) {
        context.go(AppRoutes.home);
      } else {
        context.go(AppRoutes.optionalModulesPath(isFirstLogin: true));
      }
    } catch (e) {
      String message = 'Invalid email or password.';
      if (e is Map && e['message'] != null) {
        message = e['message'].toString();
      }
      if (mounted) {
        CustomSnackBar.show(
          context,
          message: AppLogger.getSafeErrorMessage(message),
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F9FF),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Ambient decorative background gradients
          Positioned(
            top: -60.h,
            right: -50.w,
            child: Container(
              width: 220.w,
              height: 220.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF52B1FF).withValues(alpha: 0.35),
                    const Color(0xFF52B1FF).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 120.h,
            left: -40.w,
            child: Container(
              width: 160.w,
              height: 160.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFF59E0B).withValues(alpha: 0.20),
                    const Color(0xFFF59E0B).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          // Main scrollable content
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  AppSpacing.h18,

                  // Top Header & Logo Section
                  FadeInDown(
                    duration: const Duration(milliseconds: 600),
                    child: Column(
                      children: [
                        // Premium Explorer Emblem with Gradient Ring & Glow
                        Container(
                          width: 104.w,
                          height: 104.h,
                          padding: EdgeInsets.all(3.5.w),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF52B1FF), Color(0xFF0284C7)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0284C7).withValues(alpha: 0.28),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                              BoxShadow(
                                color: const Color(0xFF52B1FF).withValues(alpha: 0.18),
                                blurRadius: 12,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            padding: EdgeInsets.all(2.w),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/logo.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        AppSpacing.h12,

                        // App Title
                        Text(
                          AppStrings.appName,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 26.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.neutralDark,
                            letterSpacing: -0.5,
                          ),
                        ),
                        AppSpacing.h12,

                        // Gamified Tagline Pill
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(9999.r),
                            border: Border.all(
                              color: const Color(0xFFE0F2FE),
                              width: 1.2.w,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF0F172A,
                                ).withValues(alpha: 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "🌍 Explore the World",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryAzure,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6.w),
                                child: Text(
                                  "•",
                                  style: TextStyle(
                                    color: const Color(0xFF94A3B8),
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.star_rounded,
                                size: 14.sp,
                                color: const Color(0xFFF59E0B),
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                "Daily Trivia",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFD97706),
                                ),
                              ),
                            ],
                          ),
                        ),
                        AppSpacing.h28,
                      ],
                    ),
                  ),

                  // Login Form Card
                  FadeInUp(
                    duration: const Duration(milliseconds: 700),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(36.r),
                          topRight: Radius.circular(36.r),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF0284C7,
                            ).withValues(alpha: 0.10),
                            blurRadius: 30,
                            offset: const Offset(0, -8),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 32.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Card Greeting
                          Text(
                            "Welcome Back! 👋",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.neutralDark,
                              letterSpacing: -0.5,
                            ),
                          ),
                          AppSpacing.h6,
                          Text(
                            "Log in to challenge your mind and level up your ranking",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          AppSpacing.h24,

                          // Email Field
                          BuildTextField(
                            label: "Explorer Email",
                            hint: AppStrings.emailPlaceholder,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.emailAddress,
                            controller: emailController,
                            prefixIcon: Icon(
                              Icons.alternate_email_rounded,
                              color: AppColors.primaryAzure,
                              size: 20.sp,
                            ),
                          ),
                          AppSpacing.h18,

                          // Password Field
                          BuildTextField(
                            label: "Secret Passcode",
                            hint: AppStrings.passwordPlaceholder,
                            controller: passwordController,
                            isPassword: true,
                            textInputAction: TextInputAction.done,
                            obscureText: _obscurePassword,
                            prefixIcon: Icon(
                              Icons.lock_outline_rounded,
                              color: AppColors.primaryAzure,
                              size: 20.sp,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: const Color(0xFF64748B),
                                size: 20.sp,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          AppSpacing.h10,

                          // Forgot Password
                          Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8.r),
                              onTap: () {
                                context.push(AppRoutes.forgotPassword);
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 4.w,
                                  vertical: 4.h,
                                ),
                                child: Text(
                                  AppStrings.forgotPassword,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13.sp,
                                    color: AppColors.primaryAzure,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          AppSpacing.h24,

                          // Log In Button
                          CustomLoginButton(
                            text: "Start Exploring",
                            fontSize: 16.sp,
                            isLoading: _isLoading,
                            onPressed: _isLoading ? null : _handleLogin,
                          ),
                          AppSpacing.h24,

                          // OR Divider
                          Row(
                            children: [
                              const Expanded(
                                child: Divider(
                                  color: Color(0xFFE2E8F0),
                                  thickness: 1,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 14.w),
                                child: Text(
                                  "or continue with",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF94A3B8),
                                  ),
                                ),
                              ),
                              const Expanded(
                                child: Divider(
                                  color: Color(0xFFE2E8F0),
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),
                          AppSpacing.h20,

                          // Google & Apple Login Buttons
                          Row(
                            children: [
                              const Expanded(child: GoogleLoginBtn()),
                              SizedBox(width: 14.w),
                              const Expanded(child: AppleLoginBtn()),
                            ],
                          ),
                          AppSpacing.h24,

                          // Create Account Link
                          Center(
                            child: RichText(
                              text: TextSpan(
                                text: AppStrings.noAccountPrefix,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF64748B),
                                ),
                                children: [
                                  TextSpan(
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        context.push(AppRoutes.signup);
                                      },
                                    text: ' ${AppStrings.createAccountTitle}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14.sp,
                                      color: AppColors.primaryAzure,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          AppSpacing.h16,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
