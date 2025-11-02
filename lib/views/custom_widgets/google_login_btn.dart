import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geography_geyser/core/app_spacing.dart';
import 'package:geography_geyser/core/app_strings.dart';

class GoogleLoginBtn extends StatelessWidget {
  const GoogleLoginBtn({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: OutlinedButton(
        onPressed: () {
          debugPrint('Google Login Pressed');
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey[400]!, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/google_logo.png',
              width: 20.w,
              height: 20.h,
            ),
            AppSpacing.w8,
            Text(
              // 'Google',
              AppStrings.googleLogin,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
