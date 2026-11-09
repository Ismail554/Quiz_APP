import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/routes/app_routes.dart';
import 'package:geography_geyser/views/custom_widgets/stitch_design_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardQuickActionBar extends StatelessWidget {
  final VoidCallback onOpenSpec;
  final VoidCallback onOpenYouTube;

  const DashboardQuickActionBar({
    super.key,
    required this.onOpenSpec,
    required this.onOpenYouTube,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionTile(
            title: 'Specification',
            subtitle: '12 A-Level Topics',
            icon: Icons.account_tree_rounded,
            iconColor: AppColors.primaryAzure,
            iconBg: const Color(0xFFE0F2FE),
            onTap: onOpenSpec,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _buildActionTile(
            title: 'YouTube Hub',
            subtitle: 'Video Lessons',
            icon: Icons.ondemand_video_rounded,
            iconColor: const Color(0xFFDC2626),
            iconBg: const Color(0xFFFEE2E2),
            onTap: onOpenYouTube,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _buildActionTile(
            title: 'Paper 3',
            subtitle: 'Synoptic Links',
            icon: Icons.hub_rounded,
            iconColor: const Color(0xFF8B5CF6),
            iconBg: const Color(0xFFEDE9FE),
            onTap: () {
              context.push(
                AppRoutes.quizPath(
                  moduleId: 'synoptic',
                  moduleName: 'Paper 3 Synoptic Challenge',
                  timeInMinutes: 10,
                  totalQuestions: 10,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required VoidCallback onTap,
  }) {
    return StitchCard(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(9.r),
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.neutralDark,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.softSlate,
            ),
          ),
        ],
      ),
    );
  }
}
