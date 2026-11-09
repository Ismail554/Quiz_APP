import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/models/v2_curriculum_models.dart';
import 'package:geography_geyser/views/custom_widgets/stitch_design_widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardRecentAttemptsSection extends StatelessWidget {
  final List<RecentAttemptItem> attempts;
  final void Function(RecentAttemptItem attempt) onRetakeTap;

  const DashboardRecentAttemptsSection({
    super.key,
    required this.attempts,
    required this.onRetakeTap,
  });

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes.clamp(1, 59)}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    if (attempts.isEmpty) {
      return StitchCard(
        child: Row(
          children: [
            Icon(
              Icons.history_edu_rounded,
              color: AppColors.primaryAzure,
              size: 28.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'Complete your first quiz to track your recent attempts and grade history here.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.softSlate,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final displayList = attempts.take(3).toList();
    return Column(
      children: displayList.map((attempt) {
        final pct = attempt.scorePercent;
        final badgeColor = pct >= 80
            ? AppColors.easyEmerald
            : (pct >= 60 ? AppColors.mediumAmber : AppColors.hardRose);

        return Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: StitchCard(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            onTap: () => onRetakeTap(attempt),
            child: Row(
              children: [
                Container(
                  width: 46.r,
                  height: 46.r,
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    attempt.grade,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: badgeColor,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (attempt.isYouTubeQuiz) ...[
                            Icon(
                              Icons.play_circle_fill_rounded,
                              size: 13.sp,
                              color: AppColors.youtubeRed,
                            ),
                            SizedBox(width: 4.w),
                          ],
                          Expanded(
                            child: Text(
                              attempt.quizTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.neutralDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        '${attempt.moduleName} • ${attempt.correctAnswers}/${attempt.totalQuestions} (${attempt.scorePercent}%) • ${_relativeTime(attempt.completedAt)}',
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '+${attempt.xpGained} XP',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.accentGold,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.replay_rounded,
                          size: 13.sp,
                          color: AppColors.primaryAzure,
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          'Retry',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryAzure,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
