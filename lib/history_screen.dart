import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import 'services/aggregator.dart';

enum DateRange { week7, month30, month90, all }

final historyFilterProvider =
    StateProvider<DateRange>((ref) => DateRange.week7);

final dailyStudyProvider = FutureProvider<Map<DateTime, Duration>>((ref) {
  final range = ref.watch(historyFilterProvider);
  final agg = SessionAggregator();
  final now = DateTime.now();
  DateTime from;
  switch (range) {
    case DateRange.week7:
      from = now.subtract(const Duration(days: 6));
      break;
    case DateRange.month30:
      from = now.subtract(const Duration(days: 29));
      break;
    case DateRange.month90:
      from = now.subtract(const Duration(days: 89));
      break;
    case DateRange.all:
      from = DateTime(2000);
      break;
  }
  return agg.dailyStudyTime(from: from, to: now);
});

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  Color _colorForMinutes(int minutes, BuildContext context) {
    if (minutes == 0) return Colors.grey.shade200;
    if (minutes <= 10) return Colors.blue.shade100;
    if (minutes <= 30) return Colors.blue.shade300;
    return Colors.blue.shade700;
  }

  Widget _buildHeatmap(BuildContext context, Map<DateTime, Duration> data) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 1);
    final days = <DateTime>[];
    for (var d = start; d.isBefore(end); d = d.add(const Duration(days: 1))) {
      days.add(d);
    }
    final firstWeekday = start.weekday % 7;
    final cells = <Widget>[];
    for (int i = 0; i < firstWeekday; i++) {
      cells.add(const SizedBox.shrink());
    }
    for (final day in days) {
      final mins = data[day]?.inMinutes ?? 0;
      cells.add(Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: _colorForMinutes(mins, context),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text('${day.day}',
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(fontSize: 10)),
      ));
    }
    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: cells,
    );
  }

  LineChartData _chartData(
      BuildContext context, List<MapEntry<DateTime, Duration>> entries) {
    final spots = entries
        .map((e) => FlSpot(
            e.key.millisecondsSinceEpoch.toDouble(),
            e.value.inMinutes.toDouble()))
        .toList();
    return LineChartData(
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: Theme.of(context).colorScheme.primary.withOpacity(.15),
          ),
        )
      ],
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: const Duration(days: 1).inMilliseconds.toDouble(),
            getTitlesWidget: (value, meta) {
              final date =
                  DateTime.fromMillisecondsSinceEpoch(value.toInt());
              return Text(
                DateFormat('M/d').format(date),
                style:
                    Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 10),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: true),
        ),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: FlGridData(show: false),
      borderData: FlBorderData(show: false),
    );
  }

  Widget _summary(Map<DateTime, Duration> data, int streak) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(const Duration(days: 6));
    final todayMin = data[today]?.inMinutes ?? 0;
    final weekMin = data.entries
        .where((e) => !e.key.isBefore(weekStart))
        .fold<int>(0, (p, e) => p + e.value.inMinutes);
    Widget card(String label, String value) {
      return Card(
        child: SizedBox(
          width: 120,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          card('今日', '$todayMin分'),
          card('今週', '$weekMin分'),
          card('連続', '$streak日'),
        ],
      ),
    );
  }

  Widget _emptyView(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.insights_outlined,
            size: 48, color: Theme.of(context).colorScheme.outline),
        const SizedBox(height: 8),
        const Text('データがありません'),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final range = ref.watch(historyFilterProvider);
    final asyncDaily = ref.watch(dailyStudyProvider);
    final aggregator = SessionAggregator();
    return asyncDaily.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (data) {
        if (data.isEmpty) {
          return Center(child: _emptyView(context));
        }
        final entries = data.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key));
        final streak = aggregator.currentStreak();
        final now = DateTime.now();
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _summary(data, streak),
            const SizedBox(height: 16),
            SegmentedButton<DateRange>(
              segments: const [
                ButtonSegment(value: DateRange.week7, label: Text('7日')),
                ButtonSegment(value: DateRange.month30, label: Text('30日')),
                ButtonSegment(value: DateRange.month90, label: Text('90日')),
                ButtonSegment(value: DateRange.all, label: Text('ALL')),
              ],
              selected: {range},
              onSelectionChanged: (vals) {
                ref.read(historyFilterProvider.notifier).state = vals.first;
              },
            ),
            const SizedBox(height: 8),
            SizedBox(height: 200, child: LineChart(_chartData(context, entries))),
            const SizedBox(height: 24),
            FutureBuilder<Map<DateTime, Duration>>(
              future: aggregator.dailyStudyTime(
                from: DateTime(now.year, now.month, 1),
                to: DateTime(now.year, now.month + 1, 1),
              ),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox(height: 200);
                }
                return _buildHeatmap(context, snapshot.data!);
              },
            ),
          ],
        );
      },
    );
  }
}
