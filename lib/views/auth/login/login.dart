import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_spacing.dart';
import 'package:geography_geyser/core/app_strings.dart';
import 'package:geography_geyser/core/font_manager.dart';
import 'package:geography_geyser/provider/auth_provider.dart';
import 'package:geography_geyser/views/auth/forgot_pass/pass_reset.dart';
import 'package:geography_geyser/views/auth/sign_up/geo_sign_up.dart';
import 'package:geography_geyser/views/custom_widgets/buildTextField.dart';
import 'package:geography_geyser/views/custom_widgets/custom_login_button.dart';
import 'package:geography_geyser/views/custom_widgets/google_login_btn.dart';
import 'package:geography_geyser/views/home/homepage.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.splashBG,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  AppSpacing.h64,

                  // Logo & Title
                  Column(
                    children: [
                      Container(
                        // margin: EdgeInsets.only(bottom: 18.h),
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
                      AppSpacing.h24,
                    ],
                  ),
                  AppSpacing.h10,

                  // Login Form Section
                  Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height * 0.80,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(130.r),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 30.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.logInButton,
                          // 'Login',
                          style: TextStyle(
                            fontSize: 32.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                        AppSpacing.h20,

                        // Email Field
                        BuildTextField(
                          label: AppStrings.emailLabel,
                          hint: AppStrings.emailPlaceholder,
                          controller: emailController,
                          errorText: authProvider.emailError,
                          onChanged: (value) {
                            // Clear error on change
                            authProvider.clearErrors();
                          },
                        ),
                        AppSpacing.h16,

                        // Password Field
                        BuildTextField(
                          label: AppStrings.passwordLabel,
                          hint: AppStrings.passwordPlaceholder,
                          controller: passwordController,
                          isPassword: true,
                          obscureText: _obscurePassword,
                          errorText: authProvider.passwordError,
                          onChanged: (value) {
                            // Clear error on change
                            authProvider.clearErrors();
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
                        AppSpacing.h4,

                        // Error Message Display
                        if (authProvider.errorMessage != null)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 12.h,
                            ),
                            margin: EdgeInsets.only(bottom: 16.h),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red.shade700,
                                  size: 20.sp,
                                ),

                                AppSpacing.w8,
                                Expanded(
                                  child: Text(
                                    authProvider.errorMessage!,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Forgot Password
                        Align(
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
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: const Color(0xFF42A5F5),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        AppSpacing.h20,

                        // Login Button
                        CustomLoginButton(
                          text: AppStrings.logInTitle,
                          isLoading: authProvider.isLoading,
                          onPressed: authProvider.isLoading
                              ? null
                              : () async {
                                  authProvider.clearErrors();

                                  final success = await authProvider.loginUser(
                                    email: emailController.text.trim(),
                                    password: passwordController.text,
                                  );

                                  if (success && mounted) {
                                    // Navigate to home page on success
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => HomePageScreen(),
                                      ),
                                    );
                                  }
                                },
                        ),
                        AppSpacing.h20,

                        // OR Divider
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Colors.grey[300],
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              child: Text(
                                AppStrings.orLoginWith,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.grey[300],
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        AppSpacing.h20,

                        // Google login
                        GoogleLoginBtn(),
                        AppSpacing.h16,

                        // Create Account
                        Center(
                          child: RichText(
                            text: TextSpan(
                              text: AppStrings.noAccountPrefix,
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: AppColors.subtitleText,
                                //  Colors.grey[600],
                              ),
                              children: [
                                TextSpan(
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const GeoSignUpScreen(),
                                        ),
                                      );
                                    },
                                  text: ' ' + AppStrings.createAccountTitle,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        AppSpacing.h24,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
