import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

/// Reusable gradient header widget — for dashboard tops, profile headers, etc.
class GradientHeader extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final Widget? bottom;
  final List<Color>? gradientColors;
  final double height;
  final EdgeInsetsGeometry padding;

  const GradientHeader({
    super.key,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.bottom,
    this.gradientColors,
    this.height = 180,
    this.padding = const EdgeInsets.fromLTRB(20, 16, 20, 20),
  });

  @override
  Widget build(BuildContext context) {
    final colors = gradientColors ?? AppColors.primaryGradient;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top row with leading/trailing
              if (leading != null || trailing != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    leading ?? const SizedBox.shrink(),
                    trailing ?? const SizedBox.shrink(),
                  ],
                ),
              if (leading != null || trailing != null)
                const SizedBox(height: 16),

              // Title
              if (title != null)
                Text(
                  title!,
                  style: AppTextStyles.bigTitle.copyWith(
                    color: AppColors.canvas,
                    fontSize: 24,
                  ),
                ),

              // Subtitle
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: AppTextStyles.subtitle.copyWith(
                    color: AppColors.canvas.withValues(alpha: 0.85),
                  ),
                ),
              ],

              // Bottom widget (search bar, stats row, etc.)
              if (bottom != null) ...[
                const SizedBox(height: 16),
                bottom!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
