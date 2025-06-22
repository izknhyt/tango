// lib/tabs_content/quiz_tab_content.dart
import 'package:flutter/material.dart';
import '../app_view.dart'; // AppScreenとScreenArgumentsのため (もしnavigateToで使うなら)
import '../quiz_setup_screen.dart';
import '../review_service.dart';

class QuizTabContent extends StatelessWidget {
  // navigateToコールバックを受け取るためのfinal変数を追加
  final Function(AppScreen screen, {ScreenArguments? args})? navigateTo;
  final ReviewMode mode;

  // コンストラクタでnavigateToを受け取るように修正 (任意パラメータとして)
  const QuizTabContent({Key? key, this.navigateTo, required this.mode})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return QuizSetupScreen(mode: mode);
  }
}
