import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_spacing.dart';
import 'package:geography_geyser/core/app_strings.dart';
import 'package:geography_geyser/core/font_manager.dart';
import 'package:geography_geyser/provider/settings_provider/privacy_settings.dart';
import 'package:geography_geyser/views/auth/forgot_pass/forget_pass_screen.dart';

import 'package:geography_geyser/views/custom_widgets/buildTextField.dart';
import 'package:geography_geyser/views/custom_widgets/custom_login_button.dart';
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
  String? _passwordMatchError;

  @override
  void dispose() {
    _oldPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  void _validatePasswordMatch() {
    if (_confirmPassController.text.isNotEmpty &&
        _newPassController.text != _confirmPassController.text) {
      setState(() {
        _passwordMatchError = 'Passwords do not match';
      });
    } else {
      setState(() {
        _passwordMatchError = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PrivacySettingsProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: AppColors.white,
          resizeToAvoidBottomInset: true,
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
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16.w),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          AppSpacing.h24,
                          BuildTextField(
                            controller: _oldPassController,
                            label: AppStrings.currentPasswordLabel,
                            hint: AppStrings.currentPasswordEditLabel,
                            isPassword: true,
                            // obscureText: _obscureOldPassword,
                            textInputAction: TextInputAction.next,
                            // suffixIcon: IconButton(
                            //   icon: Icon(
                            //     _obscureOldPassword
                            //         ? Icons.visibility_off
                            //         : Icons.visibility,
                            //     color: const Color(0xFF42A5F5),
                            //   ),
                            //   onPressed: () {
                            //     setState(() {
                            //       _obscureOldPassword = !_obscureOldPassword;
                            //     });
                            //   },
                            // ),
                          ),
                          AppSpacing.h12,
                          BuildTextField(
                            controller: _newPassController,
                            label: AppStrings.newPassword,
                            hint: AppStrings.passHint,
                            isPassword: true,
                            obscureText: _obscureNewPassword,
                            textInputAction: TextInputAction.next,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureNewPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: const Color(0xFF42A5F5),
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureNewPassword = !_obscureNewPassword;
                                });
                              },
                            ),
                            onChanged: (value) {
                              _validatePasswordMatch();
                            },
                          ),
                          AppSpacing.h12,
                          BuildTextField(
                            controller: _confirmPassController,
                            label: AppStrings.confirmNewPassword,
                            hint: AppStrings.confirmNewPasswordLabel,
                            isPassword: true,
                            obscureText: _obscureConfirmPassword,
                            textInputAction: TextInputAction.done,
                            errorText: _passwordMatchError,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: const Color(0xFF42A5F5),
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),
                            onChanged: (value) {
                              _validatePasswordMatch();
                            },
                          ),
                          AppSpacing.h12,
                          Align(
                            alignment: Alignment.topRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const PassResetScreen(),
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
                        ],
                      ),
                    ),
                  ),
                ),

                // Save Changes Button
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 12.h,
                  ),
                  child: CustomLoginButton(
                    text: provider.isLoading
                        ? "Updating..."
                        : AppStrings.saveChangesButton,
                    isLoading: provider.isLoading,
                    onPressed: provider.isLoading
                        ? null
                        : () async {
                            // Clear previous errors
                            setState(() {
                              _passwordMatchError = null;
                            });

                            // Validate all fields are filled
                            if (_oldPassController.text.isEmpty ||
                                _newPassController.text.isEmpty ||
                                _confirmPassController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please fill all fields'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            // Validate password match
                            if (_newPassController.text !=
                                _confirmPassController.text) {
                              setState(() {
                                _passwordMatchError =
                                    'New password and confirm password do not match';
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'New password and confirm password do not match',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            // Call API
                            await provider.updatePassword(
                              _oldPassController.text,
                              _newPassController.text,
                            );

                            // Show result based on API response
                            if (provider.isSuccess) {
                              // Clear fields on success
                              _oldPassController.clear();
                              _newPassController.clear();
                              _confirmPassController.clear();
                              setState(() {
                                _passwordMatchError = null;
                                _obscureOldPassword = true;
                                _obscureNewPassword = true;
                                _obscureConfirmPassword = true;
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(provider.message),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              // Show error message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(provider.message),
                                  backgroundColor: Colors.red,
                                ),
                              );
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
