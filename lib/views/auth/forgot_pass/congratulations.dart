import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_spacing.dart';
import 'package:geography_geyser/core/app_strings.dart';
import 'package:geography_geyser/routes/app_routes.dart';
import 'package:geography_geyser/views/custom_widgets/custom_login_button.dart';

class CongratulationsScreen extends StatelessWidget {
  const CongratulationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F9FF),
      body: Stack(
        children: [
          // Ambient background glow
          Positioned(
            top: -40.h,
            right: -30.w,
            child: Container(
              width: 240.w,
              height: 240.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF10B981).withValues(alpha: 0.22),
                    const Color(0xFF10B981).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -30.h,
            left: -40.w,
            child: Container(
              width: 200.w,
              height: 200.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF52B1FF).withValues(alpha: 0.22),
                    const Color(0xFF52B1FF).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppSpacing.h32,

                      // Pulsing Success Badge
                      ZoomIn(
                        duration: const Duration(milliseconds: 700),
                        child: Container(
                          width: 140.w,
                          height: 140.h,
                          padding: EdgeInsets.all(22.r),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(
                              color: const Color(0xFFDCFCE7),
                              width: 4.w,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF10B981).withValues(alpha: 0.25),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            "assets/icons/success.png",
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      AppSpacing.h28,

                      // Title & Subtitle
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        child: Column(
                          children: [
                            Text(
                              "Passcode Updated! 🔒✨",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 26.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.neutralDark,
                                letterSpacing: -0.5,
                              ),
                            ),
                            AppSpacing.h12,
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              child: Text(
                                "Your new passcode has been saved securely. You can now log into your Geography Geyser account and resume playing!",
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

                      // Security Status Badge Card
                      FadeInUp(
                        duration: const Duration(milliseconds: 700),
                        child: Container(
                          padding: EdgeInsets.all(16.r),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: const Color(0xFFE0F2FE),
                              width: 1.2.w,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 42.w,
                                height: 42.h,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.lock_reset_rounded,
                                  color: const Color(0xFF15803D),
                                  size: 22.sp,
                                ),
                              ),
                              SizedBox(width: 14.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Account Protected",
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.neutralDark,
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      "All sessions updated with latest credentials",
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      AppSpacing.h32,

                      // CTA Button
                      FadeInUp(
                        duration: const Duration(milliseconds: 800),
                        child: CustomLoginButton(
                          text: AppStrings.backToLogin,
                          icon: const Icon(
                            Icons.login_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          onPressed: () {
                            context.go(AppRoutes.login);
                          },
                        ),
                      ),
                      AppSpacing.h24,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
