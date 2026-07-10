import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/models/user_model.dart';
import '../../data/services/auth_provider.dart';
import '../../router/app_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.logout),
        content: const Text(AppStrings.confirmLogout),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppStrings.logout,
                style: TextStyle(
                    color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await authProvider.logout();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
            context, AppRouter.login, (route) => false);
      }
    }
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'farmer':
        return '🌾 Nông dân';
      case 'supplier':
        return '📦 Nhà cung cấp';
      case 'customer':
      case 'buyer':
        return '🛒 Người mua';
      default:
        return 'Chưa chọn';
    }
  }

  ImageProvider? _avatarImage(UserModel? user) {
    final url = user?.avatarUrl;
    if (url == null || url.trim().isEmpty) return null;
    return NetworkImage(url.trim());
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;
    final avatar = _avatarImage(user);
    final name = user?.fullName.trim().isNotEmpty == true
        ? user!.fullName.trim()
        : 'Chưa cập nhật tên';
    final phone = (user?.phone?.trim().isNotEmpty == true)
        ? user!.phone!
        : '';
    final email = user?.email.trim().isNotEmpty == true
        ? user!.email.trim()
        : 'Chưa cập nhật email';
    final role = user?.role ?? '';

    return Scaffold(
      backgroundColor: AppColors.surfaceElevated,
      body: CustomScrollView(
        slivers: [
          // ── Gradient header ──
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.fromLTRB(
                  24, MediaQuery.of(context).padding.top + 20, 24, 28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1B4332), Color(0xFF2D6A4F), Color(0xFF40916C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  // Title row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tài khoản',
                          style: AppTextStyles.sectionTitle
                              .copyWith(color: AppColors.canvas)),
                      IconButton(
                        icon: const Icon(Icons.settings_outlined,
                            color: AppColors.canvas),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Avatar + info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor:
                            AppColors.canvas.withValues(alpha: 0.2),
                        backgroundImage: avatar,
                        child: avatar == null
                            ? const Icon(Icons.person_rounded,
                                size: 40, color: AppColors.canvas)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name,
                                style: AppTextStyles.sectionTitle.copyWith(
                                    color: AppColors.canvas, fontSize: 18)),
                            const SizedBox(height: 4),
                            Text(email,
                                style: AppTextStyles.caption.copyWith(
                                    color: AppColors.canvas
                                        .withValues(alpha: 0.7))),
                            if (phone.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(phone,
                                  style: AppTextStyles.caption.copyWith(
                                      color: AppColors.canvas
                                          .withValues(alpha: 0.6))),
                            ],
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.canvas.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(_roleLabel(role),
                                  style: AppTextStyles.badge.copyWith(
                                      color: AppColors.canvas,
                                      fontSize: 11)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Quick stats ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Row(
                children: [
                  _statItem('0', 'Đơn hàng'),
                  _statDivider(),
                  _statItem('0', 'Yêu thích'),
                  _statDivider(),
                  _statItem('0', 'Điểm'),
                ],
              ),
            ),
          ),

          // ── Menu sections ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Text('Tài khoản',
                  style: AppTextStyles.overline.copyWith(
                      color: AppColors.muted, letterSpacing: 1.0)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _menuGroup([
                _MenuItem(Icons.edit_outlined, 'Chỉnh sửa hồ sơ',
                    AppColors.primary,
                    onTap: () => Navigator.pushNamed(
                        context, AppRouter.editProfile)),
                _MenuItem(Icons.receipt_long_outlined, 'Lịch sử đơn hàng',
                    AppColors.accent,
                    onTap: () => Navigator.pushNamed(
                        context, AppRouter.orderHistory)),
                _MenuItem(
                    Icons.favorite_outline, 'Yêu thích', AppColors.error),
              ]),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Text('Hỗ trợ',
                  style: AppTextStyles.overline.copyWith(
                      color: AppColors.muted, letterSpacing: 1.0)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _menuGroup([
                _MenuItem(
                  Icons.menu_book_outlined,
                  'Hướng dẫn mua hàng',
                  AppColors.info,
                  onTap: () => Navigator.pushNamed(context, AppRouter.howToBuy),
                ),
                _MenuItem(
                  Icons.help_outline_rounded,
                  'Câu hỏi thường gặp (FAQ)',
                  AppColors.accent,
                  onTap: () => Navigator.pushNamed(context, AppRouter.faq),
                ),
                _MenuItem(
                  Icons.security_outlined,
                  'Chính sách bảo mật',
                  AppColors.warning,
                  onTap: () => Navigator.pushNamed(context, AppRouter.privacy),
                ),
                _MenuItem(
                  Icons.gavel_outlined,
                  'Điều khoản sử dụng',
                  AppColors.primaryLight,
                  onTap: () => Navigator.pushNamed(context, AppRouter.terms),
                ),
              ]),
            ),
          ),

          // ── Logout ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: OutlinedButton.icon(
                onPressed:
                    auth.isLoading ? null : () => _handleLogout(context),
                icon: const Icon(Icons.logout_rounded,
                    color: AppColors.error, size: 20),
                label: Text('Đăng xuất',
                    style: AppTextStyles.button
                        .copyWith(color: AppColors.error)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(
                      color: AppColors.error.withValues(alpha: 0.3)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: AppTextStyles.sectionTitle
                  .copyWith(fontSize: 20, color: AppColors.ink)),
          const SizedBox(height: 2),
          Text(label,
              style: AppTextStyles.caption.copyWith(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _statDivider() {
    return Container(
        width: 1,
        height: 30,
        color: AppColors.surfaceDivider.withValues(alpha: 0.4));
  }

  Widget _menuGroup(List<_MenuItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppColors.surfaceDivider.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: items.asMap().entries.map((e) {
          final item = e.value;
          final isLast = e.key == items.length - 1;
          return Column(
            children: [
              ListTile(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon, color: item.color, size: 20),
                ),
                title: Text(item.label,
                    style: AppTextStyles.subtitle
                        .copyWith(fontWeight: FontWeight.w500)),
                trailing: const Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: AppColors.muted),
                onTap: item.onTap,
              ),
              if (!isLast)
                Divider(
                    height: 1,
                    indent: 60,
                    color: AppColors.surfaceDivider.withValues(alpha: 0.3)),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  const _MenuItem(this.icon, this.label, this.color, {this.onTap});
}
