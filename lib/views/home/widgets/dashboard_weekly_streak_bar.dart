import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/views/custom_widgets/stitch_design_widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardWeeklyStreakBar extends StatelessWidget {
  final int streakDays;

  const DashboardWeeklyStreakBar({
    super.key,
    required this.streakDays,
  });

  @override
  Widget build(BuildContext context) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final currentDayIndex = DateTime.now().weekday - 1; // 0 = Mon, 6 = Sun

    return StitchCard(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(6.r),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFEF3C7),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.local_fire_department_rounded,
                      color: const Color(0xFFD97706),
                      size: 17.sp,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Daily Geyser Streak',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.neutralDark,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  '$streakDays Days Active 🔥',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryAzure,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final isToday = index == currentDayIndex;
              final isCompleted = index <= currentDayIndex;

              return Column(
                children: [
                  Container(
                    width: 34.r,
                    height: 34.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isCompleted
                          ? (isToday
                              ? AppColors.primaryGradient
                              : const LinearGradient(
                                  colors: [
                                    Color(0xFF10B981),
                                    Color(0xFF34D399),
                                  ],
                                ))
                          : null,
                      color: isCompleted ? null : const Color(0xFFF1F5F9),
                      border: Border.all(
                        color: isToday
                            ? AppColors.primaryAzure
                            : (isCompleted
                                ? const Color(0xFF10B981)
                                : AppColors.azureBorder),
                        width: isToday ? 2 : 1,
                      ),
                      boxShadow: isToday
                          ? [
                              BoxShadow(
                                color: AppColors.primaryAzure.withValues(
                                  alpha: 0.35,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : [],
                    ),
                    child: Center(
                      child: isCompleted
                          ? Icon(
                              isToday
                                  ? Icons.bolt_rounded
                                  : Icons.check_rounded,
                              size: 18.sp,
                              color: Colors.white,
                            )
                          : Text(
                              days[index],
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.softSlate,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    days[index],
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5.sp,
                      fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                      color: isToday
                          ? AppColors.primaryAzure
                          : AppColors.softSlate,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
