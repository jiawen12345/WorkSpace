import 'package:flutter/material.dart';
import '../app/theme.dart'; // ⚠️ 这一行非常关键

class ValidationRow extends StatelessWidget {
  final String text;
  final bool ok;

  const ValidationRow({
    super.key,
    required this.text,
    required this.ok,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          ok ? Icons.check_circle : Icons.cancel,
          size: 16,
          color: ok ? AppColors.success : AppColors.danger,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: ok ? AppColors.success : AppColors.danger,
          ),
        ),
      ],
    );
  }
}
