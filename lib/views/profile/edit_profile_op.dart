import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_spacing.dart';
import 'package:geography_geyser/core/app_strings.dart';
import 'package:geography_geyser/routes/app_routes.dart';
import 'package:geography_geyser/views/home/homepage.dart';

class EditProfileOption extends StatefulWidget {
  const EditProfileOption({super.key});

  @override
  State<EditProfileOption> createState() => _EditProfileOptionState();
}

class _EditProfileOptionState extends State<EditProfileOption> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
         backgroundColor: AppColors.bgColor,
      appBar: AppBar(
           backgroundColor: AppColors.bgColor,
        title: Text(AppStrings.moduleSettingOption),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0.r),
            child: Column(
              children: [
                ActionButton(
                  icon: Icons.settings_outlined,
                  label: AppStrings.generalSetting,
                  onTap: () {
                    context.push(AppRoutes.generalSettings);
                  },
                ),
                AppSpacing.h6,
                ActionButton(
                  icon: Icons.lock_outline,
                  label: AppStrings.privacySetting,
                  onTap: () {
                    context.push(AppRoutes.privacySettings);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
