import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import 'flashcard_model.dart';
import 'flashcard_repository.dart';
import 'flashcard_repository_provider.dart';
import 'history_entry_model.dart';
import 'app_view.dart';
import 'constants.dart';
import 'models/quiz_stat.dart';

class TodaySummaryScreen extends ConsumerStatefulWidget {
  final Function(AppScreen, {ScreenArguments? args})? navigateTo;

  const TodaySummaryScreen({Key? key, this.navigateTo}) : super(key: key);

  @override
  ConsumerState<TodaySummaryScreen> createState() => _TodaySummaryScreenState();
}

class _TodaySummaryScreenState extends ConsumerState<TodaySummaryScreen> {
  late Box<HistoryEntry> _historyBox;
  late Box<QuizStat> _quizStatsBox;
  List<Flashcard> _allFlashcards = [];
  bool _isLoading = true;
  String? _error;
  bool _showDescriptions = true;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _historyBox = Hive.box<HistoryEntry>(historyBoxName);
    _quizStatsBox = Hive.box<QuizStat>(quizStatsBoxName);
    _loadAllFlashcards();
  }

  Future<void> _loadAllFlashcards() async {
    try {
      final cards = await ref.read(flashcardRepositoryProvider).loadAll();
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

  Set<String> _learnedIdsFor(Box<HistoryEntry> box, DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return box.values
        .where((e) => e.timestamp.isAfter(start) && e.timestamp.isBefore(end))
        .map((e) => e.wordId)
        .toSet();
  }

  Map<String, Set<String>> _quizWordIdsFor(Box<QuizStat> box, DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    Set<String> correct = {};
    Set<String> wrong = {};
    for (var m in box.values) {
      final ts = m.timestamp;
      if (ts.isAfter(start) && ts.isBefore(end)) {
        final ids = m.wordIds;
        final results = m.results;
        for (int i = 0; i < ids.length && i < results.length; i++) {
          if (results[i]) {
            correct.add(ids[i]);
          } else {
            wrong.add(ids[i]);
          }
        }
      }
    }
    return {'correct': correct, 'wrong': wrong};
  }

  List<Flashcard> _mapIdsToCards(Set<String> ids) {
    return _allFlashcards.where((f) => ids.contains(f.id)).toList();
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
        return ValueListenableBuilder<Box<QuizStat>>(
          valueListenable: _quizStatsBox.listenable(),
          builder: (context, qBox, __) {
            final today = DateTime.now();
            final todayStart = DateTime(today.year, today.month, today.day);
            final learned = _mapIdsToCards(_learnedIdsFor(hBox, _selectedDate));
            final quizMap = _quizWordIdsFor(qBox, _selectedDate);
            final correct = _mapIdsToCards(quizMap['correct']!);
            final wrong = _mapIdsToCards(quizMap['wrong']!);

            return GestureDetector(
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity == null) return;
                  setState(() {
                    if (details.primaryVelocity! < 0 &&
                        _selectedDate.isBefore(todayStart)) {
                      _selectedDate =
                          _selectedDate.add(const Duration(days: 1));
                    } else if (details.primaryVelocity! > 0) {
                      _selectedDate =
                          _selectedDate.subtract(const Duration(days: 1));
                    }
                  });
                },
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () {
                            setState(() {
                              _selectedDate = _selectedDate
                                  .subtract(const Duration(days: 1));
                            });
                          },
                        ),
                        Text(DateFormat('yyyy/MM/dd').format(_selectedDate)),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward),
                          onPressed: _selectedDate.isBefore(todayStart)
                              ? () {
                                  setState(() {
                                    _selectedDate = _selectedDate
                                        .add(const Duration(days: 1));
                                  });
                                }
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      title: const Text('単語概要を表示'),
                      value: _showDescriptions,
                      onChanged: (val) =>
                          setState(() => _showDescriptions = val),
                    ),
                    Text('学習した単語 (${learned.length})',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    if (learned.isEmpty)
                      const Text('まだ学習履歴がありません。')
                    else
                      ...List.generate(learned.length, (index) {
                        final c = learned[index];
                        return ListTile(
                          title: Text(c.term),
                          subtitle:
                              _showDescriptions ? Text(c.description) : null,
                          onTap: widget.navigateTo == null
                              ? null
                              : () {
                                  widget.navigateTo!(
                                    AppScreen.wordDetail,
                                    args: ScreenArguments(
                                      flashcards: learned,
                                      initialIndex: index,
                                    ),
                                  );
                                },
                        );
                      }),
                    const Divider(height: 32),
                    Text('クイズで正解した単語 (${correct.length})',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    if (correct.isEmpty)
                      const Text('正解した単語はありません。')
                    else
                      ...List.generate(correct.length, (index) {
                        final c = correct[index];
                        return ListTile(
                          title: Text(c.term),
                          subtitle:
                              _showDescriptions ? Text(c.description) : null,
                          onTap: widget.navigateTo == null
                              ? null
                              : () {
                                  widget.navigateTo!(
                                    AppScreen.wordDetail,
                                    args: ScreenArguments(
                                      flashcards: correct,
                                      initialIndex: index,
                                    ),
                                  );
                                },
                        );
                      }),
                    const Divider(height: 32),
                    Text('クイズで間違えた単語 (${wrong.length})',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    if (wrong.isEmpty)
                      const Text('間違えた単語はありません。')
                    else
                      ...List.generate(wrong.length, (index) {
                        final c = wrong[index];
                        return ListTile(
                          title: Text(c.term),
                          subtitle:
                              _showDescriptions ? Text(c.description) : null,
                          onTap: widget.navigateTo == null
                              ? null
                              : () {
                                  widget.navigateTo!(
                                    AppScreen.wordDetail,
                                    args: ScreenArguments(
                                      flashcards: wrong,
                                      initialIndex: index,
                                    ),
                                  );
                                },
                        );
                      }),
                  ],
                ));
          },
        );
      },
    );
  }
}
