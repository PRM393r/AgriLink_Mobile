import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppShadows {
  const AppShadows._();

  /// Subtle card shadow — for standard cards
  static List<BoxShadow> get card => [
        const BoxShadow(
          color: AppColors.shadowLight,
          blurRadius: 8,
          offset: Offset(0, 2),
          spreadRadius: 0,
        ),
      ];

  /// Elevated shadow — for floating elements, modals
  static List<BoxShadow> get elevated => [
        const BoxShadow(
          color: AppColors.shadowMedium,
          blurRadius: 16,
          offset: Offset(0, 4),
          spreadRadius: 0,
        ),
        const BoxShadow(
          color: AppColors.shadowLight,
          blurRadius: 4,
          offset: Offset(0, 1),
          spreadRadius: 0,
        ),
      ];

  /// Soft glow — for buttons on press/hover
  static List<BoxShadow> get softGlow => [
        const BoxShadow(
          color: AppColors.shadowGreen,
          blurRadius: 20,
          offset: Offset(0, 8),
          spreadRadius: 0,
        ),
      ];

  /// Bottom bar shadow — top shadow for bottom navigation
  static List<BoxShadow> get bottomBar => [
        BoxShadow(
          color: AppColors.ink.withValues(alpha: 0.06),
          blurRadius: 12,
          offset: const Offset(0, -4),
          spreadRadius: 0,
        ),
      ];

  /// Colored shadow — dynamic colored shadow for banners/CTAs
  static List<BoxShadow> colored(Color color, {double opacity = 0.25}) => [
        BoxShadow(
          color: color.withValues(alpha: opacity),
          blurRadius: 16,
          offset: const Offset(0, 6),
          spreadRadius: 0,
        ),
      ];

  /// Inner shadow effect (simulated) — for pressed/inset states
  static List<BoxShadow> get inset => [
        BoxShadow(
          color: AppColors.ink.withValues(alpha: 0.04),
          blurRadius: 4,
          offset: const Offset(0, 2),
          spreadRadius: -1,
        ),
      ];
}
