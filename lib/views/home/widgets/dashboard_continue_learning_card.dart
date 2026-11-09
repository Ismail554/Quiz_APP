import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/models/v2_curriculum_models.dart';
import 'package:geography_geyser/views/custom_widgets/stitch_design_widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardContinueLearningCard extends StatelessWidget {
  final UnfinishedQuizSession session;
  final VoidCallback onResumeTap;
  final VoidCallback onDismissTap;

  const DashboardContinueLearningCard({
    super.key,
    required this.session,
    required this.onResumeTap,
    required this.onDismissTap,
  });

  @override
  Widget build(BuildContext context) {
    final currentQ =
        (session.currentQuestionIndex + 1).clamp(1, session.totalQuestions);
    final minsLeft = (session.timeRemainingSeconds / 60).ceil();

    return StitchCard(
      padding: EdgeInsets.all(16.r),
      borderColor: AppColors.primarySky.withValues(alpha: 0.45),
      backgroundColor: const Color(0xFFF8FDFF),
      onTap: onResumeTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.play_circle_fill_rounded,
                      size: 13.sp,
                      color: Colors.white,
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      'CONTINUE LEARNING',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              StitchBadge(
                label: session.moduleName,
                color: AppColors.deepOcean,
              ),
              const Spacer(),
              InkWell(
                onTap: onDismissTap,
                borderRadius: BorderRadius.circular(12.r),
                child: Padding(
                  padding: EdgeInsets.all(4.r),
                  child: Icon(
                    Icons.close_rounded,
                    size: 18.sp,
                    color: AppColors.mutedSlate,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            session.quizTitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.neutralDark,
            ),
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Icon(
                Icons.quiz_outlined,
                size: 14.sp,
                color: AppColors.softSlate,
              ),
              SizedBox(width: 5.w),
              Text(
                'Question $currentQ of ${session.totalQuestions}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.softSlate,
                ),
              ),
              SizedBox(width: 14.w),
              Icon(
                Icons.timer_outlined,
                size: 14.sp,
                color: AppColors.accentGold,
              ),
              SizedBox(width: 4.w),
              Text(
                '~$minsLeft min left',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accentGold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: LinearProgressIndicator(
                    value: session.progressFraction,
                    minHeight: 8.h,
                    backgroundColor: AppColors.azureSurface,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primaryAzure,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 14.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryAzure.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'Resume',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
