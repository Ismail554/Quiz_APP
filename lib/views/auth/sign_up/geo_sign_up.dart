import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_spacing.dart';
import 'package:geography_geyser/core/app_strings.dart';
import 'package:geography_geyser/core/font_manager.dart';
import 'package:geography_geyser/core/app_logger.dart';
import 'package:geography_geyser/provider/auth_provider/signup_provider/signup_provider.dart';
import 'package:geography_geyser/utils/validators.dart';
import 'package:geography_geyser/views/custom_widgets/buildTextField.dart';
import 'package:geography_geyser/views/custom_widgets/google_login_btn.dart';
import 'package:geography_geyser/views/custom_widgets/custom_login_button.dart';
import 'package:geography_geyser/views/auth/login/login.dart';
import 'package:geography_geyser/views/auth/sign_up/verify_otp.dart';
import 'package:geography_geyser/views/custom_widgets/custom_snackbar.dart';

class GeoSignUpScreen extends StatefulWidget {
  const GeoSignUpScreen({super.key});

  @override
  State<GeoSignUpScreen> createState() => _GeoSignUpScreenState();
}

class _GeoSignUpScreenState extends State<GeoSignUpScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  bool _isLoading = false;

  // Dispose controllers to avoid memory leaks
  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashBG,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile section
            AppSpacing.h64,
            Column(
              children: [
                // Circular profile image with border
                Container(
                  width: 100.w,
                  height: 100.h,
                  decoration: BoxDecoration(
                    // shape: BoxShape.circle,
                    // border: Border.all(
                    //   color: const Color(0xFF4CAF50),
                    //   width: 4,
                    // ),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/logo.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Text(
                  AppStrings.appName,

                  style: FontManager.splashTitle(fontSize: 24.sp),
                  textAlign: TextAlign.center,
                ),
                // AppSpacing.h8,
                // // Name and title
                // Align(
                //   alignment: Alignment.center,
                //   child: Text(
                //     AppStrings.appName,
                //     style: FontManager.splashTitle(fontSize: 24.sp),
                //     textAlign: TextAlign.center,
                //   ),
                // ),
                AppSpacing.h24,
              ],
            ),

            // White rounded container with form
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(120.r),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Create account title
                    Align(
                      alignment: Alignment.topRight,
                      child: Text(
                        AppStrings.signUpButton,
                        style: TextStyle(
                          fontFamily: 'SegoeUI',
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    AppSpacing.h16,

                    // Full Name Field
                    BuildTextField(
                      label: AppStrings.fullNameLabel,
                      hint: 'Enter Full Name',
                      textInputAction: TextInputAction.next,
                      controller: _fullNameController,
                    ),
                    AppSpacing.h16,

                    // Email Field
                    BuildTextField(
                      label: 'Email',
                      hint: 'Enter Email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      errorText: _emailError,
                      onChanged: (value) {
                        setState(() {
                          _emailError = Validators.validateEmail(value);
                        });
                      },
                    ),
                    AppSpacing.h16,

                    // Password Field
                    BuildTextField(
                      label: 'Password',
                      obscureText: _obscurePassword,
                      hint: 'Enter Password',
                      controller: _passwordController,
                      textInputAction: TextInputAction.next,
                      isPassword: true,
                      errorText: _passwordError,
                      onChanged: (value) {
                        setState(() {
                          _passwordError = Validators.validatePassword(value);

                          // Re-validate confirm password when password changes
                          if (_confirmPasswordController.text.isNotEmpty) {
                            _confirmPasswordError =
                                Validators.validateConfirmPassword(
                                  _confirmPasswordController.text,
                                  value,
                                );
                          }
                        });
                      },
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: const Color(0xFF42A5F5),
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    AppSpacing.h16,

                    // Confirm Password Field
                    BuildTextField(
                      label: 'Confirm Password',
                      hint: 'Enter Password',
                      obscureText: _obscureConfirmPassword,
                      controller: _confirmPasswordController,
                      textInputAction: TextInputAction.done,
                      isPassword: true,
                      errorText: _confirmPasswordError,
                      onChanged: (value) {
                        setState(() {
                          _confirmPasswordError =
                              Validators.validateConfirmPassword(
                                value,
                                _passwordController.text,
                              );
                        });
                      },
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: const Color(0xFF42A5F5),
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                    AppSpacing.h16,

                    // Sign Up Button
                    CustomLoginButton(
                      text: AppStrings.signUpButton,
                      isLoading: _isLoading, // <-- add this in your state class
                      onPressed: _isLoading
                          ? null
                          : () async {
                              // Step 1: Validate all fields
                              setState(() {
                                _emailError = Validators.validateEmail(
                                  _emailController.text,
                                );
                                _passwordError = Validators.validatePassword(
                                  _passwordController.text,
                                );
                                _confirmPasswordError =
                                    Validators.validateConfirmPassword(
                                      _confirmPasswordController.text,
                                      _passwordController.text,
                                    );
                              });

                              final isValid =
                                  _emailError == null &&
                                  _passwordError == null &&
                                  _confirmPasswordError == null;

                              if (!isValid) return;

                              // Step 2: Run Signup API
                              setState(() => _isLoading = true);

                              try {
                                await SignupProvider.signup(
                                  _emailController.text.trim(),
                                  _fullNameController.text.trim(),
                                  _passwordController.text.trim(),
                                  context,
                                );

                                // Step 3: Handle success
                                if (context.mounted) {
                                  CustomSnackBar.show(
                                    context,
                                    message: "Signup successful!",
                                    isError: false,
                                  );

                                  // Step 4: Navigate next (like OTP verify or home)
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => VerifyOtpScreen(
                                        email: _emailController.text.trim(),
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                // Step 5: Handle errors
                                String message =
                                    'Signup failed. Please try again.';

                                if (e is Map<String, dynamic>) {
                                  message =
                                      e['message']?.toString() ??
                                      e['error']?.toString() ??
                                      message;
                                } else if (e is String) {
                                  message = e;
                                } else {
                                  message = e.toString();
                                }

                                AppLogger.error('Signup Error', e);

                                if (context.mounted) {
                                  CustomSnackBar.show(
                                    context,
                                    message: AppLogger.getSafeErrorMessage(
                                      message,
                                    ),
                                    isError: true,
                                  );
                                }
                              } finally {
                                // Step 6: Stop loader
                                if (mounted) {
                                  setState(() => _isLoading = false);
                                }
                              }
                            },
                    ),

                    AppSpacing.h20,

                    // OR divider
                    Row(
                      children: [
                        Expanded(
                          child: Divider(color: Colors.grey[300], thickness: 1),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: Text(
                            'OR Login With',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(color: Colors.grey[300], thickness: 1),
                        ),
                      ],
                    ),
                    AppSpacing.h20,

                    // Google Login Button
                    GoogleLoginBtn(),
                    AppSpacing.h16,

                    // Login link
                    Center(
                      child: RichText(
                        text: TextSpan(
                          text: 'Already have Account? ',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey[600],
                          ),
                          children: [
                            TextSpan(
                              text: 'Login',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Color(0xFF42A5F5),
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LoginScreen(),
                                    ),
                                  );
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                    AppSpacing.h16,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
