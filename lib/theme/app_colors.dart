import 'package:flutter/material.dart';

class AppColors {
  static const Color brand = Color(0xFF007AFF);
  static const Color accent = Color(0xFFFF6B6B);

  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFE74C3C);

  static ColorScheme light = ColorScheme.fromSeed(
    seedColor: brand,
    brightness: Brightness.light,
  ).copyWith(
    primary: brand,
    secondary: accent,
  );

  static ColorScheme dark = ColorScheme.fromSeed(
    seedColor: brand,
    brightness: Brightness.dark,
  ).copyWith(
    primary: brand,
    secondary: accent,
  );
}
