import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'flashcard_model.dart';
import 'history_entry_model.dart';

const String historyBoxName = 'history_box_v2';
const String quizStatsBoxName = 'quiz_stats_box_v1';

class TodaySummaryScreen extends StatefulWidget {
  const TodaySummaryScreen({Key? key}) : super(key: key);

  @override
  State<TodaySummaryScreen> createState() => _TodaySummaryScreenState();
}

class _TodaySummaryScreenState extends State<TodaySummaryScreen> {
  late Box<HistoryEntry> _historyBox;
  late Box<Map> _quizStatsBox;
  List<Flashcard> _allFlashcards = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _historyBox = Hive.box<HistoryEntry>(historyBoxName);
    _quizStatsBox = Hive.box<Map>(quizStatsBoxName);
    _loadAllFlashcards();
  }

  Future<void> _loadAllFlashcards() async {
    try {
      final jsonString =
          await DefaultAssetBundle.of(context).loadString('assets/words.json');
      final List<dynamic> jsonData = json.decode(jsonString) as List<dynamic>;
      List<Flashcard> cards = [];
      for (var item in jsonData) {
        if (item is Map<String, dynamic> &&
            item['id'] != null &&
            item['term'] != null) {
          try {
            cards.add(Flashcard.fromJson(item));
          } catch (_) {}
        }
      }
      if (!mounted) return;
      setState(() {
        _allFlashcards = cards;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = '単語データの読み込みに失敗しました。';
        _isLoading = false;
      });
    }
  }

  Set<String> _todayLearnedIds(Box<HistoryEntry> box) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    return box.values
        .where((e) => e.timestamp.isAfter(start) && e.timestamp.isBefore(end))
        .map((e) => e.wordId)
        .toSet();
  }

  Map<String, Set<String>> _todayQuizWordIds(Box<Map> box) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    Set<String> correct = {};
    Set<String> wrong = {};
    for (var m in box.values) {
      final ts = m['timestamp'] as DateTime?;
      if (ts != null && ts.isAfter(start) && ts.isBefore(end)) {
        final ids = (m['wordIds'] as List?)?.cast<String>();
        final results = (m['results'] as List?)?.cast<bool>();
        if (ids != null && results != null && ids.length == results.length) {
          for (int i = 0; i < ids.length; i++) {
            if (results[i]) {
              correct.add(ids[i]);
            } else {
              wrong.add(ids[i]);
            }
          }
        }
      }
    }
    return {'correct': correct, 'wrong': wrong};
  }

  List<Flashcard> _mapIdsToCards(Set<String> ids) {
    return ids
        .map((id) => _allFlashcards.firstWhere(
              (f) => f.id == id,
              orElse: () => null,
            ))
        .whereType<Flashcard>()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!));
    }

    return ValueListenableBuilder<Box<HistoryEntry>>(
      valueListenable: _historyBox.listenable(),
      builder: (context, hBox, _) {
        return ValueListenableBuilder<Box<Map>>(
          valueListenable: _quizStatsBox.listenable(),
          builder: (context, qBox, __) {
            final learned = _mapIdsToCards(_todayLearnedIds(hBox));
            final quizMap = _todayQuizWordIds(qBox);
            final correct = _mapIdsToCards(quizMap['correct']!);
            final wrong = _mapIdsToCards(quizMap['wrong']!);

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('今日学んだ単語 (${learned.length})',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (learned.isEmpty)
                  const Text('まだ学習履歴がありません。')
                else
                  ...learned.map((c) => ListTile(title: Text(c.term))),
                const Divider(height: 32),
                Text('クイズで正解した単語 (${correct.length})',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (correct.isEmpty)
                  const Text('正解した単語はありません。')
                else
                  ...correct.map((c) => ListTile(title: Text(c.term))),
                const Divider(height: 32),
                Text('クイズで間違えた単語 (${wrong.length})',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (wrong.isEmpty)
                  const Text('間違えた単語はありません。')
                else
                  ...wrong.map((c) => ListTile(title: Text(c.term))),
              ],
            );
          },
        );
      },
    );
  }
}
