import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/data/static_curriculum_data.dart';
import 'package:geography_geyser/models/v2_curriculum_models.dart';
import 'package:geography_geyser/provider/local_progress_provider.dart';
import 'package:geography_geyser/routes/app_routes.dart';
import 'package:geography_geyser/views/custom_widgets/stitch_design_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SubQuizSelectionScreen extends StatelessWidget {
  final String moduleId;
  final int eqNumber;
  final EnquiryQuestionItem? initialEq;

  const SubQuizSelectionScreen({
    super.key,
    required this.moduleId,
    required this.eqNumber,
    this.initialEq,
  });

  @override
  Widget build(BuildContext context) {
    final module = StaticCurriculumData.findModuleById(moduleId) ??
        StaticCurriculumData.allModules.first;
    final eq = initialEq ??
        StaticCurriculumData.findEqById(module.id, eqNumber) ??
        module.enquiryQuestions.first;
    final progressProvider = context.watch<LocalProgressProvider>();

    return StitchAmbientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.neutralDark,
            size: 20.sp,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '${module.name} • ${eq.eqBadge}',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18.sp,
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
              // EQ Summary Card
              StitchCard(
                padding: EdgeInsets.all(16.r),
                borderColor: module.accentColor.withValues(alpha: 0.35),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        StitchBadge(
                          label: 'LEVEL 3 OF 3',
                          color: AppColors.primaryAzure,
                        ),
                        SizedBox(width: 8.w),
                        StitchBadge(
                          label: '${module.name} • ${eq.eqBadge}',
                          color: module.accentColor,
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      eq.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15.5.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.neutralDark,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      eq.keyFocus,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.softSlate,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),

              const StitchSectionHeader(
                title: 'Available Sub-Quizzes',
                subtitle: 'Choose a difficulty tier to start or resume your assessment',
                leadingIcon: Icons.auto_stories_rounded,
              ),
              SizedBox(height: 14.h),

              ...eq.subQuizzes.asMap().entries.map((entry) {
                final subQuiz = entry.value;
                final isResumable =
                    progressProvider.isQuizInProgress(subQuiz.id);
                final isCompleted =
                    progressProvider.isQuizCompleted(subQuiz.id);
                final bestScore = progressProvider.getBestScore(subQuiz.id);

                return FadeInUp(
                  duration: Duration(milliseconds: 280 + (entry.key * 80)),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 14.h),
                    child: StitchCard(
                      padding: EdgeInsets.all(18.r),
                      borderColor: isResumable
                          ? AppColors.primarySky
                          : (isCompleted
                              ? AppColors.easyEmerald.withValues(alpha: 0.4)
                              : AppColors.azureBorder),
                      onTap: () => _handleSubQuizTap(
                        context,
                        subQuiz,
                        isResumable: isResumable,
                        unfinished: progressProvider.unfinishedSession,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              DifficultyBadge(difficulty: subQuiz.difficulty),
                              SizedBox(width: 8.w),
                              StitchBadge(
                                label: 'Available',
                                icon: Icons.verified_rounded,
                                color: AppColors.primaryAzure,
                              ),
                              const Spacer(),
                              if (isResumable)
                                StitchBadge(
                                  label: 'In Progress',
                                  icon: Icons.play_circle_fill_rounded,
                                  color: AppColors.accentGold,
                                  backgroundColor: AppColors.accentAmberLight,
                                )
                              else if (isCompleted)
                                StitchBadge(
                                  label: 'Best: ${bestScore ?? 85}%',
                                  icon: Icons.check_circle_rounded,
                                  color: AppColors.easyEmerald,
                                  backgroundColor: AppColors.easyEmeraldBg,
                                ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            subQuiz.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.neutralDark,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            subQuiz.topicSummary,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.softSlate,
                              height: 1.35,
                            ),
                          ),
                          SizedBox(height: 14.h),
                          Row(
                            children: [
                              Icon(
                                Icons.format_list_numbered_rounded,
                                size: 15.sp,
                                color: AppColors.softSlate,
                              ),
                              SizedBox(width: 5.w),
                              Text(
                                '${subQuiz.questionCount} Questions',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.softSlate,
                                ),
                              ),
                              SizedBox(width: 14.w),
                              Icon(
                                Icons.schedule_rounded,
                                size: 15.sp,
                                color: AppColors.softSlate,
                              ),
                              SizedBox(width: 5.w),
                              Text(
                                '~${subQuiz.estimatedMinutes} Mins',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.softSlate,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 9.h,
                                ),
                                decoration: BoxDecoration(
                                  gradient: isResumable
                                      ? AppColors.goldBadgeGradient
                                      : AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(12.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryAzure.withValues(
                                        alpha: 0.22,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isResumable
                                          ? Icons.play_arrow_rounded
                                          : (isCompleted
                                              ? Icons.replay_rounded
                                              : Icons.rocket_launch_rounded),
                                      size: 15.sp,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 5.w),
                                    Text(
                                      isResumable
                                          ? 'Resume'
                                          : (isCompleted
                                              ? 'Retry Quiz'
                                              : 'Start Quiz'),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12.5.sp,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSubQuizTap(
    BuildContext context,
    SubQuizItem subQuiz, {
    required bool isResumable,
    UnfinishedQuizSession? unfinished,
  }) {
    if (isResumable && unfinished != null) {
      context.push(
        AppRoutes.quizPath(
          moduleId: subQuiz.id,
          moduleName: '${subQuiz.moduleName} • ${subQuiz.title}',
          timeInMinutes: unfinished.totalTimeMinutes,
          totalQuestions: subQuiz.questionCount,
        ),
        extra: {
          'moduleId': subQuiz.id,
          'moduleName': '${subQuiz.moduleName} • ${subQuiz.title}',
          'timeInMinutes': unfinished.totalTimeMinutes,
          'totalQuestions': subQuiz.questionCount,
          'initialQuestionIndex': unfinished.currentQuestionIndex,
          'initialCorrectCount': unfinished.correctAnswersCount,
          'initialTimeRemainingSeconds': unfinished.timeRemainingSeconds,
        },
      );
      return;
    }

    context.push(
      AppRoutes.selectTime,
      extra: {
        'moduleId': subQuiz.id,
        'moduleName': '${subQuiz.moduleName} • ${subQuiz.title}',
      },
    );
  }
}
