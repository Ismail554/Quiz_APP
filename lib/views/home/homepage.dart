import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_spacing.dart';
import 'package:geography_geyser/core/app_strings.dart';
import 'package:geography_geyser/views/modules/module_home.dart';
import 'package:geography_geyser/views/profile/profile_screen.dart';
import 'package:geography_geyser/provider/home_provider.dart';
import 'package:geography_geyser/services/api_service.dart';
import 'package:provider/provider.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeContent(),
    const ModuleHomeScreen(),
    const ProfileScreen(hideSettingsCard: false),
  ];

  void _onTap(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      backgroundColor: AppColors.bgColor,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
        selectedItemColor: AppColors.blue,
        unselectedItemColor: AppColors.grey,
        backgroundColor: AppColors.white,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: AppStrings.homeButton,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: AppStrings.navBarModule,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: AppStrings.navBarProfile,
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  @override
  void initState() {
    super.initState();
    // Fetch user data when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<UserProvider>(context, listen: false);
      if (provider.userModel == null && !provider.isLoading) {
        provider.fetchUserData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          // Show loading indicator while fetching data
          if (userProvider.isLoading && userProvider.userModel == null) {
            return Center(child: CircularProgressIndicator());
          }

          final user = userProvider.userModel;

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // --- Profile Card ---
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: AppColors.cardBG,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Row(
                    children: [
                      // Profile Picture
                      _buildProfileAvatar(user?.profilePic),

                      AppSpacing.w16,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.fullName ?? 'Loading...',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            AppSpacing.h4,
                            Row(
                              children: [
                                Icon(
                                  Icons.emoji_events_outlined,
                                  color: Colors.orange,
                                  size: 18,
                                ),

                                AppSpacing.w4,
                                Text(
                                  "XP: 39,900",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.orange,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),

                            AppSpacing.h8,
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.r),
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.blue,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                AppStrings.strongestModuleLabel +
                                    AppStrings.waterCycleSubject,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                AppSpacing.h20,

                // --- Stats Cards (2x2 Grid) ---
                Row(
                  children: [
                    Expanded(
                      child: InfoCard(
                        icon: Icons.blinds_outlined,
                        title: 'Average Score',
                        value: '85%',
                      ),
                    ),

                    AppSpacing.w12,
                    Expanded(
                      child: InfoCard(
                        icon: Icons.local_fire_department_outlined,
                        title: 'Daily Quiz Streak',
                        value: '08',
                      ),
                    ),
                  ],
                ),

                AppSpacing.h12,
                Row(
                  children: [
                    Expanded(
                      child: InfoCard(
                        icon: Icons.query_stats_outlined,
                        title: 'Total Attempt Quiz',
                        value: '130',
                      ),
                    ),

                    AppSpacing.w12,

                    /// Special card for Last Activity with proper text layout
                    Expanded(child: LastActivityCard()),
                  ],
                ),

                AppSpacing.h20,

                // --- Action Buttons ---
                ActionButton(
                  icon: Icons.bar_chart_outlined,
                  label: 'Student Stats',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProfileScreen(hideSettingsCard: true),
                      ),
                    );
                  },
                ),
                ActionButton(
                  icon: Icons.quiz_outlined,
                  label: 'Take a Quiz',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ModuleHomeScreen(),
                      ),
                    );
                  },
                ),
                // ActionButton(
                //   icon: Icons.settings_outlined,
                //   label: 'Module Settings',
                //   onTap: () {
                //     // Handle Module Settings navigation
                //   },
                // ),
              ],
            ),
          );
        },
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
        radius: 35,
        backgroundColor: Colors.grey[300],
        child: ClipOval(
          child: Image.network(
            imageUrl,
            width: 70,
            height: 70,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                'assets/images/man.png',
                width: 70,
                height: 70,
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
        radius: 35,
        backgroundImage: AssetImage('assets/images/man.png'),
      );
    }
  }
}

/// ✅ Custom Info Card Widget
class InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const InfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 100.h,
      padding: EdgeInsets.symmetric(horizontal: 8.0.w, vertical: 24.0.h),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
          width: 1.5,
          style: BorderStyle.solid,
        ),
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.blue, size: 36),
          AppSpacing.h6,
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.sp, color: Colors.black),
          ),

          AppSpacing.h4,

          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              height: 1,
              overflow: TextOverflow.ellipsis,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

/// ✅ Special card for Last Activity with proper text layout
class LastActivityCard extends StatelessWidget {
  const LastActivityCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        // height: 100.h,
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 8.0.w, vertical: 20.0.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: Colors.blue.withOpacity(0.3),
            width: 1.5,
            style: BorderStyle.solid,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.access_time, color: Colors.blue, size: 36),
            AppSpacing.h2,
            Text(
              'Last Activity',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            AppSpacing.h8,
            Text(
              'Last quiz: 2 hours ago',
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.grey[700],
                fontWeight: FontWeight.w400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            AppSpacing.h2,
            Text(
              'Topic: Globalization',
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.grey[700],
                fontWeight: FontWeight.w400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// ✅ Reusable Button Card
class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: Colors.grey.shade300, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black87),
            AppSpacing.w12,
            Text(
              label,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
