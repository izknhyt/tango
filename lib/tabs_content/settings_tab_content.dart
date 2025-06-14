// lib/tabs_content/settings_tab_content.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart'; // lib/theme_provider.dart をインポート

class SettingsTabContent extends StatefulWidget {
  const SettingsTabContent({Key? key}) : super(key: key);

  @override
  _SettingsTabContentState createState() => _SettingsTabContentState();
}

class _SettingsTabContentState extends State<SettingsTabContent> {
  // ローカルの _selectedFontSize String は不要になります。
  // ThemeProvider から直接 AppFontSize を取得・変換して表示します。

  // AppFontSize enum を表示用の文字列に変換するヘルパーメソッド
  String _appFontSizeToString(AppFontSize fontSize) {
    switch (fontSize) {
      case AppFontSize.small:
        return '小';
      case AppFontSize.medium:
        return '中';
      case AppFontSize.large:
        return '大';
    }
  }

  // 表示用の文字列を AppFontSize enum に変換するヘルパーメソッド
  AppFontSize _stringToAppFontSize(String? fontSizeString) {
    switch (fontSizeString) {
      case '小':
        return AppFontSize.small;
      case '大':
        return AppFontSize.large;
      case '中':
      default:
        return AppFontSize.medium;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool currentIsDarkMode = themeProvider.isDarkMode;
    // 現在の文字サイズを ThemeProvider から取得
    AppFontSize currentAppFontSize = themeProvider.appFontSize;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: <Widget>[
        // --- ダークモード設定 ---
        ListTile(
          leading: Icon(
            currentIsDarkMode
                ? Icons.brightness_3_outlined
                : Icons.brightness_7_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text(
            'ダークモード',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w500),
          ),
          trailing: Switch(
            value: currentIsDarkMode,
            onChanged: (bool value) {
              themeProvider.toggleThemeBySwitch(value);
            },
            activeColor: Theme.of(context).colorScheme.primary,
          ),
        ),
        Divider(),

        // --- 文字サイズ設定 ---
        ListTile(
          leading: Icon(
            Icons.format_size,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text(
            '文字サイズ',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w500),
          ),
          // ThemeProvider の状態を表示
          subtitle: Text('現在のサイズ: ${_appFontSizeToString(currentAppFontSize)}'),
          trailing: Icon(Icons.arrow_forward_ios,
              size: 16, color: Theme.of(context).colorScheme.outline),
          onTap: () {
            // ダイアログ表示時に現在の ThemeProvider の値を渡す
            _showFontSizeSelectionDialog(context, currentAppFontSize);
          },
        ),
        Divider(),
        // ... (残りの設定項目)
      ],
    );
  }

  // 文字サイズ選択ダイアログの表示
  void _showFontSizeSelectionDialog(
      BuildContext context, AppFontSize initialFontSize) {
    // context を通じて ThemeProvider を取得 (listen: false で良い場合もあるが、ダイアログ内で即時変更を反映したい場合は listen: true の方が自然か、
    // あるいはダイアログを閉じたときに適用でも良い)
    // ここではダイアログを閉じたときに適用する形とします。
    AppFontSize selectedFontSizeEnum = initialFontSize; // ダイアログ内での一時的な選択状態

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // dialogContext を使用
        return StatefulBuilder(
          // ダイアログ内の状態管理のため StatefulBuilder を使用
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: Text('文字サイズを選択'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: AppFontSize.values.map((AppFontSize value) {
                  // enum の値を直接使用
                  return RadioListTile<AppFontSize>(
                    title: Text(_appFontSizeToString(value)),
                    value: value,
                    groupValue: selectedFontSizeEnum, // ダイアログ内の一時的な選択状態を使用
                    onChanged: (AppFontSize? newValue) {
                      if (newValue != null) {
                        setDialogState(() {
                          // ダイアログのUIを更新
                          selectedFontSizeEnum = newValue;
                        });
                      }
                    },
                    activeColor: Theme.of(dialogContext).colorScheme.primary,
                  );
                }).toList(),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('キャンセル'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
                TextButton(
                  child: Text('適用'),
                  onPressed: () {
                    // ★★★ ThemeProvider の setAppFontSize を呼び出す ★★★
                    Provider.of<ThemeProvider>(context, listen: false)
                        .setAppFontSize(selectedFontSizeEnum);
                    Navigator.of(dialogContext).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
