import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1677FF);
  static const Color success = Color(0xFF52C41A);
  static const Color error = Color(0xFFFF4D4F);
  static const Color bgWhite = Colors.white;
  static const Color bgGray = Color(0xFFF5F5F5);
  static const Color border = Color(0xFFD9D9D9);
  static const Color textMain = Color(0xFF262626);
  static const Color textSub = Color(0xFF8C8C8C);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: AppColors.bgGray,
      primaryColor: AppColors.primary,

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgWhite,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }
}
