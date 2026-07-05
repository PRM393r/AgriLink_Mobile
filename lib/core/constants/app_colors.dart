import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  // ── Primary Green Palette ──
  static const Color primary = Color(0xFF2D6A4F);
  static const Color primaryActive = Color(0xFF1B4332);
  static const Color primaryLight = Color(0xFF52B788);
  static const Color primaryUltraLight = Color(0xFFD8F3DC);
  static const Color primarySoft = Color(0xFF95D5B2);

  // ── Accent / Warm Palette ──
  static const Color accent = Color(0xFFF4A261);
  static const Color accentActive = Color(0xFFE76F51);
  static const Color accentLight = Color(0xFFFFF3E0);

  // ── Harvest / Gold ──
  static const Color harvest = Color(0xFFFFB703);
  static const Color harvestLight = Color(0xFFFFF8E1);

  // ── Semantic Colors ──
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);

  // ── Text Colors ──
  static const Color ink = Color(0xFF1A1A1A);
  static const Color body = Color(0xFF3D3D3D);
  static const Color muted = Color(0xFF6B7280);
  static const Color disabled = Color(0xFF9CA3AF);

  // ── Surface Colors ──
  static const Color canvas = Color(0xFFFFFFFF);
  static const Color surfaceSoft = Color(0xFFF9FBF9);
  static const Color surfaceGreen = Color(0xFFF0FFF4);
  static const Color surfaceElevated = Color(0xFFFFFDF7);
  static const Color surfaceWarm = Color(0xFFFFFBF5);
  static const Color surfaceDivider = Color(0xFFE5E7EB);

  // ── Gradient Presets ──
  static const List<Color> primaryGradient = [
    Color(0xFF1B4332),
    Color(0xFF2D6A4F),
    Color(0xFF52B788),
  ];

  static const List<Color> freshGradient = [
    Color(0xFF40916C),
    Color(0xFF95D5B2),
  ];

  static const List<Color> warmGradient = [
    Color(0xFFF4A261),
    Color(0xFFE76F51),
  ];

  static const List<Color> sunsetGradient = [
    Color(0xFFFFB703),
    Color(0xFFF4A261),
  ];

  static const List<Color> skyGradient = [
    Color(0xFF3B82F6),
    Color(0xFF60A5FA),
  ];

  // ── Shadow Colors ──
  static const Color shadowLight = Color(0x0A000000);
  static const Color shadowMedium = Color(0x14000000);
  static const Color shadowDark = Color(0x29000000);
  static const Color shadowGreen = Color(0x1A2D6A4F);
}
