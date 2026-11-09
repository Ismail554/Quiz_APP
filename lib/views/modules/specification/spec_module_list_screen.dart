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

class SpecModuleListScreen extends StatefulWidget {
  const SpecModuleListScreen({super.key});

  @override
  State<SpecModuleListScreen> createState() => _SpecModuleListScreenState();
}

class _SpecModuleListScreenState extends State<SpecModuleListScreen> {
  int _selectedFilter = 0; // 0: All, 1: Group A, 2: Group B

  @override
  Widget build(BuildContext context) {
    final progressProvider = context.watch<LocalProgressProvider>();
    final groupA = StaticCurriculumData.groupAModules;
    final groupB = StaticCurriculumData.groupBModules;

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
          'Specification Quiz',
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
              // Breadcrumb Step Indicator
              _buildStepHeader(),
              SizedBox(height: 14.h),

              // Group Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChipPill(
                      label: 'All Modules (12)',
                      isSelected: _selectedFilter == 0,
                      onTap: () => setState(() => _selectedFilter = 0),
                    ),
                    SizedBox(width: 8.w),
                    _FilterChipPill(
                      label: 'Group A • Core (EQ1–EQ3)',
                      isSelected: _selectedFilter == 1,
                      onTap: () => setState(() => _selectedFilter = 1),
                    ),
                    SizedBox(width: 8.w),
                    _FilterChipPill(
                      label: 'Group B • Options (EQ1–EQ4)',
                      isSelected: _selectedFilter == 2,
                      onTap: () => setState(() => _selectedFilter = 2),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 18.h),

              // Group A Section
              if (_selectedFilter == 0 || _selectedFilter == 1) ...[
                const StitchSectionHeader(
                  title: 'Group A — Core Modules',
                  subtitle: 'Each module contains 3 Enquiry Questions (EQ1, EQ2, EQ3)',
                  leadingIcon: Icons.layers_rounded,
                ),
                SizedBox(height: 12.h),
                ...groupA.asMap().entries.map(
                      (entry) => FadeInUp(
                        duration: Duration(milliseconds: 280 + (entry.key * 45)),
                        child: _ModuleHierarchyCard(
                          module: entry.value,
                          completedMap: progressProvider.completedBestScores,
                          onTap: () {
                            context.push(
                              AppRoutes.specEqSelectionPath(entry.value.id),
                              extra: entry.value,
                            );
                          },
                        ),
                      ),
                    ),
                SizedBox(height: 18.h),
              ],

              // Group B Section
              if (_selectedFilter == 0 || _selectedFilter == 2) ...[
                const StitchSectionHeader(
                  title: 'Group B — Dynamic & Optional Modules',
                  subtitle: 'Each module contains 4 Enquiry Questions (EQ1, EQ2, EQ3, EQ4)',
                  leadingIcon: Icons.explore_rounded,
                ),
                SizedBox(height: 12.h),
                ...groupB.asMap().entries.map(
                      (entry) => FadeInUp(
                        duration: Duration(milliseconds: 280 + (entry.key * 45)),
                        child: _ModuleHierarchyCard(
                          module: entry.value,
                          completedMap: progressProvider.completedBestScores,
                          onTap: () {
                            context.push(
                              AppRoutes.specEqSelectionPath(entry.value.id),
                              extra: entry.value,
                            );
                          },
                        ),
                      ),
                    ),
                SizedBox(height: 16.h),
              ],

              // Synoptic Challenge Card
              _buildSynopticBanner(context),
              SizedBox(height: 28.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.azureBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              'LEVEL 1 OF 3',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.sp,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'Select a Module → Choose EQ → Start Sub-Quiz',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.softSlate,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSynopticBanner(BuildContext context) {
    return StitchCard(
      gradient: AppColors.heroCardGradient,
      borderColor: Colors.transparent,
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
            width: 50.r,
            height: 50.r,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              Icons.hub_rounded,
              color: Colors.white,
              size: 26.sp,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PAPER 3 • SYNOPTIC LINKS',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFFDE68A),
                    letterSpacing: 0.6,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  'Full Specification Synoptic Quiz',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15.5.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Connect Players, Attitudes & Futures across all modules',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white,
            size: 16.sp,
          ),
        ],
      ),
    );
  }
}

class _FilterChipPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChipPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : AppColors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.azureBorder,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryAzure.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.5.sp,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : AppColors.neutralSlate,
          ),
        ),
      ),
    );
  }
}

class _ModuleHierarchyCard extends StatelessWidget {
  final SpecModuleItem module;
  final Map<String, int> completedMap;
  final VoidCallback onTap;

  const _ModuleHierarchyCard({
    required this.module,
    required this.completedMap,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    int completedCount = 0;
    for (final eq in module.enquiryQuestions) {
      for (final sub in eq.subQuizzes) {
        if (completedMap.containsKey(sub.id)) completedCount++;
      }
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: StitchCard(
        padding: EdgeInsets.all(16.r),
        onTap: onTap,
        child: Row(
          children: [
            Hero(
              tag: 'module_hero_${module.id}',
              child: Container(
                width: 54.r,
                height: 54.r,
                decoration: BoxDecoration(
                  color: module.accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: module.accentColor.withValues(alpha: 0.28),
                  ),
                ),
                child: Icon(
                  module.icon,
                  color: module.accentColor,
                  size: 26.sp,
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
                        label: module.paperLabel,
                        color: module.accentColor,
                      ),
                      SizedBox(width: 6.w),
                      StitchBadge(
                        label: '${module.enquiryQuestions.length} EQs',
                        color: AppColors.primaryAzure,
                      ),
                      if (completedCount > 0) ...[
                        SizedBox(width: 6.w),
                        StitchBadge(
                          label: '$completedCount/${module.totalSubQuizzes} Done',
                          color: AppColors.easyEmerald,
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 7.h),
                  Text(
                    module.name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.neutralDark,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    module.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.softSlate,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: AppColors.softSky,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 15.sp,
                color: AppColors.primaryAzure,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
