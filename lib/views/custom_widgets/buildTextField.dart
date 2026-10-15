import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_spacing.dart';

class BuildTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool isPassword;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final String? errorText;
  final Color bgcolor;
  final bool isReadOnly;
  final TextInputAction? textInputAction;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;

  const BuildTextField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.prefixIcon,
    this.bgcolor = const Color(0xFFF8FAFC),
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.suffixIcon,
    this.obscureText = false,
    this.errorText,
    this.onChanged,
    this.isReadOnly = false,
    this.textInputAction,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.neutralDark,
              letterSpacing: 0.1,
            ),
          ),
          AppSpacing.h8,
        ],

        // Input field
        TextFormField(
          textInputAction: textInputAction,
          readOnly: isReadOnly,
          controller: controller,
          keyboardType: keyboardType,
          obscureText: isPassword ? obscureText : false,
          onChanged: onChanged,
          validator: validator,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.neutralDark,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: bgcolor,
            hintText: hint,
            hintStyle: GoogleFonts.plusJakartaSans(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF94A3B8),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
            errorText: errorText,
            errorStyle: GoogleFonts.plusJakartaSans(
              fontSize: 12.sp,
              color: Colors.red.shade600,
              fontWeight: FontWeight.w600,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : const Color(0xFFE2E8F0),
                width: 1.2.w,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : const Color(0xFFE2E8F0),
                width: 1.2.w,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : AppColors.primaryAzure,
                width: 1.8.w,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(color: Colors.red.shade400, width: 1.5.w),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(color: Colors.red, width: 1.8.w),
            ),
          ),
        ),
      ],
    );
  }
}
