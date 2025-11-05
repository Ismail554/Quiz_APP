import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_spacing.dart';
import 'package:geography_geyser/core/app_strings.dart';
import 'package:geography_geyser/core/font_manager.dart';
import 'package:geography_geyser/custom_widgets/custom_module.dart';
import 'package:geography_geyser/views/home/homepage.dart';
import 'package:geography_geyser/views/modules/module_home.dart';
import 'package:geography_geyser/views/modules/select_time.dart';

class QuizResult_Screen extends StatelessWidget {
  const QuizResult_Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              // Title
              Text(
                AppStrings.quizCompleteTitle,
                style: FontManager.bigTitle(
                  fontSize: 28,
                  color: AppColors.blue,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.h24,

              // Result Summary Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    buildResultRow(
                      icon: Icons.check_circle,
                      iconColor: AppColors.green,
                      label: AppStrings.correctLabel,
                      value: AppStrings.correctValue,
                      valueColor: AppColors.green,
                    ),
                    // AppSpacing.h8,
                    buildResultRow(
                      icon: Icons.cancel,
                      iconColor: AppColors.red,
                      label: AppStrings.incorrectLabel,
                      value: AppStrings.incorrectValue,
                      valueColor: AppColors.red,
                    ),
                    // AppSpacing.h8,
                    buildResultRow(
                      icon: Icons.emoji_events,
                      iconColor: AppColors.yellow,
                      label: AppStrings.scoreLabel,
                      value: AppStrings.scoreValue,
                      valueColor: AppColors.yellow,
                    ),
                    // AppSpacing.h8,
                    buildResultRow(
                      icon: Icons.star,
                      iconColor: AppColors.yellow,
                      label: AppStrings.gradeLabel,
                      value: AppStrings.gradeValue,
                      valueColor: AppColors.yellow,
                    ),
                    AppSpacing.h8,
                    buildXPGainedRow(
                      labelText: AppStrings.xpGainedLabel,
                      valueText: AppStrings.xpGainedValue,
                    ),
                  ],
                ),
              ),
              AppSpacing.h32,

              // Attend another Quiz section
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  AppStrings.attendAnotherQuizInstruction,
                  style: FontManager.boldHeading(
                    fontSize: 18,
                    color: AppColors.grey4B,
                  ),
                ),
              ),
              AppSpacing.h16,

              // Quiz topic options
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.blueTransparent),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomModule(
                  text: AppStrings.carbonCycleSubject,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SelectTime_screen(),
                      ),
                    );
                  },
                ),
              ),
              // CustomQuizTopicOption(AppStrings.quizButtonCarbonCycle),
              AppSpacing.h12,
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.blueTransparent),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomModule(
                  text: AppStrings.coastsSubject,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SelectTime_screen(),
                      ),
                    );
                  },
                ),
              ),
              // CustomQuizTopicOption(AppStrings.quizButtonCoasts),
              AppSpacing.h32,

              // Bottom action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ModuleHomeScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        foregroundColor: AppColors.white,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        AppStrings.retryQuizButton,
                        style: FontManager.buttonText().copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                  AppSpacing.w16,
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomePageScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonColor,
                        foregroundColor: AppColors.white,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        AppStrings.returnMenuButton,
                        style: FontManager.buttonText().copyWith(
                          color: AppColors.white,
                        ),
                      ),
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
    return Card(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 8.0.h),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: iconColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.white, size: 20.sp),
            ),
            AppSpacing.w16,
            Expanded(
              child: Text(
                label,
                style: FontManager.generalText(
                  fontSize: 20,
                ).copyWith(color: iconColor, fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              value,
              style: FontManager.boldHeading(fontSize: 18, color: valueColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildXPGainedRow({
    required String labelText,
    required String valueText,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.green,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.flash_on, color: AppColors.white, size: 20.sp),
          ),
          AppSpacing.w16,
          Expanded(
            child: Text(
              labelText,
              // AppStrings.xpGainedLabel,
              style: FontManager.generalText(
                fontSize: 16,
              ).copyWith(color: AppColors.white, fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            valueText,
            // AppStrings.xpGainedValue,
            style: FontManager.boldHeading(
              fontSize: 18,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget CustomQuizTopicOption(String topic) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Text(
        topic,
        style: FontManager.bodyText().copyWith(fontWeight: FontWeight.w500),
      ),
    );
  }
}
