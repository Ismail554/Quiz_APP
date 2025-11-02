import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/font_manager.dart';

class CustomModule extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? shadowColor;
  final double? fontSize;
  final TextStyle? textStyle;
  final Widget? leading;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final bool isSelected;

  const CustomModule({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.borderColor,
    this.shadowColor,
    this.fontSize,
    this.textStyle,
    this.leading,
    this.trailing,
    this.padding,
    this.borderRadius,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(borderRadius ?? 8.r),
      child: Container(
        width: double.infinity,
        padding:
            padding ?? EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFE8F4FF)
              : (backgroundColor ?? AppColors.white),
          border: Border.all(
            color: isSelected
                ? Colors.blueAccent
                : (borderColor ?? Colors.grey.shade300),
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(borderRadius ?? 8.r),
          boxShadow: [
            BoxShadow(
              color: (shadowColor ?? Colors.black).withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 2,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leading != null) ...[leading!, SizedBox(width: 8.w)],
            Flexible(
              child: Text(
                text.toUpperCase(),
                textAlign: TextAlign.center,
                style:
                    textStyle ??
                    FontManager.headerSubtitleText(
                      fontSize: fontSize ?? 20,
                      color: Colors.black,
                    ),
              ),
            ),
            if (trailing != null) ...[SizedBox(width: 8.w), trailing!],
          ],
        ),
      ),
    );
  }
}
