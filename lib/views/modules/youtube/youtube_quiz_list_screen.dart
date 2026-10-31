import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/data/static_youtube_data.dart';
import 'package:geography_geyser/models/v2_curriculum_models.dart';
import 'package:geography_geyser/provider/local_progress_provider.dart';
import 'package:geography_geyser/routes/app_routes.dart';
import 'package:geography_geyser/views/custom_widgets/stitch_design_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class YouTubeQuizListScreen extends StatefulWidget {
  const YouTubeQuizListScreen({super.key});

  @override
  State<YouTubeQuizListScreen> createState() => _YouTubeQuizListScreenState();
}

class _YouTubeQuizListScreenState extends State<YouTubeQuizListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedTopic = 'All';

  static const List<String> _topics = [
    'All',
    'Tectonics',
    'Carbon',
    'Water',
    'Coasts',
    'Globalisation',
    'Superpowers',
    'Regenerating Places',
    'Migration',
    'HHRI',
    'Synoptic',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openYouTubeChannelOrVideo(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  List<YouTubeQuizItem> _filteredVideos() {
    final byTopic = StaticYouTubeData.filterByModule(_selectedTopic);
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return byTopic;
    return byTopic.where((v) {
      return v.title.toLowerCase().contains(query) ||
          v.subtitle.toLowerCase().contains(query) ||
          v.moduleName.toLowerCase().contains(query) ||
          v.eqBadge.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final progressProvider = context.watch<LocalProgressProvider>();
    final videos = _filteredVideos();

    return StitchAmbientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.neutralDark,
            size: 20.sp,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'YouTube Quizzes',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 19.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.neutralDark,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Open @GeographyGeyser on YouTube',
            icon: Icon(
              Icons.ondemand_video_rounded,
              color: AppColors.youtubeRed,
              size: 22.sp,
            ),
            onPressed: () =>
                _openYouTubeChannelOrVideo(StaticYouTubeData.channelUrl),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search & Topic Filters
            Padding(
              padding: EdgeInsets.fromLTRB(18.w, 6.h, 18.w, 12.h),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: AppColors.azureBorder),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryAzure.withValues(alpha: 0.05),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutralDark,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            'Search @GeographyGeyser lessons or topics...',
                        hintStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 13.sp,
                          color: AppColors.mutedSlate,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: AppColors.primaryAzure,
                          size: 20.sp,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear_rounded,
                                  size: 18.sp,
                                  color: AppColors.softSlate,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 13.h,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    height: 36.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _topics.length,
                      separatorBuilder: (_, _) => SizedBox(width: 8.w),
                      itemBuilder: (context, index) {
                        final topic = _topics[index];
                        final isSelected = _selectedTopic == topic;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedTopic = topic),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 7.h,
                            ),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? AppColors.youtubeGradient
                                  : null,
                              color: isSelected ? null : AppColors.white,
                              borderRadius: BorderRadius.circular(18.r),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.transparent
                                    : AppColors.azureBorder,
                              ),
                            ),
                            child: Text(
                              topic,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.neutralSlate,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Video Quiz List
            Expanded(
              child: videos.isEmpty
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.r),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.video_library_outlined,
                              size: 56.sp,
                              color: AppColors.mutedSlate,
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              'No matching YouTube quizzes found',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.neutralDark,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              'Try clearing your search or selecting "All" topics.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.sp,
                                color: AppColors.softSlate,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(18.w, 4.h, 18.w, 28.h),
                      itemCount: videos.length,
                      itemBuilder: (context, index) {
                        final video = videos[index];
                        final isCompleted = progressProvider.isQuizCompleted(
                          video.quizId,
                        );
                        final bestScore = progressProvider.getBestScore(
                          video.quizId,
                        );

                        return FadeInUp(
                          duration: Duration(milliseconds: 250 + (index * 50)),
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 16.h),
                            child: _YouTubeQuizCard(
                              video: video,
                              isCompleted: isCompleted,
                              bestScore: bestScore,
                              onWatchTap: () => _openYouTubeChannelOrVideo(
                                video.youtubeWatchUrl,
                              ),
                              onStartQuizTap: () {
                                context.push(
                                  AppRoutes.quizByIdPath(
                                    video.quizId,
                                    moduleName: video.title,
                                    timeInMinutes: video.durationMinutes,
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _YouTubeQuizCard extends StatelessWidget {
  final YouTubeQuizItem video;
  final bool isCompleted;
  final int? bestScore;
  final VoidCallback onWatchTap;
  final VoidCallback onStartQuizTap;

  const _YouTubeQuizCard({
    required this.video,
    required this.isCompleted,
    required this.bestScore,
    required this.onWatchTap,
    required this.onStartQuizTap,
  });

  @override
  Widget build(BuildContext context) {
    return StitchCard(
      padding: EdgeInsets.zero,
      onTap: onStartQuizTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 16:9 Video Header with Hero
          Hero(
            tag: 'yt_thumb_${video.quizId}',
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(19.r)),
              child: SizedBox(
                height: 158.h,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF0F172A),
                            Color(0xFF0369A1),
                            Color(0xFF0284C7),
                          ],
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                        ),
                      ),
                    ),
                    Image.network(
                      video.thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Center(
                        child: Icon(
                          Icons.play_circle_fill_rounded,
                          size: 56.sp,
                          color: Colors.white.withValues(alpha: 0.35),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.72),
                            Colors.transparent,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12.h,
                      left: 12.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 5.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.youtubeRed,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.ondemand_video_rounded,
                              size: 13.sp,
                              color: Colors.white,
                            ),
                            SizedBox(width: 5.w),
                            Text(
                              '@GeographyGeyser Lesson',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.5.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isCompleted)
                      Positioned(
                        top: 12.h,
                        right: 12.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 5.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.easyEmerald,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                size: 13.sp,
                                color: Colors.white,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                'Completed • ${bestScore ?? 100}%',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10.5.sp,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    Positioned(
                      bottom: 10.h,
                      left: 12.w,
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 9.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.20),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              '${video.moduleName} • ${video.eqBadge}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 10.h,
                      right: 12.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.78),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          'Video ${video.videoDurationLabel}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content & Actions
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    DifficultyBadge(difficulty: video.difficulty),
                    SizedBox(width: 8.w),
                    StitchBadge(
                      label:
                          '${video.questions.length} Qs • ~${video.durationMinutes} min quiz',
                      icon: Icons.timer_outlined,
                      color: AppColors.primaryAzure,
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Text(
                  video.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15.5.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.neutralDark,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  video.subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.softSlate,
                    height: 1.35,
                  ),
                ),
                SizedBox(height: 14.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onWatchTap,
                        icon: Icon(
                          Icons.play_circle_outline_rounded,
                          size: 17.sp,
                          color: AppColors.youtubeRed,
                        ),
                        label: Text(
                          'Watch Lesson',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.neutralDark,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.slateBorder),
                          padding: EdgeInsets.symmetric(vertical: 11.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onStartQuizTap,
                        icon: Icon(
                          isCompleted
                              ? Icons.replay_rounded
                              : Icons.bolt_rounded,
                          size: 17.sp,
                          color: Colors.white,
                        ),
                        label: Text(
                          isCompleted ? 'Retake Quiz' : 'Start Quiz',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryAzure,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: 11.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
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
}
