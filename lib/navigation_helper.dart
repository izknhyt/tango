import 'app_view.dart';

/// Convenience methods to convert between [AppScreen] and bottom navigation
/// indices.
extension AppScreenNavigation on AppScreen {
  static const Map<AppScreen, int> _toIndex = {
    AppScreen.home: 0,
    AppScreen.wordList: 1,
    AppScreen.favorites: 2,
    AppScreen.history: 3,
    AppScreen.quiz: 4,
    AppScreen.wordDetail: 1,
    AppScreen.wordbook: 2,
    AppScreen.todaySummary: 0,
    AppScreen.learningHistoryDetail: 0,
    AppScreen.about: 0,
  };

  /// Returns the bottom navigation index for this screen.
  int toNavIndex(int currentIndex) =>
      this == AppScreen.settings ? currentIndex : _toIndex[this] ?? currentIndex;

  static const Map<int, AppScreen> _fromIndex = {
    0: AppScreen.home,
    1: AppScreen.wordList,
    2: AppScreen.wordbook,
    3: AppScreen.history,
    4: AppScreen.quiz,
  };

  /// Returns the [AppScreen] for the given bottom navigation index.
  static AppScreen fromIndex(int index) =>
      _fromIndex[index] ?? AppScreen.home;
}

AppScreen appScreenFromIndex(int index) =>
    AppScreenNavigation.fromIndex(index);

int indexFromAppScreen(AppScreen screen, int currentIndex) =>
    screen.toNavIndex(currentIndex);
