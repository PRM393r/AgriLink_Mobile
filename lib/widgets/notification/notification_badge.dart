import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../data/providers/notification_provider.dart';
import '../../router/app_router.dart';

class NotificationBadge extends StatelessWidget {
  const NotificationBadge({super.key, this.iconColor = AppColors.primary});

  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final count = context.select<NotificationProvider, int>(
      (provider) => provider.unreadCount,
    );

    return IconButton(
      tooltip: 'Thông báo',
      onPressed: () => Navigator.pushNamed(context, AppRouter.notifications),
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(Icons.notifications_outlined, color: iconColor),
          if (count > 0)
            Positioned(
              top: -7,
              right: -9,
              child: Container(
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.canvas, width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  count > 99 ? '99+' : '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
