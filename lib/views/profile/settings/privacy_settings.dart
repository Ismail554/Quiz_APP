import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_spacing.dart';
import 'package:geography_geyser/core/app_strings.dart';
import 'package:geography_geyser/core/font_manager.dart';
import 'package:geography_geyser/views/auth/forgot_pass/pass_reset.dart';
import 'package:geography_geyser/views/custom_widgets/buildTextField.dart';
import 'package:geography_geyser/views/custom_widgets/custom_login_button.dart';

class PrivacySettings_Screen extends StatefulWidget {
  const PrivacySettings_Screen({super.key});

  @override
  State<PrivacySettings_Screen> createState() => _PrivacySettings_ScreenState();
}

class _PrivacySettings_ScreenState extends State<PrivacySettings_Screen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          AppStrings.changePasswordButton,
          style: FontManager.titleText(),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable section
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: [
                    AppSpacing.h24,
                    BuildTextField(
                      label: AppStrings.currentPasswordLabel,
                      hint: AppStrings.currentPasswordEditLabel,
                    ),
                    AppSpacing.h12,
                    BuildTextField(
                      label: AppStrings.newPassword,
                      hint: AppStrings.passHint,
                    ),
                    AppSpacing.h12,
                    BuildTextField(
                      label: AppStrings.confirmNewPassword,
                      hint: AppStrings.confirmNewPasswordLabel,
                    ),
                    AppSpacing.h12,
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PassResetScreen(),
                              ),
                            );
                          },
                          child: Text(
                            AppStrings.forgotPassword,
                            style: FontManager.subtitleText(
                              color: AppColors.blue,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: CustomLoginButton(
                text: AppStrings.saveChangesButton,
                onPressed: () {
                  debugPrint("Save Changes Pressed");
                },
              ),
            ),
            AppSpacing.h16,
          ],
        ),
      ),
    );
  }
}
