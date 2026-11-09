import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/models/userstats_model.dart';
import 'package:geography_geyser/models/v2_curriculum_models.dart';
import 'package:geography_geyser/views/custom_widgets/stitch_design_widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardRecentScoreCard extends StatelessWidget {
  final RecentAttemptItem? latestAttempt;
  final UserStatsModel? stats;
  final VoidCallback? onRetakeLatest;
  final VoidCallback onViewStatsTap;

  const DashboardRecentScoreCard({
    super.key,
    required this.latestAttempt,
    required this.stats,
    this.onRetakeLatest,
    required this.onViewStatsTap,
  });

  @override
  Widget build(BuildContext context) {
    final scorePercent =
        latestAttempt?.scorePercent ?? (stats?.averageScore ?? 85).round();
    final quizTitle =
        latestAttempt?.quizTitle ?? 'Tectonic Hazards & PAR Model';
    final moduleName = latestAttempt?.moduleName ?? 'Tectonics';
    final grade = latestAttempt?.grade ?? 'A';
    final xpGained = latestAttempt?.xpGained ?? 120;
    final avgScore = stats?.averageScore ?? 84.5;
    final totalQuizzes = stats?.totalAttemptedQuizzes ?? 18;

    final scoreColor = scorePercent >= 80
        ? AppColors.easyEmerald
        : (scorePercent >= 60 ? AppColors.mediumAmber : AppColors.hardRose);

    return Column(
      children: [
        StitchCard(
          padding: EdgeInsets.all(18.r),
          onTap: onRetakeLatest,
          child: Row(
            children: [
              // Circular Score Gauge
              SizedBox(
                width: 68.r,
                height: 68.r,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 68.r,
                      height: 68.r,
                      child: CircularProgressIndicator(
                        value: (scorePercent / 100).clamp(0.0, 1.0),
                        strokeWidth: 7,
                        backgroundColor: scoreColor.withValues(alpha: 0.14),
                        valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$scorePercent%',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.neutralDark,
                          ),
                        ),
                        Text(
                          'Grade $grade',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: scoreColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        StitchBadge(
                          label: 'RECENT SCORE',
                          icon: Icons.bolt_rounded,
                          color: AppColors.primaryAzure,
                        ),
                        SizedBox(width: 6.w),
                        StitchBadge(
                          label: '+$xpGained XP',
                          color: AppColors.accentGold,
                          backgroundColor: AppColors.accentAmberLight,
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      quizTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.neutralDark,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      '$moduleName • ${latestAttempt != null ? '${latestAttempt!.correctAnswers}/${latestAttempt!.totalQuestions} Correct' : 'Latest completed assessment'}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.softSlate,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.primaryAzure,
                size: 22.sp,
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        // Mini Stat Row
        Row(
          children: [
            Expanded(
              child: _MiniMetricTile(
                icon: Icons.auto_graph_rounded,
                iconColor: AppColors.primaryAzure,
                label: 'Average Score',
                value: '${avgScore.toStringAsFixed(1)}%',
                onTap: onViewStatsTap,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _MiniMetricTile(
                icon: Icons.fact_check_rounded,
                iconColor: AppColors.easyEmerald,
                label: 'Quizzes Completed',
                value: '$totalQuizzes',
                onTap: onViewStatsTap,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MiniMetricTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _MiniMetricTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return StitchCard(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(9.r),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: iconColor, size: 19.sp),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.neutralDark,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.softSlate,
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
