import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/services/auth_provider.dart';
import '../../router/app_router.dart';
import '../../widgets/common/agri_button.dart';
import '../../widgets/common/agri_card.dart';

class RolePickerScreen extends StatefulWidget {
  const RolePickerScreen({super.key});

  @override
  State<RolePickerScreen> createState() => _RolePickerScreenState();
}

class _RolePickerScreenState extends State<RolePickerScreen> {
  String _selectedRole = 'farmer'; // default role is farmer

  final List<Map<String, dynamic>> _roles = [
    {
      'id': 'farmer',
      'title': "Nông dân",
      'description': "Đăng bán nông sản của bạn",
      'icon': Icons.agriculture,
      'color': AppColors.primary,
    },
    {
      'id': 'supplier',
      'title': "Nhà cung cấp",
      'description': "Cung cấp vật tư nông nghiệp",
      'icon': Icons.inventory_2,
      'color': AppColors.primaryLight,
    },
    {
      'id': 'customer',
      'title': "Người mua",
      'description': "Mua sắm nông sản tươi sạch",
      'icon': Icons.shopping_bag,
      'color': AppColors.accent,
    },
  ];

  void _saveRole() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.updateRole(
      _selectedRole,
      onSuccess: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật vai trò thành công!')),
        );
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRouter.home,
          (route) => false,
        );
      },
      onError: (err) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err),
            backgroundColor: AppColors.error,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 36.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      AppStrings.rolePickerTitle,
                      style: AppTextStyles.bigTitle.copyWith(color: AppColors.primary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.rolePickerSubtitle,
                      style: AppTextStyles.body.copyWith(color: AppColors.muted),
                    ),
                    const SizedBox(height: 32),
                    // Roles List (Column vertical cards)
                    ..._roles.map((role) {
                      final isSelected = _selectedRole == role['id'];
                      final color = role['color'] as Color;

                      return AgriCard(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        color: isSelected ? AppColors.surfaceGreen : AppColors.canvas,
                        onTap: () {
                          setState(() {
                            _selectedRole = role['id'] as String;
                          });
                        },
                        child: Row(
                          children: [
                            // Icon container
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected ? color.withValues(alpha: 0.15) : AppColors.surfaceSoft,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                role['icon'] as IconData,
                                size: 28,
                                color: color,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    role['title'] as String,
                                    style: AppTextStyles.body.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? AppColors.primaryActive : AppColors.ink,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    role['description'] as String,
                                    style: AppTextStyles.caption.copyWith(color: AppColors.body),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Arrow icon on the right
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: isSelected ? AppColors.primaryActive : AppColors.muted,
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            // Bottom Action Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: AgriButton(
                text: AppStrings.verifyButton,
                onPressed: _saveRole,
                isLoading: authProvider.isLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
