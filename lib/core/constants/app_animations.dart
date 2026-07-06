import 'package:flutter/material.dart';

class AppAnimations {
  const AppAnimations._();

  // ── Duration presets ──
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 400);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration splash = Duration(milliseconds: 800);
  static const Duration pageTransition = Duration(milliseconds: 350);

  // ── Curve presets ──
  static const Curve defaultCurve = Curves.easeInOutCubic;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve springCurve = Curves.easeOutBack;
  static const Curve gentleCurve = Curves.easeOutQuart;
  static const Curve sharpCurve = Curves.easeInOutQuart;

  // ── Stagger delay ──
  /// Base delay for staggered list animations
  static const Duration staggerDelay = Duration(milliseconds: 80);

  /// Calculate delay for item at index in a staggered animation
  static Duration staggerDelayFor(int index) {
    return Duration(milliseconds: 80 * index);
  }

  // ── Scale values ──
  static const double tapScale = 0.97;
  static const double pressedScale = 0.95;
  static const double bounceScale = 1.05;
}
