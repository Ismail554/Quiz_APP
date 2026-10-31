import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/models/v2_curriculum_models.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

/// Wraps screen content with the signature Stitch Design System soft-sky background
/// and ambient radial glow spheres matching the redesigned Auth flow.
class StitchAmbientScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;

  const StitchAmbientScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.softSky,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      body: Stack(
        children: [
          Positioned(
            top: -70.h,
            right: -50.w,
            child: IgnorePointer(
              child: Container(
                width: 240.w,
                height: 240.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primarySky.withValues(alpha: 0.28),
                      AppColors.primarySky.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 140.h,
            left: -60.w,
            child: IgnorePointer(
              child: Container(
                width: 180.w,
                height: 180.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accentGold.withValues(alpha: 0.16),
                      AppColors.accentGold.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body,
        ],
      ),
    );
  }
}

/// Elevated white card with azure border and soft ocean shadow.
class StitchCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final Gradient? gradient;

  const StitchCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = 20,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius.r);
    final container = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: gradient == null ? (backgroundColor ?? AppColors.white) : null,
        gradient: gradient,
        borderRadius: radius,
        border: Border.all(
          color: borderColor ?? AppColors.azureBorder,
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryAzure.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: padding ?? EdgeInsets.all(16.r),
            child: child,
          ),
        ),
      ),
    );
    return container;
  }
}

class StitchSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onActionTap;
  final IconData? leadingIcon;

  const StitchSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onActionTap,
    this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (leadingIcon != null) ...[
          Container(
            padding: EdgeInsets.all(7.r),
            decoration: BoxDecoration(
              color: AppColors.primaryAzure.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              leadingIcon,
              size: 16.sp,
              color: AppColors.primaryAzure,
            ),
          ),
          SizedBox(width: 10.w),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.neutralDark,
                  letterSpacing: -0.3,
                ),
              ),
              if (subtitle != null) ...[
                SizedBox(height: 2.h),
                Text(
                  subtitle!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.softSlate,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (actionLabel != null && onActionTap != null)
          TextButton(
            onPressed: onActionTap,
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  actionLabel!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryAzure,
                  ),
                ),
                SizedBox(width: 3.w),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 14.sp,
                  color: AppColors.primaryAzure,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class DifficultyBadge extends StatelessWidget {
  final QuizDifficulty difficulty;
  final bool compact;

  const DifficultyBadge({
    super.key,
    required this.difficulty,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8.w : 10.w,
        vertical: compact ? 3.h : 5.h,
      ),
      decoration: BoxDecoration(
        color: difficulty.backgroundColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: difficulty.color.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.r,
            height: 6.r,
            decoration: BoxDecoration(
              color: difficulty.color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 5.w),
          Text(
            difficulty.label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: compact ? 10.5.sp : 11.5.sp,
              fontWeight: FontWeight.w700,
              color: difficulty.color,
            ),
          ),
        ],
      ),
    );
  }
}

class StitchBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;
  final Color? backgroundColor;

  const StitchBadge({
    super.key,
    required this.label,
    this.icon,
    this.color = AppColors.primaryAzure,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: backgroundColor ?? color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12.sp, color: color),
            SizedBox(width: 4.w),
          ],
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class StitchShimmerList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;

  const StitchShimmerList({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 92,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Shimmer.fromColors(
            baseColor: const Color(0xFFE2E8F0),
            highlightColor: const Color(0xFFF8FAFC),
            child: Container(
              height: itemHeight.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
          ),
        );
      },
    );
  }
}
