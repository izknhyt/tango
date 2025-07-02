import 'package:flutter/material.dart';

import '../app_view.dart';
import '../navigation_helper.dart';

class MainNavigationBar extends StatelessWidget {
  final int currentIndex;
  final AppScreen currentScreen;
  final ValueChanged<int> onTap;

  const MainNavigationBar({
    super.key,
    required this.currentIndex,
    required this.currentScreen,
    required this.onTap,
  });

  Color _selectedItemBackgroundColor(BuildContext context) {
    return Theme.of(context).colorScheme.secondary.withOpacity(0.2);
  }

  Widget _buildActiveIcon(IconData icon, BuildContext context, int itemIndex) {
    bool isSelected = currentIndex == itemIndex;
    if (currentScreen == AppScreen.wordDetail && itemIndex == 1) {
      isSelected = true;
    } else if ((currentScreen == AppScreen.settings ||
            currentScreen == AppScreen.wordDetail ||
            currentScreen == AppScreen.learningHistoryDetail ||
            currentScreen == AppScreen.about) &&
        currentIndex != itemIndex) {
      if (!(currentScreen == AppScreen.wordDetail &&
          itemIndex == indexFromAppScreen(AppScreen.wordList, currentIndex))) {
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
    return BottomNavigationBar(
      items: [
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
          icon: const Icon(Icons.menu_book_outlined),
          activeIcon: _buildActiveIcon(Icons.menu_book, context, 2),
          label: '単語帳',
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
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
    );
  }
}
