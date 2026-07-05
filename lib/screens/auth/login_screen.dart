import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/phone_formatter.dart';
import '../../data/services/auth_provider.dart';
import '../../router/app_router.dart';
import '../../widgets/auth/phone_input.dart';
import '../../widgets/common/agri_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();
  bool _isPhoneValid = false;

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
  void dispose() {
    _phoneController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onPhoneChanged(String val) {
    setState(() {
      _isPhoneValid = PhoneFormatter.isValidVietnamesePhone(val);
    });
  }

  void _sendOtp() {
    if (!_isPhoneValid) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.sendOtp(
      _phoneController.text.trim(),
      onSuccess: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mã OTP đã được gửi thành công!')),
        );
        Navigator.pushNamed(context, AppRouter.otp);
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
                        AppStrings.appName,
                        style: AppTextStyles.bigTitle.copyWith(
                          color: AppColors.canvas,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        AppStrings.loginSubtitle,
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.loginTitle,
                            style: AppTextStyles.sectionTitle.copyWith(
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Vui lòng nhập số điện thoại để tiếp tục đăng nhập hoặc đăng ký tài khoản mới.',
                            style: AppTextStyles.subtitle.copyWith(
                              color: AppColors.muted,
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Phone input
                          PhoneInput(
                            controller: _phoneController,
                            onChanged: _onPhoneChanged,
                          ),
                          const SizedBox(height: 28),

                          // CTA Button
                          AgriButton.gradient(
                            text: AppStrings.sendOtpButton,
                            onPressed: _isPhoneValid ? _sendOtp : null,
                            isLoading: isLoading,
                            icon: Icons.send_rounded,
                          ),
                          const SizedBox(height: 32),

                          // Trust indicators
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.lock_outline_rounded,
                                  size: 14,
                                  color: AppColors.muted.withValues(alpha: 0.6),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Bảo mật bởi Firebase Authentication',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.muted.withValues(alpha: 0.6),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
