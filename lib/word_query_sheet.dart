import 'package:flutter/material.dart';

import 'word_list_query.dart';
import 'star_color.dart';

/// Bottom sheet widget for editing [WordListQuery].
class WordQuerySheet extends StatefulWidget {
  final WordListQuery initial;
  const WordQuerySheet({Key? key, required this.initial}) : super(key: key);

  @override
  State<WordQuerySheet> createState() => _WordQuerySheetState();
}

class _WordQuerySheetState extends State<WordQuerySheet> {
  late TextEditingController _controller;
  late Set<WordFilter> _filters;
  late Set<StarColor> _starFilters;
  late bool _useAnd;

  @override
  void initState() {
    super.initState();
    _filters = {...widget.initial.filters};
    _controller = TextEditingController(text: widget.initial.searchText);
    _starFilters = {...widget.initial.starFilters};
    _useAnd = widget.initial.starAnd;
  }

  void _toggleStarFilter(StarColor color) {
    setState(() {
      if (_starFilters.contains(color)) {
        _starFilters.remove(color);
      } else {
        _starFilters.add(color);
      }
    });
  }

  Widget _buildFilterStar(StarColor color, Color displayColor) {
    final selected = _starFilters.contains(color);
    return IconButton(
      icon: Icon(
        selected ? Icons.star : Icons.star_border,
        color: selected
            ? displayColor
            : Theme.of(context).colorScheme.outline,
        size: 24,
      ),
      onPressed: () => _toggleStarFilter(color),
      tooltip: '${color.label}星で絞り込む',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    labelText: '検索語',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('未閲覧'),
                      selected: _filters.contains(WordFilter.unviewed),
                      onSelected: (val) {
                        setState(() {
                          if (val) {
                            _filters.add(WordFilter.unviewed);
                          } else {
                            _filters.remove(WordFilter.unviewed);
                          }
                        });
                      },
                    ),
                    FilterChip(
                      label: const Text('間違えのみ'),
                      selected: _filters.contains(WordFilter.wrongOnly),
                      onSelected: (val) {
                        setState(() {
                          if (val) {
                            _filters.add(WordFilter.wrongOnly);
                          } else {
                            _filters.remove(WordFilter.wrongOnly);
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    ToggleButtons(
                      isSelected: [_useAnd, !_useAnd],
                      onPressed: (i) {
                        setState(() {
                          _useAnd = i == 0;
                        });
                      },
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text('AND'),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text('OR'),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    _buildFilterStar(
                        StarColor.red, Theme.of(context).colorScheme.error),
                    _buildFilterStar(StarColor.yellow,
                        Theme.of(context).colorScheme.secondary),
                    _buildFilterStar(
                        StarColor.blue, Theme.of(context).colorScheme.primary),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(
                          widget.initial.copyWith(
                            searchText: _controller.text,
                            filters: _filters,
                            starFilters: _starFilters,
                            starAnd: _useAnd,
                          ),
                        );
                      },
                      child: const Text('適用'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Show a [WordQuerySheet] and return the updated [WordListQuery].
Future<WordListQuery?> showWordQuerySheet(
    BuildContext context, WordListQuery current) {
  return showModalBottomSheet<WordListQuery>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => WordQuerySheet(initial: current),
  );
}
