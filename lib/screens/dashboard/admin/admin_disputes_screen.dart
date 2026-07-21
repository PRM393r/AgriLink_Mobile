import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../../widgets/common/loading_overlay.dart';

class AdminDisputesScreen extends StatefulWidget {
  const AdminDisputesScreen({super.key});

  @override
  State<AdminDisputesScreen> createState() => _AdminDisputesScreenState();
}

class _AdminDisputesScreenState extends State<AdminDisputesScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _disputes = [];
  String _statusFilter = 'open';

  static const _statusOptions = [
    {'value': 'open', 'label': 'Đang mở'},
    {'value': 'resolved', 'label': 'Đã xử lý'},
    {'value': 'rejected', 'label': 'Đã từ chối'},
  ];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _isLoading = true);
    try {
      final repo = context.read<AdminRepository>();
      final disputes = await repo.getDisputes(status: _statusFilter);
      if (!mounted) return;
      setState(() => _disputes = disputes);
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

  Future<void> _resolve(Map<String, dynamic> dispute, String status) async {
    final noteController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(status == 'resolved' ? 'Đánh dấu đã xử lý' : 'Từ chối khiếu nại'),
        content: TextField(
          controller: noteController,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'Ghi chú xử lý (tùy chọn)...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Xác nhận')),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final repo = context.read<AdminRepository>();
      final id = dispute['_id'] as String? ?? dispute['id'] as String;
      await repo.resolveDispute(id, status, noteController.text.trim());
      if (!mounted) return;
      setState(() => _disputes.removeWhere((d) => (d['_id'] ?? d['id']) == id));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xử lý khiếu nại')));
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceFirst('Exception:', '').trim()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      appBar: AppBar(title: const Text('Khiếu nại đơn hàng')),
      body: Column(
        children: [
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _statusOptions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final option = _statusOptions[i];
                final selected = _statusFilter == option['value'];
                return ChoiceChip(
                  label: Text(option['label']!),
                  selected: selected,
                  onSelected: (_) {
                    setState(() => _statusFilter = option['value']!);
                    _fetch();
                  },
                  selectedColor: AppColors.primaryUltraLight,
                  labelStyle: TextStyle(color: selected ? AppColors.primary : AppColors.body),
                );
              },
            ),
          ),
          Expanded(
            child: LoadingOverlay(
              isLoading: _isLoading,
              child: _disputes.isEmpty && !_isLoading
                  ? const Center(child: Text('Không có khiếu nại nào'))
                  : RefreshIndicator(
                      onRefresh: _fetch,
                      color: AppColors.primary,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _disputes.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) => _buildDisputeTile(_disputes[i]),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisputeTile(Map<String, dynamic> dispute) {
    final order = dispute['orderId'] as Map<String, dynamic>?;
    final buyer = dispute['raisedBy'] as Map<String, dynamic>?;
    final isOpen = dispute['status'] == 'open';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Đơn #${order?['orderCode'] ?? '---'}', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
              Text(
                CurrencyFormatter.format((order?['totalAmount'] as num?)?.toDouble() ?? 0),
                style: AppTextStyles.body.copyWith(color: AppColors.accentActive, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('Người khiếu nại: ${buyer?['fullName'] ?? ''}', style: AppTextStyles.caption.copyWith(color: AppColors.muted)),
          const SizedBox(height: 8),
          Text(dispute['reason'] as String? ?? '', style: AppTextStyles.body),
          if (dispute['resolutionNote'] != null && (dispute['resolutionNote'] as String).isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('Ghi chú: ${dispute['resolutionNote']}', style: AppTextStyles.caption.copyWith(fontStyle: FontStyle.italic)),
          ],
          if (isOpen) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _resolve(dispute, 'rejected'),
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                    child: const Text('Từ chối'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _resolve(dispute, 'resolved'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    child: const Text('Đã xử lý'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
