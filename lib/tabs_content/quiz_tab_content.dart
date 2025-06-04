// lib/tabs_content/quiz_tab_content.dart
import 'package:flutter/material.dart';
import '../app_view.dart'; // AppScreenとScreenArgumentsのため (もしnavigateToで使うなら)
import '../quiz_setup_screen.dart';

class QuizTabContent extends StatelessWidget {
  // navigateToコールバックを受け取るためのfinal変数を追加
  final Function(AppScreen screen, {ScreenArguments? args})? navigateTo;

  // コンストラクタでnavigateToを受け取るように修正 (任意パラメータとして)
  const QuizTabContent({Key? key, this.navigateTo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const QuizSetupScreen();
  }
}
