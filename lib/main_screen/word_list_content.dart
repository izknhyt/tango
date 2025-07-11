import 'package:flutter/material.dart';

import '../flashcard_model.dart';
import '../tabs_content/word_list_tab_content.dart';
import '../app_view.dart';

class WordListContent extends StatelessWidget {
  final GlobalKey<WordListTabContentState> listKey;
  final void Function(AppScreen, {ScreenArguments? args}) navigateTo;

  const WordListContent({
    super.key,
    required this.listKey,
    required this.navigateTo,
  });

  @override
  Widget build(BuildContext context) {
    return WordListTabContent(
      key: listKey,
      onWordTap: (List<Flashcard> cards, int index) {
        navigateTo(
          AppScreen.wordDetail,
          args: ScreenArguments(flashcards: cards, initialIndex: index),
        );
      },
    );
  }
}
