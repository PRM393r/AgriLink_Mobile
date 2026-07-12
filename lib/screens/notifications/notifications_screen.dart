import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/models/notification_model.dart';
import '../../data/providers/notification_provider.dart';
import '../../data/repositories/order_repository.dart';
import '../../data/services/api_service.dart';
import '../../router/app_router.dart';
import '../../widgets/common/agri_card.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/shimmer_loading.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<NotificationProvider>().fetchNotifications();
    });
  }

  Future<void> _handleNotificationTap(NotificationModel notification) async {
    await context.read<NotificationProvider>().markAsRead(notification.id);
    final orderId = notification.data['orderId']?.toString();
    if (orderId == null || orderId.isEmpty || !mounted) return;

    try {
      final order = await OrderRepository(ApiService()).getOrderById(orderId);
      if (mounted) {
        Navigator.pushNamed(
          context,
          AppRouter.orderDetail,
          arguments: order,
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error.toString().replaceFirst('Exception:', '').trim(),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();

    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      appBar: AppBar(
        title: const Text('Thông báo'),
        actions: [
          if (provider.unreadCount > 0)
            TextButton.icon(
              onPressed: provider.markAllAsRead,
              icon: const Icon(Icons.done_all_rounded, size: 19),
              label: const Text('Đọc tất cả'),
            ),
        ],
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(NotificationProvider provider) {
    if (provider.isLoading && provider.notifications.isEmpty) {
      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, __) => const ShimmerLoading(height: 104),
      );
    }

    if (provider.errorMessage != null && provider.notifications.isEmpty) {
      return EmptyState(
        icon: Icons.cloud_off_outlined,
        title: 'Không tải được thông báo',
        message: provider.errorMessage!,
        actionLabel: 'Thử lại',
        onActionPressed: provider.refresh,
      );
    }

    if (provider.notifications.isEmpty) {
      return RefreshIndicator(
        onRefresh: provider.refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 160),
            EmptyState(
              icon: Icons.notifications_none_rounded,
              title: 'Chưa có thông báo',
              message: 'Các cập nhật mới về đơn hàng và hoạt động sẽ xuất hiện ở đây.',
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: provider.refresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        itemCount: provider.notifications.length,
        itemBuilder: (_, index) {
          final item = provider.notifications[index];
          return _NotificationTile(
            notification: item,
            onTap: () => _handleNotificationTap(item),
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});

  final NotificationModel notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final unread = !notification.isRead;
    return AgriCard(
      color: unread ? AppColors.surfaceGreen : AppColors.canvas,
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(_icon, color: _iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: AppTextStyles.subtitle.copyWith(
                          color: AppColors.ink,
                          fontWeight: unread ? FontWeight.w700 : FontWeight.w600,
                        ),
                      ),
                    ),
                    if (unread) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(notification.body, style: AppTextStyles.caption),
                if (notification.createdAt != null) ...[
                  const SizedBox(height: 8),
                  Text(_formattedTime, style: AppTextStyles.overline),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData get _icon => switch (notification.type.toLowerCase()) {
        'order' || 'order_status' => Icons.receipt_long_outlined,
        'payment' => Icons.payments_outlined,
        'promotion' => Icons.local_offer_outlined,
        'review' => Icons.star_outline_rounded,
        _ => Icons.notifications_outlined,
      };

  Color get _iconColor => switch (notification.type.toLowerCase()) {
        'payment' => AppColors.success,
        'promotion' => AppColors.accentActive,
        'review' => AppColors.harvest,
        _ => AppColors.primary,
      };

  String get _formattedTime {
    final value = notification.createdAt!.toLocal();
    final now = DateTime.now();
    final difference = now.difference(value);
    if (difference.inMinutes < 1) return 'Vừa xong';
    if (difference.inHours < 1) return '${difference.inMinutes} phút trước';
    if (difference.inDays < 1) return '${difference.inHours} giờ trước';
    if (difference.inDays < 7) return '${difference.inDays} ngày trước';
    return DateFormat('dd/MM/yyyy, HH:mm').format(value);
  }
}
