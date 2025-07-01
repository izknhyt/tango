import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import 'flashcard_model.dart';
import 'flashcard_repository.dart';
import 'flashcard_repository_provider.dart';
import 'quiz_in_progress_screen.dart';
import 'quiz_setup_screen.dart';
import 'constants.dart';
import 'services/review_queue_service.dart';

enum _QuickSource { all, weak, star }

class QuickQuizScreen extends ConsumerStatefulWidget {
  const QuickQuizScreen({super.key});

  @override
  ConsumerState<QuickQuizScreen> createState() => _QuickQuizScreenState();
}

class _QuickQuizScreenState extends ConsumerState<QuickQuizScreen> {
  final List<int?> _countOptions = [10, 20, null];
  int _countIndex = 0;
  _QuickSource _source = _QuickSource.all;

  late ReviewQueueService _queueService;
  late Box<Map> _favoritesBox;
  List<Flashcard>? _allWords;

  @override
  void initState() {
    super.initState();
    _queueService = ReviewQueueService();
    _favoritesBox = Hive.box<Map>(favoritesBoxName);
    ref.read(flashcardRepositoryProvider).loadAll().then((cards) {
      if (mounted) setState(() => _allWords = cards);
    });
  }

  bool get _weakAvailable => _queueService.size > 0;
  bool get _starAvailable => _favoritesBox.values
      .whereType<Map>()
      .any((m) => m.values.any((v) => v == true));

  int? get _questionCount => _countOptions[_countIndex];

  Future<void> _start() async {
    List<Flashcard> cards;
    if (_source == _QuickSource.all) {
      cards = _allWords ??
          await ref.read(flashcardRepositoryProvider).loadAll();
    } else if (_source == _QuickSource.weak) {
      int count = _questionCount ?? _queueService.size;
      final ids = await _queueService.popMany(count);
      final all = _allWords ??
          await ref.read(flashcardRepositoryProvider).loadAll();
      final idSet = ids.toSet();
      cards = all.where((c) => idSet.contains(c.id)).toList();
    } else {
      List<String> ids = [];
      for (final key in _favoritesBox.keys) {
        final raw = _favoritesBox.get(key);
        if (raw is Map && raw.values.any((v) => v == true)) {
          ids.add(key as String);
        }
      }
      final all = _allWords ??
          await ref.read(flashcardRepositoryProvider).loadAll();
      final idSet = ids.toSet();
      cards = all.where((c) => idSet.contains(c.id)).toList();
    }
    cards.shuffle();
    final count = _questionCount;
    if (count != null && count < cards.length) {
      cards = cards.take(count).toList();
    }
    if (!mounted || cards.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuizInProgressScreen(
          quizSessionWords: cards,
          totalSessionQuestions: cards.length,
          quizSessionType: QuizType.multipleChoice,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final disableWeak = !_weakAvailable;
    final disableStar = !_starAvailable;

    return Scaffold(
      appBar: AppBar(title: const Text('クイッククイズ')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ToggleButtons(
              isSelected: [
                _source == _QuickSource.all,
                _source == _QuickSource.weak,
                _source == _QuickSource.star,
              ],
              onPressed: (index) {
                if ((index == 1 && disableWeak) || (index == 2 && disableStar)) {
                  return;
                }
                setState(() {
                  _source = _QuickSource.values[index];
                });
              },
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('ALL'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'WEAK',
                    style: disableWeak
                        ? TextStyle(color: Theme.of(context).disabledColor)
                        : null,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'STAR',
                    style: disableStar
                        ? TextStyle(color: Theme.of(context).disabledColor)
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ToggleButtons(
              isSelected: List.generate(
                _countOptions.length,
                (i) => i == _countIndex,
              ),
              onPressed: (i) => setState(() => _countIndex = i),
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('10'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('20'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('∞'),
                ),
              ],
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _start,
                child: const Text('クイズ開始'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
