import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFFC107);
  static const error = Color(0xFFEF5350);

  static final ColorScheme light = ColorScheme.fromSeed(
    seedColor: Color(0xFF007AFF),
    brightness: Brightness.light,
  ).copyWith(secondary: const Color(0xFFFF6B6B));

  static final ColorScheme dark = ColorScheme.fromSeed(
    seedColor: Color(0xFF007AFF),
    brightness: Brightness.dark,
  ).copyWith(secondary: const Color(0xFFFF6B6B));
}
