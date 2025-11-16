import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_spacing.dart';
import 'package:geography_geyser/core/app_strings.dart';
import 'package:geography_geyser/core/font_manager.dart';
import 'package:geography_geyser/provider/auth_provider/signup_provider/verify_otp_provider.dart';
import 'package:geography_geyser/views/auth/sign_up/reg_congratulations.dart';
import 'package:pinput/pinput.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String? email;

  const VerifyOtpScreen({super.key, this.email});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();
  int _resendTimer = 60;
  Timer? _timer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() {
          _resendTimer--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pinController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  String _maskEmail(String email) {
    if (email.isEmpty) return email;

    final parts = email.split('@');
    if (parts.length != 2) return email;

    final localPart = parts[0];
    final domain = parts[1];

    if (localPart.isEmpty) return email;

    // Show first letter and mask the rest
    final maskedLocal = localPart[0] + ('*' * (localPart.length - 1));

    return '$maskedLocal@$domain';
  }

  @override
  Widget build(BuildContext context) {
    // Pinput theme configuration
    final defaultPinTheme = PinTheme(
      width: 45.w,
      height: 52.h,
      textStyle: TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.buttonColor, width: 1.5),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppColors.buttonColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.buttonColor.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: Color(0xFFF3F4F6),
        border: Border.all(color: AppColors.buttonColor, width: 1.5),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(12.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(Icons.arrow_back_outlined, color: Colors.black),
                  ),
                ),
              ),
              Text(
                AppStrings.verifyAccountTitle,
                style: FontManager.bigTitle(fontSize: 22),
                //  TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w700),
              ),
              Text(AppStrings.almostDone),
              AppSpacing.h16,
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.r),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Image.asset(
                          "assets/images/security_vec.png",
                          // width: 180.w,
                          height: 180.h,
                          fit: BoxFit.contain,
                        ),
                      ),

                      AppSpacing.h12,
                      Text(
                        AppStrings.verificationCodePrompt,
                        style: FontManager.bigTitle(),
                      ),
                      AppSpacing.h16,
                      Text(
                        AppStrings.verificationCodeSent,
                        style: FontManager.subtitleText(),
                      ),
                      AppSpacing.h10,
                      Text(
                        widget.email != null && widget.email!.isNotEmpty
                            ? _maskEmail(widget.email!)
                            : AppStrings.otpInstructionEmailExample,
                        style: FontManager.subSubtitleText(),
                      ),
                      AppSpacing.h32,
                      Center(
                        child: Pinput(
                          keyboardType: TextInputType.phone,
                          controller: _pinController,
                          focusNode: _pinFocusNode,
                          length: 6,
                          defaultPinTheme: defaultPinTheme,
                          focusedPinTheme: focusedPinTheme,
                          submittedPinTheme: submittedPinTheme,
                          pinAnimationType: PinAnimationType.fade,
                          hapticFeedbackType: HapticFeedbackType.lightImpact,
                          onCompleted: (pin) {
                            debugPrint('Completed: $pin');
                          },
                          onChanged: (value) {
                            debugPrint('Changed: $value');
                          },
                          cursor: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                margin: EdgeInsets.only(bottom: 8.h),
                                width: 22.w,
                                height: 1.h,
                                color: AppColors.buttonColor,
                              ),
                            ],
                          ),
                        ),
                      ),

                      AppSpacing.h24,
                      RichText(
                        text: TextSpan(
                          text: AppStrings.didntReceiveCode,
                          style: FontManager.bodyText(),
                          children: [
                            TextSpan(
                              text: ' ${AppStrings.resendOTPCode}',
                              style: FontManager.bodyText(
                                color: AppColors.buttonColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppSpacing.h10,
                      // Verify Button
                      SizedBox(
                        width: double.infinity,
                        height: 46.h,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  final otp = _pinController.text.trim();

                                  if (otp.length != 6) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Please enter 6-digit OTP",
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  setState(() => _isLoading = true);

                                  try {
                                    final response =
                                        await VerifyProvider.verifyOtp(
                                          otp,
                                          context,
                                        );

                                    if (response['success'] == true) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text("OTP Verified ✅"),
                                          ),
                                        );

                                        // ✅ Navigate ONLY on success
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                RegCongratulations_Screen(),
                                          ),
                                        );
                                      }
                                    } else {
                                      // ❌ OTP failed → navigator disabled automatically
                                      throw {
                                        'message':
                                            response['message'] ??
                                            'OTP verification failed',
                                      };
                                    }
                                  } catch (e) {
                                    String message = 'OTP verification failed';
                                    if (e is Map && e['message'] != null) {
                                      message = e['message'].toString();
                                    }

                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text(message)),
                                      );
                                    }
                                  } finally {
                                    if (mounted)
                                      setState(() => _isLoading = false);
                                  }
                                },

                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buttonColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  AppStrings.verifyAccountTitle,
                                  style: FontManager.buttonTextRegular(),
                                ),
                        ),
                      ),

                      AppSpacing.h20,
                      // Resend Code Timer
                      Text(
                        'Resend code in ${_resendTimer}s',
                        style: FontManager.buttonText(),
                        //  TextStyle(
                        //   fontSize: 14.sp,
                        //   fontWeight: FontWeight.w500,
                        //   color: Colors.black87,
                        // ),
                      ),

                      // Help Text
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
