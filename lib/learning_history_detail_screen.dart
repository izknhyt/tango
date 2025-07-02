import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import 'package:tango/history_entry_model.dart';
import 'constants.dart';
import 'models/quiz_stat.dart';
import 'services/history_chart_service.dart';
import 'widgets/history_charts/bar_chart.dart';
import 'widgets/history_charts/line_chart.dart';

enum ViewMode { day, week, month }

class LearningHistoryDetailScreen extends StatefulWidget {
  const LearningHistoryDetailScreen({Key? key}) : super(key: key);

  @override
  State<LearningHistoryDetailScreen> createState() =>
      _LearningHistoryDetailScreenState();
}

class _LearningHistoryDetailScreenState
    extends State<LearningHistoryDetailScreen> {
  late Box<HistoryEntry> _historyBox;
  late Box<QuizStat> _quizStatsBox;
  late HistoryChartService _chartService;
  ViewMode _mode = ViewMode.day;
  int _offset = 0;

  @override
  void initState() {
    super.initState();
    _historyBox = Hive.box<HistoryEntry>(historyBoxName);
    _quizStatsBox = Hive.box<QuizStat>(quizStatsBoxName);
    _chartService = HistoryChartService(_historyBox, _quizStatsBox);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _historyBox.listenable(),
      builder: (context, _, __) {
        return ValueListenableBuilder(
          valueListenable: _quizStatsBox.listenable(),
          builder: (context, __, ___) {
            final ranges = _chartService.currentRanges(_mode, _offset);
            final dateFormat = _mode == ViewMode.month
                ? DateFormat('yyyy/MM')
                : DateFormat('M/d');
            final labels =
                ranges.map((r) => dateFormat.format(r.start)).toList();

            final learned = _chartService.learnedSpots(ranges);
            final accuracy = _chartService.accuracySpots(ranges);
            final timeBars = _chartService.timeBars(ranges);

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ToggleButtons(
                  isSelected: ViewMode.values.map((m) => m == _mode).toList(),
                  onPressed: (index) {
                    setState(() {
                      _mode = ViewMode.values[index];
                      _offset = 0;
                    });
                  },
                  children: const [Text('日'), Text('週'), Text('月')],
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('学習単語数の推移'),
                        SizedBox(
                          height: 200,
                          child: GestureDetector(
                            onHorizontalDragEnd: (details) {
                              if (details.primaryVelocity == null) return;
                              setState(() {
                                if (details.primaryVelocity! < 0) {
                                  _offset--;
                                } else if (details.primaryVelocity! > 0) {
                                  _offset++;
                                }
                              });
                            },
                            child: HistoryLineChart(spots: learned, labels: labels),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('正解率の推移'),
                        SizedBox(
                          height: 200,
                          child: GestureDetector(
                            onHorizontalDragEnd: (details) {
                              if (details.primaryVelocity == null) return;
                              setState(() {
                                if (details.primaryVelocity! < 0) {
                                  _offset--;
                                } else if (details.primaryVelocity! > 0) {
                                  _offset++;
                                }
                              });
                            },
                            child: HistoryLineChart(
                              spots: accuracy,
                              labels: labels,
                              isPercent: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('学習時間の推移 (分)'),
                        SizedBox(
                          height: 200,
                          child: GestureDetector(
                            onHorizontalDragEnd: (details) {
                              if (details.primaryVelocity == null) return;
                              setState(() {
                                if (details.primaryVelocity! < 0) {
                                  _offset--;
                                } else if (details.primaryVelocity! > 0) {
                                  _offset++;
                                }
                              });
                            },
                            child: HistoryBarChart(bars: timeBars, labels: labels),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
