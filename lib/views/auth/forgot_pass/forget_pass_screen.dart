import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_spacing.dart';
import 'package:geography_geyser/core/app_strings.dart';
import 'package:geography_geyser/provider/forgot_password/forgot_pass_provider.dart';
import 'package:geography_geyser/views/auth/forgot_pass/verify_screen.dart';
import 'package:geography_geyser/views/custom_widgets/buildTextField.dart';
import 'package:geography_geyser/views/custom_widgets/custom_login_button.dart';
import 'package:geography_geyser/views/custom_widgets/custom_snackbar.dart';
import 'package:provider/provider.dart';

class PassResetScreen extends StatefulWidget {
  const PassResetScreen({super.key});

  @override
  State<PassResetScreen> createState() => _PassResetScreenState();
}

class _PassResetScreenState extends State<PassResetScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F9FF),
      body: Stack(
        children: [
          // Ambient background glow
          Positioned(
            top: -50.h,
            left: -40.w,
            child: Container(
              width: 220.w,
              height: 220.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF52B1FF).withValues(alpha: 0.30),
                    const Color(0xFF52B1FF).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 140.h,
            right: -30.w,
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
                                  color: const Color(
                                    0xFF0F172A,
                                  ).withValues(alpha: 0.05),
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
                            "Account Recovery",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppSpacing.h24,

                    // Key & Lock Illustration
                    ZoomIn(
                      duration: const Duration(milliseconds: 600),
                      child: Container(
                        width: 110.w,
                        height: 110.h,
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
                              color: const Color(
                                0xFF0284C7,
                              ).withValues(alpha: 0.16),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.vpn_key_rounded,
                            size: 48.sp,
                            color: AppColors.primaryAzure,
                          ),
                        ),
                      ),
                    ),
                    AppSpacing.h24,

                    // Title & Instructions
                    FadeInDown(
                      duration: const Duration(milliseconds: 500),
                      child: Column(
                        children: [
                          Text(
                            "Forgot Password? 🔑",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.neutralDark,
                              letterSpacing: -0.5,
                            ),
                          ),
                          AppSpacing.h10,
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Text(
                              "No worries! Enter your registered explorer email and we'll send you an OTP code to reset your passcode.",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF64748B),
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppSpacing.h28,

                    // Input Card
                    FadeInUp(
                      duration: const Duration(milliseconds: 650),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28.r),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF0284C7,
                              ).withValues(alpha: 0.08),
                              blurRadius: 24,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 22.w,
                          vertical: 28.h,
                        ),
                        child: Consumer<ForgotPasswordProvider>(
                          builder: (context, forgotPasswordProvider, child) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // // Error banner if exists
                                // if (forgotPasswordProvider.errorMessage != null)
                                //   Container(
                                //     margin: EdgeInsets.only(bottom: 16.h),
                                //     padding: EdgeInsets.all(12.r),
                                //     decoration: BoxDecoration(
                                //       color: const Color(0xFFFEF2F2),
                                //       borderRadius: BorderRadius.circular(12.r),
                                //       border: Border.all(
                                //         color: const Color(0xFFFCA5A5),
                                //       ),
                                //     ),
                                //     child: Row(
                                //       children: [
                                //         Icon(
                                //           Icons.error_outline_rounded,
                                //           color: Colors.red.shade700,
                                //           size: 20.sp,
                                //         ),
                                //         SizedBox(width: 8.w),
                                //         Expanded(
                                //           child: Text(
                                //             forgotPasswordProvider.errorMessage!,
                                //             style: GoogleFonts.plusJakartaSans(
                                //               color: Colors.red.shade800,
                                //               fontSize: 13.sp,
                                //               fontWeight: FontWeight.w600,
                                //             ),
                                //           ),
                                //         ),
                                //         InkWell(
                                //           onTap: () {
                                //             forgotPasswordProvider.clearError();
                                //           },
                                //           child: Icon(
                                //             Icons.close_rounded,
                                //             size: 18.sp,
                                //             color: Colors.red.shade700,
                                //           ),
                                //         ),
                                //       ],
                                //     ),
                                //   ),

                                BuildTextField(
                                  label: "Explorer Email",
                                  hint: "Enter your registered email",
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  prefixIcon: Icon(
                                    Icons.alternate_email_rounded,
                                    color: AppColors.primaryAzure,
                                    size: 20.sp,
                                  ),
                                ),
                                AppSpacing.h24,

                                CustomLoginButton(
                                  text: forgotPasswordProvider.isLoading
                                      ? "Sending Code..."
                                      : "Send Reset Code",
                                  isLoading: forgotPasswordProvider.isLoading,
                                  icon: const Icon(
                                    Icons.send_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  onPressed: forgotPasswordProvider.isLoading
                                      ? null
                                      : () async {
                                          final email = _emailController.text
                                              .trim();
                                          if (email.isEmpty) {
                                            CustomSnackBar.show(
                                              context,
                                              message:
                                                  'Please enter your email',
                                              isError: true,
                                            );
                                            return;
                                          }

                                          try {
                                            await forgotPasswordProvider
                                                .sendForgotPasswordRequest(
                                                  email,
                                                );

                                            if (context.mounted) {
                                              CustomSnackBar.show(
                                                context,
                                                message:
                                                    'OTP code sent successfully!',
                                                isError: false,
                                              );

                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      VerifyScreen(
                                                        email: email,
                                                      ),
                                                ),
                                              );
                                            }
                                          } catch (e) {
                                            if (context.mounted &&
                                                forgotPasswordProvider
                                                        .errorMessage !=
                                                    null) {
                                              CustomSnackBar.show(
                                                context,
                                                message: forgotPasswordProvider
                                                    .errorMessage!,
                                                isError: true,
                                              );
                                            }
                                          }
                                        },
                                ),
                                AppSpacing.h20,

                                Center(
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(8.r),
                                    onTap: () {
                                      forgotPasswordProvider
                                          .clearPassResetToken();
                                      Navigator.pop(context);
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 4.h,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.arrow_back_rounded,
                                            size: 16.sp,
                                            color: AppColors.primaryAzure,
                                          ),
                                          SizedBox(width: 4.w),
                                          Text(
                                            AppStrings.backToLogin,
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
                                ),
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
