// lib/tabs_content/home_tab_content.dart (旧 home_tab_page.dart から修正)
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart'; // <– add this
import '../history_entry_model.dart';
import '../app_view.dart'; // AppScreen enum のため

const String historyBoxName = 'history_box_v2';
const String quizStatsBoxName = 'quiz_stats_box_v1';

class HomeTabContent extends StatefulWidget {
  final Function(AppScreen, {ScreenArguments? args}) navigateTo;

  const HomeTabContent({Key? key, required this.navigateTo}) : super(key: key);

  @override
  State<HomeTabContent> createState() => _HomeTabContentState();
}

class _HomeTabContentState extends State<HomeTabContent> {
  late Box<HistoryEntry> _historyBox;
  late Box<Map> _quizStatsBox;

  @override
  void initState() {
    super.initState();
    _historyBox = Hive.box<HistoryEntry>(historyBoxName);
    _quizStatsBox = Hive.box<Map>(quizStatsBoxName);
  }

  int _todayLearnedWords(Box<HistoryEntry> box) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    final entries = box.values
        .where((e) => e.timestamp.isAfter(start) && e.timestamp.isBefore(end));
    return entries.map((e) => e.wordId).toSet().length;
  }

  Map<String, dynamic> _todayQuizStats(Box<Map> box) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    final todayEntries = box.values.where((e) {
      final ts = e['timestamp'] as DateTime?;
      return ts != null && ts.isAfter(start) && ts.isBefore(end);
    });
    int sessions = todayEntries.length;
    int questions = 0;
    int correct = 0;
    for (var m in todayEntries) {
      questions += (m['questionCount'] as int? ?? 0);
      correct += (m['correctCount'] as int? ?? 0);
    }
    int incorrect = questions - correct;
    return {
      'sessions': sessions,
      'questions': questions,
      'correct': correct,
      'incorrect': incorrect,
    };
  }

  double _accuracy(Box<Map> box, Duration range) {
    final now = DateTime.now();
    final since = now.subtract(range);
    final entries = box.values.where((e) {
      final ts = e['timestamp'] as DateTime?;
      return ts != null && ts.isAfter(since);
    });
    int questions = 0;
    int correct = 0;
    for (var m in entries) {
      questions += (m['questionCount'] as int? ?? 0);
      correct += (m['correctCount'] as int? ?? 0);
    }
    if (questions == 0) return 0;
    return correct / questions * 100;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<HistoryEntry>>(
      valueListenable: _historyBox.listenable(),
      builder: (context, historyBox, _) {
        return ValueListenableBuilder<Box<Map>>(
          valueListenable: _quizStatsBox.listenable(),
          builder: (context, quizBox, __) {
            final learnedToday = _todayLearnedWords(historyBox);
            final quizStats = _todayQuizStats(quizBox);
            final weekAcc = _accuracy(quizBox, const Duration(days: 7));
            final monthAcc = _accuracy(quizBox, const Duration(days: 30));

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('今日の学習単語数: $learnedToday語'),
                  const SizedBox(height: 8),
                  Text(
                      '今日のクイズ回数／回答数: ${quizStats['sessions']}回／${quizStats['questions']}問'),
                  const SizedBox(height: 8),
                  Text(
                      '今日のクイズ正解数／不正解数: ${quizStats['correct']}問／${quizStats['incorrect']}問'),
                  const SizedBox(height: 8),
                  Text(
                      'クイズの累積正解率: 1週間 ${weekAcc.toStringAsFixed(1)}% , 1ヶ月 ${monthAcc.toStringAsFixed(1)}%'),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
