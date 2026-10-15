import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_spacing.dart';
import 'package:geography_geyser/core/app_strings.dart';
import 'package:geography_geyser/provider/forgot_password/forgot_pass_provider.dart';
import 'package:geography_geyser/secure_storage/secure_storage_helper.dart';
import 'package:geography_geyser/views/auth/forgot_pass/new_pass.dart';
import 'package:geography_geyser/views/custom_widgets/custom_login_button.dart';
import 'package:geography_geyser/views/custom_widgets/custom_snackbar.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class VerifyScreen extends StatefulWidget {
  final String? email;

  const VerifyScreen({super.key, this.email});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();
  int _resendTimer = 60;
  Timer? _timer;
  String? _storedEmail;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _loadEmailFromStorage();
  }

  Future<void> _loadEmailFromStorage() async {
    final email = await SecureStorageHelper.getResetPasswordEmail();
    if (mounted) {
      setState(() {
        _storedEmail = email;
      });
    }
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _resendTimer = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() {
          _resendTimer--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pinController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  String _maskEmail(String email) {
    if (email.isEmpty) return email;

    final parts = email.split('@');
    if (parts.length != 2) return email;

    final localPart = parts[0];
    final domain = parts[1];

    if (localPart.length <= 3) {
      return email;
    }

    final first = localPart[0];
    final lastTwo = localPart.substring(localPart.length - 2);
    final starsCount = localPart.length - 3;
    final stars = '*' * starsCount;

    return '$first$stars$lastTwo@$domain';
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 48.w,
      height: 56.h,
      textStyle: GoogleFonts.plusJakartaSans(
        fontSize: 22.sp,
        fontWeight: FontWeight.w800,
        color: AppColors.neutralDark,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5.w),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: Colors.white,
        border: Border.all(color: AppColors.primaryAzure, width: 2.w),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryAzure.withValues(alpha: 0.18),
            blurRadius: 12,
            offset: Offset(0, 3.w),
          ),
        ],
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: const Color(0xFFF0F9FF),
        border: Border.all(color: AppColors.primarySky, width: 1.5.w),
      ),
    );

    final displayEmail = (widget.email != null && widget.email!.isNotEmpty)
        ? widget.email!
        : (_storedEmail != null && _storedEmail!.isNotEmpty)
            ? _storedEmail!
            : "";

    return Scaffold(
      backgroundColor: const Color(0xFFF0F9FF),
      body: Stack(
        children: [
          Positioned(
            top: -40.h,
            right: -30.w,
            child: Container(
              width: 200.w,
              height: 200.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF52B1FF).withValues(alpha: 0.3),
                    const Color(0xFF52B1FF).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    AppSpacing.h12,

                    // Top Bar with Back Button
                    FadeInDown(
                      duration: const Duration(milliseconds: 400),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFE0F2FE),
                                width: 1.2.w,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Consumer<ForgotPasswordProvider>(
                              builder: (context, provider, child) {
                                return IconButton(
                                  icon: const Icon(
                                    Icons.arrow_back_rounded,
                                    color: AppColors.neutralDark,
                                  ),
                                  onPressed: () {
                                    provider.clearPassResetToken();
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            ),
                          ),
                          const Spacer(),
                          Text(
                            "Step 2 of 3",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppSpacing.h16,

                    // Security Illustration
                    ZoomIn(
                      duration: const Duration(milliseconds: 600),
                      child: Container(
                        width: 120.w,
                        height: 120.h,
                        padding: EdgeInsets.all(18.r),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            color: const Color(0xFFE0F2FE),
                            width: 3.w,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0284C7).withValues(alpha: 0.15),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          "assets/images/security_vec.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    AppSpacing.h20,

                    // Title & Instruction
                    FadeInDown(
                      duration: const Duration(milliseconds: 500),
                      child: Column(
                        children: [
                          Text(
                            "Verify Reset Code 🔐",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.neutralDark,
                              letterSpacing: -0.5,
                            ),
                          ),
                          AppSpacing.h8,
                          Text(
                            "We sent a 6-digit password reset code to",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          AppSpacing.h8,

                          // Email Badge
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(9999.r),
                              border: Border.all(
                                color: const Color(0xFFBAE6FD),
                                width: 1.2.w,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0284C7).withValues(alpha: 0.06),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.mail_outline_rounded,
                                  size: 15.sp,
                                  color: AppColors.primaryAzure,
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  displayEmail.isNotEmpty
                                      ? _maskEmail(displayEmail)
                                      : "your registered email",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.neutralDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppSpacing.h28,

                    // Card Container
                    FadeInUp(
                      duration: const Duration(milliseconds: 650),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28.r),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0284C7).withValues(alpha: 0.08),
                              blurRadius: 24,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 28.h,
                        ),
                        child: Consumer<ForgotPasswordProvider>(
                          builder: (context, provider, child) {
                            return Column(
                              children: [
                                if (provider.errorMessage != null)
                                  Container(
                                    margin: EdgeInsets.only(bottom: 16.h),
                                    padding: EdgeInsets.all(12.r),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF2F2),
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(
                                        color: const Color(0xFFFCA5A5),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.error_outline_rounded,
                                          color: Colors.red.shade700,
                                          size: 20.sp,
                                        ),
                                        SizedBox(width: 8.w),
                                        Expanded(
                                          child: Text(
                                            provider.errorMessage!,
                                            style: GoogleFonts.plusJakartaSans(
                                              color: Colors.red.shade800,
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            provider.clearError();
                                          },
                                          child: Icon(
                                            Icons.close_rounded,
                                            size: 18.sp,
                                            color: Colors.red.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                Text(
                                  "Enter 6-Digit Code",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                                AppSpacing.h16,

                                // Pinput
                                Pinput(
                                  controller: _pinController,
                                  focusNode: _pinFocusNode,
                                  length: 6,
                                  defaultPinTheme: defaultPinTheme,
                                  focusedPinTheme: focusedPinTheme,
                                  submittedPinTheme: submittedPinTheme,
                                  pinAnimationType: PinAnimationType.fade,
                                  hapticFeedbackType: HapticFeedbackType.lightImpact,
                                  cursor: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(bottom: 10.h),
                                        width: 18.w,
                                        height: 2.h,
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryAzure,
                                          borderRadius: BorderRadius.circular(2.r),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                AppSpacing.h24,

                                CustomLoginButton(
                                  text: provider.isLoading
                                      ? "Verifying..."
                                      : "Verify & Proceed",
                                  isLoading: provider.isLoading,
                                  icon: const Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  onPressed: provider.isLoading
                                      ? null
                                      : () async {
                                          if (_pinController.text.length != 6) {
                                            CustomSnackBar.show(
                                              context,
                                              message: 'Please enter 6-digit OTP code',
                                              isError: true,
                                            );
                                            return;
                                          }

                                          try {
                                            final response = await provider
                                                .verifyForgotPasswordOtp(
                                              _pinController.text.trim(),
                                            );

                                            if (context.mounted) {
                                              final successMessage =
                                                  response['msg'] ??
                                                      'OTP verified successfully!';

                                              CustomSnackBar.show(
                                                context,
                                                message: successMessage,
                                                isError: false,
                                              );

                                              Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const NewPass_screen(),
                                                ),
                                                (route) => false,
                                              );
                                            }
                                          } catch (e) {
                                            if (context.mounted) {
                                              String errorMsg =
                                                  'OTP verification failed';
                                              if (provider.errorMessage != null) {
                                                errorMsg = provider.errorMessage!;
                                              } else if (e is Map) {
                                                errorMsg = e['msg'] ??
                                                    e['error'] ??
                                                    e['message'] ??
                                                    errorMsg;
                                              }
                                              CustomSnackBar.show(
                                                context,
                                                message: errorMsg,
                                                isError: true,
                                              );
                                            }
                                          }
                                        },
                                ),
                                AppSpacing.h20,

                                // Resend Code Section
                                if (_resendTimer > 0) ...[
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 14.w,
                                      vertical: 6.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(9999.r),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.timer_outlined,
                                          size: 15.sp,
                                          color: const Color(0xFF64748B),
                                        ),
                                        SizedBox(width: 6.w),
                                        Text(
                                          "Resend code in ${_resendTimer}s",
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ] else ...[
                                  InkWell(
                                    borderRadius: BorderRadius.circular(9999.r),
                                    onTap: provider.isLoading
                                        ? null
                                        : () async {
                                            try {
                                              final emailToUse =
                                                  widget.email ?? _storedEmail;
                                              if (emailToUse == null ||
                                                  emailToUse.isEmpty) {
                                                CustomSnackBar.show(
                                                  context,
                                                  message:
                                                      'Email not found. Please try again from start.',
                                                  isError: true,
                                                );
                                                return;
                                              }

                                              await provider
                                                  .resendForgotPasswordOtp(
                                                emailToUse,
                                              );
                                              if (context.mounted) {
                                                CustomSnackBar.show(
                                                  context,
                                                  message:
                                                      'OTP resent successfully!',
                                                );
                                                _startTimer();
                                              }
                                            } catch (e) {
                                              // handled in provider
                                            }
                                          },
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12.w,
                                        vertical: 6.h,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.refresh_rounded,
                                            size: 16.sp,
                                            color: AppColors.primaryAzure,
                                          ),
                                          SizedBox(width: 6.w),
                                          Text(
                                            "Resend OTP Code",
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.primaryAzure,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    AppSpacing.h24,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
