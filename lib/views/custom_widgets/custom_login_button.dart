import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geography_geyser/core/app_colors.dart';

class CustomLoginButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Gradient? gradient;
  final Color? textColor;
  final double? width;
  final double? height;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? borderRadius;
  final bool isLoading;
  final Widget? icon;

  const CustomLoginButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.gradient,
    this.textColor,
    this.width,
    this.height,
    this.fontSize,
    this.fontWeight,
    this.borderRadius,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = BorderRadius.circular(borderRadius ?? 16.r);
    final effectiveGradient = backgroundColor != null
        ? null
        : (gradient ??
            const LinearGradient(
              colors: [Color(0xFF52B1FF), Color(0xFF0284C7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ));

    return Container(
      width: width ?? double.infinity,
      height: height ?? 52.h,
      decoration: BoxDecoration(
        borderRadius: effectiveRadius,
        gradient: effectiveGradient,
        color: effectiveGradient == null
            ? (backgroundColor ?? AppColors.buttonColor)
            : null,
        boxShadow: onPressed != null && !isLoading
            ? [
                BoxShadow(
                  color: (backgroundColor ?? AppColors.primaryAzure)
                      .withValues(alpha: 0.28),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: effectiveRadius,
          splashColor: Colors.white.withValues(alpha: 0.2),
          highlightColor: Colors.white.withValues(alpha: 0.1),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 22.w,
                    height: 22.h,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        icon!,
                        SizedBox(width: 8.w),
                      ],
                      Text(
                        text,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: fontSize ?? 16.sp,
                          fontWeight: fontWeight ?? FontWeight.w700,
                          color: textColor ?? Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
