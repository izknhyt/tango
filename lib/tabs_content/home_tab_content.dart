// lib/tabs_content/home_tab_content.dart (旧 home_tab_page.dart から修正)
import 'package:flutter/material.dart';
import '../app_view.dart'; // AppScreen enum のため

class HomeTabContent extends StatelessWidget {
  final Function(AppScreen, {ScreenArguments? args}) navigateTo;

  const HomeTabContent({Key? key, required this.navigateTo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Scaffold や AppBar はありません
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('ホーム画面コンテンツ', style: TextStyle(fontSize: 20)),
          SizedBox(height: 20),
          // ElevatedButton(
          //   onPressed: () {
          //     // 例：設定画面に遷移する場合
          //     // navigateTo(AppScreen.settings);
          //   },
          //   child: Text("設定へ（仮）"),
          // )
        ],
      ),
    );
  }
}
