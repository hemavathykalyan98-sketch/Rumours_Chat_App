import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF08080A);
  static const panel = Color(0xFF111521);
  static const field = Color(0xFF242529);
  static const lime = Color(0xFFA6EA2B);
  static const text = Color(0xFFF7F7F8);
  static const muted = Color(0xFF92949D);
  static const incoming = Color(0xFF171B26);
  static const divider = Color(0xFF252A35);
}

class AppTheme {
  static final dark = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'Roboto',
    colorScheme: const ColorScheme.dark(
      primary: AppColors.lime,
      surface: AppColors.panel,
      onPrimary: Colors.black,
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.text),
      titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.text),
      bodyMedium: TextStyle(fontSize: 13, color: AppColors.text),
      bodySmall: TextStyle(fontSize: 11, color: AppColors.muted),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.field,
      hintStyle: const TextStyle(color: AppColors.muted),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lime, width: 1.2),
      ),
    ),
  );
}
