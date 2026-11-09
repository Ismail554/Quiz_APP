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

class EqSelectionScreen extends StatelessWidget {
  final String moduleId;
  final SpecModuleItem? initialModule;

  const EqSelectionScreen({
    super.key,
    required this.moduleId,
    this.initialModule,
  });

  @override
  Widget build(BuildContext context) {
    final module = initialModule ??
        StaticCurriculumData.findModuleById(moduleId) ??
        StaticCurriculumData.allModules.first;
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
          'Enquiry Questions',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 19.sp,
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
              // Hero Module Header Card
              StitchCard(
                padding: EdgeInsets.all(18.r),
                borderColor: module.accentColor.withValues(alpha: 0.35),
                child: Row(
                  children: [
                    Hero(
                      tag: 'module_hero_${module.id}',
                      child: Container(
                        width: 58.r,
                        height: 58.r,
                        decoration: BoxDecoration(
                          color: module.accentColor.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Icon(
                          module.icon,
                          color: module.accentColor,
                          size: 28.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              StitchBadge(
                                label: 'LEVEL 2 OF 3',
                                color: AppColors.primaryAzure,
                              ),
                              SizedBox(width: 6.w),
                              StitchBadge(
                                label: module.group.shortBadge,
                                color: module.accentColor,
                              ),
                            ],
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            module.name,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 19.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.neutralDark,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            module.shortTitle,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.softSlate,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),

              StitchSectionHeader(
                title: 'Select an Enquiry Question (${module.enquiryQuestions.length} EQs)',
                subtitle: module.group == ModuleGroup.groupA
                    ? 'Group A modules cover EQ1, EQ2, and EQ3'
                    : 'Group B modules cover EQ1, EQ2, EQ3, and EQ4',
                leadingIcon: Icons.help_outline_rounded,
              ),
              SizedBox(height: 14.h),

              ...module.enquiryQuestions.asMap().entries.map((entry) {
                final eq = entry.value;
                int doneCount = 0;
                for (final sq in eq.subQuizzes) {
                  if (progressProvider.isQuizCompleted(sq.id)) doneCount++;
                }

                return FadeInUp(
                  duration: Duration(milliseconds: 280 + (entry.key * 70)),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 14.h),
                    child: StitchCard(
                      padding: EdgeInsets.all(18.r),
                      onTap: () {
                        context.push(
                          AppRoutes.specSubQuizzesPath(
                            moduleId: module.id,
                            eqNumber: eq.eqNumber,
                          ),
                          extra: eq,
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Text(
                                  eq.eqBadge,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10.w),
                              StitchBadge(
                                label: '${eq.subQuizzes.length} Sub-Quizzes',
                                icon: Icons.quiz_outlined,
                                color: module.accentColor,
                              ),
                              const Spacer(),
                              if (doneCount > 0)
                                StitchBadge(
                                  label: '$doneCount/${eq.subQuizzes.length} Completed',
                                  icon: Icons.check_circle_rounded,
                                  color: AppColors.easyEmerald,
                                ),
                            ],
                          ),
                          SizedBox(height: 12.h),
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
                            'Key Specification Focus: ${eq.keyFocus}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.softSlate,
                              height: 1.35,
                            ),
                          ),
                          SizedBox(height: 14.h),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6.r),
                                  child: LinearProgressIndicator(
                                    value: eq.subQuizzes.isNotEmpty
                                        ? (doneCount / eq.subQuizzes.length)
                                            .clamp(0.06, 1.0)
                                        : 0.06,
                                    minHeight: 6.h,
                                    backgroundColor: AppColors.azureSurface,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      doneCount > 0
                                          ? AppColors.easyEmerald
                                          : module.accentColor,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Text(
                                'View Sub-Quizzes →',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5.sp,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryAzure,
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
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
