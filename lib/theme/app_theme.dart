import 'package:flutter/material.dart';
import 'app_colors.dart';

@immutable
class CustomColors extends ThemeExtension<CustomColors> {
  const CustomColors({
    required this.success,
    required this.warning,
    required this.error,
  });

  final Color success;
  final Color warning;
  final Color error;

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
  static final lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: AppColors.light,
    extensions: const [
      CustomColors(
        success: AppColors.success,
        warning: AppColors.warning,
        error: AppColors.error,
      ),
    ],
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: AppColors.dark,
    extensions: const [
      CustomColors(
        success: AppColors.success,
        warning: AppColors.warning,
        error: AppColors.error,
      ),
    ],
  );
}
