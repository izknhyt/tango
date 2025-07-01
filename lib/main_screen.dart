// lib/main_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_view.dart'; // AppScreen enum と ScreenArguments クラス
import 'flashcard_model.dart'; // Flashcard モデル

// 各タブや詳細画面の「コンテンツ」ウィジェットをインポート
import 'tabs_content/home_tab_content.dart';
import 'tabs_content/word_list_tab_content.dart';
import 'tabs_content/placeholder_tab_content.dart';
import 'history_screen.dart';
import 'tabs_content/quiz_tab_content.dart';
import 'tabs_content/settings_tab_content.dart'; // 設定画面コンテンツ
import 'learning_history_detail_screen.dart';
import 'about_screen.dart';
import 'today_summary_screen.dart';
import 'review_service.dart';
import 'review_mode_ext.dart';
import 'word_detail_content.dart'; // 詳細表示用コンテンツウィジェット
import 'word_detail_controller.dart';
import 'wordbook_screen.dart';
import 'word_list_query.dart';
import 'overflow_menu.dart';
import 'flashcard_repository.dart';
import 'flashcard_repository_provider.dart';
import 'navigation_helper.dart';
import 'utils/main_screen_utils.dart';
import 'widgets/main_bottom_navigation_bar.dart';

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
  final GlobalKey<WordbookScreenState> _wordbookKey =
      GlobalKey<WordbookScreenState>();
  int _wordbookIndex = 0;
  ReviewMode _reviewMode = ReviewMode.random;


  Widget _buildHomeContent() {
    return HomeTabContent(
      key: const ValueKey('HomeTabContent'),
      navigateTo: _navigateTo,
    );
  }

  Widget _buildWordListContent() {
    return WordListTabContent(
      key: _wordListKey,
      onWordTap: (flashcards, index) {
        _navigateTo(
          AppScreen.wordDetail,
          args: ScreenArguments(
            flashcards: flashcards,
            initialIndex: index,
          ),
        );
      },
    );
  }

  Widget _buildWordDetailContent() {
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
    return const Center(
      child: Text('単語情報がありません。一覧に戻ります...'),
    );
  }

  Widget _buildWordbookContent() {
    if (_currentArguments?.flashcards != null) {
      final list = _currentArguments!.flashcards!;
      return WordbookScreen(
        key: _wordbookKey,
        flashcards: list,
        onIndexChanged: (i) {
          setState(() {
            _wordbookIndex = i;
          });
        },
      );
    }
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildFavoritesContent() {
    return const PlaceholderTabContent(
      key: ValueKey('PlaceholderTabContent'),
    );
  }

  Widget _buildHistoryContent() {
    return const HistoryScreen(key: ValueKey('HistoryScreen'));
  }

  Widget _buildQuizContent() {
    return QuizTabContent(
      key: const ValueKey('QuizTabContent'),
      navigateTo: _navigateTo,
      mode: _reviewMode,
    );
  }

  Widget _buildTodaySummaryContent() {
    return TodaySummaryScreen(
      key: const ValueKey('TodaySummaryScreen'),
      navigateTo: _navigateTo,
    );
  }

  Widget _buildLearningHistoryDetailContent() {
    return const LearningHistoryDetailScreen(
      key: ValueKey('LearningHistoryDetail'),
    );
  }

  Widget _buildAboutContent() {
    return const AboutScreen();
  }

  Widget _buildSettingsContent() {
    return const SettingsTabContent(
      key: ValueKey('SettingsTabContent'),
    );
  }


  Widget _buildCurrentScreenContent() {
    switch (_currentScreen) {
      case AppScreen.home:
        return _buildHomeContent();
      case AppScreen.wordList:
        return _buildWordListContent();
      case AppScreen.wordDetail:
        return _buildWordDetailContent();
      case AppScreen.wordbook:
        return _buildWordbookContent();
      case AppScreen.favorites:
        return _buildFavoritesContent();
      case AppScreen.history:
        return _buildHistoryContent();
      case AppScreen.quiz:
        return _buildQuizContent();
      case AppScreen.todaySummary:
        return _buildTodaySummaryContent();
      case AppScreen.learningHistoryDetail:
        return _buildLearningHistoryDetailContent();
      case AppScreen.about:
        return _buildAboutContent();
      case AppScreen.settings:
        return _buildSettingsContent();
    }
  }

  void _onBottomNavItemTapped(int index) {
    if (_bottomNavIndex == index &&
        _currentScreen == appScreenFromIndex(index) &&
        _currentScreen != AppScreen.wordDetail &&
        _currentScreen != AppScreen.settings) {
      return;
    }
    if (index == 2) {
      ref.read(flashcardRepositoryProvider).loadAll().then((list) {
        if (!mounted) return;
        setState(() {
          _bottomNavIndex = index;
          _currentScreen = AppScreen.wordbook;
          _currentArguments = ScreenArguments(flashcards: list);
        });
      });
      return;
    }
    setState(() {
      _bottomNavIndex = index;
      _currentScreen = appScreenFromIndex(index);
      _currentArguments = null;
    });
  }

  void _navigateTo(AppScreen screen, {ScreenArguments? args}) {
    if (!mounted) return;
    setState(() {
      _currentScreen = screen;
      _currentArguments = args;
      _bottomNavIndex = indexFromAppScreen(screen, _bottomNavIndex);
    });
  }

  Color _selectedItemBackgroundColor(BuildContext context) {
    return Theme.of(context).colorScheme.secondary.withOpacity(0.2);
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
          itemIndex == indexFromAppScreen(AppScreen.wordList, _bottomNavIndex))) {
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
        color: isSelected
            ? _selectedItemBackgroundColor(context)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(icon, color: iconColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final words = ref.watch(wordListForModeProvider);
    final query = ref.watch(currentQueryProvider);
    final filtered = words != null ? query.apply(words) : <Flashcard>[];

    bool canGoBack = _currentScreen == AppScreen.wordDetail ||
        _currentScreen == AppScreen.settings ||
        _currentScreen == AppScreen.learningHistoryDetail ||
        _currentScreen == AppScreen.todaySummary ||
        _currentScreen == AppScreen.about;
    AppScreen screenToNavigateBack =
        appScreenFromIndex(_bottomNavIndex); // デフォルトは現在のタブのトップ
    if (_currentScreen == AppScreen.wordDetail) {
      screenToNavigateBack = AppScreen.wordList;
    } else if (_currentScreen == AppScreen.settings) {
      // 設定画面から戻る場合は、最後にアクティブだったボトムナビのタブ、または固定でホームなど
      screenToNavigateBack = appScreenFromIndex(_bottomNavIndex);
    } else if (_currentScreen == AppScreen.learningHistoryDetail ||
        _currentScreen == AppScreen.todaySummary) {
      screenToNavigateBack = AppScreen.home;
    } else if (_currentScreen == AppScreen.about) {
      screenToNavigateBack = AppScreen.home;
    }

    return Scaffold(
      appBar: AppBar(
        title: AnimatedBuilder(
          animation: _detailController,
          builder: (context, _) {
            final baseTitle =
                getAppBarTitle(_currentScreen, _detailController, _currentArguments);
            if (_currentScreen == AppScreen.wordList && words != null) {
              return Text(
                  '$baseTitle (${filtered.length} / ${words.length} 件)');
            } else if (_currentScreen == AppScreen.wordbook &&
                _currentArguments?.flashcards != null) {
              final total = _currentArguments!.flashcards!.length;
              return Text('$baseTitle (${_wordbookIndex + 1} / $total)');
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
          if (_currentScreen == AppScreen.wordList ||
              _currentScreen == AppScreen.quiz)
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
          if (_currentScreen == AppScreen.wordbook)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                _wordbookKey.currentState?.openSearch();
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
      bottomNavigationBar: MainBottomNavigationBar(
        currentIndex: _bottomNavIndex,
        onTap: _onBottomNavItemTapped,
        activeIconBuilder: _buildActiveIcon,
      ),
    );
  }
}
