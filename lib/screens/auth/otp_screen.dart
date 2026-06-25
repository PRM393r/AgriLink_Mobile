import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/phone_formatter.dart';
import '../../data/services/auth_provider.dart';
import '../../router/app_router.dart';
import '../../widgets/common/agri_button.dart';
import '../../widgets/common/agri_text_field.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  int _countdown = 60;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    setState(() {
      _countdown = 60;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown == 0) {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      } else {
        setState(() {
          _countdown--;
        });
      }
    });
  }

  void _resendOtp() {
    if (!_canResend) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final phone = authProvider.phoneNumber;
    if (phone == null) return;

    authProvider.sendOtp(
      phone,
      onSuccess: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mã OTP mới đã được gửi!')),
        );
        _startCountdown();
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

  void _verifyOtp() {
    final code = _otpController.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đầy đủ 6 chữ số'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.verifyOtp(
      code,
      onSuccess: (isNewUser) {
        if (isNewUser) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRouter.rolePicker,
            (route) => false,
          );
        } else {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRouter.home,
            (route) => false,
          );
        }
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
    final formattedPhone = PhoneFormatter.formatForDisplay(authProvider.phoneNumber ?? '');

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.otpTitle),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                AppStrings.otpTitle,
                style: AppTextStyles.sectionTitle.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: AppTextStyles.body.copyWith(color: AppColors.body),
                  children: [
                    const TextSpan(text: AppStrings.otpSubtitle),
                    const TextSpan(text: ' '),
                    TextSpan(
                      text: formattedPhone,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              // OTP field (styled for 6-digit with space spacing)
              AgriTextField(
                controller: _otpController,
                hintText: AppStrings.otpHint,
                keyboardType: TextInputType.number,
                maxLength: 6,
                prefixIcon: const Icon(Icons.lock_outline, color: AppColors.muted),
                onChanged: (val) {
                  if (val.length == 6) {
                    _verifyOtp();
                  }
                },
              ),
              const SizedBox(height: 24),
              // Resend Timer Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.resendOtpPrompt,
                    style: AppTextStyles.caption,
                  ),
                  _canResend
                      ? TextButton(
                          onPressed: _resendOtp,
                          child: Text(
                            AppStrings.resendOtpButton,
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : Text(
                          '${AppStrings.resendOtpButton} (${_countdown}s)',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.muted,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ],
              ),
              const SizedBox(height: 48),
              // Confirm Button
              AgriButton(
                text: AppStrings.verifyButton,
                onPressed: _otpController.text.length == 6 ? _verifyOtp : null,
                isLoading: authProvider.isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
