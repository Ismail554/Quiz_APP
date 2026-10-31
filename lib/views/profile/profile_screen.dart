import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_spacing.dart';
import 'package:geography_geyser/core/app_strings.dart';
import 'package:geography_geyser/models/home_model.dart';
import 'package:geography_geyser/models/userstats_model.dart';
import 'package:geography_geyser/models/user_performance_model.dart';
import 'package:geography_geyser/provider/auth_provider/login_provider.dart';
import 'package:geography_geyser/provider/home_provider.dart';
import 'package:geography_geyser/provider/local_progress_provider.dart';
import 'package:geography_geyser/provider/settings_provider/optional_module_provider.dart';
import 'package:geography_geyser/provider/user_performance_provider.dart';
import 'package:geography_geyser/provider/userstats_provider.dart';
import 'package:geography_geyser/routes/app_routes.dart';
import 'package:geography_geyser/services/api_service.dart';
import 'package:geography_geyser/views/custom_widgets/custom_snackbar.dart';
import 'package:geography_geyser/views/custom_widgets/stitch_design_widgets.dart';

class ProfileScreen extends StatelessWidget {
  final bool hideSettingsCard;

  const ProfileScreen({super.key, this.hideSettingsCard = false});

  static bool _isInitialized = false;

  static void resetInitialization() {
    _isInitialized = false;
  }

  void _initializeData(BuildContext context) {
    if (_isInitialized) return;
    _isInitialized = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!context.mounted) return;
      await _loadUserData(context);
      if (!context.mounted) return;
      await _loadStatsData(context);
      if (!context.mounted) return;
      await _loadPerformanceData(context);
    });
  }

  Future<void> _loadUserData(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.loadUserDataFromStorage();

    if (context.mounted &&
        userProvider.userModel == null &&
        !userProvider.isLoading) {
      await userProvider.fetchUserData();
    }
  }

  Future<void> _loadStatsData(BuildContext context) async {
    final statsProvider = Provider.of<UserStatsProvider>(
      context,
      listen: false,
    );
    await statsProvider.loadUserStatsFromStorage();

    if (context.mounted &&
        statsProvider.userStats == null &&
        !statsProvider.isLoading) {
      await statsProvider.fetchUserStats();
    }
  }

  Future<void> _loadPerformanceData(BuildContext context) async {
    final performanceProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );
    await performanceProvider.loadProfileFromStorage();

    if (context.mounted &&
        performanceProvider.profileData == null &&
        !performanceProvider.isLoading) {
      await performanceProvider.fetchProfile();
    }
  }

  Future<void> _refreshAllData(
    UserProvider userProvider,
    UserStatsProvider statsProvider,
    ProfileProvider performanceProvider,
  ) async {
    await Future.wait([
      userProvider.fetchUserData(),
      statsProvider.fetchUserStats(),
      performanceProvider.fetchProfile(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    _initializeData(context);
    return StitchAmbientScaffold(
      body: SafeArea(
        child:
            Consumer4<
              UserProvider,
              UserStatsProvider,
              ProfileProvider,
              LocalProgressProvider
            >(
              builder:
                  (
                    context,
                    userProvider,
                    statsProvider,
                    performanceProvider,
                    localProgress,
                    child,
                  ) {
                    final user = userProvider.userModel;
                    final stats = statsProvider.userStats;
                    final performance = performanceProvider.profileData;

                    final isLoading =
                        userProvider.isLoading ||
                        statsProvider.isLoading ||
                        performanceProvider.isLoading;
                    final hasNoData = user == null && stats == null;

                    if (isLoading && hasNoData) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryAzure,
                        ),
                      );
                    }

                    return RefreshIndicator(
                      color: AppColors.primaryAzure,
                      onRefresh: () => _refreshAllData(
                        userProvider,
                        statsProvider,
                        performanceProvider,
                      ),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 32.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (hideSettingsCard) ...[
                              InkWell(
                                borderRadius: BorderRadius.circular(12.r),
                                onTap: () => Navigator.pop(context),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 6.h),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.arrow_back_ios_new_rounded,
                                        size: 16.sp,
                                        color: AppColors.neutralDark,
                                      ),
                                      SizedBox(width: 6.w),
                                      Text(
                                        AppStrings.backButton,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.neutralDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 12.h),
                            ],

                            // 1. User Profile & Account Hero Card
                            FadeInDown(
                              duration: const Duration(milliseconds: 420),
                              child: _buildProfileHeroCard(
                                context,
                                user,
                                stats,
                                performance,
                              ),
                            ),
                            SizedBox(height: 20.h),

                            // Learning Progress & Subject Mastery
                            FadeInUp(
                              duration: const Duration(milliseconds: 460),
                              child: _buildProgressMetricsRow(
                                stats,
                                performance,
                              ),
                            ),
                            SizedBox(height: 20.h),

                            FadeInUp(
                              duration: const Duration(milliseconds: 500),
                              child: _buildSubjectPerformanceSection(
                                performance,
                              ),
                            ),
                            SizedBox(height: 24.h),

                            if (!hideSettingsCard) ...[
                              // Section 1: Account & Curriculum Settings
                              _buildSectionTitle('Account & Curriculum'),
                              SizedBox(height: 10.h),
                              StitchCard(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 6.h,
                                ),
                                child: Column(
                                  children: [
                                    _buildSettingsNavTile(
                                      icon: Icons.person_outline_rounded,
                                      iconColor: AppColors.primaryAzure,
                                      title: 'Edit Profile & Account',
                                      subtitle:
                                          'Update your name, avatar, and explorer details',
                                      onTap: () => context.push(
                                        AppRoutes.generalSettings,
                                      ),
                                    ),
                                    const Divider(
                                      color: Color(0xFFF1F5F9),
                                      height: 1,
                                    ),
                                    _buildSettingsNavTile(
                                      icon: Icons.tune_rounded,
                                      iconColor: const Color(0xFF8B5CF6),
                                      title: AppStrings.moduleSettingOption,
                                      subtitle:
                                          'Choose Group B optional topics (Coasts/Glaciers, etc.)',
                                      onTap: () => context.push(
                                        AppRoutes.optionalModules,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 22.h),

                              // Section 2: Theme Preferences
                              _buildSectionTitle('Theme Preferences'),
                              SizedBox(height: 10.h),
                              StitchCard(
                                padding: EdgeInsets.all(14.r),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.palette_outlined,
                                          color: AppColors.primaryAzure,
                                          size: 20.sp,
                                        ),
                                        SizedBox(width: 10.w),
                                        Text(
                                          'Appearance Mode',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.neutralDark,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12.h),
                                    Row(
                                      children: [
                                        _buildThemeModeChip(
                                          context: context,
                                          label: 'Light',
                                          icon: Icons.light_mode_rounded,
                                          mode: ThemeMode.light,
                                          currentMode: localProgress.themeMode,
                                        ),
                                        SizedBox(width: 8.w),
                                        _buildThemeModeChip(
                                          context: context,
                                          label: 'Dark',
                                          icon: Icons.dark_mode_rounded,
                                          mode: ThemeMode.dark,
                                          currentMode: localProgress.themeMode,
                                        ),
                                        SizedBox(width: 8.w),
                                        _buildThemeModeChip(
                                          context: context,
                                          label: 'System',
                                          icon: Icons.brightness_auto_rounded,
                                          mode: ThemeMode.system,
                                          currentMode: localProgress.themeMode,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 22.h),

                              // Section 3: Notification Preferences
                              _buildSectionTitle('Notification Preferences'),
                              SizedBox(height: 10.h),
                              StitchCard(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 6.h,
                                ),
                                child: Column(
                                  children: [
                                    _buildSwitchTile(
                                      icon:
                                          Icons.notifications_active_outlined,
                                      iconColor: AppColors.accentGoldDark,
                                      title: 'Daily Geyser Streak Reminders',
                                      subtitle:
                                          'Stay consistent with daily A-Level revision prompts',
                                      value:
                                          localProgress.notificationsEnabled,
                                      onChanged: (val) => localProgress
                                          .setNotificationsEnabled(val),
                                    ),
                                    const Divider(
                                      color: Color(0xFFF1F5F9),
                                      height: 1,
                                    ),
                                    _buildSwitchTile(
                                      icon: Icons.ondemand_video_rounded,
                                      iconColor: const Color(0xFFDC2626),
                                      title:
                                          'New @GeographyGeyser Video Quizzes',
                                      subtitle:
                                          'Get notified when a new YouTube lesson & quiz drops',
                                      value: localProgress.youtubeAlertsEnabled,
                                      onChanged: (val) => localProgress
                                          .setYoutubeAlertsEnabled(val),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 22.h),

                              // Section 4: App Preferences
                              _buildSectionTitle('App Preferences'),
                              SizedBox(height: 10.h),
                              StitchCard(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 6.h,
                                ),
                                child: Column(
                                  children: [
                                    _buildSwitchTile(
                                      icon: Icons.volume_up_outlined,
                                      iconColor: AppColors.primaryAzure,
                                      title: 'Quiz Sound Effects',
                                      subtitle:
                                          'Play audio feedback on correct and wrong answers',
                                      value: localProgress.soundEffectsEnabled,
                                      onChanged: (val) => localProgress
                                          .setSoundEffectsEnabled(val),
                                    ),
                                    const Divider(
                                      color: Color(0xFFF1F5F9),
                                      height: 1,
                                    ),
                                    _buildSwitchTile(
                                      icon: Icons.vibration_rounded,
                                      iconColor: AppColors.emeraldSuccess,
                                      title: 'Tactile Haptic Feedback',
                                      subtitle:
                                          'Subtle vibrations during quiz interactions',
                                      value: localProgress.hapticsEnabled,
                                      onChanged: (val) =>
                                          localProgress.setHapticsEnabled(val),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 22.h),

                              // Section 5: Help & Support
                              _buildSectionTitle('Help & Support'),
                              SizedBox(height: 10.h),
                              StitchCard(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 6.h,
                                ),
                                child: Column(
                                  children: [
                                    _buildSettingsNavTile(
                                      icon: Icons.smart_display_rounded,
                                      iconColor: const Color(0xFFDC2626),
                                      title: '@GeographyGeyser YouTube Channel',
                                      subtitle:
                                          'Watch Edexcel A-Level Geography revision lessons',
                                      onTap: () async {
                                        final uri = Uri.parse(
                                          'https://www.youtube.com/@GeographyGeyser',
                                        );
                                        await launchUrl(
                                          uri,
                                          mode: LaunchMode.externalApplication,
                                        );
                                      },
                                    ),
                                    const Divider(
                                      color: Color(0xFFF1F5F9),
                                      height: 1,
                                    ),
                                    _buildSettingsNavTile(
                                      icon: Icons.link_rounded,
                                      iconColor: AppColors.primaryAzure,
                                      title: 'Test YouTube Deep Link',
                                      subtitle:
                                          'Simulate clicking a YouTube description quiz link',
                                      onTap: () =>
                                          _showDeepLinkTesterDialog(context),
                                    ),
                                    const Divider(
                                      color: Color(0xFFF1F5F9),
                                      height: 1,
                                    ),
                                    _buildSettingsNavTile(
                                      icon: Icons.mail_outline_rounded,
                                      iconColor: AppColors.accentGoldDark,
                                      title: 'Contact Creator & Support',
                                      subtitle:
                                          'simonA@standsureeducation.co.uk',
                                      onTap: () async {
                                        final emailUri = Uri(
                                          scheme: 'mailto',
                                          path:
                                              'simonA@standsureeducation.co.uk',
                                          query:
                                              'subject=Geography Geyser V2 Support',
                                        );
                                        try {
                                          await launchUrl(emailUri);
                                        } catch (_) {
                                          if (context.mounted) {
                                            CustomSnackBar.show(
                                              context,
                                              message:
                                                  'Support: simonA@standsureeducation.co.uk',
                                            );
                                          }
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 22.h),

                              // Section 6: Privacy & Legal Information
                              _buildSectionTitle('Privacy & Legal'),
                              SizedBox(height: 10.h),
                              StitchCard(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 6.h,
                                ),
                                child: Column(
                                  children: [
                                    _buildSettingsNavTile(
                                      icon: Icons.lock_outline_rounded,
                                      iconColor: AppColors.primaryAzure,
                                      title: AppStrings.privacySetting,
                                      subtitle:
                                          'Update your account password & security',
                                      onTap: () => context.push(
                                        AppRoutes.privacySettings,
                                      ),
                                    ),
                                    const Divider(
                                      color: Color(0xFFF1F5F9),
                                      height: 1,
                                    ),
                                    _buildSettingsNavTile(
                                      icon: Icons.info_outline_rounded,
                                      iconColor: AppColors.emeraldSuccess,
                                      title: 'About Geography Geyser & Legal',
                                      subtitle:
                                          'Version 2.0 • Terms of Use & Privacy Policy',
                                      onTap: () =>
                                          context.push(AppRoutes.aboutApp),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 22.h),

                              // Section 7: Sign-Out & Account Management
                              _buildSectionTitle('Account Management'),
                              SizedBox(height: 10.h),
                              StitchCard(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 6.h,
                                ),
                                child: Column(
                                  children: [
                                    _buildSettingsNavTile(
                                      icon: Icons.logout_rounded,
                                      iconColor: AppColors.errorCoral,
                                      title: AppStrings.logOutOption,
                                      subtitle:
                                          'Sign out of your Geography Geyser account',
                                      titleColor: AppColors.errorCoral,
                                      onTap: () => showLogoutDialog(context),
                                    ),
                                    const Divider(
                                      color: Color(0xFFF1F5F9),
                                      height: 1,
                                    ),
                                    _buildSettingsNavTile(
                                      icon: Icons.delete_forever_rounded,
                                      iconColor: AppColors.errorCoral,
                                      title: AppStrings.accountdelection,
                                      subtitle:
                                          'Permanently delete your account and XP history',
                                      titleColor: AppColors.errorCoral,
                                      onTap: () =>
                                          context.push(AppRoutes.accountDelete),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
            ),
      ),
    );
  }

  Widget _buildProfileHeroCard(
    BuildContext context,
    HomeModel? user,
    UserStatsModel? stats,
    ProfileModel? performance,
  ) {
    final profilePic = performance?.profilePic ?? user?.profilePic;
    final fullName =
        performance?.fullName ?? user?.fullName ?? 'Alex Mercer';
    final email = user?.email ?? 'explorer@geographygeyser.com';
    final totalXp = performance?.totalXp ?? stats?.totalXp ?? 1240;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: AppColors.oceanHeaderGradient,
        borderRadius: BorderRadius.circular(26.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryAzure.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildProfileAvatar(profilePic),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 19.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.bolt_rounded,
                            color: const Color(0xFFFDE047),
                            size: 15.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '$totalXp XP',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    InkWell(
                      onTap: () => context.push(AppRoutes.generalSettings),
                      borderRadius: BorderRadius.circular(999.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999.r),
                        ),
                        child: Text(
                          'Edit Profile',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryAzure,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar(String? profilePicUrl) {
    return Container(
      padding: EdgeInsets.all(2.5.r),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.7),
          width: 2,
        ),
      ),
      child: CircleAvatar(
        radius: 34.r,
        backgroundColor: Colors.white,
        child: ClipOval(
          child: (profilePicUrl != null && profilePicUrl.isNotEmpty)
              ? Image.network(
                  _buildImageUrl(profilePicUrl),
                  width: 68.w,
                  height: 68.w,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Image.asset(
                    'assets/images/man.png',
                    width: 68.w,
                    height: 68.w,
                    fit: BoxFit.cover,
                  ),
                )
              : Image.asset(
                  'assets/images/man.png',
                  width: 68.w,
                  height: 68.w,
                  fit: BoxFit.cover,
                ),
        ),
      ),
    );
  }

  String _buildImageUrl(String profilePicUrl) {
    if (profilePicUrl.startsWith('http://') ||
        profilePicUrl.startsWith('https://')) {
      return profilePicUrl;
    }
    final cleanUrl = profilePicUrl.startsWith('/')
        ? profilePicUrl.substring(1)
        : profilePicUrl;
    return '${ApiService.baseUrl}/$cleanUrl';
  }

  Widget _buildProgressMetricsRow(
    UserStatsModel? stats,
    ProfileModel? performance,
  ) {
    final attempted =
        performance?.quizAttempted ?? stats?.totalAttemptedQuizzes ?? 18;
    final avgScore = performance != null
        ? '${performance.averageScore.toStringAsFixed(0)}%'
        : (stats != null ? '${stats.averageScore.toStringAsFixed(0)}%' : '84%');
    final covered = performance?.subjectCovered ?? 8;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.quiz_outlined,
            color: AppColors.primaryAzure,
            value: '$attempted',
            label: 'Quizzes',
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _buildStatCard(
            icon: Icons.insights_rounded,
            color: AppColors.emeraldSuccess,
            value: avgScore,
            label: 'Avg Score',
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _buildStatCard(
            icon: Icons.public_rounded,
            color: AppColors.accentGoldDark,
            value: '$covered/12',
            label: 'Modules',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return StitchCard(
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 10.w),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22.sp),
          SizedBox(height: 6.h),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.neutralDark,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.neutralSlate,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectPerformanceSection(ProfileModel? performance) {
    final subjects = performance?.subjects ?? [];
    if (subjects.isEmpty) return const SizedBox.shrink();

    return StitchCard(
      padding: EdgeInsets.all(18.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.bar_chart_rounded,
                color: AppColors.primaryAzure,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                AppStrings.subjectPerformanceTitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15.5.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.neutralDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          ...subjects.take(6).map((subject) {
            final pct = subject.progress.clamp(0.0, 100.0);
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          subject.moduleName,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.neutralDark,
                          ),
                        ),
                      ),
                      Text(
                        '${pct.toInt()}%',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryAzure,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999.r),
                    child: LinearProgressIndicator(
                      value: (pct / 100.0).clamp(0.04, 1.0),
                      minHeight: 7.h,
                      backgroundColor: AppColors.softSky,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primaryAzure,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11.5.sp,
          fontWeight: FontWeight.w800,
          color: AppColors.neutralSlate,
          letterSpacing: 0.9,
        ),
      ),
    );
  }

  Widget _buildSettingsNavTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          children: [
            Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(11.r),
              ),
              child: Icon(icon, color: iconColor, size: 20.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: titleColor ?? AppColors.neutralDark,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.neutralSlate,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.neutralMuted,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          Container(
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11.r),
            ),
            child: Icon(icon, color: iconColor, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutralDark,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.neutralSlate,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeTrackColor: AppColors.primaryAzure,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeModeChip({
    required BuildContext context,
    required String label,
    required IconData icon,
    required ThemeMode mode,
    required ThemeMode currentMode,
  }) {
    final isSelected = mode == currentMode;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          context.read<LocalProgressProvider>().setThemeMode(mode);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryAzure : AppColors.softSky,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryAzure
                  : AppColors.azureBorder,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16.sp,
                color: isSelected ? Colors.white : AppColors.neutralSlate,
              ),
              SizedBox(width: 6.w),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : AppColors.neutralDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeepLinkTesterDialog(BuildContext context) {
    final controller = TextEditingController(
      text: 'https://geographygeyser.com/quiz/yt-tectonics-plates',
    );
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Text(
            'YouTube-to-App Deep Link Simulator',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.neutralDark,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Paste or select a Geography Geyser YouTube quiz link to verify direct deep-link routing:',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5.sp,
                  color: AppColors.neutralSlate,
                ),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: controller,
                style: GoogleFonts.plusJakartaSans(fontSize: 12.5.sp),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.softSky,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: AppColors.azureBorder),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Wrap(
                spacing: 6.w,
                runSpacing: 6.h,
                children: [
                  ActionChip(
                    label: const Text('Tectonics Video'),
                    onPressed: () => controller.text =
                        'https://geographygeyser.com/quiz/yt-tectonics-plates',
                  ),
                  ActionChip(
                    label: const Text('Superpowers Video'),
                    onPressed: () => controller.text =
                        'https://geographygeyser.com/quiz/yt-superpowers-china',
                  ),
                  ActionChip(
                    label: const Text('Invalid ID Fallback'),
                    onPressed: () => controller.text =
                        'https://geographygeyser.com/quiz/unknown-video-999',
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryAzure,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final raw = controller.text.trim();
                Navigator.of(dialogContext).pop();
                final uri = Uri.tryParse(raw);
                if (uri != null && uri.path.isNotEmpty) {
                  context.push(uri.path);
                } else {
                  context.push(AppRoutes.quizByIdPath(raw));
                }
              },
              child: const Text('Open Deep Link'),
            ),
          ],
        );
      },
    );
  }

  void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Text(
            AppStrings.areYouSureTitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.neutralDark,
            ),
            textAlign: TextAlign.center,
          ),
          content: Text(
            AppStrings.logoutConfirmationMessage,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5.sp,
              color: AppColors.neutralSlate,
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primaryAzure),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 13.h),
                    ),
                    child: Text(
                      AppStrings.cancelButton,
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.primaryAzure,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                AppSpacing.w12,
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.of(dialogContext).pop();

                      final userProvider = Provider.of<UserProvider>(
                        context,
                        listen: false,
                      );
                      final statsProvider = Provider.of<UserStatsProvider>(
                        context,
                        listen: false,
                      );
                      final profileProvider = Provider.of<ProfileProvider>(
                        context,
                        listen: false,
                      );
                      final optionalModuleProvider =
                          Provider.of<OptionalModuleProvider>(
                            context,
                            listen: false,
                          );

                      await Future.wait([
                        userProvider.clearUserData(),
                        statsProvider.clearUserStats(),
                        profileProvider.clearProfileData(),
                      ]);

                      optionalModuleProvider.clearModulePairs();
                      ProfileScreen.resetInitialization();
                      await LoginProvider.logout();

                      if (!context.mounted) return;
                      context.go(AppRoutes.login);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.errorCoral,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 13.h),
                    ),
                    child: Text(
                      AppStrings.logOutButton,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
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
