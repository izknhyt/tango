// lib/tabs_content/home_tab_content.dart (旧 home_tab_page.dart から修正)
import 'package:flutter/material.dart';
import '../app_view.dart'; // AppScreen enum のため
import 'package:hive_flutter/hive_flutter.dart';
import '../study_stats_model.dart';

class HomeTabContent extends StatefulWidget {
  final Function(AppScreen, {ScreenArguments? args}) navigateTo;

  const HomeTabContent({Key? key, required this.navigateTo}) : super(key: key);

  @override
  State<HomeTabContent> createState() => _HomeTabContentState();
}

class _HomeTabContentState extends State<HomeTabContent> {
  late Box<StudyStats> _statsBox;

  @override
  void initState() {
    super.initState();
    _statsBox = Hive.box<StudyStats>(studyStatsBoxName);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<StudyStats>>(
      valueListenable: _statsBox.listenable(),
      builder: (context, box, _) {
        List<StudyStats> stats = box.values.toList();
        if (stats.isEmpty) {
          return Center(child: Text('学習履歴はまだありません。'));
        }
        stats.sort((a, b) => b.date.compareTo(a.date));
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('学習履歴', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ...stats.map((s) {
              final dateStr =
                  '${s.date.year.toString().padLeft(4, '0')}/${s.date.month.toString().padLeft(2, '0')}/${s.date.day.toString().padLeft(2, '0')}';
              return Card(
                child: ListTile(
                  title: Text(dateStr),
                  subtitle: Text('単語 ${s.wordsViewed}件  クイズ ${s.quizzesTaken}回  正解 ${s.correctAnswers}問'),
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }
}
