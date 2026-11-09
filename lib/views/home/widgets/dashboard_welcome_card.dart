import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/models/home_model.dart';
import 'package:geography_geyser/models/userstats_model.dart';
import 'package:geography_geyser/views/custom_widgets/explorer_avatar.dart';
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
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _formatFirstName(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) return 'Explorer';
    final parts = fullName.trim().split(RegExp(r'\s+'));
    return parts.isNotEmpty ? parts[0] : 'Explorer';
  }

  @override
  Widget build(BuildContext context) {
    final rawName = (user?.fullName?.trim().isNotEmpty == true)
        ? user!.fullName!
        : 'Alex Rivera';
    final firstName = _formatFirstName(rawName);
    final totalXp = stats?.totalXp ?? 2450;
    final streak = stats?.dailyStreak ?? 7;
    final strongest = (stats?.strongestModule.trim().isNotEmpty == true)
        ? stats!.strongestModule
        : 'Tectonics';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0369A1), Color(0xFF0284C7), Color(0xFF38BDF8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withValues(alpha: 0.32),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: const Color(0xFF52B1FF).withValues(alpha: 0.18),
            blurRadius: 14,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background ambient circular gradient highlights
          Positioned(
            right: -20.w,
            top: -20.h,
            child: Container(
              width: 140.w,
              height: 140.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.16),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 32.w,
            bottom: -28.h,
            child: Icon(
              Icons.public_rounded,
              size: 120.sp,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Avatar + Greeting + Streak Pill
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ExplorerAvatar(
                      imageUrl: user?.profilePic,
                      name: rawName,
                      radius: 27,
                      heroTag: 'profile_avatar_hero',
                      onTap: onProfileTap,
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
                                  color: Colors.white.withValues(alpha: 0.90),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            firstName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.4,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Edexcel A-Level Geography Explorer',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.82),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Gamified Streak Pill
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 11.w,
                        vertical: 7.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.30),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_fire_department_rounded,
                            color: const Color(0xFFFBBF24),
                            size: 19.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '${streak}d',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 18.h),

                // Gamified Status & XP Strip
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 11.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.16),
                      width: 1.1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // XP Badge
                      Container(
                        padding: EdgeInsets.all(5.r),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.22),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.bolt_rounded,
                          color: const Color(0xFFFBBF24),
                          size: 16.sp,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '$totalXp XP',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),

                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 12.w),
                        width: 1,
                        height: 16.h,
                        color: Colors.white.withValues(alpha: 0.25),
                      ),

                      // Top Module Badge
                      Icon(
                        Icons.workspace_premium_rounded,
                        color: const Color(0xFF7DD3FC),
                        size: 18.sp,
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          'Strongest: $strongest',
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
}
