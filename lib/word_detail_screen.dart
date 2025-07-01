// lib/word_detail_screen.dart

import 'package:flutter/material.dart';
import 'flashcard_model.dart'; // 作成したFlashcardモデルをインポート
import 'package:hive/hive.dart';
import 'star_color.dart';
import 'constants.dart';
import 'widgets/detail_item.dart';
import 'widgets/favorite_star_button.dart';

class WordDetailScreen extends StatefulWidget {
  final Flashcard flashcard;

  const WordDetailScreen({Key? key, required this.flashcard}) : super(key: key);

  @override
  _WordDetailScreenState createState() => _WordDetailScreenState();
}

class _WordDetailScreenState extends State<WordDetailScreen> {
  late Box<Map> _favoritesBox;
  Map<StarColor, bool> _favoriteStatus = {
    StarColor.red: false,
    StarColor.yellow: false,
    StarColor.blue: false,
  };

  @override
  void initState() {
    super.initState();
    _favoritesBox = Hive.box<Map>(favoritesBoxName);
    _loadFavoriteStatus();
  }

  void _loadFavoriteStatus() {
    final String id = widget.flashcard.id;
    if (_favoritesBox.containsKey(id)) {
      final stored = _favoritesBox.get(id);
      if (stored != null) {
        setState(() {
          _favoriteStatus[StarColor.red] = stored['red'] as bool? ?? false;
          _favoriteStatus[StarColor.yellow] =
              stored['yellow'] as bool? ?? false;
          _favoriteStatus[StarColor.blue] = stored['blue'] as bool? ?? false;
        });
      }
    }
  }

  Future<void> _toggleFavorite(StarColor colorKey) async {
    setState(() {
      _favoriteStatus[colorKey] = !_favoriteStatus[colorKey]!;
    });
    await _favoritesBox.put(
      widget.flashcard.id,
      {for (final e in _favoriteStatus.entries) e.key.name: e.value},
    );
  }


  @override
  Widget build(BuildContext context) {
    Flashcard card = widget.flashcard;
    String categories =
        "${card.categoryLarge} > ${card.categoryMedium} > ${card.categorySmall}";
    // categoryItem が重複しない場合や意味のある値の場合のみ追加
    if (card.categoryItem != card.categorySmall &&
        card.categoryItem.isNotEmpty &&
        ![
          "（小分類全体）",
          "[脅威の種類]",
          "[マルウェア・不正プログラム]",
          "nan",
          "ー",
        ].contains(card.categoryItem)) {
      categories += " > ${card.categoryItem}";
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(card.term),
        // backgroundColorはmain.dartのAppBarThemeで設定されているものを使用
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    card.term,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                // 星アイコンを横並びに
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FavoriteStarButton(
                      isFavorite: _favoriteStatus[StarColor.red]!,
                      activeColor: Theme.of(context).colorScheme.error,
                      inactiveColor:
                          Theme.of(context).colorScheme.outline,
                      onPressed: () => _toggleFavorite(StarColor.red),
                      tooltip: '赤星 (未学習など)',
                    ),
                    FavoriteStarButton(
                      isFavorite: _favoriteStatus[StarColor.yellow]!,
                      activeColor: Theme.of(context).colorScheme.secondary,
                      inactiveColor:
                          Theme.of(context).colorScheme.outline,
                      onPressed: () => _toggleFavorite(StarColor.yellow),
                      tooltip: '黄星 (自信なしなど)',
                    ),
                    FavoriteStarButton(
                      isFavorite: _favoriteStatus[StarColor.blue]!,
                      activeColor: Theme.of(context).colorScheme.primary,
                      inactiveColor:
                          Theme.of(context).colorScheme.outline,
                      onPressed: () => _toggleFavorite(StarColor.blue),
                      tooltip: '青星 (習得済みなど)',
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 6),
            if (card.reading.isNotEmpty &&
                card.reading != 'nan' &&
                card.reading != 'ー')
              Text(
                "読み: ${card.reading}",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withOpacity(0.7),
                    ),
              ),
            SizedBox(height: 12),
            DetailItem(
              label: '重要度:',
              value: "★" * card.importance.toInt() +
                  (card.importance - card.importance.toInt() > 0.0 ? '☆' : '') +
                  ' (${card.importance.toStringAsFixed(1)})',
            ),
            DetailItem(label: 'カテゴリー:', value: categories),
            Divider(height: 24, thickness: 0.8),
            DetailItem(label: '概要 (Description):', value: card.description),
            DetailItem(label: '解説 (Practical Tip):', value: card.practicalTip),
            DetailItem(label: '出題例 (Exam Example):', value: card.examExample),
            DetailItem(label: '試験ポイント (Exam Point):', value: card.examPoint),
            DetailItem(
              label: '関連用語 (Related Terms):',
              value: card.relatedIds?.join('、'),
            ), // 区切り文字を読点に変更
          ],
        ),
      ),
    );
  }
}
