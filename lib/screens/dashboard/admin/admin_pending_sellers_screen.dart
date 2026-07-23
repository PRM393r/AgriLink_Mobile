import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../../widgets/common/loading_overlay.dart';

class AdminPendingSellersScreen extends StatefulWidget {
  const AdminPendingSellersScreen({super.key});

  @override
  State<AdminPendingSellersScreen> createState() => _AdminPendingSellersScreenState();
}

class _AdminPendingSellersScreenState extends State<AdminPendingSellersScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _sellers = [];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _isLoading = true);
    try {
      final repo = context.read<AdminRepository>();
      final sellers = await repo.getPendingSellers();
      if (!mounted) return;
      setState(() => _sellers = sellers);
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

  Future<void> _decide(Map<String, dynamic> seller, String status) async {
    final label = status == 'approved' ? 'duyệt' : 'từ chối';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Xác nhận $label'),
        content: Text('Bạn có chắc muốn $label seller "${seller['fullName']}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(label[0].toUpperCase() + label.substring(1))),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final repo = context.read<AdminRepository>();
      final id = seller['_id'] as String? ?? seller['id'] as String;
      await repo.setSellerApproval(id, status);
      if (!mounted) return;
      setState(() => _sellers.removeWhere((s) => (s['_id'] ?? s['id']) == id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã $label seller')),
      );
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
      appBar: AppBar(title: const Text('Duyệt người bán mới')),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: _sellers.isEmpty && !_isLoading
            ? const Center(child: Text('Không có yêu cầu chờ duyệt'))
            : RefreshIndicator(
                onRefresh: _fetch,
                color: AppColors.primary,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _sellers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final seller = _sellers[i];
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
                          Text(seller['fullName'] as String? ?? '', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                          Text(seller['email'] as String? ?? '', style: AppTextStyles.caption.copyWith(color: AppColors.muted)),
                          Text(
                            seller['role'] == 'farmer' ? 'Nông dân' : 'Nhà cung cấp',
                            style: AppTextStyles.caption.copyWith(color: AppColors.primary),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => _decide(seller, 'rejected'),
                                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                                  child: const Text('Từ chối'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _decide(seller, 'approved'),
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                                  child: const Text('Duyệt'),
                                ),
                              ),
                            ],
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
