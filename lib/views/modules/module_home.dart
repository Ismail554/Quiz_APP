import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/data/static_curriculum_data.dart';
import 'package:geography_geyser/core/data/static_youtube_data.dart';
import 'package:geography_geyser/provider/local_progress_provider.dart';
import 'package:geography_geyser/routes/app_routes.dart';
import 'package:geography_geyser/views/custom_widgets/stitch_design_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ModuleHomeScreen extends StatelessWidget {
  final bool showBackButton;
  final bool hideback;

  const ModuleHomeScreen({
    super.key,
    this.showBackButton = false,
    this.hideback = false,
  });

  @override
  Widget build(BuildContext context) {
    final progressProvider = context.watch<LocalProgressProvider>();
    final totalSpecQuizzes = StaticCurriculumData.allModules.fold<int>(
      0,
      (sum, m) => sum + m.totalSubQuizzes,
    );
    final totalYtQuizzes = StaticYouTubeData.videos.length;
    final shouldShowBack = (showBackButton || hideback) && context.canPop();

    return StitchAmbientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        leading: shouldShowBack
            ? IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.neutralDark,
                  size: 20.sp,
                ),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(AppRoutes.home);
                  }
                },
              )
            : null,
        title: Text(
          'Quiz Discovery Hub',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.neutralDark,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subtitle Banner
              Text(
                'Choose your learning pathway',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.softSlate,
                ),
              ),
              SizedBox(height: 14.h),

              // ===============================================================
              // OPTION A — SPECIFICATION QUIZ CARD
              // ===============================================================
              FadeInUp(
                duration: const Duration(milliseconds: 320),
                child: _PathwayHeroCard(
                  optionTag: 'OPTION A • EDEXCEL SPECIFICATION',
                  title: 'Specification Quiz',
                  description:
                      'Navigate Group A (EQ1–EQ3) & Group B (EQ1–EQ4) modules to master every Enquiry Question and topic sub-quiz.',
                  badgeLeft: '12 Modules • 43 EQs',
                  badgeRight: '$totalSpecQuizzes Sub-Quizzes',
                  ctaText: 'Explore Specification',
                  icon: Icons.account_tree_rounded,
                  gradient: AppColors.heroCardGradient,
                  onTap: () => context.push(AppRoutes.specModules),
                ),
              ),
              SizedBox(height: 16.h),

              // ===============================================================
              // OPTION B — YOUTUBE QUIZ CARD
              // ===============================================================
              FadeInUp(
                duration: const Duration(milliseconds: 420),
                child: _PathwayHeroCard(
                  optionTag: 'OPTION B • @GEOGRAPHYGEYSER VIDEO LESSONS',
                  title: 'YouTube Quiz',
                  description:
                      'Jump straight into quizzes paired with official Geography Geyser YouTube lessons, case studies & exam technique videos.',
                  badgeLeft: '$totalYtQuizzes Video Quizzes',
                  badgeRight: 'Direct Launch',
                  ctaText: 'Browse Video Quizzes',
                  icon: Icons.ondemand_video_rounded,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF991B1B),
                      Color(0xFFDC2626),
                      Color(0xFFF43F5E),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: () => context.push(AppRoutes.youtubeQuizzes),
                ),
              ),
              SizedBox(height: 24.h),

              // ===============================================================
              // QUICK MODULE JUMP (GROUP A & GROUP B PREVIEW)
              // ===============================================================
              StitchSectionHeader(
                title: 'Quick Jump by Module',
                subtitle: 'Tap any module to open its Enquiry Questions (EQs)',
                leadingIcon: Icons.grid_view_rounded,
                actionLabel: 'All 12 Modules',
                onActionTap: () => context.push(AppRoutes.specModules),
              ),
              SizedBox(height: 12.h),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 6,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12.h,
                  crossAxisSpacing: 12.w,
                  childAspectRatio: 1.38,
                ),
                itemBuilder: (context, index) {
                  final modules = [
                    StaticCurriculumData.allModules[0], // Tectonics (Group A)
                    StaticCurriculumData.allModules[1], // Carbon (Group A)
                    StaticCurriculumData.allModules[2], // Water (Group A)
                    StaticCurriculumData.allModules[5], // Coasts (Group B)
                    StaticCurriculumData.allModules[4], // Superpowers (Group A)
                    StaticCurriculumData.allModules[7], // Regenerating Places (Group B)
                  ];
                  final module = modules[index];

                  return StitchCard(
                    padding: EdgeInsets.all(14.r),
                    onTap: () {
                      context.push(
                        AppRoutes.specEqSelectionPath(module.id),
                        extra: module,
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Hero(
                              tag: 'module_hero_${module.id}',
                              child: Container(
                                width: 36.r,
                                height: 36.r,
                                decoration: BoxDecoration(
                                  color:
                                      module.accentColor.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Icon(
                                  module.icon,
                                  color: module.accentColor,
                                  size: 20.sp,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 7.w,
                                vertical: 3.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.softSky,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                '${module.enquiryQuestions.length} EQs',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryAzure,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          module.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.5.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.neutralDark,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          module.group.shortBadge,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.softSlate,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(height: 16.h),

              // Synoptic Assessment Shortcut
              StitchCard(
                padding: EdgeInsets.all(16.r),
                borderColor: AppColors.accentGold.withValues(alpha: 0.45),
                backgroundColor: const Color(0xFFFFFBEB),
                onTap: () {
                  context.push(
                    AppRoutes.selectTime,
                    extra: {
                      'moduleId': 'synoptic',
                      'moduleName': 'Paper 3 Synoptic Challenge',
                    },
                  );
                },
                child: Row(
                  children: [
                    Container(
                      width: 46.r,
                      height: 46.r,
                      decoration: BoxDecoration(
                        gradient: AppColors.goldBadgeGradient,
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.white,
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 13.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Paper 3 Synoptic Assessment',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.neutralDark,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Test cross-topic links, Players, Attitudes & Futures (${progressProvider.completedBestScores['synoptic'] != null ? 'Best: ${progressProvider.completedBestScores['synoptic']}%' : '+150 XP bonus'})',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.softSlate,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16.sp,
                      color: AppColors.accentGold,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _PathwayHeroCard extends StatelessWidget {
  final String optionTag;
  final String title;
  final String description;
  final String badgeLeft;
  final String badgeRight;
  final String ctaText;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  const _PathwayHeroCard({
    required this.optionTag,
    required this.title,
    required this.description,
    required this.badgeLeft,
    required this.badgeRight,
    required this.ctaText,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutralDark.withValues(alpha: 0.16),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24.r),
          child: Stack(
            children: [
              Positioned(
                right: -20.w,
                bottom: -25.h,
                child: Icon(
                  icon,
                  size: 128.sp,
                  color: Colors.white.withValues(alpha: 0.10),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(22.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            optionTag,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: EdgeInsets.all(9.r),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            icon,
                            color: Colors.white,
                            size: 22.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.4,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      description,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.88),
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 18.h),
                    Row(
                      children: [
                        _MiniWhitePill(text: badgeLeft),
                        SizedBox(width: 8.w),
                        _MiniWhitePill(text: badgeRight),
                        const Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 9.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                ctaText,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.neutralDark,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 15.sp,
                                color: AppColors.neutralDark,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniWhitePill extends StatelessWidget {
  final String text;

  const _MiniWhitePill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10.5.sp,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
