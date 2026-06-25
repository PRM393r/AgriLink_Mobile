import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/phone_formatter.dart';
import '../common/agri_text_field.dart';

class PhoneInput extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const PhoneInput({
    super.key,
    required this.controller,
    this.onChanged,
  });

  @override
  State<PhoneInput> createState() => _PhoneInputState();
}

class _PhoneInputState extends State<PhoneInput> {
  String? _errorText;

  void _validatePhone(String value) {
    if (value.isEmpty) {
      setState(() {
        _errorText = null;
      });
      return;
    }

    final isValid = PhoneFormatter.isValidVietnamesePhone(value);
    setState(() {
      _errorText = isValid ? null : AppStrings.errorInvalidPhone;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AgriTextField(
      controller: widget.controller,
      labelText: AppStrings.phoneLabel,
      hintText: AppStrings.phoneHint,
      errorText: _errorText,
      keyboardType: TextInputType.phone,
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 14.0, right: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.phone_outlined, color: AppColors.muted),
            const SizedBox(width: 8),
            Text(
              '+84',
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              height: 20,
              width: 1,
              color: AppColors.muted.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
      onChanged: (val) {
        _validatePhone(val);
        if (widget.onChanged != null) {
          widget.onChanged!(val);
        }
      },
    );
  }
}
