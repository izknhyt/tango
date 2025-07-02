import 'package:flutter/material.dart';

import '../app_view.dart';
import '../word_detail_content.dart';
import '../word_detail_controller.dart';

class WordDetailContentWrapper extends StatelessWidget {
  final ScreenArguments? arguments;
  final WordDetailController controller;
  final void Function(AppScreen, {ScreenArguments? args}) navigateTo;

  const WordDetailContentWrapper({
    super.key,
    required this.arguments,
    required this.controller,
    required this.navigateTo,
  });

  @override
  Widget build(BuildContext context) {
    if (arguments?.flashcards != null && arguments?.initialIndex != null) {
      final list = arguments!.flashcards!;
      final index = arguments!.initialIndex!;
      return WordDetailContent(
        key: ValueKey('${list[index].id}_$index'),
        flashcards: list,
        initialIndex: index,
        controller: controller,
      );
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigateTo(AppScreen.wordList);
    });
    return const Center(
      child: Text('単語情報がありません。一覧に戻ります...'),
    );
  }
}
