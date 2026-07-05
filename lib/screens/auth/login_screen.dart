import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/services/auth_provider.dart';
import '../../router/app_router.dart';
import '../../widgets/common/agri_button.dart';
import '../../widgets/common/agri_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey     = GlobalKey<FormState>();
  final _emailCtrl   = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure      = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _login() {
    if (!_formKey.currentState!.validate()) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    auth.login(
      email:    _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      onSuccess: (isNewUser) {
        if (isNewUser) {
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

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<AuthProvider>(context).isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // Logo / Brand
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryUltraLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.eco_outlined, size: 60, color: AppColors.primary),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'AgriLink',
                        style: AppTextStyles.bigTitle.copyWith(
                          color: AppColors.primary,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Nông sản Việt — kết nối trực tiếp',
                        style: AppTextStyles.body.copyWith(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                Text('Đăng nhập', style: AppTextStyles.sectionTitle.copyWith(fontSize: 22)),
                const SizedBox(height: 6),
                Text(
                  'Nhập email và mật khẩu để tiếp tục.',
                  style: AppTextStyles.caption.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: 24),

                // Email
                AgriTextField(
                  controller: _emailCtrl,
                  hintText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined, color: AppColors.muted),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Vui lòng nhập email';
                    final ok = RegExp(r'^[\w\.\-]+@[\w\-]+\.\w{2,}$').hasMatch(v.trim());
                    if (!ok) return 'Email không hợp lệ';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Mật khẩu
                AgriTextField(
                  controller: _passwordCtrl,
                  hintText: 'Mật khẩu',
                  obscureText: _obscure,
                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.muted),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.muted,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Vui lòng nhập mật khẩu';
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                AgriButton(
                  text: 'Đăng nhập',
                  onPressed: _login,
                  isLoading: isLoading,
                ),
                const SizedBox(height: 20),

                // Link đến register
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Chưa có tài khoản? ',
                        style: AppTextStyles.caption.copyWith(color: AppColors.muted)),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, AppRouter.register),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
