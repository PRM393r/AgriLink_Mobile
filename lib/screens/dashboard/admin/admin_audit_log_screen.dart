import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../../widgets/common/loading_overlay.dart';

class AdminAuditLogScreen extends StatefulWidget {
  const AdminAuditLogScreen({super.key});

  @override
  State<AdminAuditLogScreen> createState() => _AdminAuditLogScreenState();
}

class _AdminAuditLogScreenState extends State<AdminAuditLogScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _logs = [];

  static const _actionLabels = {
    'user_locked': 'Khóa tài khoản',
    'user_unlocked': 'Mở khóa tài khoản',
    'seller_approved': 'Duyệt seller',
    'seller_rejected': 'Từ chối seller',
    'product_hidden': 'Ẩn sản phẩm',
    'product_unhidden': 'Khôi phục sản phẩm',
    'review_deleted': 'Xóa đánh giá',
    'dispute_resolved': 'Xử lý khiếu nại',
    'broadcast_sent': 'Gửi thông báo hàng loạt',
  };

  static const _actionIcons = {
    'user_locked': Icons.lock_outline,
    'user_unlocked': Icons.lock_open_outlined,
    'seller_approved': Icons.check_circle_outline,
    'seller_rejected': Icons.cancel_outlined,
    'product_hidden': Icons.visibility_off_outlined,
    'product_unhidden': Icons.visibility_outlined,
    'review_deleted': Icons.delete_outline,
    'dispute_resolved': Icons.gavel_outlined,
    'broadcast_sent': Icons.campaign_outlined,
  };

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _isLoading = true);
    try {
      final repo = context.read<AdminRepository>();
      final result = await repo.getAuditLogs(limit: 50);
      if (!mounted) return;
      setState(() => _logs = List<Map<String, dynamic>>.from(result['items'] as List? ?? []));
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceFirst('Exception:', '').trim()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      appBar: AppBar(title: const Text('Nhật ký hoạt động')),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: _logs.isEmpty && !_isLoading
            ? const Center(child: Text('Chưa có hoạt động nào'))
            : RefreshIndicator(
                onRefresh: _fetch,
                color: AppColors.primary,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _logs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final log = _logs[i];
                    final action = log['action'] as String? ?? '';
                    final createdAt = DateTime.tryParse(log['createdAt'] as String? ?? '');
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(_actionIcons[action] ?? Icons.info_outline, color: AppColors.primary, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_actionLabels[action] ?? action, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                                if ((log['detail'] as String?)?.isNotEmpty == true)
                                  Text(log['detail'] as String, style: AppTextStyles.caption.copyWith(color: AppColors.muted)),
                                const SizedBox(height: 2),
                                Text(
                                  '${log['adminName']} · ${createdAt != null ? dateFormat.format(createdAt) : ''}',
                                  style: AppTextStyles.overline.copyWith(color: AppColors.muted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
