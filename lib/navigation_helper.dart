import 'app_view.dart';

AppScreen appScreenFromIndex(int index) {
  switch (index) {
    case 0:
      return AppScreen.home;
    case 1:
      return AppScreen.wordList;
    case 2:
      return AppScreen.wordbook;
    case 3:
      return AppScreen.history;
    case 4:
      return AppScreen.quiz;
    default:
      return AppScreen.home;
  }
}

int indexFromAppScreen(AppScreen screen, int currentIndex) {
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
    case AppScreen.wordbook:
      return 2;
    case AppScreen.todaySummary:
    case AppScreen.learningHistoryDetail:
    case AppScreen.about:
      return 0;
    case AppScreen.settings:
      return currentIndex;
  }
}
