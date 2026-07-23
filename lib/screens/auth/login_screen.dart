import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/services/auth_provider.dart';
import '../../router/app_router.dart';
import '../../widgets/common/agri_button.dart';
import '../../widgets/common/agri_text_field.dart';

class _MockLoginDivider extends StatelessWidget {
  const _MockLoginDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'Test nhanh',
            style: TextStyle(fontSize: 12, color: AppColors.muted.withValues(alpha: 0.7)),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

class _MockLoginButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MockLoginButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _didApplyPrefill = false;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _fadeController.forward();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didApplyPrefill) return;
    _didApplyPrefill = true;

    // Prefill from verify-email route args or AuthProvider.pendingEmail
    final args = ModalRoute.of(context)?.settings.arguments;
    String? prefill;
    if (args is String && args.trim().isNotEmpty) {
      prefill = args.trim();
    } else if (args is Map && args['prefillEmail'] is String) {
      prefill = (args['prefillEmail'] as String).trim();
    }
    prefill ??=
        Provider.of<AuthProvider>(context, listen: false).pendingEmail?.trim();

    if (prefill != null && prefill.isNotEmpty) {
      _emailCtrl.text = prefill;
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _login() {
    if (!_formKey.currentState!.validate()) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    auth.login(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      onSuccess: (needsRoleSelection) {
        if (needsRoleSelection) {
          Navigator.pushNamedAndRemoveUntil(
            context, AppRouter.rolePicker, (r) => false,
          );
        } else {
          Navigator.pushNamedAndRemoveUntil(
            context, AppRouter.home, (r) => false,
          );
        }
      },
      onError: (err) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err), backgroundColor: AppColors.error),
        );
      },
    );
  }

  void _quickLogin(String email) {
    _emailCtrl.text = email;
    _passwordCtrl.text = 'demo123';
    _login();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<AuthProvider>(context).isLoading;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceElevated,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top gradient header ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF1B4332),
                        Color(0xFF2D6A4F),
                        Color(0xFF40916C),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Logo
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.canvas.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.canvas.withValues(alpha: 0.2),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.eco_rounded,
                          size: 48,
                          color: AppColors.canvas,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'AgriLink',
                        style: AppTextStyles.bigTitle.copyWith(
                          color: AppColors.canvas,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Nông sản Việt — kết nối trực tiếp',
                        style: AppTextStyles.subtitle.copyWith(
                          color: AppColors.canvas.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Form section ──
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Đăng nhập',
                              style: AppTextStyles.sectionTitle.copyWith(
                                fontSize: 22,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Nhập email và mật khẩu để tiếp tục. '
                              '(Dev OTP email: 123456 nếu chưa cấu hình SMTP)',
                              style: AppTextStyles.subtitle.copyWith(
                                color: AppColors.muted,
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Email
                            AgriTextField(
                              controller: _emailCtrl,
                              hintText: 'Email',
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: const Icon(Icons.email_outlined,
                                  color: AppColors.muted),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Vui lòng nhập email';
                                }
                                final ok = RegExp(
                                        r'^[\w\.\-]+@[\w\-]+\.\w{2,}$')
                                    .hasMatch(v.trim());
                                if (!ok) return 'Email không hợp lệ';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Password
                            AgriTextField(
                              controller: _passwordCtrl,
                              hintText: 'Mật khẩu',
                              obscureText: _obscure,
                              prefixIcon: const Icon(Icons.lock_outline,
                                  color: AppColors.muted),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.muted,
                                ),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Vui lòng nhập mật khẩu';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 28),

                            // Login button
                            AgriButton.gradient(
                              text: 'Đăng nhập',
                              onPressed: _login,
                              isLoading: isLoading,
                              icon: Icons.login_rounded,
                            ),
                            const SizedBox(height: 20),

                            // Register link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Chưa có tài khoản? ',
                                    style: AppTextStyles.caption
                                        .copyWith(color: AppColors.muted)),
                                GestureDetector(
                                  onTap: () => Navigator.pushNamed(
                                      context, AppRouter.register),
                                  child: Text(
                                    'Đăng ký ngay',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Quick login for testing
                            const _MockLoginDivider(),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _MockLoginButton(
                                    label: 'Buyer',
                                    icon: Icons.person_outline,
                                    color: const Color(0xFF2563EB),
                                    onTap: () => _quickLogin('customer1@agrilink.vn'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _MockLoginButton(
                                    label: 'Farmer',
                                    icon: Icons.agriculture_outlined,
                                    color: const Color(0xFF16A34A),
                                    onTap: () => _quickLogin('farmer1@agrilink.vn'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _MockLoginButton(
                                    label: 'Supplier',
                                    icon: Icons.store_outlined,
                                    color: const Color(0xFFD97706),
                                    onTap: () => _quickLogin('supplier1@agrilink.vn'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: _MockLoginButton(
                                label: 'Admin',
                                icon: Icons.admin_panel_settings_outlined,
                                color: const Color(0xFFDC2626),
                                onTap: () => _quickLogin('admin@agrilink.vn'),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Trust indicators
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.lock_outline_rounded,
                                    size: 14,
                                    color:
                                        AppColors.muted.withValues(alpha: 0.6),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Bảo mật bởi AgriLink Server',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.muted
                                          .withValues(alpha: 0.6),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
