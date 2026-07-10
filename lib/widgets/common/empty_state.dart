import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import 'agri_button.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  const EmptyState({
    super.key,
    this.icon = Icons.inbox_outlined,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 72,
              color: AppColors.muted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTextStyles.sectionTitle.copyWith(color: AppColors.ink),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTextStyles.body.copyWith(color: AppColors.muted),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onActionPressed != null) ...[
              const SizedBox(height: 24),
              AgriButton(
                text: actionLabel!,
                onPressed: onActionPressed,
              ),
            ]
          ],
        ),
      ),
    );
  }
}
