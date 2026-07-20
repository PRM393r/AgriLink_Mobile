import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_shadows.dart';
import '../../core/constants/app_animations.dart';

enum AgriCardVariant { elevated, outlined, flat }

class AgriCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color? color;
  final AgriCardVariant variant;
  final VoidCallback? onTap;
  final List<Color>? gradientColors;
  final double borderRadius;

  const AgriCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.symmetric(vertical: 6),
    this.color,
    this.variant = AgriCardVariant.elevated,
    this.onTap,
    this.gradientColors,
    this.borderRadius = 16,
  });

  /// Flat card without shadow or border
  const AgriCard.flat({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.symmetric(vertical: 6),
    this.color,
    this.onTap,
    this.gradientColors,
    this.borderRadius = 16,
  }) : variant = AgriCardVariant.flat;

  @override
  State<AgriCard> createState() => _AgriCardState();
}

class _AgriCardState extends State<AgriCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: AppAnimations.fast,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.onTap != null) _scaleController.forward();
  }

  void _onTapUp(TapUpDetails _) {
    _scaleController.reverse();
  }

  void _onTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final hasGradient = widget.gradientColors != null;
    final bgColor = widget.color ?? AppColors.canvas;

    final decoration = BoxDecoration(
      color: hasGradient ? null : bgColor,
      gradient: hasGradient
          ? LinearGradient(
              colors: widget.gradientColors!,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : null,
      borderRadius: BorderRadius.circular(widget.borderRadius),
      border: widget.variant == AgriCardVariant.outlined ||
              widget.variant == AgriCardVariant.elevated
          ? Border.all(
              color: bgColor == AppColors.surfaceGreen
                  ? AppColors.primaryLight.withValues(alpha: 0.25)
                  : AppColors.surfaceDivider.withValues(alpha: 0.3),
            )
          : null,
      boxShadow:
          widget.variant == AgriCardVariant.elevated ? AppShadows.card : null,
    );

    Widget card = Container(
      margin: widget.margin,
      decoration: decoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          splashColor: AppColors.primary.withValues(alpha: 0.08),
          highlightColor: AppColors.primary.withValues(alpha: 0.04),
          child: Padding(
            padding: widget.padding,
            child: widget.child,
          ),
        ),
      ),
    );

    if (widget.onTap != null) {
      return GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: card,
        ),
      );
    }

    return card;
  }
}
