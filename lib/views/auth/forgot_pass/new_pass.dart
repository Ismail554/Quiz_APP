import 'package:flutter/material.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_spacing.dart';
import 'package:geography_geyser/core/app_strings.dart';
import 'package:geography_geyser/core/font_manager.dart';
import 'package:geography_geyser/views/auth/forgot_pass/congratulations.dart';
import 'package:geography_geyser/views/custom_widgets/buildTextField.dart';
import 'package:geography_geyser/views/custom_widgets/custom_login_button.dart';

class NewPass_screen extends StatefulWidget {
  const NewPass_screen({super.key});

  @override
  State<NewPass_screen> createState() => _NewPass_screenState();
}

class _NewPass_screenState extends State<NewPass_screen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.bgColor.withOpacity(01),
        title: Text("Back", style: FontManager.appBarText()),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                AppSpacing.h24,
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    AppStrings.createPassword,
                    style: FontManager.boldHeading(color: Colors.blue),
                  ),
                ),
                AppSpacing.h24,
                BuildTextField(
                  label: AppStrings.newPassword,
                  hint: AppStrings.passHint,
                ),
                AppSpacing.h20,
                BuildTextField(
                  label: AppStrings.confirmNewPassword,
                  hint: AppStrings.confirmNewHint,
                ),
                AppSpacing.h24,
                CustomLoginButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CongratulationsScreen(),
                      ),
                    );
                  },
                  text: AppStrings.saveButton,
                  // backgroundColor: AppColors.buttonColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
