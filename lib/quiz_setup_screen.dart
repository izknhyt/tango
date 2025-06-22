import 'package:flutter/material.dart';

import 'flashcard_model.dart';
import 'review_service.dart';
import 'quiz_in_progress_screen.dart';

// Review modes for selecting question order
enum ReviewMode {
  newWords,
  random,
  wrongDescending,
  tagFocus,
  spacedRepetition,
  mixed,
  tagOnly,
}

// Quiz type options
enum QuizType { multipleChoice, flashcard }

/// Quiz setup screen widget.
/// Users configure quiz options before starting a session.
class QuizSetupScreen extends StatefulWidget {
  const QuizSetupScreen({Key? key}) : super(key: key);

  @override
  State<QuizSetupScreen> createState() => _QuizSetupScreenState();
}

class _QuizSetupScreenState extends State<QuizSetupScreen> {
  ReviewMode _mode = ReviewMode.random;
  QuizType _quizType = QuizType.multipleChoice;
  int _questionCount = 10;
  bool _loadingCount = false;
  String? _countError;
  final Map<String, bool> _starFilter = {
    'red': true,
    'yellow': true,
    'blue': true,
  };

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

  Widget _buildStarCheckbox(String key, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: _starFilter[key],
          onChanged: (val) {
            setState(() {
              _starFilter[key] = val ?? false;
            });
          },
          activeColor: color,
        ),
        Text(key == 'red'
            ? '赤'
            : key == 'yellow'
                ? '黄'
                : '青'),
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
        RadioListTile<ReviewMode>(
          title: const Text('新出語'),
          value: ReviewMode.newWords,
          groupValue: _mode,
          onChanged: (v) => setState(() => _mode = v!),
        ),
        RadioListTile<ReviewMode>(
          title: const Text('ランダム'),
          value: ReviewMode.random,
          groupValue: _mode,
          onChanged: (v) => setState(() => _mode = v!),
        ),
        RadioListTile<ReviewMode>(
          title: const Text('間違え順'),
          value: ReviewMode.wrongDescending,
          groupValue: _mode,
          onChanged: (v) => setState(() => _mode = v!),
        ),
        RadioListTile<ReviewMode>(
          title: const Text('タグ集中'),
          value: ReviewMode.tagFocus,
          groupValue: _mode,
          onChanged: (v) => setState(() => _mode = v!),
        ),
        RadioListTile<ReviewMode>(
          title: const Text('復習間隔順'),
          value: ReviewMode.spacedRepetition,
          groupValue: _mode,
          onChanged: (v) => setState(() => _mode = v!),
        ),
        RadioListTile<ReviewMode>(
          title: const Text('総合優先度'),
          value: ReviewMode.mixed,
          groupValue: _mode,
          onChanged: (v) => setState(() => _mode = v!),
        ),
        RadioListTile<ReviewMode>(
          title: const Text('タグのみ'),
          value: ReviewMode.tagOnly,
          groupValue: _mode,
          onChanged: (v) => setState(() => _mode = v!),
        ),
        const SizedBox(height: 24),
        Text('星フィルタ', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildStarCheckbox('red', Theme.of(context).colorScheme.error),
            _buildStarCheckbox(
                'yellow', Theme.of(context).colorScheme.secondary),
            _buildStarCheckbox('blue', Theme.of(context).colorScheme.primary),
          ],
        ),
        const SizedBox(height: 24),
        Text('問題数', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Row(
          children: [
            DropdownButton<int>(
              value: _questionCount,
              items: const [
                10,
                20,
                30,
                40,
                50,
                100,
                200,
                300,
                400,
                500,
                600,
                700,
                800
              ]
                  .map((e) => DropdownMenuItem<int>(
                      value: e, child: Text(e.toString())))
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
