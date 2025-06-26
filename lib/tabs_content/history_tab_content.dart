// lib/tabs_content/history_tab_content.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart'; // 日時フォーマット用 (pubspec.yaml に intl パッケージを追加してください)
import '../flashcard_model.dart';
import '../app_view.dart';
import '../history_entry_model.dart'; // 履歴エントリーモデルをインポート
import '../flashcard_repository.dart';
import '../constants.dart';

class HistoryTabContent extends StatefulWidget {
  final Function(AppScreen screen, {ScreenArguments? args}) navigateTo;

  const HistoryTabContent({Key? key, required this.navigateTo})
      : super(key: key);

  @override
  _HistoryTabContentState createState() => _HistoryTabContentState();
}

class _HistoryTabContentState extends State<HistoryTabContent> {
  late Box<HistoryEntry> _historyBox;
  List<Flashcard> _allFlashcards = []; // 全単語リストを保持
  bool _isInitialLoading = true;
  String? _initialError;

  @override
  void initState() {
    super.initState();
    _historyBox = Hive.box<HistoryEntry>(historyBoxName);
    _loadAllFlashcards(); // words.json から全単語を読み込む (お気に入りタブと同様)
  }

  Future<void> _loadAllFlashcards() async {
    if (!mounted) return;
    setState(() {
      _isInitialLoading = true;
      _initialError = null;
    });
    try {
      final loadedCards = await FlashcardRepository.loadAll();
      if (!mounted) return;
      setState(() {
        _allFlashcards = loadedCards;
        _isInitialLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _initialError = '単語データの読み込みに失敗しました。';
        _isInitialLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('単語データを読込中...', style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      );
    }
    if (_initialError != null) {
      return Center(
          child: Text(
        _initialError!,
        style: Theme.of(context)
            .textTheme
            .bodyLarge
            ?.copyWith(color: Theme.of(context).colorScheme.error),
      ));
    }

    // ValueListenableBuilder を使ってHive Boxの変更をリッスン
    return ValueListenableBuilder<Box<HistoryEntry>>(
      valueListenable: _historyBox.listenable(),
      builder: (context, box, _) {
        // Boxのデータから閲覧履歴リストを構築 (タイムスタンプの降順 = 新しい順)
        List<MapEntry<HistoryEntry, Flashcard?>> historyWithFlashcards = [];

        // box.values は Iterable<HistoryEntry>
        List<HistoryEntry> entries = box.values.toList();
        entries.sort((a, b) => b.timestamp.compareTo(a.timestamp)); // 新しい順にソート

        for (var entry in entries) {
          Flashcard? flashcard;
          try {
            flashcard =
                _allFlashcards.firstWhere((card) => card.id == entry.wordId);
          } catch (e) {
            // _allFlashcards に該当単語がない場合 (ほぼありえないが念のため)
            // print('Flashcard for history entry ${entry.wordId} not found.');
          }
          // flashcardが見つからなくても履歴エントリ自体は表示する（IDだけでも）か、
          // あるいはスキップするかは設計次第。ここではflashcardが見つかったもののみリストに追加。
          if (flashcard != null) {
            historyWithFlashcards.add(MapEntry(entry, flashcard));
          }
        }

        if (historyWithFlashcards.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '閲覧履歴はまだありません。\n単語を閲覧するとここに追加されます。',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.outline, height: 1.5),
              ),
            ),
          );
        }

        final List<Flashcard> flashcardList =
            historyWithFlashcards.map((e) => e.value!).toList();

        return ListView.builder(
          itemCount: historyWithFlashcards.length,
          itemBuilder: (context, index) {
            final historyEntry = historyWithFlashcards[index].key;
            final flashcard =
                historyWithFlashcards[index].value!; // nullチェックは上で済んでいる想定

            // 日時フォーマット (intlパッケージが必要)
            final String formattedTimestamp =
                DateFormat('yyyy/MM/dd HH:mm').format(historyEntry.timestamp);

            return Card(
              elevation: 1.0,
              margin:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                title: Text(
                  flashcard.term,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Text(
                  "閲覧日時: $formattedTimestamp",
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Theme.of(context).colorScheme.outline),
                ),
                trailing: Icon(Icons.arrow_forward_ios,
                    size: 14, color: Theme.of(context).colorScheme.outline),
                onTap: () {
                  widget.navigateTo(
                    AppScreen.wordDetail,
                    args: ScreenArguments(
                      flashcards: flashcardList,
                      initialIndex: index,
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
