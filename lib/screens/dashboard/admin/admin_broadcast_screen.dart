import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../../widgets/common/agri_button.dart';

class AdminBroadcastScreen extends StatefulWidget {
  const AdminBroadcastScreen({super.key});

  @override
  State<AdminBroadcastScreen> createState() => _AdminBroadcastScreenState();
}

class _AdminBroadcastScreenState extends State<AdminBroadcastScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  String? _targetRole;
  bool _isSending = false;

  static const _roleOptions = [
    {'value': null, 'label': 'Tất cả người dùng'},
    {'value': 'customer', 'label': 'Chỉ khách hàng'},
    {'value': 'farmer', 'label': 'Chỉ nông dân'},
    {'value': 'supplier', 'label': 'Chỉ nhà cung cấp'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận gửi thông báo'),
        content: Text(
          'Gửi thông báo này tới "${_roleOptions.firstWhere((o) => o['value'] == _targetRole)['label']}"?\n\nHành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Gửi')),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isSending = true);
    try {
      final repo = context.read<AdminRepository>();
      final sentCount = await repo.broadcastNotification(
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
        role: _targetRole,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã gửi thông báo tới $sentCount người dùng')),
      );
      _titleController.clear();
      _bodyController.clear();
      setState(() => _targetRole = null);
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
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      appBar: AppBar(title: const Text('Gửi thông báo')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Đối tượng nhận', style: AppTextStyles.sectionTitle),
            const SizedBox(height: 10),
            ..._roleOptions.map((option) => RadioListTile<String?>(
                  contentPadding: EdgeInsets.zero,
                  title: Text(option['label'] as String),
                  value: option['value'],
                  // ignore: deprecated_member_use
                  groupValue: _targetRole,
                  activeColor: AppColors.primary,
                  // ignore: deprecated_member_use
                  onChanged: (v) => setState(() => _targetRole = v),
                )),
            const SizedBox(height: 20),
            Text('Tiêu đề', style: AppTextStyles.sectionTitle),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              maxLength: 100,
              decoration: const InputDecoration(hintText: 'Vd: Bảo trì hệ thống'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập tiêu đề' : null,
            ),
            const SizedBox(height: 12),
            Text('Nội dung', style: AppTextStyles.sectionTitle),
            const SizedBox(height: 8),
            TextFormField(
              controller: _bodyController,
              maxLines: 5,
              maxLength: 500,
              decoration: const InputDecoration(hintText: 'Nội dung thông báo...'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập nội dung' : null,
            ),
            const SizedBox(height: 20),
            AgriButton(
              text: 'Gửi thông báo',
              isLoading: _isSending,
              onPressed: _isSending ? null : _send,
            ),
          ],
        ),
      ),
    );
  }
}
