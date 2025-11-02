import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_padding.dart';
import 'package:geography_geyser/core/app_spacing.dart';
import 'package:geography_geyser/core/app_strings.dart';
import 'package:geography_geyser/core/font_manager.dart';

class ElevatedButtonCustom extends StatelessWidget {
  final GlobalKey<FormState>? formKey;
  final String? text;
  final String? iconPath;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final VoidCallback? onPressed;

  const ElevatedButtonCustom({
    super.key,
    this.formKey,
    required this.text,
    this.iconPath,
    required this.backgroundColor,
    this.onPressed,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12.0),
      child: SizedBox(
        width: double.infinity.w,
        height: 48.h,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? AppColors.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: AppPadding.c12),
          ),
          onPressed: () {
            if (formKey == null ||
                (formKey!.currentState?.validate() ?? false)) {
              onPressed?.call();
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (iconPath != null) ...[
                Image.asset(iconPath!, height: 20.h, width: 20.w),
                AppSpacing.w8,
              ],
              Text(
                text ?? AppStrings.logInButton,
                style: FontManager.whiteButtonText(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
