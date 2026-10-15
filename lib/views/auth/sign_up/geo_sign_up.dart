import 'package:animate_do/animate_do.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_logger.dart';
import 'package:geography_geyser/core/app_spacing.dart';
import 'package:geography_geyser/core/app_strings.dart';
import 'package:geography_geyser/provider/auth_provider/signup_provider/signup_provider.dart';
import 'package:geography_geyser/utils/validators.dart';
import 'package:geography_geyser/views/auth/login/login.dart';
import 'package:geography_geyser/views/auth/sign_up/verify_otp.dart';
import 'package:geography_geyser/views/custom_widgets/apple_login_btn.dart';
import 'package:geography_geyser/views/custom_widgets/buildTextField.dart';
import 'package:geography_geyser/views/custom_widgets/custom_login_button.dart';
import 'package:geography_geyser/views/custom_widgets/google_login_btn.dart';
import 'package:geography_geyser/views/custom_widgets/custom_snackbar.dart';

class GeoSignUpScreen extends StatefulWidget {
  const GeoSignUpScreen({super.key});

  @override
  State<GeoSignUpScreen> createState() => _GeoSignUpScreenState();
}

class _GeoSignUpScreenState extends State<GeoSignUpScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Password strength helper
  double _getPasswordStrength(String password) {
    if (password.isEmpty) return 0.0;
    double strength = 0.0;
    if (password.length >= 6) strength += 0.35;
    if (password.length >= 8) strength += 0.25;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.2;
    if (RegExp(r'[A-Z]').hasMatch(password) ||
        RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      strength += 0.2;
    }
    return strength.clamp(0.0, 1.0);
  }

  Color _getStrengthColor(double strength) {
    if (strength <= 0.35) return const Color(0xFFEF4444);
    if (strength <= 0.7) return const Color(0xFFF59E0B);
    return const Color(0xFF10B981);
  }

  String _getStrengthLabel(double strength) {
    if (strength <= 0.35) return "Weak";
    if (strength <= 0.7) return "Medium";
    return "Strong ✨";
  }

  Future<void> _handleSignup() async {
    final name = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    setState(() {
      _nameError = name.isEmpty ? "Please enter your full name" : null;
      _emailError = Validators.validateEmail(email);
      _passwordError = Validators.validatePassword(password);
      _confirmPasswordError =
          Validators.validateConfirmPassword(confirmPassword, password);
    });

    final isValid = _nameError == null &&
        _emailError == null &&
        _passwordError == null &&
        _confirmPasswordError == null;

    if (!isValid) return;

    setState(() => _isLoading = true);

    try {
      await SignupProvider.signup(
        email,
        name,
        password,
        context,
      );

      if (mounted) {
        CustomSnackBar.show(
          context,
          message: "Signup successful! Check your email for OTP.",
          isError: false,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => VerifyOtpScreen(
              email: email,
            ),
          ),
        );
      }
    } catch (e) {
      String message = 'Signup failed. Please try again.';
      if (e is Map<String, dynamic>) {
        message = e['message']?.toString() ??
            e['error']?.toString() ??
            message;
      } else if (e is String) {
        message = e;
      } else {
        message = e.toString();
      }

      AppLogger.error('Signup Error', e);

      if (mounted) {
        CustomSnackBar.show(
          context,
          message: AppLogger.getSafeErrorMessage(message),
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final passwordStrength = _getPasswordStrength(_passwordController.text);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F9FF),
      body: Stack(
        children: [
          // Ambient decorative orbs
          Positioned(
            top: -40.h,
            left: -50.w,
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
            top: 100.h,
            right: -30.w,
            child: Container(
              width: 150.w,
              height: 150.h,
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

          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  AppSpacing.h20,

                  // Header branding
                  FadeInDown(
                    duration: const Duration(milliseconds: 600),
                    child: Column(
                      children: [
                        // Premium Explorer Emblem with Gradient Ring & Glow
                        Container(
                          width: 98.w,
                          height: 98.h,
                          padding: EdgeInsets.all(3.w),
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
                                blurRadius: 22,
                                offset: const Offset(0, 7),
                              ),
                              BoxShadow(
                                color: const Color(0xFF52B1FF).withValues(alpha: 0.18),
                                blurRadius: 10,
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
                        Text(
                          AppStrings.appName,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.neutralDark,
                            letterSpacing: -0.5,
                          ),
                        ),
                        AppSpacing.h6,
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 5.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(9999.r),
                            border: Border.all(
                              color: const Color(0xFFE0F2FE),
                              width: 1.2.w,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.explore_rounded,
                                size: 14.sp,
                                color: AppColors.primaryAzure,
                              ),
                              SizedBox(width: 5.w),
                              Text(
                                "Create Explorer Profile",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryAzure,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AppSpacing.h24,
                      ],
                    ),
                  ),

                  // Form Card Container
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
                            color: const Color(0xFF0284C7).withValues(alpha: 0.10),
                            blurRadius: 30,
                            offset: const Offset(0, -8),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 30.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Join The Expedition 🚀",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.neutralDark,
                              letterSpacing: -0.5,
                            ),
                          ),
                          AppSpacing.h6,
                          Text(
                            "Discover trivia, unlock country badges, and challenge friends",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          AppSpacing.h24,

                          // Full Name Field
                          BuildTextField(
                            label: "Explorer Name",
                            hint: "e.g. Alex Henderson",
                            textInputAction: TextInputAction.next,
                            controller: _fullNameController,
                            errorText: _nameError,
                            prefixIcon: Icon(
                              Icons.person_outline_rounded,
                              color: AppColors.primaryAzure,
                              size: 20.sp,
                            ),
                          ),
                          AppSpacing.h16,

                          // Email Field
                          BuildTextField(
                            label: "Explorer Email",
                            hint: "alex@worldquest.com",
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            errorText: _emailError,
                            prefixIcon: Icon(
                              Icons.alternate_email_rounded,
                              color: AppColors.primaryAzure,
                              size: 20.sp,
                            ),
                            onChanged: (value) {
                              setState(() {
                                _emailError = Validators.validateEmail(value);
                              });
                            },
                          ),
                          AppSpacing.h16,

                          // Password Field
                          BuildTextField(
                            label: "Secret Passcode",
                            hint: "At least 6 characters",
                            controller: _passwordController,
                            textInputAction: TextInputAction.next,
                            isPassword: true,
                            obscureText: _obscurePassword,
                            errorText: _passwordError,
                            prefixIcon: Icon(
                              Icons.lock_outline_rounded,
                              color: AppColors.primaryAzure,
                              size: 20.sp,
                            ),
                            onChanged: (value) {
                              setState(() {
                                _passwordError =
                                    Validators.validatePassword(value);
                                if (_confirmPasswordController.text.isNotEmpty) {
                                  _confirmPasswordError =
                                      Validators.validateConfirmPassword(
                                    _confirmPasswordController.text,
                                    value,
                                  );
                                }
                              });
                            },
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

                          // Password strength indicator
                          if (_passwordController.text.isNotEmpty) ...[
                            AppSpacing.h8,
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4.r),
                                    child: LinearProgressIndicator(
                                      value: passwordStrength,
                                      backgroundColor: const Color(0xFFE2E8F0),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        _getStrengthColor(passwordStrength),
                                      ),
                                      minHeight: 4.h,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Text(
                                  _getStrengthLabel(passwordStrength),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                    color: _getStrengthColor(passwordStrength),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          AppSpacing.h16,

                          // Confirm Password Field
                          BuildTextField(
                            label: "Confirm Passcode",
                            hint: "Re-enter your passcode",
                            obscureText: _obscureConfirmPassword,
                            controller: _confirmPasswordController,
                            textInputAction: TextInputAction.done,
                            isPassword: true,
                            errorText: _confirmPasswordError,
                            prefixIcon: Icon(
                              Icons.lock_reset_rounded,
                              color: AppColors.primaryAzure,
                              size: 20.sp,
                            ),
                            onChanged: (value) {
                              setState(() {
                                _confirmPasswordError =
                                    Validators.validateConfirmPassword(
                                  value,
                                  _passwordController.text,
                                );
                              });
                            },
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: const Color(0xFF64748B),
                                size: 20.sp,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                          AppSpacing.h24,

                          // Sign Up Button
                          CustomLoginButton(
                            text: "Create Explorer Account",
                            isLoading: _isLoading,
                            onPressed: _isLoading ? null : _handleSignup,
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
                                  "or register with",
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

                          // Social Login Buttons
                          Row(
                            children: [
                              const Expanded(child: GoogleLoginBtn()),
                              SizedBox(width: 14.w),
                              const Expanded(child: AppleLoginBtn()),
                            ],
                          ),
                          AppSpacing.h24,

                          // Already have account
                          Center(
                            child: RichText(
                              text: TextSpan(
                                text: 'Already have an account? ',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF64748B),
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Log In',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14.sp,
                                      color: AppColors.primaryAzure,
                                      fontWeight: FontWeight.w800,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const LoginScreen(),
                                          ),
                                        );
                                      },
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
