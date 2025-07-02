import 'package:flutter/material.dart';

import '../today_summary_screen.dart';
import '../app_view.dart';

class TodaySummaryContent extends StatelessWidget {
  final void Function(AppScreen, {ScreenArguments? args}) navigateTo;

  const TodaySummaryContent({super.key, required this.navigateTo});

  @override
  Widget build(BuildContext context) {
    return TodaySummaryScreen(
      key: const ValueKey('TodaySummaryScreen'),
      navigateTo: navigateTo,
    );
  }
}
