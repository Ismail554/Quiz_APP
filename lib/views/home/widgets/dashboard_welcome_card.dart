import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/models/home_model.dart';
import 'package:geography_geyser/models/userstats_model.dart';
import 'package:geography_geyser/services/api_service.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardWelcomeCard extends StatelessWidget {
  final HomeModel? user;
  final UserStatsModel? stats;
  final VoidCallback onProfileTap;

  const DashboardWelcomeCard({
    super.key,
    required this.user,
    required this.stats,
    required this.onProfileTap,
  });

  String _greetingByHour() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final fullName = (user?.fullName?.trim().isNotEmpty == true)
        ? user!.fullName!
        : 'Alex Rivera';
    final totalXp = stats?.totalXp ?? 2450;
    final streak = stats?.dailyStreak ?? 7;
    final strongest = (stats?.strongestModule.trim().isNotEmpty == true)
        ? stats!.strongestModule
        : 'Tectonics';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.heroCardGradient,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryAzure.withValues(alpha: 0.26),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -25.w,
            top: -25.h,
            child: Container(
              width: 120.w,
              height: 120.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            right: 40.w,
            bottom: -35.h,
            child: Icon(
              Icons.public_rounded,
              size: 110.sp,
              color: Colors.white.withValues(alpha: 0.07),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: onProfileTap,
                      child: Hero(
                        tag: 'profile_avatar_hero',
                        child: Container(
                          padding: EdgeInsets.all(2.5.r),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.85),
                              width: 2,
                            ),
                          ),
                          child: _buildAvatar(user?.profilePic),
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
                              Text(
                                '${_greetingByHour()} 👋',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.88),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            fullName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Edexcel A-Level Geography Explorer',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.80),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Streak Flame Pill
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 11.w,
                        vertical: 7.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_fire_department_rounded,
                            color: const Color(0xFFFBBF24),
                            size: 18.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '${streak}d',
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
                SizedBox(height: 16.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.14),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.emoji_events_rounded,
                        color: const Color(0xFFFBBF24),
                        size: 18.sp,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        '$totalXp XP',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 12.w),
                        width: 1,
                        height: 14.h,
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                      Icon(
                        Icons.workspace_premium_rounded,
                        color: const Color(0xFF7DD3FC),
                        size: 17.sp,
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          'Top Module: $strongest',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withValues(alpha: 0.95),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String? profilePicUrl) {
    if (profilePicUrl != null && profilePicUrl.isNotEmpty) {
      final imageUrl =
          profilePicUrl.startsWith('http://') ||
              profilePicUrl.startsWith('https://')
          ? profilePicUrl
          : '${ApiService.baseUrl}/${profilePicUrl.startsWith('/') ? profilePicUrl.substring(1) : profilePicUrl}';
      return CircleAvatar(
        radius: 26.r,
        backgroundColor: Colors.white24,
        child: ClipOval(
          child: Image.network(
            imageUrl,
            width: 52.r,
            height: 52.r,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Image.asset(
              'assets/images/man.png',
              width: 52.r,
              height: 52.r,
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    }
    return CircleAvatar(
      radius: 26.r,
      backgroundColor: Colors.white24,
      backgroundImage: const AssetImage('assets/images/man.png'),
    );
  }
}
