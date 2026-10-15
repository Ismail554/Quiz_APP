import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_spacing.dart';
import 'package:geography_geyser/core/app_strings.dart';
import 'package:geography_geyser/provider/auth_provider/login_provider.dart';
import 'package:geography_geyser/views/home/homepage.dart';
import 'package:geography_geyser/views/custom_widgets/custom_snackbar.dart';
import 'package:geography_geyser/views/home/op_mod_settings.dart';

class AppleLoginBtn extends StatefulWidget {
  final double? width;
  final double? height;

  const AppleLoginBtn({super.key, this.width, this.height});

  @override
  State<AppleLoginBtn> createState() => _AppleLoginBtnState();
}

class _AppleLoginBtnState extends State<AppleLoginBtn> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height ?? 50.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2.w),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14.r),
          onTap: _isLoading
              ? null
              : () async {
                  setState(() {
                    _isLoading = true;
                  });

                  try {
                    final response = await LoginProvider.signInWithApple();

                    if (!context.mounted) return;

                    final isOptionalModuleSelected =
                        response['is_optional_module_selected'] == true ||
                        response['is_optional_module_selected'] == 'true';

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => isOptionalModuleSelected
                            ? HomePageScreen()
                            : OptionalModuleSettings(isFirstLogin: true),
                      ),
                    );
                  } catch (e) {
                    if (!context.mounted) return;
                    String message = 'Apple sign-in failed';
                    if (e is Map && e['message'] != null) {
                      message = e['message'].toString();
                    }
                    CustomSnackBar.show(
                      context,
                      message: message,
                      isError: true,
                    );
                  } finally {
                    if (mounted) {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  }
                },
          child: Center(
            child: _isLoading
                ? SizedBox(
                    height: 20.h,
                    width: 20.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.neutralDark),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.apple_rounded, size: 22.sp, color: AppColors.neutralDark),
                      AppSpacing.w8,
                      Text(
                        AppStrings.continueWithApple,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.neutralDark,
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
