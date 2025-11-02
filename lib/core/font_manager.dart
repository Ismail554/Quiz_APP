import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class FontManager {
  // Font Families
  static const String poppins = "Poppins";
  static const String inter = "Inter";

  // Font Weights
  static const FontWeight w400 = FontWeight.w400;
  static const FontWeight w600 = FontWeight.w600;
  static const FontWeight w700 = FontWeight.w700;
  static const FontWeight w800 = FontWeight.w800;

  // Default Text Colors
  static const Color mainTextColor = AppColors.black;
  static final Color subtitleColor = AppColors.grey4B;
  static const Color subSubtitleColor = AppColors.grey;

  // ================== Text Styles ==================

  // Splash title
  static TextStyle splashTitle({
    double fontSize = 40,
    Color color = Colors.black,
  }) => GoogleFonts.notoSans(
    fontSize: fontSize.sp,
    fontWeight: w800,
    color: color,
    height: 1.0,
    letterSpacing: 0.sp,
  );
  // Big bold title
  static TextStyle bigTitle({
    double fontSize = 16,
    Color color = Colors.black,
  }) => GoogleFonts.notoSans(
    fontSize: fontSize.sp,
    fontWeight: FontWeight.w800,
    color: color,
  );
  // Title Text
  static TextStyle titleText({Color color = mainTextColor}) => TextStyle(
    fontFamily: inter,
    fontSize: 22.sp,
    fontWeight: w700,
    color: color,
    height: 1.0,
    letterSpacing: 0.0,
  );
  // Subtitle Text
  static TextStyle subtitleText({
    double fontSize = 16,
    Color color = Colors.grey,
    double height = 1,
  }) => GoogleFonts.montserrat(
    fontSize: fontSize.sp,
    fontWeight: FontWeight.w400,
    color: color,
    height: height,
    letterSpacing: 0.0,
  );

  // //Bold Title Text
  // static TextStyle boldTitleText() => TextStyle(
  //   fontFamily: "SegoeUI",
  //   fontSize: 22.sp,
  //   fontWeight: w700,
  //   color: mainTextColor,
  //   height: 1.0,
  //   letterSpacing: 0.0,
  // );

  // General Text
  static TextStyle generalText({
    double fontSize = 14,
    Color color = Colors.black,
  }) => GoogleFonts.montserrat(
    fontSize: fontSize.sp,
    fontWeight: FontWeight.w500,
    color: color,
    height: 1.0,
    letterSpacing: 0.0,
  );

  // static TextStyle boldSubtitleText() => GoogleFonts.montserrat(
  //   fontSize: 14.sp,
  //   fontWeight: w600,
  //   color: mainTextColor,
  //   height: 1.0,
  //   letterSpacing: 0.0,
  // );

  // Sub-subtitle Text
  static TextStyle subSubtitleText({
    double fontSize = 12,
    color = AppColors.grey,
  }) => GoogleFonts.montserrat(
    fontSize: fontSize.sp,
    fontWeight: w400,
    color: color,
    height: 1.0,
    letterSpacing: 0.0,
  );

  // Header Subtitle
  static TextStyle headerSubtitleText({
    double fontSize = 14,
    Color color = Colors.black,
  }) => GoogleFonts.montserrat(
    fontSize: fontSize,
    fontWeight: w600,
    color: color,
    height: 1.0,
    letterSpacing: 0.0,
  );

  // Header Subtitle
  static TextStyle regularText({
    double fontSize = 14,
    Color color = Colors.black,
  }) => GoogleFonts.montserrat(
    fontSize: fontSize,
    fontWeight: w600,
    color: color,
    height: 1.0,
    letterSpacing: 0.0,
  );
  // Body / Caption Text (default)
  static TextStyle bodyText({Color color = mainTextColor}) => TextStyle(
    fontFamily: inter,
    fontSize: 14.sp,
    fontWeight: w400,
    color: color,
    height: 1.0,
    letterSpacing: 0.0,
  );

  // Button Text
  static TextStyle buttonText() => TextStyle(
    fontFamily: "SegoeUI",
    fontSize: 16.sp,
    fontWeight: w800,
    color: Colors.white,
    height: 1.0,
    letterSpacing: 0.9,
  );

  // AppBar Text
  static TextStyle appBarText({Color color = mainTextColor}) => TextStyle(
    fontFamily: inter,
    fontSize: 22.sp,
    fontWeight: w800,

    color: color,
    height: 1.0,
    letterSpacing: 0.0,
  );
  // Button Text (Regular, White)
  static TextStyle buttonTextRegular() => TextStyle(
    fontFamily: inter,
    fontSize: 16.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.white,
    height: 1.0,
    letterSpacing: 0.0,
  ); // White Button Text (Regular, 16px)
  static TextStyle whiteButtonText() => TextStyle(
    fontFamily: inter,
    fontSize: 16.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.white, // text color
    height: 1.0,
    letterSpacing: 0.0,
  );

  // ======= Details page ====//

  // Header Subtitle
  static TextStyle headlineText({
    double fontSize = 16,
    Color color = Colors.black,
  }) => GoogleFonts.montserrat(
    fontSize: fontSize,
    fontWeight: w600,
    color: color,
    height: 1.0,
    letterSpacing: 0.0,
  );
  // Header Subtitle
  static TextStyle boldHeading({
    double fontSize = 24,
    Color color = Colors.green,
  }) => TextStyle(
    fontFamily: 'SegoeUI',
    fontSize: fontSize.sp,
    fontWeight: w600,
    color: color,
    height: 1.0,
    letterSpacing: 0.72.sp,
  );
}
