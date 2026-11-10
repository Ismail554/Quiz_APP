import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/data/static_curriculum_data.dart';
import 'package:geography_geyser/models/v2_curriculum_models.dart';
import 'package:geography_geyser/views/custom_widgets/stitch_design_widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardAvailableQuizzesSection extends StatelessWidget {
  final void Function(SubQuizItem subQuiz) onStartSubQuiz;
  final void Function(SpecModuleItem module) onOpenModule;

  const DashboardAvailableQuizzesSection({
    super.key,
    required this.onStartSubQuiz,
    required this.onOpenModule,
  });

  @override
  Widget build(BuildContext context) {
    // Curate 4 diverse quizzes across Easy, Medium, and Hard difficulties
    final recommended = <SubQuizItem>[
      StaticCurriculumData.allModules[0].enquiryQuestions[0].subQuizzes[0], // Tectonics Easy
      StaticCurriculumData.allModules[1].enquiryQuestions[1].subQuizzes[1], // Carbon EQ2 Medium
      StaticCurriculumData.allModules[5].enquiryQuestions[3].subQuizzes[2], // Coasts EQ4 Hard
      StaticCurriculumData.allModules[4].enquiryQuestions[2].subQuizzes[1], // Superpowers EQ3 Medium
    ];

    return Column(
      children: recommended.map((quiz) {
        final module = StaticCurriculumData.findModuleById(quiz.moduleId);
        final accent = module?.accentColor ?? AppColors.primaryAzure;

        return Padding(
          padding: EdgeInsets.only(bottom: 11.h),
          child: StitchCard(
            padding: EdgeInsets.all(15.r),
            onTap: () => onStartSubQuiz(quiz),
            child: Row(
              children: [
                Hero(
                  tag: 'quiz_icon_${quiz.id}',
                  child: Container(
                    width: 48.r,
                    height: 48.r,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Icon(
                      module?.icon ?? Icons.public_rounded,
                      color: accent,
                      size: 24.sp,
                    ),
                  ),
                ),
                SizedBox(width: 13.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: StitchBadge(
                              label: '${quiz.moduleName} • EQ${quiz.eqNumber}',
                              color: accent,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          DifficultyBadge(
                            difficulty: quiz.difficulty,
                            compact: true,
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        quiz.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.5.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.neutralDark,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        '${quiz.questionCount} Questions • ~${quiz.estimatedMinutes} mins',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.softSlate,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryAzure.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    'Start',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryAzure,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
