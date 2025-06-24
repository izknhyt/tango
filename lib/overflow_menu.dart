import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'word_list_query.dart';

enum _OverflowAction { search, filter, clear }

/// Popup menu used in the word list AppBar.
class OverflowMenu extends ConsumerWidget {
  final VoidCallback onOpenSheet;
  const OverflowMenu({Key? key, required this.onOpenSheet}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(currentQueryProvider);
    return PopupMenuButton<_OverflowAction>(
      icon: const Icon(Icons.more_vert),
      onSelected: (action) {
        switch (action) {
          case _OverflowAction.search:
          case _OverflowAction.filter:
            onOpenSheet();
            break;
          case _OverflowAction.clear:
            ref.read(currentQueryProvider.notifier).state = query.reset();
            break;
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: _OverflowAction.search,
          child: Text('検索'),
        ),
        PopupMenuItem(
          value: _OverflowAction.filter,
          child: Text('フィルタ'),
        ),
        PopupMenuItem(
          value: _OverflowAction.clear,
          child: Text('条件クリア'),
        ),
      ],
    );
  }
}
