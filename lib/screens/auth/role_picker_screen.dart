import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/services/auth_provider.dart';
import '../../router/app_router.dart';
import '../../widgets/common/agri_button.dart';

class RolePickerScreen extends StatefulWidget {
  const RolePickerScreen({super.key});

  @override
  State<RolePickerScreen> createState() => _RolePickerScreenState();
}

class _RolePickerScreenState extends State<RolePickerScreen>
    with SingleTickerProviderStateMixin {
  String _selectedRole = 'farmer';

  late final AnimationController _entryController;

  final List<Map<String, dynamic>> _roles = [
    {
      'id': 'farmer',
      'title': "Nông dân",
      'description': "Đăng bán nông sản của bạn",
      'icon': Icons.agriculture,
      'emoji': '🌾',
      'gradient': const [Color(0xFF2D6A4F), Color(0xFF52B788)],
    },
    {
      'id': 'supplier',
      'title': "Nhà cung cấp",
      'description': "Cung cấp vật tư nông nghiệp",
      'icon': Icons.inventory_2,
      'emoji': '📦',
      'gradient': const [Color(0xFF3B82F6), Color(0xFF60A5FA)],
    },
    {
      'id': 'customer',
      'title': "Người mua",
      'description': "Mua sắm nông sản tươi sạch",
      'icon': Icons.shopping_bag,
      'emoji': '🛒',
      'gradient': const [Color(0xFFF4A261), Color(0xFFFFB703)],
    },
  ];

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _entryController.forward();
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

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
      backgroundColor: AppColors.surfaceElevated,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 36.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    // Emoji header
                    const Center(
                      child: Text('👋', style: TextStyle(fontSize: 48)),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        AppStrings.rolePickerTitle,
                        style: AppTextStyles.headline.copyWith(
                          color: AppColors.ink,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        AppStrings.rolePickerSubtitle,
                        style: AppTextStyles.subtitle.copyWith(
                          color: AppColors.muted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Roles
                    ..._roles.asMap().entries.map((entry) {
                      final index = entry.key;
                      final role = entry.value;
                      final isSelected = _selectedRole == role['id'];
                      final gradient = role['gradient'] as List<Color>;

                      return AnimatedBuilder(
                        animation: _entryController,
                        builder: (context, child) {
                          final delay = index * 0.2;
                          final start = delay;
                          final end = (delay + 0.6).clamp(0.0, 1.0);
                          final curvedAnimation = CurvedAnimation(
                            parent: _entryController,
                            curve: Interval(start, end,
                                curve: Curves.easeOutCubic),
                          );

                          return FadeTransition(
                            opacity: curvedAnimation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.2),
                                end: Offset.zero,
                              ).animate(curvedAnimation),
                              child: child,
                            ),
                          );
                        },
                        child: _buildRoleCard(role, isSelected, gradient),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Bottom action
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.canvas,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.ink.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: AgriButton.gradient(
                text: 'Tiếp tục',
                onPressed: _saveRole,
                isLoading: authProvider.isLoading,
                trailingIcon: Icons.arrow_forward_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    Map<String, dynamic> role,
    bool isSelected,
    List<Color> gradient,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = role['id'] as String;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected ? null : AppColors.canvas,
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    gradient[0].withValues(alpha: 0.08),
                    gradient[1].withValues(alpha: 0.04),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? gradient[0].withValues(alpha: 0.4)
                : AppColors.surfaceDivider.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: gradient[0].withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Emoji + gradient circle
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(colors: gradient)
                    : null,
                color: isSelected ? null : AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                role['emoji'] as String,
                style: const TextStyle(fontSize: 24),
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
                      fontWeight: FontWeight.w600,
                      color: isSelected ? gradient[0] : AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role['description'] as String,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Selection indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isSelected ? LinearGradient(colors: gradient) : null,
                border: isSelected
                    ? null
                    : Border.all(
                        color: AppColors.surfaceDivider,
                        width: 2,
                      ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: AppColors.canvas, size: 16)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
