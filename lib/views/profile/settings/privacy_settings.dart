import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_spacing.dart';
import 'package:geography_geyser/core/app_strings.dart';
import 'package:geography_geyser/provider/settings_provider/privacy_settings.dart';
import 'package:geography_geyser/routes/app_routes.dart';
import 'package:geography_geyser/views/custom_widgets/buildTextField.dart';
import 'package:geography_geyser/views/custom_widgets/custom_login_button.dart';
import 'package:geography_geyser/views/custom_widgets/custom_snackbar.dart';
import 'package:geography_geyser/views/custom_widgets/stitch_design_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PrivacySettings_Screen extends StatefulWidget {
  const PrivacySettings_Screen({super.key});

  @override
  State<PrivacySettings_Screen> createState() => _PrivacySettings_ScreenState();
}

class _PrivacySettings_ScreenState extends State<PrivacySettings_Screen> {
  final TextEditingController _oldPassController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _oldPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PrivacySettingsProvider>(
      builder: (context, provider, child) {
        return StitchAmbientScaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.azureBorder),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16.sp,
                  color: AppColors.neutralDark,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              AppStrings.changePasswordButton,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.neutralDark,
              ),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StitchCard(
                            padding: EdgeInsets.all(20.r),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8.r),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFE0F2FE),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.lock_reset_rounded,
                                        color: AppColors.primaryAzure,
                                        size: 20.sp,
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Update Password',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.neutralDark,
                                            ),
                                          ),
                                          SizedBox(height: 2.h),
                                          Text(
                                            'Choose a strong passcode of at least 8 characters',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11.5.sp,
                                              color: AppColors.softSlate,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20.h),

                                BuildTextField(
                                  controller: _oldPassController,
                                  label: AppStrings.currentPasswordLabel,
                                  hint: AppStrings.currentPasswordEditLabel,
                                  isPassword: true,
                                  obscureText: _obscureOldPassword,
                                  textInputAction: TextInputAction.next,
                                  prefixIcon: Icon(
                                    Icons.lock_outline_rounded,
                                    color: AppColors.primaryAzure,
                                    size: 20.sp,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureOldPassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: AppColors.softSlate,
                                      size: 20.sp,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureOldPassword = !_obscureOldPassword;
                                      });
                                    },
                                  ),
                                ),
                                AppSpacing.h16,

                                BuildTextField(
                                  controller: _newPassController,
                                  label: AppStrings.newPassword,
                                  hint: AppStrings.passHint,
                                  isPassword: true,
                                  obscureText: _obscureNewPassword,
                                  textInputAction: TextInputAction.next,
                                  prefixIcon: Icon(
                                    Icons.lock_rounded,
                                    color: AppColors.primaryAzure,
                                    size: 20.sp,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureNewPassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: AppColors.softSlate,
                                      size: 20.sp,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureNewPassword = !_obscureNewPassword;
                                      });
                                    },
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Password is required';
                                    }
                                    if (value.length < 8) {
                                      return 'Password must be 8 characters long';
                                    }
                                    return null;
                                  },
                                ),
                                AppSpacing.h16,

                                BuildTextField(
                                  controller: _confirmPassController,
                                  label: AppStrings.confirmNewPassword,
                                  hint: AppStrings.confirmNewPasswordLabel,
                                  isPassword: true,
                                  obscureText: _obscureConfirmPassword,
                                  textInputAction: TextInputAction.done,
                                  prefixIcon: Icon(
                                    Icons.check_circle_outline_rounded,
                                    color: AppColors.primaryAzure,
                                    size: 20.sp,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirmPassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: AppColors.softSlate,
                                      size: 20.sp,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureConfirmPassword =
                                            !_obscureConfirmPassword;
                                      });
                                    },
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please confirm your password';
                                    }
                                    if (value != _newPassController.text) {
                                      return 'Passwords do not match';
                                    }
                                    return null;
                                  },
                                ),
                                AppSpacing.h12,

                                Align(
                                  alignment: Alignment.topRight,
                                  child: TextButton(
                                    onPressed: () {
                                      context.push(AppRoutes.forgotPassword);
                                    },
                                    child: Text(
                                      AppStrings.forgotPassword,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primaryAzure,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
                  child: CustomLoginButton(
                    text: provider.isLoading
                        ? "Updating Password..."
                        : AppStrings.saveChangesButton,
                    isLoading: provider.isLoading,
                    onPressed: provider.isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              await provider.updatePassword(
                                _oldPassController.text,
                                _newPassController.text,
                              );

                              if (!context.mounted) return;

                              if (provider.isSuccess) {
                                CustomSnackBar.show(
                                  context,
                                  message: 'Password updated successfully',
                                  isError: false,
                                );
                                _oldPassController.clear();
                                _newPassController.clear();
                                _confirmPassController.clear();
                                setState(() {
                                  _obscureOldPassword = true;
                                  _obscureNewPassword = true;
                                  _obscureConfirmPassword = true;
                                  FocusScope.of(context).unfocus();
                                });
                              } else {
                                CustomSnackBar.show(
                                  context,
                                  message: provider.message.isNotEmpty
                                      ? provider.message
                                      : 'Failed to update password',
                                  isError: true,
                                );
                              }
                            }
                          },
                  ),
                ),
                AppSpacing.h16,
              ],
            ),
          ),
        );
      },
    );
  }
}
