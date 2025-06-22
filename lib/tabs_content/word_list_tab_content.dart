// lib/tabs_content/word_list_tab_content.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../history_entry_model.dart';
import '../flashcard_model.dart'; // lib/flashcard_model.dart
import '../review_service.dart';
// import '../word_detail_screen.dart'; // MainScreen が管理するので直接は不要

enum SortMode { id, importance, lastReviewed }
enum FilterMode { unviewed, wrongOnly }

class WordListTabContent extends StatefulWidget {
  final Function(List<Flashcard>, int) onWordTap; // 単語タップ時のコールバック
  final ReviewMode mode;

  const WordListTabContent({
    Key? key,
    required this.onWordTap,
    required this.mode,
  }) : super(key: key);

  @override
  WordListTabContentState createState() => WordListTabContentState();
}

class WordListTabContentState extends State<WordListTabContent> {
  List<Flashcard> _allFlashcards = []; // JSONから読み込んだ全データ
  List<Flashcard> _filteredFlashcards = []; // 表示用（フィルタリング後）のデータ
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();
  Set<String> _selectedTags = {};
  RangeValues _importanceRange = const RangeValues(1, 5);
  Set<String> _allTags = {};
  Timer? _debounce;
  late Box<HistoryEntry> _historyBox;
  late Box<Map> _quizStatsBox;
  SortMode _sortMode = SortMode.importance;
  final Set<FilterMode> _filterModes = {};
  late ReviewMode _mode;

  @override
  void initState() {
    super.initState();
    _mode = widget.mode;
    _historyBox = Hive.box<HistoryEntry>(historyBoxName);
    _quizStatsBox = Hive.box<Map>(quizStatsBoxName);
    _loadFlashcards();
    _searchController.addListener(() {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () {
        if (mounted) _performFiltering();
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose(); // コントローラーを破棄
    super.dispose();
  }
  Future<void> _loadFlashcards() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final service = ReviewService();
      List<Flashcard> loadedCards;
      if (_mode == ReviewMode.autoFilter) {
        loadedCards = await service.topByPriority(200);
      } else {
        loadedCards = await service.fetchForMode(_mode);
      }
      final tagSet = <String>{};
      for (var card in loadedCards) {
        if (card.tags != null) tagSet.addAll(card.tags!);
      }
      setState(() {
        _allFlashcards = loadedCards;
        _filteredFlashcards = loadedCards;
        _allTags = tagSet;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = '単語データの読み込みに失敗しました。';
        _isLoading = false;
      });
    }
  }

  /// Update review mode and reload flashcards.
  void updateMode(ReviewMode mode) {
    _mode = mode;
    _loadFlashcards();
  }



  // フィルタリングロジック
  void _performFiltering() {
    final q = _searchController.text.trim().toLowerCase();
    final viewedIds = _historyBox.values.map((e) => e.wordId).toSet();
    final Map<String, int> wrongCounts = {};
    for (var m in _quizStatsBox.values) {
      final ids = (m['wordIds'] as List?)?.cast<String>() ?? [];
      final results = (m['results'] as List?)?.cast<bool>() ?? [];
      for (int i = 0; i < ids.length && i < results.length; i++) {
        if (results[i] == false) {
          wrongCounts[ids[i]] = (wrongCounts[ids[i]] ?? 0) + 1;
        }
      }
    }
    final Map<String, DateTime> lastReviewed = {};
    for (final e in _historyBox.values) {
      final prev = lastReviewed[e.wordId];
      if (prev == null || e.timestamp.isAfter(prev)) {
        lastReviewed[e.wordId] = e.timestamp;
      }
    }

    List<Flashcard> result = _allFlashcards.where((card) {
      final matchesQuery = q.isEmpty ||
          card.term.toLowerCase().contains(q) ||
          card.reading.toLowerCase().contains(q);
      final matchesTags = _selectedTags.isEmpty ||
          _selectedTags.every((t) => card.tags?.contains(t) ?? false);
      final matchesImportance =
          card.importance >= _importanceRange.start &&
              card.importance <= _importanceRange.end;
      bool passesFilter = true;
      if (_filterModes.contains(FilterMode.unviewed)) {
        passesFilter = passesFilter && !viewedIds.contains(card.id);
      }
      if (_filterModes.contains(FilterMode.wrongOnly)) {
        passesFilter = passesFilter && (wrongCounts[card.id] ?? 0) > 0;
      }
      return matchesQuery && matchesTags && matchesImportance && passesFilter;
    }).toList();

    switch (_sortMode) {
      case SortMode.id:
        result.sort((a, b) => a.id.compareTo(b.id));
        break;
      case SortMode.importance:
        result.sort((a, b) => b.importance.compareTo(a.importance));
        break;
      case SortMode.lastReviewed:
        result.sort((a, b) {
          final at = lastReviewed[a.id];
          final bt = lastReviewed[b.id];
          if (at == null && bt == null) return 0;
          if (at == null) return 1;
          if (bt == null) return -1;
          return bt.compareTo(at);
        });
        break;
    }

    setState(() {
      _filteredFlashcards = result;
    });
  }

  void openFilterSheet(BuildContext context) {
    _openFilterSheet(context);
  }

  void _openFilterSheet(BuildContext context) {
    final tags = _allTags.toList()..sort();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return FilterSheet(
          allTags: tags,
          searchQuery: _searchController.text,
          selectedTags: _selectedTags,
          importanceRange: _importanceRange,
          onApply: (q, tags, range) {
            Navigator.of(ctx).pop();
            _searchController.text = q;
            _selectedTags = tags;
            _importanceRange = range;
            _performFiltering();
          },
        );
      },
    );
  }

  void _openSearchDialog(BuildContext context) {
    final controller = TextEditingController(text: _searchController.text);
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('検索'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: '単語名または読み方で検索...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _searchController.text = controller.text;
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _openSortSheet(BuildContext context) {
    String sortLabel(SortMode mode) {
      switch (mode) {
        case SortMode.id:
          return 'ID順';
        case SortMode.importance:
          return '重要度順';
        case SortMode.lastReviewed:
          return '最終閲覧順';
      }
    }

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...SortMode.values.map(
                  (m) => RadioListTile<SortMode>(
                    title: Text(sortLabel(m)),
                    value: m,
                    groupValue: _sortMode,
                    onChanged: (v) {
                      if (v != null) {
                        Navigator.of(ctx).pop();
                        setState(() => _sortMode = v);
                        _performFiltering();
                      }
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('未閲覧'),
                      selected: _filterModes.contains(FilterMode.unviewed),
                      onSelected: (val) {
                        setState(() {
                          if (val) {
                            _filterModes.add(FilterMode.unviewed);
                          } else {
                            _filterModes.remove(FilterMode.unviewed);
                          }
                        });
                        _performFiltering();
                      },
                    ),
                    FilterChip(
                      label: const Text('間違えのみ'),
                      selected: _filterModes.contains(FilterMode.wrongOnly),
                      onSelected: (val) {
                        setState(() {
                          if (val) {
                            _filterModes.add(FilterMode.wrongOnly);
                          } else {
                            _filterModes.remove(FilterMode.wrongOnly);
                          }
                        });
                        _performFiltering();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('単語を読込中...', style: TextStyle(fontSize: 16)),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 16)),
      );
    }

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          floating: true,
          title: Text('表示中 ${_filteredFlashcards.length} / 全 ${_allFlashcards.length} 単語'),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: '検索',
              onPressed: () => _openSearchDialog(context),
            ),
            IconButton(
              icon: const Icon(Icons.filter_alt_outlined),
              tooltip: 'フィルター',
              onPressed: () => _openFilterSheet(context),
            ),
            IconButton(
              icon: const Icon(Icons.sort),
              tooltip: '並び替え',
              onPressed: () => _openSortSheet(context),
            ),
          ],
        ),
        if (_filteredFlashcards.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text(
                _searchController.text.isEmpty && _allFlashcards.isEmpty
                    ? '登録されている単語がありません。'
                    : '検索結果に一致する単語がありません。',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final card = _filteredFlashcards[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                  child: Card(
                    elevation: 1.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 6.0,
                        horizontal: 16.0,
                      ),
                      title: Text(
                        card.term,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 3.0),
                        child: Text(
                          card.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Colors.grey[400],
                      ),
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        widget.onWordTap(_filteredFlashcards, index);
                      },
                    ),
                  ),
                );
              },
              childCount: _filteredFlashcards.length,
            ),
          ),
      ],
    );
  }

}

const String historyBoxName = 'history_box_v2';
const String quizStatsBoxName = 'quiz_stats_box_v1';

class FilterSheet extends StatefulWidget {
  final String searchQuery;
  final Set<String> selectedTags;
  final RangeValues importanceRange;
  final List<String> allTags;
  final void Function(String, Set<String>, RangeValues) onApply;

  const FilterSheet({
    Key? key,
    required this.searchQuery,
    required this.selectedTags,
    required this.importanceRange,
    required this.allTags,
    required this.onApply,
  }) : super(key: key);

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late TextEditingController _controller;
  late Set<String> _tags;
  late RangeValues _range;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.searchQuery);
    _tags = {...widget.selectedTags};
    _range = widget.importanceRange;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_tags.contains(tag)) {
        _tags.remove(tag);
      } else {
        _tags.add(tag);
      }
    });
  }

  void _reset() {
    setState(() {
      _controller.text = '';
      _tags.clear();
      _range = const RangeValues(1, 5);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: bottom),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    labelText: '検索語',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              if (widget.allTags.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Wrap(
                    spacing: 8,
                    children: widget.allTags.map((tag) {
                      final selected = _tags.contains(tag);
                      return FilterChip(
                        label: Text(tag),
                        selected: selected,
                        onSelected: (_) => _toggleTag(tag),
                      );
                    }).toList(),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('重要度'),
                    RangeSlider(
                      values: _range,
                      min: 1,
                      max: 5,
                      divisions: 4,
                      labels: RangeLabels(
                        _range.start.round().toString(),
                        _range.end.round().toString(),
                      ),
                      onChanged: (v) => setState(() => _range = v),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: _reset,
                      child: const Text('リセット'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        widget.onApply(_controller.text, _tags, _range);
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
