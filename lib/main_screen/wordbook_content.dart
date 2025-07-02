import 'package:flutter/material.dart';

import '../app_view.dart';
import '../wordbook_screen.dart';

class WordbookContent extends StatelessWidget {
  final ScreenArguments? arguments;
  final GlobalKey<WordbookScreenState> wordbookKey;
  final ValueChanged<int> onIndexChanged;

  const WordbookContent({
    super.key,
    required this.arguments,
    required this.wordbookKey,
    required this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (arguments?.flashcards != null) {
      final list = arguments!.flashcards!;
      return WordbookScreen(
        key: wordbookKey,
        flashcards: list,
        onIndexChanged: onIndexChanged,
      );
    }
    return const Center(child: CircularProgressIndicator());
  }
}
