import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_spacing.dart';
import 'package:geography_geyser/core/app_strings.dart';
import 'package:geography_geyser/core/font_manager.dart';
import 'package:geography_geyser/views/custom_widgets/custom_login_button.dart';
import 'package:geography_geyser/views/custom_widgets/custom_toggle_button.dart';
import 'package:geography_geyser/views/custom_widgets/module_selection_row.dart';
import 'package:geography_geyser/views/home/homepage.dart';

class OptionalModuleSettings extends StatefulWidget {
  const OptionalModuleSettings({super.key});

  @override
  State<OptionalModuleSettings> createState() => _OptionalModuleSettingsState();
}

class _OptionalModuleSettingsState extends State<OptionalModuleSettings> {
  bool row1LeftSelected = true;
  bool row2RightSelected = true;
  bool row3LeftSelected = false;
  bool row3RightSelected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppStrings.moduleSettingTitle,
          style: FontManager.titleText(),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSpacing.h20,

                    Text(
                      AppStrings.selectOptionalModuleInstruction,
                      style: FontManager.bigTitle(),
                    ),
                    AppSpacing.h32,

                    //     // Module Selection Rows

                    //     ModuleSelectionRow(
                    //       leftOption: AppStrings.moduleCoasts,
                    //       rightOption: AppStrings.moduleCoasts,
                    //       isLeftSelected: row1LeftSelected,
                    //       isRightSelected: !row1LeftSelected,
                    //       onSelectionChanged: (isLeft) {
                    //         setState(() {
                    //           row1LeftSelected = isLeft;
                    //         });
                    //       },
                    //     ),
                    //     AppSpacing.h16,

                    //     ModuleSelectionRow(
                    //       leftOption: AppStrings.moduleGlaciers,
                    //       rightOption: AppStrings.moduleHHRI,
                    //       isLeftSelected: !row2RightSelected,
                    //       isRightSelected: row2RightSelected,
                    //       onSelectionChanged: (isLeft) {
                    //         setState(() {
                    //           row2RightSelected = !isLeft;
                    //         });
                    //       },
                    //     ),
                    //     AppSpacing.h16,

                    //     ModuleSelectionRow(
                    //       leftOption: AppStrings.moduleMigrations,
                    //       rightOption: AppStrings.moduleCoasts,
                    //       isLeftSelected: row3LeftSelected,
                    //       isRightSelected: row3RightSelected,
                    //       onSelectionChanged: (isLeft) {
                    //         setState(() {
                    //           row3LeftSelected = isLeft;
                    //           row3RightSelected = !isLeft;
                    //         });
                    //       },
                    //     ),
                    //     AppSpacing.h20,

                    // new toggle button UI
                    CustomToggleButton(
                      option1: AppStrings.carbonCycleSubject,
                      option2: AppStrings.glaciersSubject,
                    ),
                    AppSpacing.h12,
                    CustomToggleButton(
                      option1: AppStrings.coastsSubject,
                      option2: AppStrings.migrationSubject,
                    ),
                    AppSpacing.h12,
                    CustomToggleButton(
                      option1: AppStrings.coastsSubject,
                      option2: AppStrings.glaciersSubject,
                    ),
                    AppSpacing.h12,
                  ],
                ),
              ),
            ),

            // Go to Home Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: CustomLoginButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HomePageScreen(),
                    ),
                  );
                },
                text: AppStrings.goHome,
              ),
            ),
            AppSpacing.h16,
          ],
        ),
      ),
    );
  }
}
