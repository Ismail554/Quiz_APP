import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/services/api_service.dart';
import 'package:google_fonts/google_fonts.dart';

/// Production-grade, modern explorer avatar component that completely replaces
/// any legacy clipart/default placeholders with a signature Stitch Design System
/// gradient monogram emblem or loaded photo.
class ExplorerAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double radius;
  final VoidCallback? onTap;
  final String? heroTag;
  final bool showEditBadge;
  final bool showGlow;
  final Border? customBorder;

  const ExplorerAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.radius = 28,
    this.onTap,
    this.heroTag,
    this.showEditBadge = false,
    this.showGlow = true,
    this.customBorder,
  });

  String _extractInitials(String? rawName) {
    if (rawName == null || rawName.trim().isEmpty) return 'GG';
    final parts = rawName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      final first = parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '';
      final second = parts[1].isNotEmpty ? parts[1][0].toUpperCase() : '';
      final initials = '$first$second';
      return initials.isNotEmpty ? initials : 'GG';
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'GG';
  }

  LinearGradient _gradientForName(String name) {
    final code = name.codeUnits.fold(0, (acc, c) => acc + c);
    const gradients = [
      LinearGradient(
        colors: [Color(0xFF0284C7), Color(0xFF38BDF8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      LinearGradient(
        colors: [Color(0xFF0369A1), Color(0xFF52B1FF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      LinearGradient(
        colors: [Color(0xFF0D9488), Color(0xFF2DD4BF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      LinearGradient(
        colors: [Color(0xFF4F46E5), Color(0xFF818CF8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      LinearGradient(
        colors: [Color(0xFFD97706), Color(0xFFFBBF24)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ];
    return gradients[code % gradients.length];
  }

  String _formatImageUrl(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    final clean = url.startsWith('/') ? url.substring(1) : url;
    return '${ApiService.baseUrl}/$clean';
  }

  @override
  Widget build(BuildContext context) {
    final diameter = radius * 2;
    final displayName = (name != null && name!.trim().isNotEmpty)
        ? name!.trim()
        : 'Geography Explorer';
    final initials = _extractInitials(displayName);
    final avatarGradient = _gradientForName(displayName);

    Widget avatarContent;

    if (imageUrl != null && imageUrl!.trim().isNotEmpty) {
      final fullUrl = _formatImageUrl(imageUrl!.trim());
      avatarContent = Image.network(
        fullUrl,
        width: diameter.r,
        height: diameter.r,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildMonogram(diameter, initials, avatarGradient),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            width: diameter.r,
            height: diameter.r,
            decoration: BoxDecoration(
              gradient: avatarGradient,
            ),
            child: Center(
              child: SizedBox(
                width: radius.r * 0.7,
                height: radius.r * 0.7,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          );
        },
      );
    } else {
      avatarContent = _buildMonogram(diameter, initials, avatarGradient);
    }

    Widget avatarWidget = Container(
      width: diameter.r,
      height: diameter.r,
      padding: EdgeInsets.all(2.5.r),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF52B1FF), Color(0xFF0284C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: AppColors.primaryAzure.withValues(alpha: 0.28),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        padding: EdgeInsets.all(1.5.r),
        child: ClipOval(child: avatarContent),
      ),
    );

    if (heroTag != null && heroTag!.isNotEmpty) {
      avatarWidget = Hero(tag: heroTag!, child: avatarWidget);
    }

    if (showEditBadge) {
      avatarWidget = Stack(
        clipBehavior: Clip.none,
        children: [
          avatarWidget,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryAzure.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.camera_alt_rounded,
                size: (radius * 0.42).sp,
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: avatarWidget,
      );
    }

    return avatarWidget;
  }

  Widget _buildMonogram(double diameter, String initials, LinearGradient gradient) {
    return Container(
      width: diameter.r,
      height: diameter.r,
      decoration: BoxDecoration(
        gradient: gradient,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Subtle geographic coordinate line texture effect
          Positioned(
            right: -8,
            bottom: -8,
            child: Icon(
              Icons.public_rounded,
              size: diameter.r * 0.72,
              color: Colors.white.withValues(alpha: 0.14),
            ),
          ),
          Center(
            child: Text(
              initials,
              style: GoogleFonts.plusJakartaSans(
                fontSize: (radius * 0.75).sp,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
