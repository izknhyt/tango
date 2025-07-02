import 'package:flutter/material.dart';

import '../history_screen.dart';

class HistoryContent extends StatelessWidget {
  const HistoryContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const HistoryScreen(key: ValueKey('HistoryScreen'));
  }
}
