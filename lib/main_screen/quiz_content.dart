import 'package:flutter/material.dart';

import '../review_service.dart';
import '../review_mode_ext.dart';
import '../tabs_content/quiz_tab_content.dart';
import '../app_view.dart';

class QuizContent extends StatelessWidget {
  final ReviewMode mode;
  final void Function(AppScreen, {ScreenArguments? args}) navigateTo;

  const QuizContent({
    super.key,
    required this.mode,
    required this.navigateTo,
  });

  @override
  Widget build(BuildContext context) {
    return QuizTabContent(
      key: const ValueKey('QuizTabContent'),
      navigateTo: navigateTo,
      mode: mode,
    );
  }
}
