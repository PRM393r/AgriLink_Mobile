import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Shimmer loading placeholder — replaces boring CircularProgressIndicator.
/// Use for skeleton loading states while data is being fetched.
class ShimmerLoading extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Widget? child;

  const ShimmerLoading({
    super.key,
    this.width = double.infinity,
    this.height = 100,
    this.borderRadius = 12,
    this.child,
  });

  /// Creates a circular shimmer placeholder (e.g. for avatars)
  const ShimmerLoading.circle({
    super.key,
    required double size,
    this.child,
  })  : width = size,
        height = size,
        borderRadius = 999;

  /// Creates a text-line shimmer placeholder
  const ShimmerLoading.text({
    super.key,
    this.width = 120,
    this.child,
  })  : height = 14,
        borderRadius = 4;

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.child != null) {
      return widget.child!;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + _animation.value, 0),
              end: Alignment(1.0 + _animation.value, 0),
              colors: const [
                AppColors.surfaceSoft,
                AppColors.surfaceDivider,
                AppColors.surfaceSoft,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// A pre-built shimmer skeleton for a product card
class ShimmerProductCard extends StatelessWidget {
  const ShimmerProductCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.surfaceDivider.withValues(alpha: 0.3),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerLoading(height: 120, borderRadius: 16),
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLoading.text(width: 80),
                SizedBox(height: 8),
                ShimmerLoading.text(width: 140),
                SizedBox(height: 8),
                ShimmerLoading.text(width: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A pre-built shimmer skeleton for a list item
class ShimmerListItem extends StatelessWidget {
  const ShimmerListItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const ShimmerLoading.circle(size: 48),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLoading.text(width: MediaQuery.of(context).size.width * 0.5),
                const SizedBox(height: 6),
                const ShimmerLoading.text(width: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
