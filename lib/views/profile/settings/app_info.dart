import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_spacing.dart';
import 'package:geography_geyser/views/custom_widgets/custom_snackbar.dart';
import 'package:geography_geyser/views/custom_widgets/stitch_design_widgets.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StitchAmbientScaffold(
      appBar: AppBar(
        title: Text(
          'About Geography Geyser',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.neutralDark,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18.sp,
            color: AppColors.neutralDark,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 32.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: StitchCard(
                padding: EdgeInsets.all(22.r),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20.r),
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 76.w,
                        height: 76.w,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Geography Geyser',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.neutralDark,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Edexcel A-Level Geography Companion & YouTube Quiz Hub',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutralSlate,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    const StitchBadge(
                      label: 'Version 2.0.0 • Production Build',
                      color: AppColors.primaryAzure,
                      icon: Icons.verified_rounded,
                    ),
                  ],
                ),
              ),
            ),
            AppSpacing.h24,

            _buildSectionHeader('What’s New in Version 2'),
            AppSpacing.h10,
            StitchCard(
              padding: EdgeInsets.all(16.r),
              child: Column(
                children: [
                  _buildFeatureItem(
                    icon: Icons.account_tree_rounded,
                    color: AppColors.softSky,
                    iconColor: AppColors.primaryAzure,
                    title: 'Specification Quiz Hierarchy',
                    subtitle:
                        'Structured around Group A (3 EQs) & Group B (4 EQs) Edexcel A-Level Geography topics.',
                  ),
                  const Divider(color: Color(0xFFF1F5F9)),
                  _buildFeatureItem(
                    icon: Icons.ondemand_video_rounded,
                    color: const Color(0xFFFEE2E2),
                    iconColor: const Color(0xFFDC2626),
                    title: '@GeographyGeyser YouTube Quizzes',
                    subtitle:
                        'Watch a Geography Geyser revision video and jump straight into its linked quiz.',
                  ),
                  const Divider(color: Color(0xFFF1F5F9)),
                  _buildFeatureItem(
                    icon: Icons.link_rounded,
                    color: const Color(0xFFDCFCE7),
                    iconColor: AppColors.emeraldSuccess,
                    title: 'YouTube-to-App Deep Linking',
                    subtitle:
                        'Open any video description quiz link directly in the app with automatic session continuity.',
                  ),
                ],
              ),
            ),
            AppSpacing.h24,

            _buildSectionHeader('Privacy & Legal Summary'),
            AppSpacing.h10,
            StitchCard(
              padding: EdgeInsets.all(16.r),
              child: Text(
                'Geography Geyser respects student privacy. Your quiz scores, XP streaks, and selected optional modules are stored securely to personalize your revision dashboard. You can export or permanently delete your account at any time from Settings → Account Management.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.neutralSlate,
                  height: 1.5,
                ),
              ),
            ),
            AppSpacing.h24,

            _buildSectionHeader('Creator & Support'),
            AppSpacing.h10,
            StitchCard(
              onTap: () async {
                final Uri emailLaunchUri = Uri(
                  scheme: 'mailto',
                  path: 'simonA@standsureeducation.co.uk',
                );
                try {
                  await launchUrl(emailLaunchUri);
                } catch (_) {
                  if (context.mounted) {
                    CustomSnackBar.show(
                      context,
                      message: 'simonA@standsureeducation.co.uk',
                    );
                  }
                }
              },
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Icon(
                      Icons.mail_outline_rounded,
                      color: AppColors.accentGoldDark,
                      size: 22.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Email Support',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.neutralDark,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'simonA@standsureeducation.co.uk',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryAzure,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.open_in_new_rounded,
                    size: 18.sp,
                    color: AppColors.neutralMuted,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 15.sp,
        fontWeight: FontWeight.w800,
        color: AppColors.neutralDark,
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: iconColor, size: 20.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.neutralDark,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.neutralSlate,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
