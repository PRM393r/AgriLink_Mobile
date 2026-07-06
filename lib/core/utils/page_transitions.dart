import 'package:flutter/material.dart';
import '../../core/constants/app_animations.dart';

/// Custom page route with slide-up transition — for modals, detail screens
class SlideUpRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SlideUpRoute({required this.page})
      : super(
          transitionDuration: AppAnimations.pageTransition,
          reverseTransitionDuration: AppAnimations.pageTransition,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final tween = Tween<Offset>(
              begin: const Offset(0, 0.15),
              end: Offset.zero,
            ).chain(CurveTween(curve: AppAnimations.gentleCurve));

            final fadeTween = Tween<double>(begin: 0.0, end: 1.0)
                .chain(CurveTween(curve: Curves.easeOut));

            return SlideTransition(
              position: animation.drive(tween),
              child: FadeTransition(
                opacity: animation.drive(fadeTween),
                child: child,
              ),
            );
          },
        );
}

/// Custom page route with fade-scale transition — for main navigation
class FadeScaleRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadeScaleRoute({required this.page})
      : super(
          transitionDuration: AppAnimations.pageTransition,
          reverseTransitionDuration: AppAnimations.pageTransition,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final scaleTween = Tween<double>(begin: 0.94, end: 1.0)
                .chain(CurveTween(curve: AppAnimations.gentleCurve));

            final fadeTween = Tween<double>(begin: 0.0, end: 1.0)
                .chain(CurveTween(curve: Curves.easeOut));

            return ScaleTransition(
              scale: animation.drive(scaleTween),
              child: FadeTransition(
                opacity: animation.drive(fadeTween),
                child: child,
              ),
            );
          },
        );
}

/// Custom page route with horizontal slide — for forward navigation
class SlideRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SlideRoute({required this.page})
      : super(
          transitionDuration: AppAnimations.pageTransition,
          reverseTransitionDuration: AppAnimations.pageTransition,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final tween = Tween<Offset>(
              begin: const Offset(0.3, 0),
              end: Offset.zero,
            ).chain(CurveTween(curve: AppAnimations.defaultCurve));

            final fadeTween = Tween<double>(begin: 0.5, end: 1.0)
                .chain(CurveTween(curve: Curves.easeOut));

            return SlideTransition(
              position: animation.drive(tween),
              child: FadeTransition(
                opacity: animation.drive(fadeTween),
                child: child,
              ),
            );
          },
        );
}
