import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_spacing.dart';
import 'package:geography_geyser/core/app_strings.dart';
import 'package:geography_geyser/core/font_manager.dart';
import 'package:geography_geyser/provider/auth_provider/login_provider.dart';
import 'package:geography_geyser/provider/home_provider.dart';
import 'package:geography_geyser/provider/userstats_provider.dart';
import 'package:geography_geyser/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:geography_geyser/views/auth/login/login.dart';
import 'package:geography_geyser/views/home/op_mod_settings.dart';
import 'package:geography_geyser/views/profile/settings/general_settings.dart';
import 'package:geography_geyser/views/profile/settings/privacy_settings.dart';
import 'package:geography_geyser/models/home_model.dart';
import 'package:geography_geyser/models/userstats_model.dart';

class ProfileScreen extends StatefulWidget {
  final bool hideSettingsCard;

  const ProfileScreen({super.key, this.hideSettingsCard = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 🔹 Load user data
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.userModel == null && !userProvider.isLoading) {
        await userProvider.fetchUserData();
      }

      // 🔹 Load stats from storage first, then from API
      final statsProvider =
          Provider.of<UserStatsProvider>(context, listen: false);
      await statsProvider.loadUserStatsFromStorage();
      await statsProvider.fetchUserStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: Consumer2<UserProvider, UserStatsProvider>(
          builder: (context, userProvider, statsProvider, child) {
            final user = userProvider.userModel;
            final stats = statsProvider.userStats;

            final isLoading =
                userProvider.isLoading || statsProvider.isLoading;

            if (isLoading && (user == null || stats == null)) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button (only show when navigated to as a pushed screen)
                  if (widget.hideSettingsCard) ...[
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Row(
                        children: [
                          Icon(Icons.arrow_back, color: AppColors.black),
                          AppSpacing.w8,
                          Text(
                            AppStrings.backButton,
                            style:
                                FontManager.bodyText(color: AppColors.black),
                          ),
                        ],
                      ),
                    ),
                    AppSpacing.h24,
                  ],

                  // Profile Header
                  buildProfileHeader(user, stats),

                  AppSpacing.h24,

                  // Progress Section
                  buildProgressSection(stats),

                  AppSpacing.h24,

                  // Subject Performance Section
                  buildSubjectPerformanceSection(),

                  AppSpacing.h40,
                  // Settings Card (conditionally shown)
                  if (!widget.hideSettingsCard) ...[
                    buildSettingsCard(context),
                    AppSpacing.h24,
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// PROFILE HEADER
  Widget buildProfileHeader(HomeModel? user, UserStatsModel? stats) {
    return Center(
      child: Column(
        children: [
          _buildProfileAvatar(user?.profilePic),
          AppSpacing.h16,
          Text(
            user?.fullName ?? AppStrings.userName,
            style: FontManager.bigTitle(fontSize: 18),
          ),
          AppSpacing.h8,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emoji_events_outlined,
                color: Colors.orange,
                size: 20.sp,
              ),
              AppSpacing.w8,
              Text(
                "XP: ${stats?.totalXp ?? '--'}",
                style: FontManager.bodyText(color: Colors.orange),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build profile avatar with network image fallback
  Widget _buildProfileAvatar(String? profilePicUrl) {
    if (profilePicUrl != null && profilePicUrl.isNotEmpty) {
      // Handle relative URLs by prepending base URL
      String imageUrl = profilePicUrl;
      if (!profilePicUrl.startsWith('http://') &&
          !profilePicUrl.startsWith('https://')) {
        // Remove leading slash if present and combine with base URL
        String cleanUrl = profilePicUrl.startsWith('/')
            ? profilePicUrl.substring(1)
            : profilePicUrl;
        imageUrl = '${ApiService.baseUrl}/$cleanUrl';
      }

      return CircleAvatar(
        radius: 50.r,
        backgroundColor: Colors.grey[300],
        child: ClipOval(
          child: Image.network(
            imageUrl,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                'assets/images/man.png',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
          ),
        ),
      );
    } else {
      return CircleAvatar(
        radius: 50.r,
        backgroundImage: AssetImage('assets/images/man.png'),
      );
    }
  }

  /// SETTINGS CARD
  Widget buildSettingsCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // General settings
          buildSettingRow(
            icon: Icons.settings_outlined,
            text: AppStrings.generalSetting,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GeneralSettings_Screen(),
                ),
              );
            },
          ),
          Divider(height: 1, color: Colors.grey[300]),
          //Privacy settings
          buildSettingRow(
            icon: Icons.lock_outline,
            text: AppStrings.privacySetting,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PrivacySettings_Screen(),
                ),
              );
            },
          ),
          Divider(height: 1, color: Colors.grey[300]),
          // Module Settings Row
          buildSettingRow(
            icon: Icons.settings_outlined,
            text: AppStrings.moduleSettingOption,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OptionalModuleSettings(),
                ),
              );
            },
          ),
          Divider(height: 1, color: Colors.grey[300]),
          // Logout Row
          buildSettingRow(
            icon: Icons.logout_outlined,
            text: AppStrings.logOutOption,
            textColor: AppColors.red, // ✅ Themed logout color
            iconColor: AppColors.red,
            onTap: () => showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  Widget buildSettingRow({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? Colors.black, size: 24.sp),
            AppSpacing.w16,
            Expanded(
              child: Text(
                text,
                style: FontManager.bodyText(color: textColor ?? Colors.black),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[600], size: 16.sp),
          ],
        ),
      ),
    );
  }

  /// PROGRESS SECTION
  Widget buildProgressSection(UserStatsModel? stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.progressTitle, style: FontManager.bigTitle()),
        AppSpacing.h16,
        Column(
          children: [
            buildProgressCard(
              label: AppStrings.quizAttemptedLabel,
              value: stats != null
                  ? '${stats.totalAttemptedQuizzes}'
                  : AppStrings.quizAttemptedValue,
            ),
            AppSpacing.h12,
            buildProgressCard(
              label: AppStrings.averageScoreLabel,
              value: stats != null
                  ? '${stats.averageScore.toStringAsFixed(1)}%'
                  : AppStrings.averageScoreValue,
            ),
            AppSpacing.h12,
            buildProgressCard(
              label: AppStrings.subjectCoveredLabel,
              value: AppStrings.subjectCoveredValue,
            ),
          ],
        ),
      ],
    );
  }

  Widget buildProgressCard({required String label, required String value}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 8.r, horizontal: 16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: FontManager.subtitleText()),
          AppSpacing.h8,
          Text(
            value,
            style: FontManager.bigTitle(),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// SUBJECT PERFORMANCE
  Widget buildSubjectPerformanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.subjectPerformanceTitle, style: FontManager.bigTitle()),
        AppSpacing.h16,
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              buildSubjectProgress(AppStrings.tectonicsSubject, 48),
              AppSpacing.h12,
              buildSubjectProgress(AppStrings.waterCycleSubject, 74),
              AppSpacing.h12,
              buildSubjectProgress(AppStrings.carbonCycleSubject, 54),
              AppSpacing.h12,
              buildSubjectProgress(AppStrings.globalisationSubject, 88),
              AppSpacing.h12,
              buildSubjectProgress(AppStrings.migrationSubject, 65),
              AppSpacing.h12,
              buildSubjectProgress(AppStrings.coastsSubject, 76),
              AppSpacing.h12,
              buildSubjectProgress(AppStrings.glaciersSubject, 24),
              AppSpacing.h12,
              buildSubjectProgress(AppStrings.regeneratingPlacesSubject, 82),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildSubjectProgress(String subject, int percentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(subject, style: FontManager.bodyText(color: Colors.black)),
            Text(
              '$percentage%',
              style: FontManager.bodyText(color: Colors.black),
            ),
          ],
        ),
        AppSpacing.h8,
        Container(
          height: 8.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.r),
            color: Colors.grey[200],
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage / 100,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.r),
                color: AppColors.buttonColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// LOGOUT DIALOG
  void showLogoutDialog(BuildContext context) {
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
            AppStrings.logoutConfirmationMessage,
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
                    onPressed: () async {
                      Navigator.of(context).pop();
                      // Clear secure storage and all login data
                      await LoginProvider.logout();
                      if (context.mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      }
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.buttonColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Text(
                      AppStrings.logOutButton,
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
}

// void showTimeoutDialog(BuildContext context) {
//   showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16.r),
//         ),
//         contentPadding: EdgeInsets.all(24.w),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Clock Icon
//             Container(
//               width: 60.w,
//               height: 60.h,
//               decoration: BoxDecoration(
//                 color: Colors.red.shade50,
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.access_time_rounded,
//                 color: Colors.red,
//                 size: 32.sp,
//               ),
//             ),
//             AppSpacing.h20,

//             // Title
//             Text(
//               AppStrings.timeUp,
//               style: FontManager.bigTitle(),
//               textAlign: TextAlign.center,
//             ),

//             AppSpacing.h14,

//             // Description
//             Text(
//               AppStrings.timeUpwarning,
//               style: FontManager.bodyText(color: AppColors.grey),
//               textAlign: TextAlign.center,
//             ),

//             AppSpacing.h24,

//             // Ok Button
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () => Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => QuizResult_Screen()),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Color(0xFF4A90E2), // Blue color
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8.r),
//                   ),
//                   padding: EdgeInsets.symmetric(vertical: 14.h),
//                   elevation: 0,
//                 ),
//                 child: Text(
//                   AppStrings.cancelButton, // Or use "Ok" directly
//                   style: FontManager.bodyText(color: Colors.white),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       );
//     },
//   );
// }
