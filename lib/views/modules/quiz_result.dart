import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_logger.dart';
import 'package:geography_geyser/core/app_spacing.dart';
import 'package:geography_geyser/core/app_strings.dart';
import 'package:geography_geyser/core/font_manager.dart';
import 'package:geography_geyser/models/quiz_model.dart';
import 'package:geography_geyser/provider/module_provider/quiz_finish_provider.dart';
import 'package:geography_geyser/provider/module_provider/quiz_provider.dart';
import 'package:geography_geyser/routes/app_routes.dart';
import 'package:geography_geyser/views/custom_widgets/stitch_design_widgets.dart';
import 'package:provider/provider.dart';

class QuizResult_Screen extends StatefulWidget {
  const QuizResult_Screen({super.key});

  @override
  State<QuizResult_Screen> createState() => _QuizResult_ScreenState();
}

class _QuizResult_ScreenState extends State<QuizResult_Screen> {
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeQuizData();
  }

  Future<void> _initializeQuizData() async {
    if (_hasInitialized) return;
    _hasInitialized = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final quizFinishProvider = Provider.of<QuizFinishProvider>(
        context,
        listen: false,
      );
      final quizProvider = Provider.of<QuizProvider>(context, listen: false);

      if (quizFinishProvider.quizFinishData == null &&
          !quizFinishProvider.isLoading) {
        final quizId = quizProvider.quizData?.quizId;
        final questions = quizProvider.quizData?.questions ?? [];

        if (quizId != null && quizId.isNotEmpty && questions.isNotEmpty) {
          final attempted = questions.length;
          await quizFinishProvider.finishQuiz(quizId, 0, attempted);
        }
      }
    });
  }

  void _showQuestionReviewSheet(
    BuildContext context,
    List<QuestionModel> questions,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.82,
          minChildSize: 0.5,
          maxChildSize: 0.94,
          builder: (_, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: AppColors.softSky,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
              ),
              padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: AppColors.slateBorder,
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Question & Mark Scheme Review',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.neutralDark,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      physics: const BouncingScrollPhysics(),
                      itemCount: questions.length,
                      separatorBuilder: (_, __) => SizedBox(height: 10.h),
                      itemBuilder: (context, index) {
                        final q = questions[index];
                        final options = q.optionsList;
                        final correctIdx = q.correctAnswerIndex.clamp(
                          0,
                          options.isEmpty ? 0 : options.length - 1,
                        );
                        final correctOption = options.isNotEmpty
                            ? options[correctIdx]
                            : q.correctAnswer;

                        return StitchCard(
                          padding: EdgeInsets.all(14.r),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'QUESTION ${index + 1}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10.5.sp,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryAzure,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                q.questionText,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.5.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.neutralDark,
                                ),
                              ),
                              SizedBox(height: 10.h),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 9.h,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: AppColors.emeraldSuccess.withValues(
                                      alpha: 0.4,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle_rounded,
                                      size: 17.sp,
                                      color: AppColors.emeraldSuccess,
                                    ),
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      child: Text(
                                        'Correct Answer: $correctOption',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12.5.sp,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF065F46),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final quizProvider = context.watch<QuizProvider>();
    final questions = quizProvider.quizData?.questions ?? [];

    return StitchAmbientScaffold(
      body: SafeArea(
        child: Consumer<QuizFinishProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryAzure),
              );
            }

            if (provider.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64.sp, color: AppColors.red),
                    AppSpacing.h16,
                    Text(
                      AppLogger.getSafeErrorMessage(provider.errorMessage!),
                      style: FontManager.bodyText(),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            final quizData = provider.quizFinishData;
            if (quizData == null) {
              return _buildFallbackUI(context);
            }

            final attempted =
                provider.attemptedQuestions ?? quizData.totalQuestions;
            final correctAnswers = quizData.correctAnswers;
            final totalQuestions = attempted;
            final incorrectAnswers = (totalQuestions - correctAnswers).clamp(
              0,
              999,
            );
            final score = quizData.score;
            final grade = quizData.grade;
            final xpGained = quizData.xpGained;
            final attendAnotherQuiz = quizData.attendAnotherQuiz;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 28.h),
              child: Column(
                children: [
                  // Celebratory Header Banner
                  FadeInDown(
                    duration: const Duration(milliseconds: 450),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(22.r),
                      decoration: BoxDecoration(
                        gradient: AppColors.oceanHeaderGradient,
                        borderRadius: BorderRadius.circular(26.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryAzure.withValues(
                              alpha: 0.24,
                            ),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 72.w,
                            height: 72.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.16),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.35),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                grade,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 28.sp,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            AppStrings.quizCompleteTitle,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'You scored $score% ($correctAnswers/$totalQuestions correct)',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          SizedBox(height: 14.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 7.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.emeraldSuccess,
                              borderRadius: BorderRadius.circular(999.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.bolt_rounded,
                                  color: Colors.white,
                                  size: 17.sp,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  '+$xpGained XP Earned',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 18.h),

                  // Detailed Breakdown Card
                  FadeInUp(
                    duration: const Duration(milliseconds: 500),
                    child: StitchCard(
                      padding: EdgeInsets.all(18.r),
                      child: Column(
                        children: [
                          buildResultRow(
                            icon: Icons.check_circle_rounded,
                            iconColor: AppColors.emeraldSuccess,
                            label: AppStrings.correctLabel,
                            value: '$correctAnswers',
                            valueColor: AppColors.emeraldSuccess,
                          ),
                          Divider(
                            color: AppColors.slateBorder,
                            height: 18.h,
                          ),
                          buildResultRow(
                            icon: Icons.cancel_rounded,
                            iconColor: AppColors.errorCoral,
                            label: AppStrings.incorrectLabel,
                            value: '$incorrectAnswers',
                            valueColor: AppColors.errorCoral,
                          ),
                          Divider(
                            color: AppColors.slateBorder,
                            height: 18.h,
                          ),
                          buildResultRow(
                            icon: Icons.emoji_events_rounded,
                            iconColor: AppColors.accentGold,
                            label: AppStrings.scoreLabel,
                            value: '$score%',
                            valueColor: AppColors.accentGoldDark,
                          ),
                          if (questions.isNotEmpty) ...[
                            SizedBox(height: 16.h),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    _showQuestionReviewSheet(context, questions),
                                icon: Icon(
                                  Icons.fact_check_rounded,
                                  size: 18.sp,
                                ),
                                label: const Text(
                                  'Review Questions & Mark Scheme',
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primaryAzure,
                                  side: const BorderSide(
                                    color: AppColors.primaryAzure,
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14.r),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 22.h),

                  // Recommended Next Quizzes
                  if (attendAnotherQuiz.isNotEmpty) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        AppStrings.attendAnotherQuizInstruction,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.neutralDark,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    ...attendAnotherQuiz.map((quiz) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: StitchCard(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 14.h,
                          ),
                          onTap: () {
                            context.push(
                              AppRoutes.selectTime,
                              extra: {
                                'moduleId': quiz.id,
                                'moduleName': quiz.moduleName,
                              },
                            );
                          },
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10.r),
                                decoration: BoxDecoration(
                                  color: AppColors.softSky,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Icon(
                                  Icons.explore_rounded,
                                  color: AppColors.primaryAzure,
                                  size: 20.sp,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  quiz.moduleName,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.neutralDark,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 15.sp,
                                color: AppColors.primaryAzure,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    SizedBox(height: 16.h),
                  ],

                  // Bottom Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            context.go(AppRoutes.modules);
                          },
                          icon: const Icon(Icons.replay_rounded),
                          label: Text(AppStrings.retryQuizButton),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryAzure,
                            side: const BorderSide(
                              color: AppColors.primaryAzure,
                              width: 1.4,
                            ),
                            padding: EdgeInsets.symmetric(vertical: 15.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.go(AppRoutes.home);
                          },
                          icon: const Icon(Icons.home_rounded),
                          label: Text(AppStrings.returnMenuButton),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryAzure,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 15.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFallbackUI(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: StitchCard(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.quizCompleteTitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.neutralDark,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.h16,
              Text(
                'Your quiz session has been recorded.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5.sp,
                  color: AppColors.neutralSlate,
                ),
              ),
              AppSpacing.h24,
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.go(AppRoutes.modules),
                      child: Text(AppStrings.retryQuizButton),
                    ),
                  ),
                  AppSpacing.w12,
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => context.go(AppRoutes.home),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryAzure,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(AppStrings.returnMenuButton),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildResultRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Row(
      children: [
        Container(
          width: 38.w,
          height: 38.w,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20.sp),
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.5.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.neutralDark,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 17.sp,
            fontWeight: FontWeight.w800,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
