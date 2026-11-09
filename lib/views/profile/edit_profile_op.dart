import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_spacing.dart';
import 'package:geography_geyser/core/app_strings.dart';
import 'package:geography_geyser/routes/app_routes.dart';

class EditProfileOption extends StatefulWidget {
  const EditProfileOption({super.key});

  @override
  State<EditProfileOption> createState() => _EditProfileOptionState();
}

class _EditProfileOptionState extends State<EditProfileOption> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softSky,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(AppStrings.moduleSettingOption),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
                _ProfileOptionTile(
                  icon: Icons.settings_outlined,
                  label: AppStrings.generalSetting,
                  onTap: () {
                    context.push(AppRoutes.generalSettings);
                  },
                ),
                AppSpacing.h12,
                _ProfileOptionTile(
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

class _ProfileOptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ProfileOptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.azureBorder),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryAzure),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.neutralDark,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: AppColors.softSlate,
        ),
        onTap: onTap,
      ),
    );
  }
}