// lib/word_detail_content.dart

import 'package:flutter/material.dart';
import 'package:hive/hive.dart'; // Hiveをインポート
import 'flashcard_model.dart';
import '../history_entry_model.dart'; // 閲覧履歴用のモデルをインポート (libフォルダ直下にある想定)
import '../word_detail_controller.dart';
import 'flashcard_repository.dart';

// Box名は他のファイルと共通にするため定数化
const String favoritesBoxName = 'favorites_box_v2';
const String historyBoxName = 'history_box_v2'; // ★閲覧履歴用のBox名を追加

class _ViewState {
  final List<Flashcard> list;
  final int index;
  const _ViewState(this.list, this.index);
}

class WordDetailContent extends StatefulWidget {
  final List<Flashcard> flashcards;
  final int initialIndex;
  final WordDetailController? controller;

  const WordDetailContent({
    Key? key,
    required this.flashcards,
    required this.initialIndex,
    this.controller,
  }) : super(key: key);

  @override
  _WordDetailContentState createState() => _WordDetailContentState();
}

class _WordDetailContentState extends State<WordDetailContent> {
  late Box<Map> _favoritesBox;
  late Box<HistoryEntry> _historyBox; // ★閲覧履歴用のBoxインスタンスを保持する変数を宣言

  late PageController _pageController;
  late int _currentIndex;
  late List<Flashcard> _displayFlashcards;
  late Flashcard _currentWord;
  List<Flashcard>? _allFlashcards;

  // History navigation state
  final List<_ViewState> _viewHistory = [];
  int _historyIndex = -1;
  bool _suppressHistoryPush = false;

  Flashcard get _currentFlashcard => _currentWord;

  // お気に入り状態のローカル管理用 (これは変更なし)
  Map<String, bool> _favoriteStatus = {
    'red': false,
    'yellow': false,
    'blue': false,
  };

  @override
  void initState() {
    super.initState();
    // Boxのインスタンスを取得
    _favoritesBox = Hive.box<Map>(favoritesBoxName);
    _historyBox = Hive.box<HistoryEntry>(historyBoxName); // ★履歴Boxのインスタンスを取得

    _displayFlashcards = widget.flashcards;
    _currentIndex = widget.initialIndex;
    _currentWord = widget.flashcards[widget.initialIndex];
    _pageController = PageController(initialPage: _currentIndex);

    FlashcardRepository.loadAll().then((cards) {
      if (!mounted) return;
      setState(() {
        _allFlashcards = cards;
      });
    });

    widget.controller?.attach(
      canGoBack: _canGoBack,
      canGoForward: _canGoForward,
      goBack: _handleBack,
      goForward: _handleForward,
      currentFlashcard: () => _currentFlashcard,
    );

    _viewHistory.add(_ViewState(_displayFlashcards, _currentIndex));
    _historyIndex = 0;

    _loadFavoriteStatus(); // 既存：お気に入り状態を読み込む
    _addHistoryEntry(); // ★新規：閲覧履歴を追加するメソッドを呼び出す
  }

  // 既存：Hiveから現在の単語のお気に入り状態を読み込むメソッド (変更なし)
  void _loadFavoriteStatus() {
    final String wordId = _displayFlashcards[_currentIndex].id;
    if (_favoritesBox.containsKey(wordId)) {
      final Map<dynamic, dynamic>? storedStatusRaw = _favoritesBox.get(wordId);
      if (storedStatusRaw != null) {
        final Map<String, bool> storedStatus = storedStatusRaw
            .map((key, value) => MapEntry(key.toString(), value as bool));

        if (!mounted) return;
        setState(() {
          _favoriteStatus['red'] = storedStatus['red'] ?? false;
          _favoriteStatus['yellow'] = storedStatus['yellow'] ?? false;
          _favoriteStatus['blue'] = storedStatus['blue'] ?? false;
        });
      }
    } else {
      if (!mounted) return;
      setState(() {
        _favoriteStatus['red'] = false;
        _favoriteStatus['yellow'] = false;
        _favoriteStatus['blue'] = false;
      });
    }
  }

  // 既存：星のON/OFFを切り替え、Hiveにお気に入り状態を保存するメソッド (変更なし)
  Future<void> _toggleFavorite(String colorKey) async {
    final String wordId = _displayFlashcards[_currentIndex].id;
    Map<String, bool> currentStatus = Map<String, bool>.from(_favoriteStatus);
    currentStatus[colorKey] = !currentStatus[colorKey]!;
    await _favoritesBox.put(wordId, Map<String, dynamic>.from(currentStatus));
    if (!mounted) return;
    setState(() {
      _favoriteStatus = currentStatus;
    });
    // print("${widget.flashcard.term} - $colorKey star saved as ${_favoriteStatus[colorKey]}");
  }

  // ★新規：閲覧履歴を追加するメソッド
  Future<void> _addHistoryEntry() async {
    final String wordId = _displayFlashcards[_currentIndex].id;
    final DateTime now = DateTime.now();

    // 同じ単語の古い履歴エントリキーを探す (線形探索なので大量データには非効率)
    dynamic oldEntryKeyToRemove; // BoxのキーはintかStringの可能性がある
    for (var key in _historyBox.keys) {
      final entry = _historyBox.get(key);
      if (entry != null && entry.wordId == wordId) {
        oldEntryKeyToRemove = key;
        break;
      }
    }

    // もし古い履歴があれば削除する (最新の閲覧日時を保持するため)
    if (oldEntryKeyToRemove != null) {
      await _historyBox.delete(oldEntryKeyToRemove);
      // print("Removed old history entry for $wordId with key $oldEntryKeyToRemove");
    }

    // 新しい履歴エントリを追加 (Hiveのaddメソッドは自動で整数キーを割り当てます)
    final newEntry = HistoryEntry(wordId: wordId, timestamp: now);
    await _historyBox.add(newEntry);
    // print(
    //     "Added to history: ${newEntry.wordId} at ${newEntry.timestamp}. Box length: ${_historyBox.length}");
    // print("Added to history: $wordId at $now. New key: ${newEntry.key}. Total history: ${_historyBox.length}");

    // オプション：履歴の件数制限 (例: 最新100件まで)
    if (_historyBox.length > 100) {
      // タイムスタンプでソートして最も古いものを削除
      List<MapEntry<dynamic, HistoryEntry>> entries =
          _historyBox.toMap().entries.toList();
      if (entries.isNotEmpty) {
        entries.sort(
            (a, b) => a.value.timestamp.compareTo(b.value.timestamp)); // 古い順
        await _historyBox.delete(entries.first.key);
        // print("History limit reached, oldest entry with key ${entries.first.key} deleted.");
      }
    }
  }

  bool _canGoBack() => _historyIndex > 0;
  bool _canGoForward() =>
      _historyIndex >= 0 && _historyIndex < _viewHistory.length - 1;

  void _pushHistory() {
    if (_suppressHistoryPush) {
      _suppressHistoryPush = false;
      return;
    }
    if (_historyIndex < _viewHistory.length - 1) {
      _viewHistory.removeRange(_historyIndex + 1, _viewHistory.length);
    }
    _viewHistory.add(_ViewState(_displayFlashcards, _currentIndex));
    _historyIndex = _viewHistory.length - 1;
    widget.controller?.update();
  }

  void _jumpToView(_ViewState view, {bool addToHistory = false}) {
    final newController = PageController(initialPage: view.index);
    _pageController.dispose();

    setState(() {
      _displayFlashcards = view.list;
      _currentIndex = view.index;
      _currentWord = view.list[view.index];
      _pageController = newController;
      _suppressHistoryPush = true; // Prevent duplicate history pushes
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients) {
        _pageController.jumpToPage(view.index);
      }
    });

    _loadFavoriteStatus();
    _addHistoryEntry();

    if (addToHistory) {
      if (_historyIndex < _viewHistory.length - 1) {
        _viewHistory.removeRange(_historyIndex + 1, _viewHistory.length);
      }
      _viewHistory.add(_ViewState(view.list, view.index));
      _historyIndex = _viewHistory.length - 1;
    }

    widget.controller?.update();
  }

  void _handleBack() {
    if (_canGoBack()) {
      _historyIndex--;
      _jumpToView(_viewHistory[_historyIndex]);
    }
  }

  void _handleForward() {
    if (_canGoForward()) {
      _historyIndex++;
      _jumpToView(_viewHistory[_historyIndex]);
    }
  }

  @override
  void dispose() {
    widget.controller?.detach();
    _pageController.dispose();
    super.dispose();
  }

  // 既存：星アイコンを生成するウィジェットメソッド (変更なし)
  Widget _buildStarIcon(String colorKey, Color color) {
    bool isFavorite = _favoriteStatus[colorKey] ?? false;
    return IconButton(
      icon: Icon(
        isFavorite ? Icons.star : Icons.star_border,
        color: isFavorite ? color : Colors.grey[400],
        size: 28,
      ),
      onPressed: () => _toggleFavorite(colorKey),
      tooltip: colorKey == 'red'
          ? '赤星'
          : colorKey == 'yellow'
              ? '黄星'
              : '青星',
    );
  }

  // 既存：詳細項目を表示するウィジェットメソッド (変更なし)
  Widget _buildDetailItem(BuildContext context, String label, String? value) {
    if (value == null ||
        value.isEmpty ||
        value.toLowerCase() == 'nan' ||
        value == 'ー') {
      return SizedBox.shrink();
    }
    final displayValue = value.replaceAllMapped(
      RegExp(r'\\n'),
      (match) => '\n',
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          SizedBox(height: 4),
          Text(
            displayValue,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.5,
                  color: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.color
                      ?.withOpacity(0.85),
                ),
          ),
        ],
      ),
    );
  }

  String? _resolveRelatedTerms(List<String>? ids) {
    if (ids == null) return null;
    final source = _allFlashcards ?? widget.flashcards;
    List<String> terms = [];
    for (final id in ids) {
      Flashcard? match;
      try {
        match = source.firstWhere((c) => c.id == id);
      } catch (_) {}
      terms.add(match?.term ?? id);
    }
    return terms.isEmpty ? null : terms.join('、');
  }

  void _navigateToFlashcard(Flashcard card) {
    final index = _displayFlashcards.indexWhere((c) => c.id == card.id);
    if (index == -1) return;

    _jumpToView(_ViewState(_displayFlashcards, index), addToHistory: true);
  }

  void _navigateToRelatedGroup(Flashcard origin, Flashcard selected) {
    final ids = origin.relatedIds;
    if (ids == null || ids.isEmpty) return;

    final source = _allFlashcards ?? widget.flashcards;
    List<Flashcard> group = [];
    for (final id in ids) {
      try {
        final match = source.firstWhere((c) => c.id == id);
        group.add(match);
      } catch (_) {}
    }
    if (group.isEmpty) return;

    int newIndex = group.indexWhere((c) => c.id == selected.id);
    if (newIndex == -1) {
      group.insert(0, selected);
      newIndex = 0;
    }

    _jumpToView(_ViewState(group, newIndex), addToHistory: true);
  }

  void _showRelatedTermDialog(Flashcard selected, Flashcard origin) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
            _navigateToRelatedGroup(origin, selected);
          },
          child: AlertDialog(
            title: Text(selected.term),
            content: Text(selected.description),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('閉じる'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRelatedTermsSection(BuildContext context, Flashcard card) {
    final ids = card.relatedIds;
    if (ids == null || ids.isEmpty) {
      return const SizedBox.shrink();
    }

    final source = _allFlashcards ?? widget.flashcards;
    List<Widget> buttons = [];
    for (final id in ids) {
      Flashcard? related;
      try {
        related = source.firstWhere((c) => c.id == id);
      } catch (_) {
        related = null;
      }
      final label = related?.term ?? id;
      buttons.add(
        Padding(
          padding: const EdgeInsets.only(right: 8.0, bottom: 4.0),
          child: TextButton(
            onPressed: related != null
                ? () => _showRelatedTermDialog(related!, card)
                : null,
            child: Text(label),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '関連用語 (Related Terms):',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 4),
          Wrap(children: buttons),
        ],
      ),
    );
  }

  Widget _buildFlashcardDetail(BuildContext context, Flashcard card) {
    String categories =
        "${card.categoryLarge} > ${card.categoryMedium} > ${card.categorySmall}";
    if (card.categoryItem != card.categorySmall &&
        card.categoryItem.isNotEmpty &&
        !["（小分類全体）", "[脅威の種類]", "[マルウェア・不正プログラム]", "nan", "ー"]
            .contains(card.categoryItem)) {
      categories += " > ${card.categoryItem}";
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  card.term,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStarIcon('red', Theme.of(context).colorScheme.error),
                  _buildStarIcon(
                      'yellow', Theme.of(context).colorScheme.secondary),
                  _buildStarIcon('blue', Theme.of(context).colorScheme.primary),
                ],
              ),
            ],
          ),
          SizedBox(height: 6),
          if (card.reading.isNotEmpty &&
              card.reading != 'nan' &&
              card.reading != 'ー')
            Text(
              "読み: ${card.reading}",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withOpacity(0.7),
                  ),
            ),
          SizedBox(height: 12),
          _buildDetailItem(
            context,
            '重要度:',
            "★" * card.importance.toInt() +
                (card.importance - card.importance.toInt() > 0.0 ? "☆" : "") +
                " (${card.importance.toStringAsFixed(1)})",
          ),
          _buildDetailItem(context, 'カテゴリー:', categories),
          Divider(height: 24, thickness: 0.8),
          _buildDetailItem(context, '概要 (Description):', card.description),
          _buildDetailItem(context, '解説 (Practical Tip):', card.practicalTip),
          _buildDetailItem(context, '出題例 (Exam Example):', card.examExample),
          _buildDetailItem(context, '試験ポイント (Exam Point):', card.examPoint),
          _buildRelatedTermsSection(context, card),
          _buildDetailItem(
            context,
            'タグ (Tags):',
            card.tags?.join('、'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: _displayFlashcards.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
                _currentWord = _displayFlashcards[index];
              });
              _loadFavoriteStatus();
              _addHistoryEntry();
              _pushHistory();
              // AppBarの表示を更新
              widget.controller?.update();
            },
            itemBuilder: (context, index) {
              return _buildFlashcardDetail(context, _displayFlashcards[index]);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: _currentIndex > 0
                    ? () {
                        _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut);
                      }
                    : null,
                child: const Text('前へ'),
              ),
              Text('${_currentIndex + 1} / ${_displayFlashcards.length}'),
              TextButton(
                onPressed: _currentIndex < _displayFlashcards.length - 1
                    ? () {
                        _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut);
                      }
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
