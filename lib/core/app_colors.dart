import 'package:flutter/material.dart';

class AppColors {
  /* ==================== Core Colors ==================== */
  static const Color bgColor = Color(0xFFF0F9FF);
  static const Color primaryColor = Color(0xFF0284C7);
  static const Color black = Color(0xFF0F172A);
  static const Color white = Color(0xFFFFFFFF);
  static const Color darkGrey = Color(0xFF1F2937);
  static const Color lightGrey = Color(0xFFDADADA);
  static const Color grey = Color(0xFF9FC2CC);
  static const Color grey2D = Color(0xFF2D2D2D);
  static const Color grey4B = Color(0xFF4B4B4B);
  static const Color greyD9 = Color(0xFFD9D9D9);
  static const Color greyE8 = Color(0xFFE8E8E8);
  static const Color greyD4 = Color(0xFFD4D4D4);
  static const Color greyEFF = Color(0xFFEFF6FF);

  /* ==================== Accent Colors ==================== */
  static const Color red = Color(0xFFF43F5E);
  static const Color yellow = Color(0xFFF59E0B);
  static const Color green = Color(0xFF10B981);
  static const Color blue = Color(0xFF0284C7);
  static const Color blueTransparent = Color(0x421E90FF);
  static const Color amberTransparent = Color(0x4DA66E00);

  static const Color borderColor = Color(0xFFE0F2FE);

  static const Color statFillColor = Color(0x261E90FF);
  static const Color buttonColor = Color(0xFF0284C7);
  static const Color splashBG = Color(0xFFA8D8FF);
  static const Color cardBG = Color(0xFFE0F2FE);
  static const Color subtitleText = Color(0xFF64748B);

  /* ==================== Stitch Design System (V2) ==================== */
  static const Color primaryAzure = Color(0xFF0284C7);
  static const Color primarySky = Color(0xFF52B1FF);
  static const Color deepOcean = Color(0xFF0369A1);
  static const Color accentGold = Color(0xFFF59E0B);
  static const Color accentGoldDark = Color(0xFFD97706);
  static const Color accentAmberLight = Color(0xFFFEF3C7);
  static const Color neutralDark = Color(0xFF0F172A);
  static const Color neutralSlate = Color(0xFF334155);
  static const Color neutralMuted = Color(0xFF94A3B8);
  static const Color softSky = Color(0xFFF0F9FF);
  static const Color azureSurface = Color(0xFFE0F2FE);
  static const Color azureBorder = Color(0xFFE0F2FE);
  static const Color slateBorder = Color(0xFFE2E8F0);
  static const Color softSlate = Color(0xFF64748B);
  static const Color mutedSlate = Color(0xFF94A3B8);
  static const Color glowAzure = Color(0x400284C7);

  /* ==================== Semantic & Difficulty Tokens ==================== */
  static const Color emeraldSuccess = Color(0xFF10B981);
  static const Color errorCoral = Color(0xFFF43F5E);
  static const Color easyEmerald = Color(0xFF10B981);
  static const Color easyEmeraldBg = Color(0xFFD1FAE5);
  static const Color mediumAmber = Color(0xFFF59E0B);
  static const Color mediumAmberBg = Color(0xFFFEF3C7);
  static const Color hardRose = Color(0xFFF43F5E);
  static const Color hardRoseBg = Color(0xFFFFE4E6);
  static const Color youtubeRed = Color(0xFFFF0000);
  static const Color youtubeRedSoft = Color(0xFFFFE4E6);

  /* ==================== Gradients ==================== */
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0284C7), Color(0xFF38BDF8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryButtonGradient = LinearGradient(
    colors: [Color(0xFF0284C7), Color(0xFF38BDF8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroCardGradient = LinearGradient(
    colors: [Color(0xFF0369A1), Color(0xFF0284C7), Color(0xFF38BDF8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient oceanHeaderGradient = LinearGradient(
    colors: [Color(0xFF0369A1), Color(0xFF0284C7), Color(0xFF38BDF8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldBadgeGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient youtubeGradient = LinearGradient(
    colors: [Color(0xFFDC2626), Color(0xFFF43F5E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
