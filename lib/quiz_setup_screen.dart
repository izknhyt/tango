import 'package:flutter/material.dart';

import 'flashcard_model.dart';
import 'review_service.dart';
import 'review_mode_ext.dart';
import 'quiz_in_progress_screen.dart';
import 'star_color.dart';

// Quiz type options
enum QuizType { multipleChoice, flashcard }

/// Quiz setup screen widget.
/// Users configure quiz options before starting a session.
class QuizSetupScreen extends StatefulWidget {
  final ReviewMode mode;

  const QuizSetupScreen({Key? key, required this.mode}) : super(key: key);

  @override
  State<QuizSetupScreen> createState() => _QuizSetupScreenState();
}

class _QuizSetupScreenState extends State<QuizSetupScreen> {
  late ReviewMode _mode;
  QuizType _quizType = QuizType.multipleChoice;
  int _questionCount = 10;
  bool _loadingCount = false;
  String? _countError;
  final Map<StarColor, bool> _starFilter = {
    StarColor.red: true,
    StarColor.yellow: true,
    StarColor.blue: true,
  };

  @override
  void initState() {
    super.initState();
    _mode = widget.mode;
  }

  @override
  void didUpdateWidget(covariant QuizSetupScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.mode != oldWidget.mode) {
      setState(() {
        _mode = widget.mode;
      });
    }
  }

  /// Fetch available word count for a review mode.
  Future<int> fetchAvailableWordCount(ReviewMode mode) async {
    final service = ReviewService();
    final cards = await service.fetchForMode(mode);
    return cards.length;
  }

  Future<void> _setAllQuestionCount() async {
    setState(() {
      _loadingCount = true;
      _countError = null;
    });
    try {
      final count = await fetchAvailableWordCount(_mode);
      if (!mounted) return;
      setState(() {
        _questionCount = count;
        if (count == 0) {
          _countError = '利用可能な問題がありません';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _countError = '利用可能な問題数の取得に失敗しました';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loadingCount = false;
        });
      }
    }
  }


  Future<void> _startQuiz() async {

    final service = ReviewService();
    final allCards = await service.fetchForMode(_mode);
    if (!mounted) return;
    final sessionWords = allCards.take(_questionCount).toList();

    if (sessionWords.isEmpty) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuizInProgressScreen(
          quizSessionWords: sessionWords,
          totalSessionQuestions: sessionWords.length,
          quizSessionType: _quizType,
        ),
      ),
    );
  }

  Widget _buildStarCheckbox(StarColor colorKey, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: _starFilter[colorKey],
          onChanged: (val) {
            setState(() {
              _starFilter[colorKey] = val ?? false;
            });
          },
          activeColor: color,
        ),
        Text(colorKey.label),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('出題モード', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        ...[
          ReviewMode.newWords,
          ReviewMode.random,
          ReviewMode.wrongDescending,
          ReviewMode.tagFocus,
          ReviewMode.spacedRepetition,
          ReviewMode.mixed,
          ReviewMode.tagOnly,
        ].map(
          (mode) => RadioListTile<ReviewMode>(
            title: Text(mode.label),
            value: mode,
            groupValue: _mode,
            onChanged: (v) => setState(() => _mode = v!),
          ),
        ),
        const SizedBox(height: 24),
        Text('星フィルタ', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildStarCheckbox(
                StarColor.red, Theme.of(context).colorScheme.error),
            _buildStarCheckbox(
                StarColor.yellow, Theme.of(context).colorScheme.secondary),
            _buildStarCheckbox(
                StarColor.blue, Theme.of(context).colorScheme.primary),
          ],
        ),
        const SizedBox(height: 24),
        Text('問題数', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Row(
          children: [
            DropdownButton<int>(
              value: _questionCount,
              items: [
                ...List.generate(5, (i) => (i + 1) * 10),
                ...List.generate(8, (i) => (i + 1) * 100),
              ]
                  .map((e) =>
                      DropdownMenuItem<int>(value: e, child: Text(e.toString())))
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  setState(() {
                    _questionCount = v;
                  });
                }
              },
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: _loadingCount ? null : _setAllQuestionCount,
              child: _loadingCount
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('全部出題する'),
            ),
          ],
        ),
        if (_countError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _countError!,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: Theme.of(context).colorScheme.error),
            ),
          ),
        const SizedBox(height: 24),
        Text('クイズタイプ', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        ToggleButtons(
          isSelected: QuizType.values
              .map((type) => type == _quizType)
              .toList(),
          onPressed: (index) {
            setState(() {
              _quizType = QuizType.values[index];
            });
          },
          children: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('4択'),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('単語帳'),
            ),
          ],
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _questionCount == 0 ? null : _startQuiz,
            child: const Text('クイズ開始'),
          ),
        ),
      ],
    );
  }
}
