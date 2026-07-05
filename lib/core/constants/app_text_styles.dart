import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  const AppTextStyles._();

  // ── Display — Hero sections, splash ──
  static TextStyle get headline => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: AppColors.ink,
        height: 1.2,
      );

  // ── Big Title — Page titles ──
  static TextStyle get bigTitle => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.ink,
        height: 1.3,
      );

  // ── Section Title — Section headers ──
  static TextStyle get sectionTitle => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
        height: 1.4,
      );

  // ── Body — Standard text ──
  static TextStyle get body => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.body,
        height: 1.5,
      );

  // ── Subtitle — Secondary info ──
  static TextStyle get subtitle => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.body,
        height: 1.4,
      );

  // ── Caption — Small helper text ──
  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.normal,
        color: AppColors.muted,
        height: 1.4,
      );

  // ── Overline — Labels, tags ──
  static TextStyle get overline => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.muted,
        letterSpacing: 0.8,
        height: 1.2,
      );

  // ── Price — Product pricing ──
  static TextStyle get price => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.accentActive,
        height: 1.3,
      );

  // ── Badge — Small badge text ──
  static TextStyle get badge => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        height: 1.2,
      );

  // ── Button — Button text ──
  static TextStyle get button => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.2,
      );
}
