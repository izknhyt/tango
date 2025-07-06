// lib/app_view.dart

import 'flashcard_model.dart'; // Flashcardモデルが必要
import 'models/word_deck.dart';

enum AppScreen {
  home,
  wordList,
  wordDetail, // 単語詳細ビュー
  wordbook,
  wordbookLibrary,
  favorites,
  history,
  quiz,
  todaySummary,
  learningHistoryDetail,
  about,
  settings, // 設定画面も追加する場合
}

// AppScreen と一緒に渡すことができる引数クラス (必要に応じて拡張)
class ScreenArguments {
  final Flashcard? flashcard;
  final List<Flashcard>? flashcards;
  final int? initialIndex;
  final List<WordDeck>? decks;

  // 他にも引数が必要ならここに追加

  ScreenArguments({
    this.flashcard,
    this.flashcards,
    this.initialIndex,
    this.decks,
  });
}
