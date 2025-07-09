import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import 'flashcard_model.dart';
import 'word_detail_controller.dart';
import 'controllers/word_history_controller.dart';
import 'flashcard_repository_provider.dart';
import 'star_color.dart';
import 'constants.dart';
import 'widgets/word_detail/flashcard_detail_view.dart';

class WordDetailContent extends ConsumerStatefulWidget {
  final List<Flashcard> flashcards;
  final int initialIndex;
  final WordDetailController? controller;
  final bool showNavigation;
  final ValueChanged<Flashcard>? onWordChanged;

  const WordDetailContent({
    super.key,
    required this.flashcards,
    required this.initialIndex,
    this.controller,
    this.showNavigation = true,
    this.onWordChanged,
  });

  @override
  ConsumerState<WordDetailContent> createState() => _WordDetailContentState();
}

class _WordDetailContentState extends ConsumerState<WordDetailContent> {
  final WordHistoryController _historyController = WordHistoryController();
  late Box<Map> _favoritesBox;
  late PageController _pageController;
  List<Flashcard>? _allFlashcards;
  Map<StarColor, bool> _favoriteStatus = {
    StarColor.red: false,
    StarColor.yellow: false,
    StarColor.blue: false,
  };

  @override
  void initState() {
    super.initState();
    _favoritesBox = Hive.box<Map>(favoritesBoxName);
    _pageController = PageController();
    _historyController.addListener(_onHistoryChanged);
    _historyController.initialize(widget.flashcards, widget.initialIndex);

    ref.read(flashcardRepositoryProvider).loadAll().then((cards) {
      if (mounted) setState(() => _allFlashcards = cards);
    });

    widget.controller?.attach(
      canGoBack: () => _historyController.canGoBack,
      canGoForward: () => _historyController.canGoForward,
      goBack: () => _historyController.back(),
      goForward: () => _historyController.forward(),
      currentFlashcard: () => _historyController.currentFlashcard,
    );
  }

  void _onHistoryChanged() {
    final view = _historyController;
    final newController = PageController(initialPage: view.currentIndex);
    _pageController.dispose();
    setState(() {
      _pageController = newController;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients) {
        _pageController.jumpToPage(view.currentIndex);
      }
    });
    _loadFavoriteStatus();
    widget.controller?.update();
    widget.onWordChanged?.call(_historyController.currentFlashcard);
  }

  void _loadFavoriteStatus() {
    final wordId = _historyController.currentFlashcard.id;
    if (_favoritesBox.containsKey(wordId)) {
      final Map<dynamic, dynamic>? stored = _favoritesBox.get(wordId);
      if (stored != null) {
        final Map<String, bool> m =
            stored.map((k, v) => MapEntry(k.toString(), v as bool));
        setState(() {
          _favoriteStatus[StarColor.red] = m['red'] ?? false;
          _favoriteStatus[StarColor.yellow] = m['yellow'] ?? false;
          _favoriteStatus[StarColor.blue] = m['blue'] ?? false;
        });
        return;
      }
    }
    setState(() {
      _favoriteStatus[StarColor.red] = false;
      _favoriteStatus[StarColor.yellow] = false;
      _favoriteStatus[StarColor.blue] = false;
    });
  }

  Future<void> _toggleFavorite(StarColor colorKey) async {
    final wordId = _historyController.currentFlashcard.id;
    final status = Map<StarColor, bool>.from(_favoriteStatus);
    status[colorKey] = !status[colorKey]!;
    await _favoritesBox.put(
        wordId, {for (final e in status.entries) e.key.name: e.value});
    setState(() => _favoriteStatus = status);
  }

  List<Flashcard> get _source => _allFlashcards ?? widget.flashcards;

  void _openRelatedGroup(Flashcard origin, Flashcard selected) {
    final ids = origin.relatedIds;
    if (ids == null || ids.isEmpty) return;
    List<Flashcard> group = [];
    for (final id in ids) {
      try {
        final m = _source.firstWhere((c) => c.id == id);
        group.add(m);
      } catch (_) {}
    }
    if (group.isEmpty) return;
    int newIndex = group.indexWhere((c) => c.id == selected.id);
    if (newIndex == -1) {
      group.insert(0, selected);
      newIndex = 0;
    }
    _historyController.openGroup(group, newIndex);
  }

  @override
  void dispose() {
    widget.controller?.detach();
    _historyController.removeListener(_onHistoryChanged);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentList = _historyController.currentList;
    final currentIndex = _historyController.currentIndex;
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: currentList.length,
            onPageChanged: (index) {
              _historyController.setPage(index);
            },
            itemBuilder: (context, index) {
              return FlashcardDetailView(
                card: currentList[index],
                favoriteStatus: _favoriteStatus,
                onToggleFavorite: _toggleFavorite,
                relatedSource: _source,
                onSelectRelated: _openRelatedGroup,
              );
            },
          ),
        ),
        if (widget.showNavigation && currentList.length > 1)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: currentIndex > 0
                      ? () => _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          )
                      : null,
                  child: const Text('前へ'),
                ),
                Text('${currentIndex + 1} / ${currentList.length}'),
                TextButton(
                  onPressed: currentIndex < currentList.length - 1
                      ? () => _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          )
                      : null,
                  child: const Text('次へ'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
