import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_animations.dart';

enum AgriButtonVariant { filled, outlined, text, gradient }

class AgriButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AgriButtonVariant variant;
  final double? width;
  final double height;
  final IconData? icon;
  final IconData? trailingIcon;
  final Color? color;

  const AgriButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.variant = AgriButtonVariant.filled,
    this.width,
    this.height = 52,
    this.icon,
    this.trailingIcon,
    this.color,
  });

  /// Convenience constructor for secondary/accent buttons
  const AgriButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.height = 52,
    this.icon,
    this.trailingIcon,
  })  : variant = AgriButtonVariant.filled,
        color = AppColors.accent;

  /// Convenience constructor for outlined buttons
  const AgriButton.outlined({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.height = 52,
    this.icon,
    this.trailingIcon,
    this.color,
  }) : variant = AgriButtonVariant.outlined;

  /// Convenience constructor for gradient buttons
  const AgriButton.gradient({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.height = 52,
    this.icon,
    this.trailingIcon,
  })  : variant = AgriButtonVariant.gradient,
        color = null;

  @override
  State<AgriButton> createState() => _AgriButtonState();
}

class _AgriButtonState extends State<AgriButton>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: AppAnimations.tapScale)
        .animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.onPressed != null && !widget.isLoading) {
      _scaleController.forward();
    }
  }

  void _onTapUp(TapUpDetails _) {
    _scaleController.reverse();
  }

  void _onTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = widget.color ?? AppColors.primary;
    final isDisabled = widget.onPressed == null || widget.isLoading;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: SizedBox(
          width: widget.width ?? double.infinity,
          height: widget.height,
          child: _buildButton(buttonColor, isDisabled),
        ),
      ),
    );
  }

  Widget _buildButton(Color buttonColor, bool isDisabled) {
    switch (widget.variant) {
      case AgriButtonVariant.gradient:
        return _buildGradientButton(isDisabled);
      case AgriButtonVariant.outlined:
        return _buildOutlinedButton(buttonColor, isDisabled);
      case AgriButtonVariant.text:
        return _buildTextButton(buttonColor, isDisabled);
      case AgriButtonVariant.filled:
        return _buildFilledButton(buttonColor, isDisabled);
    }
  }

  Widget _buildFilledButton(Color color, bool isDisabled) {
    return ElevatedButton(
      onPressed: widget.isLoading ? null : widget.onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: AppColors.canvas,
        disabledBackgroundColor: color.withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20),
      ),
      child: _buildContent(AppColors.canvas),
    );
  }

  Widget _buildGradientButton(bool isDisabled) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDisabled
              ? [
                  AppColors.primary.withValues(alpha: 0.5),
                  AppColors.primaryLight.withValues(alpha: 0.5)
                ]
              : AppColors.freshGradient,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: isDisabled
            ? []
            : [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.isLoading ? null : widget.onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Center(
            child: _buildContent(AppColors.canvas),
          ),
        ),
      ),
    );
  }

  Widget _buildOutlinedButton(Color color, bool isDisabled) {
    return OutlinedButton(
      onPressed: widget.isLoading ? null : widget.onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(
          color: isDisabled ? color.withValues(alpha: 0.3) : color,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
      ),
      child: _buildContent(color),
    );
  }

  Widget _buildTextButton(Color color, bool isDisabled) {
    return TextButton(
      onPressed: widget.isLoading ? null : widget.onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
      ),
      child: _buildContent(color),
    );
  }

  Widget _buildContent(Color textColor) {
    if (widget.isLoading) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    }

    final children = <Widget>[];

    if (widget.icon != null) {
      children.add(Icon(widget.icon, size: 20));
      children.add(const SizedBox(width: 8));
    }

    children.add(Text(
      widget.text,
      style: AppTextStyles.button.copyWith(color: textColor),
    ));

    if (widget.trailingIcon != null) {
      children.add(const SizedBox(width: 8));
      children.add(Icon(widget.trailingIcon, size: 20));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }
}
