// lib/tabs_content/home_tab_content.dart (旧 home_tab_page.dart から修正)
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../history_entry_model.dart';
import '../app_view.dart'; // AppScreen enum のため
import '../constants.dart';
import '../models/quiz_stat.dart';
import '../flashcard_repository.dart';

class HomeTabContent extends StatefulWidget {
  final Function(AppScreen, {ScreenArguments? args}) navigateTo;

  const HomeTabContent({Key? key, required this.navigateTo}) : super(key: key);

  @override
  State<HomeTabContent> createState() => _HomeTabContentState();
}

class _HomeTabContentState extends State<HomeTabContent> {
  late Box<HistoryEntry> _historyBox;
  late Box<QuizStat> _quizStatsBox;

  void _openWordList() {
    widget.navigateTo(AppScreen.wordList);
  }

  Future<void> _openWordbook() async {
    final list = await FlashcardRepository.loadAll();
    if (!mounted) return;
    widget.navigateTo(
      AppScreen.wordbook,
      args: ScreenArguments(flashcards: list),
    );
  }

  Map<String, int> _aggregateStats(Iterable<QuizStat> entries) {
    int questions = 0;
    int correct = 0;
    for (var m in entries) {
      questions += m.questionCount;
      correct += m.correctCount;
    }
    return {'questions': questions, 'correct': correct};
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return ListTile(
      leading: Icon(icon, size: 32),
      title: Text(label),
      trailing: Text(
        value,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }

  Widget _buildStatsCard({
    required int learnedToday,
    required Map<String, dynamic> quizStats,
    required double weekAcc,
    required double monthAcc,
  }) {
    final card = Card(
      child: Column(
        children: [
          _buildStatRow(
            icon: Icons.menu_book,
            label: '今日の学習単語数',
            value: '$learnedToday語',
          ),
          const Divider(height: 1),
          _buildStatRow(
            icon: Icons.quiz,
            label: '今日のクイズ回数／回答数',
            value: '${quizStats['sessions']}回／${quizStats['questions']}問',
          ),
          const Divider(height: 1),
          _buildStatRow(
            icon: Icons.check_circle_outline,
            label: '今日のクイズ正解数／不正解数',
            value: '${quizStats['correct']}問／${quizStats['incorrect']}問',
          ),
          const Divider(height: 1),
          _buildStatRow(
            icon: Icons.bar_chart,
            label: 'クイズの累積正解率',
            value:
                '1週間 ${weekAcc.toStringAsFixed(1)}%・1ヶ月 ${monthAcc.toStringAsFixed(1)}%',
          ),
        ],
      ),
    );
    return InkWell(
      onTap: () {
        widget.navigateTo(AppScreen.todaySummary);
      },
      child: card,
    );
  }

  @override
  void initState() {
    super.initState();
    _historyBox = Hive.box<HistoryEntry>(historyBoxName);
    _quizStatsBox = Hive.box<QuizStat>(quizStatsBoxName);
  }

  int _todayLearnedWords(Box<HistoryEntry> box) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    final entries = box.values
        .where((e) => e.timestamp.isAfter(start) && e.timestamp.isBefore(end));
    return entries.map((e) => e.wordId).toSet().length;
  }

  Map<String, dynamic> _todayQuizStats(Box<QuizStat> box) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    final todayEntries = box.values
        .where((e) => e.timestamp.isAfter(start) && e.timestamp.isBefore(end));
    int sessions = todayEntries.length;
    final aggregate = _aggregateStats(todayEntries);
    int questions = aggregate['questions']!;
    int correct = aggregate['correct']!;
    int incorrect = questions - correct;
    return {
      'sessions': sessions,
      'questions': questions,
      'correct': correct,
      'incorrect': incorrect,
    };
  }

  double _accuracy(Box<QuizStat> box, Duration range) {
    final now = DateTime.now();
    final since = now.subtract(range);
    final entries = box.values.where((e) => e.timestamp.isAfter(since));
    final aggregate = _aggregateStats(entries);
    int questions = aggregate['questions']!;
    int correct = aggregate['correct']!;
    if (questions == 0) return 0;
    return correct / questions * 100;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<HistoryEntry>>(
      valueListenable: _historyBox.listenable(),
      builder: (context, historyBox, _) {
        return ValueListenableBuilder<Box<QuizStat>>(
          valueListenable: _quizStatsBox.listenable(),
          builder: (context, quizBox, __) {
            final learnedToday = _todayLearnedWords(historyBox);
            final quizStats = _todayQuizStats(quizBox);
            final weekAcc = _accuracy(quizBox, const Duration(days: 7));
            final monthAcc = _accuracy(quizBox, const Duration(days: 30));

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  _buildStatsCard(
                    learnedToday: learnedToday,
                    quizStats: quizStats,
                    weekAcc: weekAcc,
                    monthAcc: monthAcc,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _openWordList,
                    child: const Text('単語一覧へ'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _openWordbook,
                    child: const Text('単語帳を開く'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      widget.navigateTo(AppScreen.learningHistoryDetail);
                    },
                    child: const Text('学習履歴詳細へ'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      widget.navigateTo(AppScreen.about);
                    },
                    child: const Text('このアプリについて'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
