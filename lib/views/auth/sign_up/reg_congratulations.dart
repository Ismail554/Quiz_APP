import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_spacing.dart';
import 'package:geography_geyser/routes/app_routes.dart';
import 'package:geography_geyser/views/custom_widgets/custom_login_button.dart';

class RegCongratulations_Screen extends StatefulWidget {
  const RegCongratulations_Screen({super.key});

  @override
  State<RegCongratulations_Screen> createState() =>
      _RegCongratulations_ScreenState();
}

class _RegCongratulations_ScreenState extends State<RegCongratulations_Screen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F9FF),
      body: Stack(
        children: [
          // Ambient celebratory particles/glow
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
                    const Color(0xFF10B981).withValues(alpha: 0.25),
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
                    const Color(0xFF52B1FF).withValues(alpha: 0.25),
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
                      AppSpacing.h24,

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
                              "Expedition Ready! 🎉",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 26.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.neutralDark,
                                letterSpacing: -0.5,
                              ),
                            ),
                            AppSpacing.h12,
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.w),
                              child: Text(
                                "Your explorer account has been created and verified. Prepare to discover the world and conquer geography trivia!",
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

                      // Unlocked Perks Container
                      FadeInUp(
                        duration: const Duration(milliseconds: 700),
                        child: Container(
                          padding: EdgeInsets.all(16.r),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24.r),
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
                          child: Column(
                            children: [
                              _buildPerkRow(
                                icon: Icons.public_rounded,
                                color: AppColors.primaryAzure,
                                title: "195+ Countries & Territories",
                                subtitle: "Flags, capitals, maps & trivia",
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.h),
                                child: const Divider(
                                  color: Color(0xFFF1F5F9),
                                  thickness: 1,
                                ),
                              ),
                              _buildPerkRow(
                                icon: Icons.military_tech_rounded,
                                color: const Color(0xFFF59E0B),
                                title: "Global Leaderboards",
                                subtitle: "Compete with players worldwide",
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.h),
                                child: const Divider(
                                  color: Color(0xFFF1F5F9),
                                  thickness: 1,
                                ),
                              ),
                              _buildPerkRow(
                                icon: Icons.bolt_rounded,
                                color: const Color(0xFF10B981),
                                title: "Daily Geyser Streaks",
                                subtitle: "Earn points and special explorer badges",
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
                          text: "Begin Journey (Log In) 🚀",
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

  Widget _buildPerkRow({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 38.w,
          height: 38.h,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutralDark,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
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
    );
  }
}
