// lib/tabs_content/settings_tab_content.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider_pkg;
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import '../theme_provider.dart';
import '../theme_mode_provider.dart';
import '../analytics_provider.dart';

class SettingsTabContent extends ConsumerStatefulWidget {
  const SettingsTabContent({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsTabContent> createState() => _SettingsTabContentState();
}

class _SettingsTabContentState extends ConsumerState<SettingsTabContent> {
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
    final themeProvider = provider_pkg.Provider.of<ThemeProvider>(context);
    final mode = ref.watch(themeModeProvider);
    final notifier = ref.read(themeModeProvider.notifier);
    final analyticsEnabled = ref.watch(analyticsProvider);
    final analyticsNotifier = ref.read(analyticsProvider.notifier);
    // 現在の文字サイズを ThemeProvider から取得
    AppFontSize currentAppFontSize = themeProvider.appFontSize;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: <Widget>[
        // --- テーマ設定 ---
        ListTile(
          leading: const Icon(Icons.brightness_auto),
          title: Text('システムに合わせる',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w500)),
          trailing: Radio<ThemeMode>(
            value: ThemeMode.system,
            groupValue: mode,
            onChanged: (m) => notifier.toggle(m!),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.light_mode),
          title: Text('ライト',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w500)),
          trailing: Radio<ThemeMode>(
            value: ThemeMode.light,
            groupValue: mode,
            onChanged: (m) => notifier.toggle(m!),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.dark_mode),
          title: Text('ダーク',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w500)),
          trailing: Radio<ThemeMode>(
            value: ThemeMode.dark,
            groupValue: mode,
            onChanged: (m) => notifier.toggle(m!),
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
        SwitchListTile(
          title: const Text('Analytics'),
          value: analyticsEnabled,
          onChanged: (val) async {
            await analyticsNotifier.setEnabled(val);
          },
        ),
        if (!kReleaseMode)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: ElevatedButton(
              onPressed: () {
                FirebaseCrashlytics.instance.crash();
              },
              child: const Text('Send test crash'),
            ),
          ),
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
                    provider_pkg.Provider.of<ThemeProvider>(context,
                            listen: false)
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
