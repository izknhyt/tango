// lib/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppFontSize { small, medium, large }

class ThemeProvider with ChangeNotifier {
  static const String _isDarkModeKey = 'is_dark_mode';
  bool _isDarkMode = false;

  static const String _fontSizeKey = 'font_size_preference';
  AppFontSize _appFontSize = AppFontSize.medium;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;
  bool get isDarkMode => _isDarkMode;
  AppFontSize get appFontSize => _appFontSize;

  // ThemeProvider のコンストラクタでは初期読み込みをトリガーしないように変更も可能ですが、
  // そのままにしておいても、main での await が優先されるため大きな問題はありません。
  // ここではコンストラクタはそのままにしておきます。
  ThemeProvider() {
    // _loadThemePreference(); // main で await するので、ここでは呼ばなくてもOK
    // _loadFontSizePreference(); // または、呼ばれても問題ない
  }

  // 設定をまとめて読み込む公開メソッド
  Future<void> loadAppPreferences() async {
    await _loadThemePreference();
    await _loadFontSizePreference();
    // 注意: ここで notifyListeners() を呼ぶ必要はありません。
    // なぜなら、このメソッドは runApp の前に呼ばれ、
    // MaterialApp がビルドされる際には既に正しい値がセットされているためです。
    // 各 _loadXXXPreference メソッド内の notifyListeners() は、
    // アプリ実行中に何らかの理由で再読み込みするようなケースでは有効です。
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_isDarkModeKey) ?? false;
    notifyListeners();
  }

  Future<void> _saveThemePreference(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isDarkModeKey, isDark);
  }

  Future<void> toggleThemeBySwitch(bool isDarkEnabled) async {
    if (_isDarkMode == isDarkEnabled) return;
    _isDarkMode = isDarkEnabled;
    await _saveThemePreference(_isDarkMode);
    notifyListeners();
  }

  Future<void> _loadFontSizePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final fontSizeString = prefs.getString(_fontSizeKey);
    if (fontSizeString == 'small') {
      _appFontSize = AppFontSize.small;
    } else if (fontSizeString == 'large') {
      _appFontSize = AppFontSize.large;
    } else {
      _appFontSize = AppFontSize.medium;
    }
    notifyListeners();
  }

  Future<void> setAppFontSize(AppFontSize size) async {
    if (_appFontSize == size) return;
    _appFontSize = size;
    final prefs = await SharedPreferences.getInstance();
    String sizeString;
    switch (size) {
      case AppFontSize.small:
        sizeString = 'small';
        break;
      case AppFontSize.medium:
        sizeString = 'medium';
        break;
      case AppFontSize.large:
        sizeString = 'large';
        break;
    }
    await prefs.setString(_fontSizeKey, sizeString);
    notifyListeners();
  }

  double get textScaleFactor {
    switch (_appFontSize) {
      case AppFontSize.small:
        return 0.85;
      case AppFontSize.medium:
        return 1.0;
      case AppFontSize.large:
        return 1.15;
      default:
        return 1.0;
    }
  }
}

final themeProvider = ChangeNotifierProvider<ThemeProvider>((ref) {
  return ThemeProvider();
});
