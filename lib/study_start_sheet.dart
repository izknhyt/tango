import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'review_service.dart';
import 'study_session_controller.dart';
import 'flashcard_model.dart';
import 'flashcard_repository.dart';

class StudyStartSheet extends ConsumerStatefulWidget {
  const StudyStartSheet({super.key});

  @override
  ConsumerState<StudyStartSheet> createState() => _StudyStartSheetState();
}

class _StudyStartSheetState extends ConsumerState<StudyStartSheet> {
  int _wordCount = 10;
  int _timerIndex = 0;
  final List<int> _timerOptions = [0, 15, 25, 30];

  Future<void> _start() async {
    final service = ReviewService();
    final all = await service.fetchForMode(ReviewMode.random);
    final words = all.take(_wordCount).toList();
    if (!mounted || words.isEmpty) return;
    Navigator.of(context).pop();
    ref.read(studySessionControllerProvider.notifier).start(
          words: words,
          targetWords: _wordCount,
          targetMinutes: _timerOptions[_timerIndex],
        );
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const StudySessionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('語数: $_wordCount'),
            Slider(
              value: _wordCount.toDouble(),
              min: 10,
              max: 100,
              divisions: 9,
              label: _wordCount.toString(),
              onChanged: (v) => setState(() => _wordCount = v.round()),
            ),
            const SizedBox(height: 8),
            const Text('タイマー'),
            ToggleButtons(
              isSelected: List.generate(
                _timerOptions.length,
                (i) => _timerIndex == i,
              ),
              onPressed: (i) => setState(() => _timerIndex = i),
              children: const [
                Padding(padding: EdgeInsets.all(8), child: Text('OFF')),
                Padding(padding: EdgeInsets.all(8), child: Text('15m')),
                Padding(padding: EdgeInsets.all(8), child: Text('25m')),
                Padding(padding: EdgeInsets.all(8), child: Text('30m')),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _start,
                child: const Text('開始'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showStudyStartSheet(BuildContext context) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => const StudyStartSheet(),
  );
}

class StudySessionScreen extends ConsumerStatefulWidget {
  const StudySessionScreen({super.key});

  @override
  ConsumerState<StudySessionScreen> createState() => _StudySessionScreenState();
}

class _StudySessionScreenState extends ConsumerState<StudySessionScreen> {
  bool _showAnswer = false;
  List<Flashcard> _choices = [];

  @override
  void initState() {
    super.initState();
    _loadChoices();
  }

  void _loadChoices() async {
    final state = ref.read(studySessionControllerProvider);
    if (state.words.isEmpty) return;
    final all = await FlashcardRepository.loadAll();
    final word = state.words[state.currentIndex];
    _choices = List<Flashcard>.from(all)
      ..removeWhere((c) => c.id == word.id);
    _choices.shuffle();
    _choices = (_choices.take(3).toList()..add(word))..shuffle();
    if (mounted) setState(() {});
  }

  void _next() async {
    setState(() => _showAnswer = false);
    await ref.read(studySessionControllerProvider.notifier).next();
    _loadChoices();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(studySessionControllerProvider);
    if (state.finished) {
      final acc = state.results.isEmpty
          ? 0
          : (state.results.where((e) => e).length / state.results.length * 100)
              .round();
      return Scaffold(
        appBar: AppBar(title: const Text('学習結果')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('学習時間: ${state.startTime != null ? DateTime.now().difference(state.startTime!).inSeconds : 0}秒'),
              Text('正答率: $acc%'),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('閉じる'),
              )
            ],
          ),
        ),
      );
    }
    final word = state.words[state.currentIndex];
    return Scaffold(
      appBar: AppBar(
        title: Text('${state.currentIndex + 1} / ${state.words.length}'),
        actions: [
          TextButton(
            onPressed: ref.read(studySessionControllerProvider.notifier).finish,
            child: const Text('終了'),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: WordDetailContent(
                flashcards: [word],
                initialIndex: 0,
              ),
            ),
            if (!state.inQuiz)
              ElevatedButton(
                onPressed: _next,
                child: const Text('次へ'),
              )
            else if (!_showAnswer)
              Column(
                children: _choices
                    .map(
                      (c) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() => _showAnswer = true);
                              ref
                                  .read(studySessionControllerProvider.notifier)
                                  .answer(c.term == word.term);
                            },
                            child: Text(c.term),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              )
            else
              Column(
                children: [
                  Text(
                    state.results.last ? '正解!' : '不正解',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _next,
                    child: const Text('次へ'),
                  )
                ],
              )
          ],
        ),
      ),
    );
  }
}
