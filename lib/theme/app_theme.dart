import 'package:flutter/material.dart';

import 'app_colors.dart';

@immutable
class CustomColors extends ThemeExtension<CustomColors> {
  final Color success;
  final Color warning;
  final Color error;

  const CustomColors({
    required this.success,
    required this.warning,
    required this.error,
  });

  @override
  CustomColors copyWith({Color? success, Color? warning, Color? error}) {
    return CustomColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
    );
  }

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) return this;
    return CustomColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
    );
  }
}

class AppTheme {
  AppTheme._();

  static ThemeData _base(ColorScheme scheme) {
    final base = ThemeData(colorScheme: scheme);
    final textTheme = base.textTheme.apply(fontFamily: 'NotoSansJP');
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: textTheme,
      extensions: const [
        CustomColors(
          success: AppColors.success,
          warning: AppColors.warning,
          error: AppColors.error,
        ),
      ],
    );
  }

  static ThemeData get lightTheme => _base(AppColors.light);

  static ThemeData get darkTheme => _base(AppColors.dark);
}
