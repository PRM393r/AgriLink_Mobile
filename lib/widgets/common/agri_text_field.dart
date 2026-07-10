import 'package:flutter/material.dart';
import '../../core/constants/app_text_styles.dart';

class AgriTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? errorText;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool readOnly;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLength;
  final int? maxLines;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  const AgriTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.errorText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.readOnly = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLength,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      readOnly: readOnly,
      maxLength: maxLength,
      maxLines: obscureText ? 1 : maxLines,
      validator: validator,
      onChanged: onChanged,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        errorText: errorText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        counterText: '', // Hide default counter to keep layout clean
      ),
    );
  }
}
