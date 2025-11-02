import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_spacing.dart';
import 'package:geography_geyser/core/app_strings.dart';
import 'package:geography_geyser/core/font_manager.dart';
import 'package:geography_geyser/views/auth/sign_up/reg_congratulations.dart';
import 'package:pinput/pinput.dart';

class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen({super.key});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();
  int _resendTimer = 60;
  Timer? _timer;

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
                        AppStrings.otpInstructionEmailExample,
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
                          onPressed: () {
                            if (_pinController.text.length == 6) {
                              debugPrint(
                                'Verifying PIN: ${_pinController.text}',
                              );
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      RegCongratulations_Screen(),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buttonColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            AppStrings.verifyAccountTitle,
                            // 'Verify Account',
                            style: FontManager.buttonTextRegular(),
                            // TextStyle(
                            //   fontSize: 16.sp,
                            //   fontWeight: FontWeight.w600,
                            //   color: AppColors.white,
                            // ),
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
