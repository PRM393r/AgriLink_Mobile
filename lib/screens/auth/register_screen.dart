import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/services/auth_provider.dart';
import '../../router/app_router.dart';
import '../../widgets/common/agri_button.dart';
import '../../widgets/common/agri_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _fullNameCtrl = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl  = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm  = true;
  String _password      = '';
  String _confirm       = '';
  String _email         = '';

  // ── Password strength ──────────────────────────────────────────────────────
  bool get _hasMinLength  => _password.length >= 8;
  bool get _hasUppercase  => _password.contains(RegExp(r'[A-Z]'));
  bool get _hasLowercase  => _password.contains(RegExp(r'[a-z]'));
  bool get _hasDigit      => _password.contains(RegExp(r'[0-9]'));
  bool get _hasSpecial    => _password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]'));

  int get _strengthScore =>
      (_hasMinLength ? 1 : 0) +
      (_hasUppercase ? 1 : 0) +
      (_hasLowercase ? 1 : 0) +
      (_hasDigit ? 1 : 0) +
      (_hasSpecial ? 1 : 0);

  // ── Email validation ───────────────────────────────────────────────────────
  bool get _emailValid =>
      _email.isNotEmpty &&
      RegExp(r'^[\w\.\-]+@[\w\-]+\.\w{2,}$').hasMatch(_email.trim());

  bool get _confirmMatch => _confirm.isNotEmpty && _confirm == _password;

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _register() {
    if (!_formKey.currentState!.validate()) return;
    if (_strengthScore < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mật khẩu chưa đủ mạnh'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    final auth = Provider.of<AuthProvider>(context, listen: false);
    auth.register(
      email:    _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      fullName: _fullNameCtrl.text.trim(),
      onSuccess: () {
        Navigator.pushNamed(
          context,
          AppRouter.verifyEmail,
          arguments: _emailCtrl.text.trim(),
        );
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
      appBar: AppBar(
        title: const Text('Đăng ký tài khoản'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.ink,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text('Tạo tài khoản AgriLink',
                    style: AppTextStyles.sectionTitle.copyWith(fontSize: 22)),
                const SizedBox(height: 6),
                Text('Điền đầy đủ thông tin bên dưới để bắt đầu.',
                    style: AppTextStyles.caption.copyWith(color: AppColors.muted)),
                const SizedBox(height: 28),

                // ── Họ và tên ───────────────────────────────────────────────
                AgriTextField(
                  controller: _fullNameCtrl,
                  hintText: 'Họ và tên',
                  prefixIcon: const Icon(Icons.person_outline, color: AppColors.muted),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Vui lòng nhập họ tên';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ── Email với realtime check ─────────────────────────────────
                AgriTextField(
                  controller: _emailCtrl,
                  hintText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined, color: AppColors.muted),
                  suffixIcon: _email.isEmpty
                      ? null
                      : Icon(
                          _emailValid ? Icons.check_circle : Icons.cancel,
                          color: _emailValid ? AppColors.primary : AppColors.error,
                          size: 20,
                        ),
                  onChanged: (v) => setState(() => _email = v),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Vui lòng nhập email';
                    if (!_emailValid) return 'Email không hợp lệ';
                    return null;
                  },
                ),
                // Hint email format
                if (_email.isNotEmpty && !_emailValid)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4),
                    child: Text(
                      'Định dạng: tên@domain.com',
                      style: AppTextStyles.caption.copyWith(color: AppColors.error, fontSize: 11),
                    ),
                  ),
                const SizedBox(height: 16),

                // ── Mật khẩu ────────────────────────────────────────────────
                AgriTextField(
                  controller: _passwordCtrl,
                  hintText: 'Mật khẩu',
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.muted),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.muted,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  onChanged: (v) => setState(() => _password = v),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Vui lòng nhập mật khẩu';
                    if (v.length < 8) return 'Mật khẩu ít nhất 8 ký tự';
                    return null;
                  },
                ),

                // ── Password strength bar ────────────────────────────────────
                if (_password.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _PasswordStrengthBar(score: _strengthScore),
                  const SizedBox(height: 8),
                  _PasswordCriteria(
                    hasMinLength: _hasMinLength,
                    hasUppercase: _hasUppercase,
                    hasLowercase: _hasLowercase,
                    hasDigit: _hasDigit,
                    hasSpecial: _hasSpecial,
                  ),
                ],
                const SizedBox(height: 16),

                // ── Confirm password ─────────────────────────────────────────
                AgriTextField(
                  controller: _confirmCtrl,
                  hintText: 'Xác nhận mật khẩu',
                  obscureText: _obscureConfirm,
                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.muted),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_confirm.isNotEmpty)
                        Icon(
                          _confirmMatch ? Icons.check_circle : Icons.cancel,
                          color: _confirmMatch ? AppColors.primary : AppColors.error,
                          size: 20,
                        ),
                      IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.muted,
                        ),
                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ],
                  ),
                  onChanged: (v) => setState(() => _confirm = v),
                  validator: (v) {
                    if (v != _passwordCtrl.text) return 'Mật khẩu xác nhận không khớp';
                    return null;
                  },
                ),
                if (_confirm.isNotEmpty && !_confirmMatch)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4),
                    child: Text(
                      'Mật khẩu chưa khớp',
                      style: AppTextStyles.caption.copyWith(color: AppColors.error, fontSize: 11),
                    ),
                  ),
                const SizedBox(height: 32),

                AgriButton(
                  text: 'Đăng ký',
                  onPressed: _register,
                  isLoading: isLoading,
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Đã có tài khoản? ',
                        style: AppTextStyles.caption.copyWith(color: AppColors.muted)),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacementNamed(context, AppRouter.login),
                      child: Text(
                        'Đăng nhập',
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

// ── Password strength bar ────────────────────────────────────────────────────
class _PasswordStrengthBar extends StatelessWidget {
  final int score; // 0-5

  const _PasswordStrengthBar({required this.score});

  Color get _color {
    if (score <= 1) return AppColors.error;
    if (score == 2) return const Color(0xFFFF9800);
    if (score == 3) return const Color(0xFFFFB703);
    if (score == 4) return const Color(0xFF52B788);
    return AppColors.primary;
  }

  String get _label {
    if (score <= 1) return 'Rất yếu';
    if (score == 2) return 'Yếu';
    if (score == 3) return 'Trung bình';
    if (score == 4) return 'Mạnh';
    return 'Rất mạnh';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: score / 5,
                  minHeight: 6,
                  backgroundColor: const Color(0xFFE5E7EB),
                  valueColor: AlwaysStoppedAnimation<Color>(_color),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              _label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Password criteria checklist ──────────────────────────────────────────────
class _PasswordCriteria extends StatelessWidget {
  final bool hasMinLength;
  final bool hasUppercase;
  final bool hasLowercase;
  final bool hasDigit;
  final bool hasSpecial;

  const _PasswordCriteria({
    required this.hasMinLength,
    required this.hasUppercase,
    required this.hasLowercase,
    required this.hasDigit,
    required this.hasSpecial,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        _Criterion(met: hasMinLength, label: '≥ 8 ký tự'),
        _Criterion(met: hasUppercase, label: 'Chữ hoa (A-Z)'),
        _Criterion(met: hasLowercase, label: 'Chữ thường (a-z)'),
        _Criterion(met: hasDigit,     label: 'Số (0-9)'),
        _Criterion(met: hasSpecial,   label: 'Ký tự đặc biệt'),
      ],
    );
  }
}

class _Criterion extends StatelessWidget {
  final bool met;
  final String label;

  const _Criterion({required this.met, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          met ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 13,
          color: met ? AppColors.primary : AppColors.muted,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: met ? AppColors.primary : AppColors.muted,
            fontWeight: met ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
