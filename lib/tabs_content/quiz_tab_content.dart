// lib/tabs_content/quiz_tab_content.dart
import 'package:flutter/material.dart';
import '../app_view.dart'; // AppScreenとScreenArgumentsのため (もしnavigateToで使うなら)

class QuizTabContent extends StatelessWidget {
  // navigateToコールバックを受け取るためのfinal変数を追加
  final Function(AppScreen screen, {ScreenArguments? args})? navigateTo;

  // コンストラクタでnavigateToを受け取るように修正 (任意パラメータとして)
  const QuizTabContent({Key? key, this.navigateTo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'クイズ画面 (準備中)',
            style: TextStyle(fontSize: 20),
          ),
          // SizedBox(height: 20),
          // ElevatedButton(
          //   onPressed: () {
          //     if (navigateTo != null) {
          //       // 例: navigateTo!(AppScreen.home); // navigateTo を使った遷移の例
          //     }
          //   },
          //   child: Text("ホームへ（仮）"),
          // ),
        ],
      ),
    );
  }
}
