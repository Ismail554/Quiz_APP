import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/models/v2_curriculum_models.dart';
import 'package:geography_geyser/views/custom_widgets/stitch_design_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class DashboardYouTubeSection extends StatelessWidget {
  final List<YouTubeQuizItem> videos;
  final Map<String, int> completedScores;
  final void Function(YouTubeQuizItem video) onTakeQuizTap;

  const DashboardYouTubeSection({
    super.key,
    required this.videos,
    required this.completedScores,
    required this.onTakeQuizTap,
  });

  Future<void> _openYouTubeVideo(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final displayVideos = videos.take(5).toList();

    return SizedBox(
      height: 256.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: displayVideos.length,
        separatorBuilder: (_, _) => SizedBox(width: 14.w),
        itemBuilder: (context, index) {
          final video = displayVideos[index];
          final bestScore = completedScores[video.quizId];

          return SizedBox(
            width: 276.w,
            child: StitchCard(
              padding: EdgeInsets.zero,
              onTap: () => onTakeQuizTap(video),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail Banner with Hero
                  Hero(
                    tag: 'yt_thumb_${video.quizId}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(19.r),
                      ),
                      child: SizedBox(
                        height: 118.h,
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
                                  Icons.ondemand_video_rounded,
                                  size: 42.sp,
                                  color: Colors.white.withValues(alpha: 0.35),
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withValues(alpha: 0.65),
                                    Colors.transparent,
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 10.h,
                              left: 10.w,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.youtubeRed,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.play_arrow_rounded,
                                      size: 13.sp,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 3.w),
                                    Text(
                                      '@GeographyGeyser',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (bestScore != null)
                              Positioned(
                                top: 10.h,
                                right: 10.w,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.easyEmerald,
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Text(
                                    '✓ $bestScore%',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            Positioned(
                              bottom: 8.h,
                              left: 10.w,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 3.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.65),
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Text(
                                  '${video.moduleName} • ${video.eqBadge}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10.5.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 8.h,
                              right: 10.w,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 7.w,
                                  vertical: 3.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.75),
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Text(
                                  video.videoDurationLabel,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10.5.sp,
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
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(12.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            video.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.neutralDark,
                              height: 1.25,
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              DifficultyBadge(
                                difficulty: video.difficulty,
                                compact: true,
                              ),
                              const Spacer(),
                              InkWell(
                                onTap: () =>
                                    _openYouTubeVideo(video.youtubeWatchUrl),
                                borderRadius: BorderRadius.circular(8.r),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6.w,
                                    vertical: 4.h,
                                  ),
                                  child: Icon(
                                    Icons.open_in_new_rounded,
                                    size: 16.sp,
                                    color: AppColors.softSlate,
                                  ),
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 11.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Text(
                                  'Take Quiz',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5.sp,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
