import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_spacing.dart';
import 'package:geography_geyser/core/app_strings.dart';
import 'package:geography_geyser/provider/forgot_password/new_pass_set_provider.dart';
import 'package:geography_geyser/views/auth/forgot_pass/congratulations.dart';
import 'package:geography_geyser/views/custom_widgets/buildTextField.dart';
import 'package:geography_geyser/views/custom_widgets/custom_login_button.dart';
import 'package:geography_geyser/views/custom_widgets/custom_snackbar.dart';
import 'package:provider/provider.dart';

class NewPass_screen extends StatefulWidget {
  const NewPass_screen({super.key});

  @override
  State<NewPass_screen> createState() => _NewPass_screenState();
}

class _NewPass_screenState extends State<NewPass_screen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validatePasswords() {
    setState(() {
      _passwordError = null;
      _confirmPasswordError = null;

      if (_newPasswordController.text.isEmpty) {
        _passwordError = 'Please enter a new passcode';
      } else if (_newPasswordController.text.length < 6) {
        _passwordError = 'Passcode must be at least 6 characters';
      }

      if (_confirmPasswordController.text.isEmpty) {
        _confirmPasswordError = 'Please confirm your passcode';
      } else if (_newPasswordController.text !=
          _confirmPasswordController.text) {
        _confirmPasswordError = 'Passcodes do not match';
      }
    });
  }

  double _getPasswordStrength(String password) {
    if (password.isEmpty) return 0.0;
    double strength = 0.0;
    if (password.length >= 6) strength += 0.35;
    if (password.length >= 8) strength += 0.25;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.2;
    if (RegExp(r'[A-Z]').hasMatch(password) ||
        RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      strength += 0.2;
    }
    return strength.clamp(0.0, 1.0);
  }

  Color _getStrengthColor(double strength) {
    if (strength <= 0.35) return const Color(0xFFEF4444);
    if (strength <= 0.7) return const Color(0xFFF59E0B);
    return const Color(0xFF10B981);
  }

  String _getStrengthLabel(double strength) {
    if (strength <= 0.35) return "Weak";
    if (strength <= 0.7) return "Good";
    return "Strong ✨";
  }

  @override
  Widget build(BuildContext context) {
    final passwordStrength = _getPasswordStrength(_newPasswordController.text);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F9FF),
      body: Stack(
        children: [
          Positioned(
            top: -40.h,
            left: -30.w,
            child: Container(
              width: 220.w,
              height: 220.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF52B1FF).withValues(alpha: 0.3),
                    const Color(0xFF52B1FF).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    AppSpacing.h12,

                    // Top Bar
                    FadeInDown(
                      duration: const Duration(milliseconds: 400),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFE0F2FE),
                                width: 1.2.w,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back_rounded,
                                color: AppColors.neutralDark,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            "Step 3 of 3",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppSpacing.h20,

                    // Shield & Lock Icon
                    ZoomIn(
                      duration: const Duration(milliseconds: 600),
                      child: Container(
                        width: 110.w,
                        height: 110.h,
                        padding: EdgeInsets.all(18.r),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            color: const Color(0xFFE0F2FE),
                            width: 3.w,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0284C7).withValues(alpha: 0.16),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.shield_outlined,
                            size: 48.sp,
                            color: AppColors.primaryAzure,
                          ),
                        ),
                      ),
                    ),
                    AppSpacing.h24,

                    // Title & Instruction
                    FadeInDown(
                      duration: const Duration(milliseconds: 500),
                      child: Column(
                        children: [
                          Text(
                            "Set New Passcode 🛡️",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.neutralDark,
                              letterSpacing: -0.5,
                            ),
                          ),
                          AppSpacing.h8,
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Text(
                              "Your new passcode must be different from previous passwords and at least 6 characters long.",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF64748B),
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppSpacing.h28,

                    // Card Container
                    FadeInUp(
                      duration: const Duration(milliseconds: 650),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28.r),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0284C7).withValues(alpha: 0.08),
                              blurRadius: 24,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 22.w,
                          vertical: 28.h,
                        ),
                        child: Consumer<NewPassSetProvider>(
                          builder: (context, provider, child) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (provider.errorMessage != null)
                                  Container(
                                    margin: EdgeInsets.only(bottom: 16.h),
                                    padding: EdgeInsets.all(12.r),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF2F2),
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(
                                        color: const Color(0xFFFCA5A5),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.error_outline_rounded,
                                          color: Colors.red.shade700,
                                          size: 20.sp,
                                        ),
                                        SizedBox(width: 8.w),
                                        Expanded(
                                          child: Text(
                                            provider.errorMessage!,
                                            style: GoogleFonts.plusJakartaSans(
                                              color: Colors.red.shade800,
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            provider.clearError();
                                          },
                                          child: Icon(
                                            Icons.close_rounded,
                                            size: 18.sp,
                                            color: Colors.red.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                // New Password Field
                                BuildTextField(
                                  label: "New Passcode",
                                  hint: AppStrings.passHint,
                                  controller: _newPasswordController,
                                  isPassword: true,
                                  obscureText: _obscureNewPassword,
                                  textInputAction: TextInputAction.next,
                                  errorText: _passwordError,
                                  prefixIcon: Icon(
                                    Icons.lock_outline_rounded,
                                    color: AppColors.primaryAzure,
                                    size: 20.sp,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureNewPassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: const Color(0xFF64748B),
                                      size: 20.sp,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureNewPassword =
                                            !_obscureNewPassword;
                                      });
                                    },
                                  ),
                                  onChanged: (value) {
                                    _validatePasswords();
                                  },
                                ),

                                // Password Strength Bar
                                if (_newPasswordController.text.isNotEmpty) ...[
                                  AppSpacing.h8,
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(4.r),
                                          child: LinearProgressIndicator(
                                            value: passwordStrength,
                                            backgroundColor:
                                                const Color(0xFFE2E8F0),
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              _getStrengthColor(
                                                  passwordStrength),
                                            ),
                                            minHeight: 4.h,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10.w),
                                      Text(
                                        _getStrengthLabel(passwordStrength),
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w700,
                                          color: _getStrengthColor(
                                              passwordStrength),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                AppSpacing.h18,

                                // Confirm Password Field
                                BuildTextField(
                                  label: "Confirm New Passcode",
                                  hint: AppStrings.confirmNewHint,
                                  controller: _confirmPasswordController,
                                  isPassword: true,
                                  obscureText: _obscureConfirmPassword,
                                  textInputAction: TextInputAction.done,
                                  errorText: _confirmPasswordError,
                                  prefixIcon: Icon(
                                    Icons.lock_reset_rounded,
                                    color: AppColors.primaryAzure,
                                    size: 20.sp,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirmPassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: const Color(0xFF64748B),
                                      size: 20.sp,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureConfirmPassword =
                                            !_obscureConfirmPassword;
                                      });
                                    },
                                  ),
                                  onChanged: (value) {
                                    _validatePasswords();
                                  },
                                ),
                                AppSpacing.h24,

                                // Save Button
                                CustomLoginButton(
                                  text: provider.isLoading
                                      ? "Saving Passcode..."
                                      : "Update Passcode",
                                  isLoading: provider.isLoading,
                                  icon: const Icon(
                                    Icons.check_circle_outline_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  onPressed: provider.isLoading
                                      ? null
                                      : () async {
                                          _validatePasswords();

                                          if (_passwordError != null ||
                                              _confirmPasswordError != null) {
                                            CustomSnackBar.show(
                                              context,
                                              message:
                                                  'Please fix the passcode errors',
                                              isError: true,
                                            );
                                            return;
                                          }

                                          try {
                                            final response =
                                                await provider.setNewPassword(
                                              _newPasswordController.text
                                                  .trim(),
                                            );

                                            if (context.mounted) {
                                              final successMessage =
                                                  response['msg'] ??
                                                      'Password reset successfully!';

                                              CustomSnackBar.show(
                                                context,
                                                message: successMessage,
                                                isError: false,
                                              );

                                              Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const CongratulationsScreen(),
                                                ),
                                                (route) => false,
                                              );
                                            }
                                          } catch (e) {
                                            if (context.mounted) {
                                              String errorMsg =
                                                  'Failed to reset password';
                                              if (provider.errorMessage !=
                                                  null) {
                                                errorMsg =
                                                    provider.errorMessage!;
                                              } else if (e is Map) {
                                                errorMsg = e['msg'] ??
                                                    e['error'] ??
                                                    e['message'] ??
                                                    errorMsg;
                                              }
                                              CustomSnackBar.show(
                                                context,
                                                message: errorMsg,
                                                isError: true,
                                              );
                                            }
                                          }
                                        },
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    AppSpacing.h24,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
