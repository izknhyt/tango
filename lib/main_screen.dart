// lib/main_screen.dart

import 'package:flutter/material.dart';
import 'app_view.dart'; // AppScreen enum と ScreenArguments クラス
import 'flashcard_model.dart'; // Flashcard モデル

// 各タブや詳細画面の「コンテンツ」ウィジェットをインポート
import 'tabs_content/home_tab_content.dart';
import 'tabs_content/word_list_tab_content.dart';
import 'tabs_content/favorites_tab_content.dart';
import 'tabs_content/history_tab_content.dart';
import 'tabs_content/quiz_tab_content.dart';
import 'tabs_content/settings_tab_content.dart'; // 設定画面コンテンツ
import 'word_detail_content.dart'; // 詳細表示用コンテンツウィジェット

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _bottomNavIndex = 0;
  AppScreen _currentScreen = AppScreen.home;
  ScreenArguments? _currentArguments;

  String _getAppBarTitle() {
    switch (_currentScreen) {
      case AppScreen.home:
        return 'ホーム';
      case AppScreen.wordList:
        return '単語一覧';
      case AppScreen.wordDetail:
        return _currentArguments?.flashcard?.term ?? '単語詳細';
      case AppScreen.favorites:
        return 'お気に入り';
      case AppScreen.history:
        return '閲覧履歴';
      case AppScreen.quiz:
        return 'クイズ';
      case AppScreen.settings:
        return '設定';
    }
  }

  Widget _buildCurrentScreenContent() {
    switch (_currentScreen) {
      case AppScreen.home:
        return HomeTabContent(
          key: const ValueKey("HomeTabContent"),
          navigateTo: _navigateTo,
        );
      case AppScreen.wordList:
        return WordListTabContent(
          key: const ValueKey("WordListTabContent"),
          onWordTap: (flashcard) {
            _navigateTo(
              AppScreen.wordDetail,
              args: ScreenArguments(flashcard: flashcard),
            );
          },
        );
      case AppScreen.wordDetail:
        if (_currentArguments?.flashcard != null) {
          return WordDetailContent(
              key: ValueKey(_currentArguments!.flashcard!.id),
              flashcard: _currentArguments!.flashcard!);
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _navigateTo(AppScreen.wordList);
          }
        });
        return const Center(child: Text("単語情報がありません。一覧に戻ります..."));
      case AppScreen.favorites:
        return FavoritesTabContent(
          key: const ValueKey("FavoritesTabContent"),
          navigateTo: _navigateTo,
        );
      case AppScreen.history:
        return HistoryTabContent(
          key: const ValueKey("HistoryTabContent"),
          navigateTo: _navigateTo,
        );
      case AppScreen.quiz:
        return QuizTabContent(
          // ★ navigateTo を渡す
          key: const ValueKey("QuizTabContent"),
          navigateTo: _navigateTo,
        );
      case AppScreen.settings:
        return SettingsTabContent(
          key: const ValueKey("SettingsTabContent"),
          onClose: () {
            _navigateTo(_mapBottomNavIndexToAppScreen(_bottomNavIndex));
          },
        );
    }
  }

  void _onBottomNavItemTapped(int index) {
    if (_bottomNavIndex == index &&
        _currentScreen == _mapBottomNavIndexToAppScreen(index) &&
        _currentScreen != AppScreen.wordDetail &&
        _currentScreen != AppScreen.settings) {
      return;
    }
    setState(() {
      _bottomNavIndex = index;
      _currentScreen = _mapBottomNavIndexToAppScreen(index);
      _currentArguments = null;
    });
  }

  AppScreen _mapBottomNavIndexToAppScreen(int index) {
    switch (index) {
      case 0:
        return AppScreen.home;
      case 1:
        return AppScreen.wordList;
      case 2:
        return AppScreen.favorites;
      case 3:
        return AppScreen.history;
      case 4:
        return AppScreen.quiz;
      default:
        return AppScreen.home;
    }
  }

  int _mapAppScreenToBottomNavIndex(AppScreen screen) {
    switch (screen) {
      case AppScreen.home:
        return 0;
      case AppScreen.wordList:
        return 1;
      case AppScreen.favorites:
        return 2;
      case AppScreen.history:
        return 3;
      case AppScreen.quiz:
        return 4;
      case AppScreen.wordDetail:
        return 1;
      case AppScreen.settings:
        return _bottomNavIndex; // 設定画面の場合は元のタブを維持
      default:
        return _bottomNavIndex;
    }
  }

  void _navigateTo(AppScreen screen, {ScreenArguments? args}) {
    if (!mounted) return;
    setState(() {
      _currentScreen = screen;
      _currentArguments = args;
      _bottomNavIndex = _mapAppScreenToBottomNavIndex(screen);
    });
  }

  final Color _selectedItemBackgroundColor = const Color(0x33FFFF00);

  Widget _buildActiveIcon(IconData icon, BuildContext context, int itemIndex) {
    bool isSelected = (_bottomNavIndex == itemIndex);
    if (_currentScreen == AppScreen.wordDetail && itemIndex == 1) {
      //単語詳細のときは単語一覧を選択状態
      isSelected = true;
    } else if ((_currentScreen == AppScreen.settings ||
            _currentScreen == AppScreen.wordDetail) &&
        _bottomNavIndex != itemIndex) {
      // 詳細画面や設定画面で、その親タブ以外は非選択にする
      if (!(_currentScreen == AppScreen.wordDetail &&
          itemIndex == _mapAppScreenToBottomNavIndex(AppScreen.wordList))) {
        isSelected = false;
      }
    }

    final Color iconColor = isSelected
        ? Theme.of(context).bottomNavigationBarTheme.selectedItemColor ??
            Theme.of(context).colorScheme.primary
        : Theme.of(context).bottomNavigationBarTheme.unselectedItemColor ??
            Colors.grey[700]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? _selectedItemBackgroundColor : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(icon, color: iconColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool canGoBack = _currentScreen == AppScreen.wordDetail ||
        _currentScreen == AppScreen.settings;
    AppScreen screenToNavigateBack =
        _mapBottomNavIndexToAppScreen(_bottomNavIndex); // デフォルトは現在のタブのトップ
    if (_currentScreen == AppScreen.wordDetail) {
      screenToNavigateBack = AppScreen.wordList;
    } else if (_currentScreen == AppScreen.settings) {
      // 設定画面から戻る場合は、最後にアクティブだったボトムナビのタブ、または固定でホームなど
      screenToNavigateBack = _mapBottomNavIndexToAppScreen(_bottomNavIndex);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        leading: canGoBack
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  _navigateTo(screenToNavigateBack);
                },
              )
            : null,
        actions: [
          if (_currentScreen != AppScreen.settings)
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: '設定',
              onPressed: () {
                _navigateTo(AppScreen.settings);
              },
            ),
        ],
      ),
      body: _buildCurrentScreenContent(),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: _buildActiveIcon(Icons.home, context, 0),
            label: 'ホーム',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.list_alt_outlined),
            activeIcon: _buildActiveIcon(Icons.list_alt, context, 1),
            label: '単語一覧',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.star_border_outlined),
            activeIcon: _buildActiveIcon(Icons.star, context, 2),
            label: 'お気に入り',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.history_outlined),
            activeIcon: _buildActiveIcon(Icons.history, context, 3),
            label: '履歴',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.quiz_outlined),
            activeIcon: _buildActiveIcon(Icons.quiz, context, 4),
            label: 'クイズ',
          ),
        ],
        currentIndex: _bottomNavIndex,
        onTap: _onBottomNavItemTapped,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
    );
  }
}
