import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/data/static_youtube_data.dart';
import 'package:geography_geyser/models/v2_curriculum_models.dart';
import 'package:geography_geyser/provider/home_provider.dart';
import 'package:geography_geyser/provider/local_progress_provider.dart';
import 'package:geography_geyser/provider/user_performance_provider.dart';
import 'package:geography_geyser/provider/userstats_provider.dart';
import 'package:geography_geyser/routes/app_routes.dart';
import 'package:geography_geyser/views/custom_widgets/stitch_design_widgets.dart';
import 'package:geography_geyser/views/home/widgets/dashboard_available_quizzes_section.dart';
import 'package:geography_geyser/views/home/widgets/dashboard_continue_learning_card.dart';
import 'package:geography_geyser/views/home/widgets/dashboard_quick_action_bar.dart';
import 'package:geography_geyser/views/home/widgets/dashboard_recent_attempts_section.dart';
import 'package:geography_geyser/views/home/widgets/dashboard_recent_score_card.dart';
import 'package:geography_geyser/views/home/widgets/dashboard_weekly_streak_bar.dart';
import 'package:geography_geyser/views/home/widgets/dashboard_welcome_card.dart';
import 'package:geography_geyser/views/home/widgets/dashboard_youtube_section.dart';
import 'package:geography_geyser/views/modules/module_home.dart';
import 'package:geography_geyser/views/profile/profile_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class HomePageScreen extends StatefulWidget {
  final int initialTabIndex;

  const HomePageScreen({super.key, this.initialTabIndex = 0});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex.clamp(0, 2);
  }

  void _switchTab(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeContent(onSwitchTab: _switchTab),
      const ModuleHomeScreen(showBackButton: false),
      const ProfileScreen(hideSettingsCard: false),
    ];

    return Scaffold(
      backgroundColor: AppColors.softSky,
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: _buildModernBottomNav(),
    );
  }

  Widget _buildModernBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: const Border(
          top: BorderSide(color: AppColors.azureBorder, width: 1.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryAzure.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavPillItem(
                icon: Icons.dashboard_outlined,
                activeIcon: Icons.dashboard_rounded,
                label: 'Home',
                isSelected: _currentIndex == 0,
                onTap: () => _switchTab(0),
              ),
              _NavPillItem(
                icon: Icons.explore_outlined,
                activeIcon: Icons.explore_rounded,
                label: 'Quizzes',
                isSelected: _currentIndex == 1,
                onTap: () => _switchTab(1),
              ),
              _NavPillItem(
                icon: Icons.tune_rounded,
                activeIcon: Icons.settings_rounded,
                label: 'Settings',
                isSelected: _currentIndex == 2,
                onTap: () => _switchTab(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavPillItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavPillItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 20.w : 14.w,
          vertical: 9.h,
        ),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryAzure.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 21.sp,
              color: isSelected ? Colors.white : AppColors.softSlate,
            ),
            SizedBox(width: 7.w),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.sp,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.softSlate,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  final void Function(int index)? onSwitchTab;

  const HomeContent({super.key, this.onSwitchTab});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _loadInitialData();
      });
    }
  }

  Future<void> _loadInitialData() async {
    final userProvider = context.read<UserProvider>();
    final statsProvider = context.read<UserStatsProvider>();
    final profileProvider = context.read<ProfileProvider>();
    final localProgress = context.read<LocalProgressProvider>();

    await localProgress.initialize();
    await Future.wait([
      userProvider.loadUserDataFromStorage(),
      statsProvider.loadUserStatsFromStorage(),
      profileProvider.loadProfileFromStorage(),
    ]);

    if (!mounted) return;
    await Future.wait([
      if (userProvider.userModel == null) userProvider.fetchUserData(),
      if (statsProvider.userStats == null) statsProvider.fetchUserStats(),
      if (profileProvider.profileData == null) profileProvider.fetchProfile(),
    ]);
  }

  Future<void> _onRefresh() async {
    final userProvider = context.read<UserProvider>();
    final statsProvider = context.read<UserStatsProvider>();
    final profileProvider = context.read<ProfileProvider>();
    await Future.wait([
      userProvider.fetchUserData(),
      statsProvider.fetchUserStats(),
      profileProvider.fetchProfile(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return StitchAmbientScaffold(
      body: SafeArea(
        child: Consumer3<UserProvider, UserStatsProvider, LocalProgressProvider>(
          builder: (context, userProvider, statsProvider, localProgress, _) {
            final user = userProvider.userModel;
            final stats = statsProvider.userStats;
            final unfinished = localProgress.unfinishedSession;

            return RefreshIndicator(
              onRefresh: _onRefresh,
              color: AppColors.primaryAzure,
              backgroundColor: Colors.white,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 28.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Welcome Profile Card
                    FadeInDown(
                      duration: const Duration(milliseconds: 350),
                      child: DashboardWelcomeCard(
                        user: user,
                        stats: stats,
                        onProfileTap: () => widget.onSwitchTab?.call(2),
                      ),
                    ),
                    SizedBox(height: 14.h),

                    // Quick Action Launchpad
                    FadeInUp(
                      duration: const Duration(milliseconds: 360),
                      child: DashboardQuickActionBar(
                        onOpenSpec: () => widget.onSwitchTab?.call(1),
                        onOpenYouTube: () => context.push(AppRoutes.youtubeQuizzes),
                      ),
                    ),
                    SizedBox(height: 14.h),

                    // Weekly Streak Bar
                    FadeInUp(
                      duration: const Duration(milliseconds: 370),
                      child: DashboardWeeklyStreakBar(
                        streakDays: stats?.dailyStreak ?? 7,
                      ),
                    ),
                    SizedBox(height: 18.h),

                    // 2. Continue Learning (Unfinished Activity)
                    if (unfinished != null) ...[
                      FadeInUp(
                        duration: const Duration(milliseconds: 380),
                        child: DashboardContinueLearningCard(
                          session: unfinished,
                          onResumeTap: () {
                            context.push(
                              AppRoutes.quizPath(
                                moduleId: unfinished.quizId,
                                moduleName:
                                    '${unfinished.moduleName} • ${unfinished.quizTitle}',
                                timeInMinutes: unfinished.totalTimeMinutes,
                                totalQuestions: unfinished.totalQuestions,
                              ),
                              extra: {
                                'moduleId': unfinished.quizId,
                                'moduleName':
                                    '${unfinished.moduleName} • ${unfinished.quizTitle}',
                                'timeInMinutes': unfinished.totalTimeMinutes,
                                'totalQuestions': unfinished.totalQuestions,
                                'initialQuestionIndex':
                                    unfinished.currentQuestionIndex,
                                'initialCorrectCount':
                                    unfinished.correctAnswersCount,
                                'initialTimeRemainingSeconds':
                                    unfinished.timeRemainingSeconds,
                              },
                            );
                          },
                          onDismissTap: () {
                            localProgress.clearUnfinishedSessionIfMatches(
                              unfinished.quizId,
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 20.h),
                    ],

                    // 3. Recent Score & Performance Highlights
                    StitchSectionHeader(
                      title: 'Performance Snapshot',
                      subtitle: 'Your latest quiz result & overall mastery',
                      leadingIcon: Icons.insights_rounded,
                      actionLabel: 'Full Stats',
                      onActionTap: () =>
                          context.push(AppRoutes.profilePath(hideSettingsCard: true)),
                    ),
                    SizedBox(height: 12.h),
                    FadeInUp(
                      duration: const Duration(milliseconds: 420),
                      child: DashboardRecentScoreCard(
                        latestAttempt: localProgress.latestAttempt,
                        stats: stats,
                        onRetakeLatest: () {
                          final latest = localProgress.latestAttempt;
                          if (latest != null) {
                            context.push(
                              AppRoutes.quizByIdPath(
                                latest.quizId,
                                moduleName: latest.quizTitle,
                              ),
                            );
                          } else {
                            widget.onSwitchTab?.call(1);
                          }
                        },
                        onViewStatsTap: () => context.push(
                          AppRoutes.profilePath(hideSettingsCard: true),
                        ),
                      ),
                    ),
                    SizedBox(height: 22.h),

                    // 4. YouTube Recommendations (@GeographyGeyser)
                    StitchSectionHeader(
                      title: 'YouTube Lesson Quizzes',
                      subtitle: 'Watch @GeographyGeyser & test yourself immediately',
                      leadingIcon: Icons.ondemand_video_rounded,
                      actionLabel: 'See All',
                      onActionTap: () => context.push(AppRoutes.youtubeQuizzes),
                    ),
                    SizedBox(height: 12.h),
                    DashboardYouTubeSection(
                      videos: StaticYouTubeData.videos,
                      completedScores: localProgress.completedBestScores,
                      onTakeQuizTap: (YouTubeQuizItem video) {
                        context.push(
                          AppRoutes.quizByIdPath(
                            video.quizId,
                            moduleName: video.title,
                            timeInMinutes: video.durationMinutes,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 22.h),

                    // 5. Available & Recommended Quizzes
                    StitchSectionHeader(
                      title: 'Recommended Quizzes',
                      subtitle: 'Specification quizzes tailored by difficulty',
                      leadingIcon: Icons.recommend_rounded,
                      actionLabel: 'All Quizzes',
                      onActionTap: () => context.push(AppRoutes.specModules),
                    ),
                    SizedBox(height: 12.h),
                    DashboardAvailableQuizzesSection(
                      onStartSubQuiz: (SubQuizItem subQuiz) {
                        context.push(
                          AppRoutes.selectTime,
                          extra: {
                            'moduleId': subQuiz.id,
                            'moduleName':
                                '${subQuiz.moduleName} • ${subQuiz.title}',
                          },
                        );
                      },
                      onOpenModule: (SpecModuleItem module) {
                        context.push(
                          AppRoutes.specEqSelectionPath(module.id),
                          extra: module,
                        );
                      },
                    ),
                    SizedBox(height: 18.h),

                    // 6. Recent Quiz Attempts
                    StitchSectionHeader(
                      title: 'Recent Quiz Attempts',
                      subtitle: 'Review your recent scores or retry for a higher grade',
                      leadingIcon: Icons.history_rounded,
                      actionLabel: 'Take New',
                      onActionTap: () => widget.onSwitchTab?.call(1),
                    ),
                    SizedBox(height: 12.h),
                    DashboardRecentAttemptsSection(
                      attempts: localProgress.recentAttempts,
                      onRetakeTap: (attempt) {
                        context.push(
                          AppRoutes.quizByIdPath(
                            attempt.quizId,
                            moduleName: attempt.quizTitle,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
