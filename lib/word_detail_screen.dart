// lib/word_detail_screen.dart

import 'package:flutter/material.dart';
import 'flashcard_model.dart'; // 作成したFlashcardモデルをインポート
import 'package:hive/hive.dart';
import 'star_color.dart';
import 'constants.dart';

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
          _favoriteStatus[StarColor.yellow] = stored['yellow'] as bool? ?? false;
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

  Widget _buildStarIcon(StarColor colorKey, Color color) {
    bool isFavorite = _favoriteStatus[colorKey]!;
    return IconButton(
      icon: Icon(
        isFavorite ? Icons.star : Icons.star_border,
        color:
            isFavorite ? color : Theme.of(context).colorScheme.outline, // 非選択時は薄い色
        size: 28, // アイコンサイズ調整
      ),
      onPressed: () => _toggleFavorite(colorKey),
      tooltip: colorKey == StarColor.red
          ? '赤星 (未学習など)'
          : colorKey == StarColor.yellow
              ? '黄星 (自信なしなど)'
              : '青星 (習得済みなど)', // ツールチップで色の意味を示唆
    );
  }

  Widget _buildDetailItem(BuildContext context, String label, String? value) {
    if (value == null ||
        value.isEmpty ||
        value.toLowerCase() == 'nan' ||
        value == 'ー') {
      return SizedBox.shrink();
    }
    // JSON内の \n を実際の改行に変換
    final displayValue = value.replaceAllMapped(
      RegExp(r'\\n'),
      (match) => '\n',
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            displayValue,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.5,
                  color: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.color
                      ?.withOpacity(0.85),
                ),
          ),
        ],
      ),
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
                    _buildStarIcon(
                        StarColor.red, Theme.of(context).colorScheme.error),
                    _buildStarIcon(
                        StarColor.yellow, Theme.of(context).colorScheme.secondary),
                    _buildStarIcon(
                        StarColor.blue, Theme.of(context).colorScheme.primary),
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
            _buildDetailItem(
              context,
              '重要度:',
              "★" * card.importance.toInt() +
                  (card.importance - card.importance.toInt() > 0.0 ? "☆" : "") +
                  " (${card.importance.toStringAsFixed(1)})",
            ),
            _buildDetailItem(context, 'カテゴリー:', categories),
            Divider(height: 24, thickness: 0.8),
            _buildDetailItem(context, '概要 (Description):', card.description),
            _buildDetailItem(context, '解説 (Practical Tip):', card.practicalTip),
            _buildDetailItem(context, '出題例 (Exam Example):', card.examExample),
            _buildDetailItem(context, '試験ポイント (Exam Point):', card.examPoint),
            _buildDetailItem(
              context,
              '関連用語 (Related Terms):',
              card.relatedIds?.join('、'),
            ), // 区切り文字を読点に変更
          ],
        ),
      ),
    );
  }
}
