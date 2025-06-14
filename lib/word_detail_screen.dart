// lib/word_detail_screen.dart

import 'package:flutter/material.dart';
import 'flashcard_model.dart'; // 作成したFlashcardモデルをインポート

class WordDetailScreen extends StatefulWidget {
  final Flashcard flashcard;

  const WordDetailScreen({Key? key, required this.flashcard}) : super(key: key);

  @override
  _WordDetailScreenState createState() => _WordDetailScreenState();
}

class _WordDetailScreenState extends State<WordDetailScreen> {
  Map<String, bool> _favoriteStatus = {
    'red': false,
    'yellow': false,
    'blue': false,
  };

  @override
  void initState() {
    super.initState();
    // TODO: 本来はここでHiveなどから永続化されたお気に入り状態を読み込む
    // 例: _loadFavoriteStatus();
  }

  void _toggleFavorite(String colorKey) {
    setState(() {
      _favoriteStatus[colorKey] = !_favoriteStatus[colorKey]!;
      // TODO: ここでHiveにお気に入り状態を保存する処理を後で追加します
      print(
        "${widget.flashcard.term} - $colorKey star toggled to ${_favoriteStatus[colorKey]}",
      );
    });
  }

  Widget _buildStarIcon(String colorKey, Color color) {
    bool isFavorite = _favoriteStatus[colorKey]!;
    return IconButton(
      icon: Icon(
        isFavorite ? Icons.star : Icons.star_border,
        color: isFavorite ? color : Colors.grey[400], // 非選択時は少し薄いグレー
        size: 28, // アイコンサイズ調整
      ),
      onPressed: () => _toggleFavorite(colorKey),
      tooltip: colorKey == 'red'
          ? '赤星 (未学習など)'
          : colorKey == 'yellow'
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
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            displayValue,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Theme.of(
                context,
              ).textTheme.bodyLarge?.color?.withOpacity(0.85),
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

    return SingleChildScrollView(
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
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                ),
                // 星アイコンを横並びに
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildStarIcon('red', Colors.redAccent),
                    _buildStarIcon('yellow', Colors.orangeAccent),
                    _buildStarIcon('blue', Colors.blueAccent),
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
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withOpacity(0.7),
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
              card.relatedTerms?.join('、'),
            ), // 区切り文字を読点に変更
          ],
        ),
      ),
    );
  }
}
