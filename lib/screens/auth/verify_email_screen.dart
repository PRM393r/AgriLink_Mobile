import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/services/auth_provider.dart';
import '../../router/app_router.dart';
import '../../widgets/common/agri_button.dart';
import '../../widgets/common/agri_text_field.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _otpCtrl = TextEditingController();
  int  _countdown = 60;
  bool _canResend = false;
  Timer? _timer;

  // email truyền qua route arguments hoặc lấy từ provider
  String get _email {
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is String && arg.isNotEmpty) return arg;
    return Provider.of<AuthProvider>(context, listen: false).pendingEmail ?? '';
  }

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpCtrl.dispose();
    super.dispose();
  }

  void _startCountdown() {
    setState(() { _countdown = 60; _canResend = false; });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown == 0) {
        setState(() => _canResend = true);
        t.cancel();
      } else {
        setState(() => _countdown--);
      }
    });
  }

  void _verify() {
    final code = _otpCtrl.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đủ 6 chữ số'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    final auth = Provider.of<AuthProvider>(context, listen: false);
    auth.verifyEmail(
      email: _email,
      code: code,
      onSuccess: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Xác thực email thành công!')),
        );
        // Sau verify → đến login để nhận token
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRouter.login,
          (route) => false,
        );
      },
      onError: (err) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err), backgroundColor: AppColors.error),
        );
      },
    );
  }

  void _resend() {
    if (!_canResend) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    auth.resendOtp(
      email: _email,
      onSuccess: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã gửi lại mã OTP!')),
        );
        _startCountdown();
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
        title: const Text('Xác thực email'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.ink,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // Icon
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryUltraLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.mark_email_read_outlined, size: 48, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Kiểm tra hộp thư của bạn',
                style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: AppTextStyles.body.copyWith(color: AppColors.body),
                  children: [
                    const TextSpan(text: 'Mã xác thực 6 số đã được gửi đến '),
                    TextSpan(
                      text: _email,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              AgriTextField(
                controller: _otpCtrl,
                hintText: 'Nhập mã 6 chữ số',
                keyboardType: TextInputType.number,
                maxLength: 6,
                prefixIcon: const Icon(Icons.lock_outline, color: AppColors.muted),
                onChanged: (v) {
                  if (v.length == 6) _verify();
                },
              ),
              const SizedBox(height: 20),

              // Resend row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Chưa nhận được mã?',
                      style: AppTextStyles.caption.copyWith(color: AppColors.muted)),
                  _canResend
                      ? TextButton(
                          onPressed: _resend,
                          child: Text('Gửi lại',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              )),
                        )
                      : Text('Gửi lại (${_countdown}s)',
                          style: AppTextStyles.caption.copyWith(color: AppColors.muted)),
                ],
              ),
              const SizedBox(height: 32),

              AgriButton(
                text: 'Xác nhận',
                onPressed: _otpCtrl.text.length == 6 ? _verify : null,
                isLoading: isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
