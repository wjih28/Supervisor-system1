import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryBlue = Color(0xFF2D62ED);
  static const Color secondaryPurple = Color(0xFF7C3AED);
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textGrey = Color(0xFF64748B);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: AppColors.primaryBlue,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      fontFamily: 'Tajawal',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        primary: AppColors.primaryBlue,
        secondary: AppColors.secondaryPurple,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.primaryBlue,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'Tajawal',
        ),
        iconTheme: IconThemeData(color: AppColors.textGrey),
      ),
    );
  }
}
