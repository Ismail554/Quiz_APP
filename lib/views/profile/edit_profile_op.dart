import 'package:flutter/material.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_spacing.dart';
import 'package:geography_geyser/core/app_strings.dart';
import 'package:geography_geyser/views/home/homepage.dart';
import 'package:geography_geyser/views/profile/settings/general_settings.dart';
import 'package:geography_geyser/views/profile/settings/privacy_settings.dart';

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
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                ActionButton(
                  icon: Icons.settings_outlined,
                  label: AppStrings.generalSetting,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GeneralSettings_Screen(),
                      ),
                    );
                  },
                ),
                AppSpacing.h6,
                ActionButton(
                  icon: Icons.lock_outline,
                  label: AppStrings.privacySetting,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PrivacySettings_Screen(),
                      ),
                    );
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
