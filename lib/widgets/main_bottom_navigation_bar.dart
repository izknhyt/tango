import 'package:flutter/material.dart';

class MainBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Widget Function(IconData, BuildContext, int) activeIconBuilder;

  const MainBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.activeIconBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home_outlined),
          activeIcon: activeIconBuilder(Icons.home, context, 0),
          label: 'ホーム',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.list_alt_outlined),
          activeIcon: activeIconBuilder(Icons.list_alt, context, 1),
          label: '単語一覧',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.menu_book_outlined),
          activeIcon: activeIconBuilder(Icons.menu_book, context, 2),
          label: '単語帳',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.history_outlined),
          activeIcon: activeIconBuilder(Icons.history, context, 3),
          label: '履歴',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.quiz_outlined),
          activeIcon: activeIconBuilder(Icons.quiz, context, 4),
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
