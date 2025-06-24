// lib/main_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_view.dart'; // AppScreen enum と ScreenArguments クラス
import 'flashcard_model.dart'; // Flashcard モデル

// 各タブや詳細画面の「コンテンツ」ウィジェットをインポート
import 'tabs_content/home_tab_content.dart';
import 'tabs_content/word_list_tab_content.dart';
import 'tabs_content/favorites_tab_content.dart';
import 'tabs_content/history_tab_content.dart';
import 'tabs_content/quiz_tab_content.dart';
import 'tabs_content/settings_tab_content.dart'; // 設定画面コンテンツ
import 'learning_history_detail_screen.dart';
import 'about_screen.dart';
import 'today_summary_screen.dart';
import 'review_service.dart';
import 'review_mode_ext.dart';
import 'word_detail_content.dart'; // 詳細表示用コンテンツウィジェット
import 'word_detail_controller.dart';
import 'word_list_query.dart';
import 'sort_type_ext.dart';
import 'overflow_menu.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({Key? key}) : super(key: key);
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _bottomNavIndex = 0;
  AppScreen _currentScreen = AppScreen.home;
  ScreenArguments? _currentArguments;
  final WordDetailController _detailController = WordDetailController();
  final GlobalKey<WordListTabContentState> _wordListKey =
      GlobalKey<WordListTabContentState>();
  ReviewMode _reviewMode = ReviewMode.random;

  String _getAppBarTitle() {
    switch (_currentScreen) {
      case AppScreen.home:
        return 'ホーム';
      case AppScreen.wordList:
        return '単語一覧';
      case AppScreen.wordDetail:
        final current = _detailController.currentFlashcard;
        if (current != null) {
          return current.term;
        }
        if (_currentArguments?.flashcards != null &&
            _currentArguments?.initialIndex != null) {
          final list = _currentArguments!.flashcards!;
          final index = _currentArguments!.initialIndex!;
          if (index >= 0 && index < list.length) {
            return list[index].term;
          }
        }
        return '単語詳細';
      case AppScreen.favorites:
        return 'お気に入り';
      case AppScreen.history:
        return '閲覧履歴';
      case AppScreen.quiz:
        return 'クイズ';
      case AppScreen.todaySummary:
        return '今日の学習サマリー';
      case AppScreen.learningHistoryDetail:
        return '学習履歴詳細';
      case AppScreen.about:
        return 'このアプリについて';
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
          key: _wordListKey,
          onWordTap: (flashcards, index) {
            _navigateTo(
              AppScreen.wordDetail,
              args: ScreenArguments(
                  flashcards: flashcards, initialIndex: index),
            );
          },
        );
      case AppScreen.wordDetail:
        if (_currentArguments?.flashcards != null &&
            _currentArguments?.initialIndex != null) {
          final list = _currentArguments!.flashcards!;
          final index = _currentArguments!.initialIndex!;
          return WordDetailContent(
            key: ValueKey('${list[index].id}_$index'),
            flashcards: list,
            initialIndex: index,
            controller: _detailController,
          );
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
          mode: _reviewMode,
        );
      case AppScreen.todaySummary:
        return TodaySummaryScreen(
          key: const ValueKey('TodaySummaryScreen'),
          navigateTo: _navigateTo,
        );
      case AppScreen.learningHistoryDetail:
        return const LearningHistoryDetailScreen(key: ValueKey('LearningHistoryDetail'));
      case AppScreen.about:
        return const AboutScreen();
      case AppScreen.settings:
        return const SettingsTabContent(key: ValueKey("SettingsTabContent"));
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
      case AppScreen.todaySummary:
        return 0;
      case AppScreen.wordDetail:
        return 1;
      case AppScreen.learningHistoryDetail:
        return 0;
      case AppScreen.about:
        return 0;
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

  Color _selectedItemBackgroundColor(BuildContext context) {
    return Theme.of(context)
        .colorScheme
        .secondary
        .withOpacity(0.2);
  }



  Widget _buildActiveIcon(IconData icon, BuildContext context, int itemIndex) {
    bool isSelected = (_bottomNavIndex == itemIndex);
    if (_currentScreen == AppScreen.wordDetail && itemIndex == 1) {
      //単語詳細のときは単語一覧を選択状態
      isSelected = true;
    } else if ((_currentScreen == AppScreen.settings ||
            _currentScreen == AppScreen.wordDetail ||
            _currentScreen == AppScreen.learningHistoryDetail ||
            _currentScreen == AppScreen.about) &&
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
            Theme.of(context).colorScheme.outline;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color:
            isSelected ? _selectedItemBackgroundColor(context) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(icon, color: iconColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final words = ref.watch(wordListForModeProvider);
    final query = ref.watch(currentQueryProvider);
    final filtered =
        words != null ? query.apply(words) : <Flashcard>[];

    bool canGoBack = _currentScreen == AppScreen.wordDetail ||
        _currentScreen == AppScreen.settings ||
        _currentScreen == AppScreen.learningHistoryDetail ||
        _currentScreen == AppScreen.todaySummary ||
        _currentScreen == AppScreen.about;
    AppScreen screenToNavigateBack =
        _mapBottomNavIndexToAppScreen(_bottomNavIndex); // デフォルトは現在のタブのトップ
    if (_currentScreen == AppScreen.wordDetail) {
      screenToNavigateBack = AppScreen.wordList;
    } else if (_currentScreen == AppScreen.settings) {
      // 設定画面から戻る場合は、最後にアクティブだったボトムナビのタブ、または固定でホームなど
      screenToNavigateBack = _mapBottomNavIndexToAppScreen(_bottomNavIndex);
    } else if (_currentScreen == AppScreen.learningHistoryDetail ||
        _currentScreen == AppScreen.todaySummary) {
      screenToNavigateBack = AppScreen.home;
    } else if (_currentScreen == AppScreen.about) {
      screenToNavigateBack = AppScreen.home;
    }

    return Scaffold(
      appBar: AppBar(
        title: _currentScreen == AppScreen.wordList
            ? PopupMenuButton<SortType>(
                initialValue: query.sort,
                onSelected: (v) {
                  ref.read(currentQueryProvider.notifier).state =
                      query.copyWith(sort: v);
                },
                itemBuilder: (context) => SortType.values
                    .map((m) => PopupMenuItem(
                          value: m,
                          child: Text(m.label),
                        ))
                    .toList(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(query.sort.label),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              )
            : AnimatedBuilder(
                animation: _detailController,
                builder: (context, _) {
                  final baseTitle = _getAppBarTitle();
                  if (_currentScreen == AppScreen.wordList && words != null) {
                    return Text(
                        '$baseTitle (${filtered.length} / ${words.length} 件)');
                  }
                  return Text(baseTitle);
                },
              ),
        leadingWidth: _currentScreen == AppScreen.wordDetail ? 96 : null,
        leading: _currentScreen == AppScreen.wordDetail
            ? AnimatedBuilder(
                animation: _detailController,
                builder: (context, _) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: _detailController.canGoBack
                            ? () {
                                _detailController.back();
                              }
                            : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: _detailController.canGoForward
                            ? () {
                                _detailController.forward();
                              }
                            : null,
                      ),
                    ],
                  );
                },
              )
            : (canGoBack
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      _navigateTo(screenToNavigateBack);
                    },
                  )
                : null),
        actions: [
          if (_currentScreen == AppScreen.wordList || _currentScreen == AppScreen.quiz)
            DropdownButtonHideUnderline(
              child: DropdownButton<ReviewMode>(
                value: _reviewMode,
                icon: const Icon(Icons.arrow_drop_down),
                onChanged: (mode) {
                  if (mode == null) return;
                  setState(() {
                    _reviewMode = mode;
                  });
                  _wordListKey.currentState?.updateMode(mode);
                },
                items: ReviewMode.values
                    .map((m) => DropdownMenuItem(
                          value: m,
                          child: Text(m.label),
                        ))
                    .toList(),
              ),
            ),
          if (_currentScreen == AppScreen.wordList)
            OverflowMenu(
              onOpenSheet: () {
                _wordListKey.currentState?.openFilterSheet(context);
              },
            ),
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
