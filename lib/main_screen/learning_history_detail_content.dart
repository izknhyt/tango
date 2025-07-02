import 'package:flutter/material.dart';

import '../learning_history_detail_screen.dart';

class LearningHistoryDetailContent extends StatelessWidget {
  const LearningHistoryDetailContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const LearningHistoryDetailScreen(
      key: ValueKey('LearningHistoryDetail'),
    );
  }
}
