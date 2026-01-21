import 'package:flutter/material.dart';
import '../app/theme.dart';

class InputField extends StatelessWidget {
  final String hint;
  final bool obscureText;
  final bool error;
  final bool success;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const InputField({
    super.key,
    required this.hint,
    this.obscureText = false,
    this.error = false,
    this.success = false,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor = Colors.grey.shade300;

    if (error) borderColor = AppColors.error;
    if (success) borderColor = AppColors.success;

    return TextFormField(
      obscureText: obscureText,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderColor, width: 1.5),
        ),
      ),
    );
  }
}
