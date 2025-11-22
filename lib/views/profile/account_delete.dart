import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_spacing.dart';
import 'package:geography_geyser/core/app_strings.dart';
import 'package:geography_geyser/core/font_manager.dart';
import 'package:geography_geyser/views/custom_widgets/buildTextField.dart';
import 'package:geography_geyser/views/custom_widgets/custom_login_button.dart';

class AccountDelete extends StatefulWidget {
  AccountDelete({super.key});

  @override
  State<AccountDelete> createState() => _AccountDeleteState();
   final TextEditingController _passwordController = TextEditingController();
}

class _AccountDeleteState extends State<AccountDelete> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        title: Text("Account Deletion", style: FontManager.titleText()),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  AppStrings.accountdeleteDescription,
                  style: FontManager.subtitleText(),
                ),
                AppSpacing.h20,
                BuildTextField(
                  // controller: _nameController,
                  label: AppStrings.enterPass,
                  hint: "*******".toString(),
                ),
                AppSpacing.h8,
                Text(AppStrings.deletePassWar, style: FontManager.alertText()),
                AppSpacing.h32,
                CustomLoginButton(
                  text: "Delete Account",
                  backgroundColor: AppColors.red,
                  onPressed: () => showAccountDelete(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void showAccountDelete(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          AppStrings.areYouSureTitle,
          style: FontManager.bigTitle(),
          textAlign: TextAlign.center,
        ),
        content: Text(
          AppStrings.accountDeleteHint,
          style: FontManager.bodyText(),
          textAlign: TextAlign.center,
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.bgColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: Text(
                    AppStrings.cancelButton,
                    style: FontManager.buttonText().copyWith(
                      color: AppColors.black,
                    ),
                  ),
                ),
              ),
              AppSpacing.w12,
              Expanded(
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: Text(
                    AppStrings.delete,
                    style: FontManager.buttonText(),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}
