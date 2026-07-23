import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../../widgets/common/loading_overlay.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _searchController = TextEditingController();
  bool _isLoading = true;
  List<Map<String, dynamic>> _users = [];
  String? _roleFilter;

  static const _roleOptions = [
    {'value': null, 'label': 'Tất cả'},
    {'value': 'customer', 'label': 'Khách hàng'},
    {'value': 'farmer', 'label': 'Nông dân'},
    {'value': 'supplier', 'label': 'Nhà cung cấp'},
    {'value': 'admin', 'label': 'Quản trị viên'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      final repo = context.read<AdminRepository>();
      final result = await repo.getUsers(
        role: _roleFilter,
        search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
        limit: 100,
      );
      if (!mounted) return;
      setState(() => _users = List<Map<String, dynamic>>.from(result['items'] as List? ?? []));
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

  Future<void> _toggleActive(Map<String, dynamic> user) async {
    final id = user['_id'] as String? ?? user['id'] as String;
    final newActive = !(user['isActive'] as bool? ?? true);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(newActive ? 'Mở khóa tài khoản' : 'Khóa tài khoản'),
        content: Text(
          newActive
              ? 'Người dùng "${user['fullName']}" sẽ có thể đăng nhập lại.'
              : 'Người dùng "${user['fullName']}" sẽ không thể đăng nhập cho tới khi được mở khóa.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              newActive ? 'Mở khóa' : 'Khóa',
              style: TextStyle(color: newActive ? AppColors.primary : AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final repo = context.read<AdminRepository>();
      await repo.setUserActive(id, newActive);
      if (!mounted) return;
      setState(() => user['isActive'] = newActive);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(newActive ? 'Đã mở khóa tài khoản' : 'Đã khóa tài khoản')),
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
      appBar: AppBar(title: const Text('Quản lý người dùng')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm theo tên, email, SĐT...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
              ),
              onSubmitted: (_) => _fetchUsers(),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _roleOptions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final option = _roleOptions[i];
                final selected = _roleFilter == option['value'];
                return ChoiceChip(
                  label: Text(option['label'] as String),
                  selected: selected,
                  onSelected: (_) {
                    setState(() => _roleFilter = option['value']);
                    _fetchUsers();
                  },
                  selectedColor: AppColors.primaryUltraLight,
                  labelStyle: TextStyle(color: selected ? AppColors.primary : AppColors.body),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: LoadingOverlay(
              isLoading: _isLoading,
              child: _users.isEmpty && !_isLoading
                  ? const Center(child: Text('Không tìm thấy người dùng'))
                  : RefreshIndicator(
                      onRefresh: _fetchUsers,
                      color: AppColors.primary,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _users.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) => _buildUserTile(_users[i]),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTile(Map<String, dynamic> user) {
    final isActive = user['isActive'] as bool? ?? true;
    final role = user['role'] as String? ?? '';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primaryUltraLight,
            backgroundImage: (user['avatarUrl'] as String?)?.isNotEmpty == true
                ? NetworkImage(user['avatarUrl'] as String)
                : null,
            child: (user['avatarUrl'] as String?)?.isNotEmpty != true
                ? Text(
                    (user['fullName'] as String? ?? '?').substring(0, 1).toUpperCase(),
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['fullName'] as String? ?? '(Chưa đặt tên)',
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  user['email'] as String? ?? '',
                  style: AppTextStyles.caption.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _RoleBadge(role: role),
                    if (!isActive) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Đã khóa', style: TextStyle(color: AppColors.error, fontSize: 11)),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Switch(
            value: isActive,
            activeTrackColor: AppColors.primary,
            onChanged: (_) => _toggleActive(user),
          ),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});

  final String role;

  static const _labels = {
    'customer': 'Khách hàng',
    'farmer': 'Nông dân',
    'supplier': 'Nhà cung cấp',
    'admin': 'Quản trị viên',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primaryUltraLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _labels[role] ?? role,
        style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
