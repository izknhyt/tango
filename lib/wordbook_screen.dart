import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'services/bookmark_service.dart';
import 'bookmark_list_screen.dart';

import 'flashcard_model.dart';
import 'word_detail_content.dart';
import 'constants.dart';

const double _edgeTapTopPadding = 72.0;

class WordbookScreen extends StatefulWidget {
  final List<Flashcard> flashcards;
  final Future<SharedPreferences> Function() prefsProvider;
  final ValueChanged<int>? onIndexChanged;
  final BookmarkService bookmarkService;

  WordbookScreen({
    Key? key,
    required this.flashcards,
    this.prefsProvider = SharedPreferences.getInstance,
    this.onIndexChanged,
    BookmarkService? bookmarkService,
  })  : bookmarkService = bookmarkService ?? BookmarkService(),
        super(key: key);

  @override
  State<WordbookScreen> createState() => WordbookScreenState();
}

class WordbookScreenState extends State<WordbookScreen> {
  static const _bookmarkKey = 'bookmark_pageIndex';
  late PageController _pageController;
  int _currentIndex = 0;
  bool _showControls = false;
  final List<int> _history = [];
  int _historyIndex = -1;
  bool get canGoBack => _historyIndex > 0;
  bool get canGoForward =>
      _historyIndex >= 0 && _historyIndex < _history.length - 1;

  int get currentIndex => _currentIndex;
  List<Flashcard> get flashcards => widget.flashcards;

  Future<void> openSearch() => _openSearch();

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadBookmark().then((_) => _migrateOldBookmark());
  }

  Future<void> _loadBookmark() async {
    final prefs = await widget.prefsProvider();
    int index = prefs.getInt(_bookmarkKey) ?? 0;
    index = index.clamp(0, widget.flashcards.length - 1);
    if (!mounted) return;
    if (widget.flashcards.isNotEmpty) {
      _pageController.jumpToPage(index);
      setState(() {
        _currentIndex = index;
      });
      _pushHistory(index);
      widget.onIndexChanged?.call(index);
    }
  }

  Future<void> _migrateOldBookmark() async {
    final prefs = await widget.prefsProvider();
    final index = prefs.getInt(_bookmarkKey);
    if (index != null) {
      if (!widget.bookmarkService.isBookmarked(index)) {
        await widget.bookmarkService.addBookmark(index);
      }
      await prefs.remove(_bookmarkKey);
    }
  }

  Future<void> _saveBookmark(int index) async {
    final prefs = await widget.prefsProvider();
    await prefs.setInt(_bookmarkKey, index);
  }

  void _pushHistory(int index) {
    if (_historyIndex >= 0 && _history[_historyIndex] == index) {
      return;
    }
    if (_historyIndex >= 0 && _historyIndex < _history.length - 1) {
      _history.removeRange(_historyIndex + 1, _history.length);
    }
    _history.add(index);
    _historyIndex = _history.length - 1;
  }

  void _onWordChanged(Flashcard card) {
    final index = widget.flashcards.indexWhere((c) => c.id == card.id);
    if (index == -1) return;
    _pageController.jumpToPage(index);
    setState(() => _currentIndex = index);
    _pushHistory(index);
    _saveBookmark(index);
    widget.onIndexChanged?.call(index);
  }

  Future<void> _openSearch() async {
    final result = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _SearchSheet(
        flashcards: widget.flashcards,
        currentIndex: _currentIndex,
      ),
    );
    if (!mounted) return;
      if (result != null) {
        _pageController.jumpToPage(result);
        setState(() {
          _currentIndex = result;
        });
        _pushHistory(result);
        _saveBookmark(result);
        widget.onIndexChanged?.call(result);
      }
  }

  void _goBack() {
    if (!canGoBack) return;
    _historyIndex--;
    final index = _history[_historyIndex];
    _pageController.jumpToPage(index);
    setState(() => _currentIndex = index);
    _saveBookmark(index);
    widget.onIndexChanged?.call(index);
  }

  void _goForward() {
    if (!canGoForward) return;
    _historyIndex++;
    final index = _history[_historyIndex];
    _pageController.jumpToPage(index);
    setState(() => _currentIndex = index);
    _saveBookmark(index);
    widget.onIndexChanged?.call(index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTabletOrDesktop =
        MediaQuery.of(context).size.shortestSide >= kTabletBreakpoint;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
        GestureDetector(
          onTapUp: (details) {
            final size = context.size;
            if (size != null &&
                details.localPosition.dx >= 48 &&
                details.localPosition.dx <= size.width - 48) {
              _toggleControls();
            }
          },
          child: PageView.builder(
            controller: _pageController,
            physics: _showControls
                ? const NeverScrollableScrollPhysics()
                : null,
            itemCount: widget.flashcards.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
                _pushHistory(index);
                _saveBookmark(index);
                widget.onIndexChanged?.call(index);
              },
            itemBuilder: (context, index) {
              return WordDetailContent(
                key: ValueKey(widget.flashcards[index].id),
                flashcards: [widget.flashcards[index]],
                initialIndex: 0,
                showNavigation: false,
                onWordChanged: _onWordChanged,
              );
            },
          ),
        ),
        // Tappable areas for page navigation on phones
        if (widget.flashcards.length > 1 && !_showControls) ...[
          Positioned(
            left: 0,
            top: MediaQuery.of(context).padding.top + _edgeTapTopPadding,
            bottom: 0,
            width: 48,
            child: const _EdgeTapArea(isLeft: true),
          ),
          Positioned(
            right: 0,
            top: MediaQuery.of(context).padding.top + _edgeTapTopPadding,
            bottom: 0,
            width: 48,
            child: const _EdgeTapArea(isLeft: false),
          ),
        ],
        if (isTabletOrDesktop && widget.flashcards.length > 1)
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _NavButton(
                  icon: Icons.chevron_left,
                  onTap: _currentIndex > 0
                      ? () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : null,
                ),
                _NavButton(
                  icon: Icons.chevron_right,
                  onTap: _currentIndex < widget.flashcards.length - 1
                      ? () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : null,
                ),
              ],
            ),
          ),
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !_showControls,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _showControls ? 1.0 : 0.0,
              child: Column(
                children: [
                  Container(
                    color: Colors.black54,
                    padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
                    alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: canGoBack ? _goBack : null,
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.search, color: Colors.white),
                            onPressed: _openSearch,
                          ),
                          IconButton(
                            icon: Icon(
                              widget.bookmarkService.isBookmarked(_currentIndex)
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color: Colors.white,
                            ),
                            onPressed: () async {
                              if (widget.bookmarkService
                                  .isBookmarked(_currentIndex)) {
                                await widget.bookmarkService
                                    .removeBookmark(_currentIndex);
                              } else {
                                await widget.bookmarkService
                                    .addBookmark(_currentIndex);
                              }
                              setState(() {});
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.list, color: Colors.white),
                            onPressed: () async {
                              final index = await Navigator.of(context).push<int>(
                                MaterialPageRoute(
                                  builder: (_) => BookmarkListScreen(
                                    service: widget.bookmarkService,
                                  ),
                                ),
                              );
                              if (index != null) {
                                _pageController.jumpToPage(index);
                                setState(() => _currentIndex = index);
                                _pushHistory(index);
                                _saveBookmark(index);
                                widget.onIndexChanged?.call(index);
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward, color: Colors.white),
                            onPressed: canGoForward ? _goForward : null,
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _toggleControls,
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                  Container(
                    color: Colors.black54,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.flashcards.length > 1)
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              tickMarkShape: _BookmarkTickMarkShape(
                                widget.bookmarkService
                                    .allBookmarks()
                                    .map((e) => e.pageIndex)
                                    .toList(),
                                widget.flashcards.length,
                              ),
                            ),
                            child: Slider(
                              value: (_currentIndex + 1).toDouble(),
                              min: 1,
                              max: widget.flashcards.length.toDouble(),
                              divisions: widget.flashcards.length - 1,
                              label: '${_currentIndex + 1}',
                              onChanged: (v) {
                                final index = v.round() - 1;
                                _pageController.jumpToPage(index);
                                _saveBookmark(index);
                                setState(() => _currentIndex = index);
                                widget.onIndexChanged?.call(index);
                              },
                              onChangeEnd: (v) {
                                final index = v.round() - 1;
                                final bookmarks = widget.bookmarkService
                                    .allBookmarks()
                                    .map((e) => e.pageIndex)
                                    .toList();
                                if (bookmarks.isEmpty) return;
                                int nearest = bookmarks.first;
                                var diff = (nearest - index).abs();
                                for (final b in bookmarks.skip(1)) {
                                  final d = (b - index).abs();
                                  if (d < diff) {
                                    nearest = b;
                                    diff = d;
                                  }
                                }
                                if (diff <= 1 && nearest != index) {
                                  _pageController.jumpToPage(nearest);
                                  _saveBookmark(nearest);
                                  setState(() => _currentIndex = nearest);
                                  widget.onIndexChanged?.call(nearest);
                                }
                              },
                            ),
                          ),
                        Text('(${_currentIndex + 1} / ${widget.flashcards.length})'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _NavButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Opacity(
        opacity: 0.6,
        child: IconButton(
          icon: Icon(icon, size: 36),
          onPressed: onTap,
        ),
      ),
    );
  }
}

class _EdgeTapArea extends StatelessWidget {
  final bool isLeft;

  const _EdgeTapArea({required this.isLeft});

  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<WordbookScreenState>();
    if (state == null) return const SizedBox.shrink();
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (isLeft) {
          if (state._currentIndex > 0) {
            state._pageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        } else {
          if (state._currentIndex < state.widget.flashcards.length - 1) {
            state._pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        }
      },
    );
  }
}

class _BookmarkTickMarkShape extends SliderTickMarkShape {
  final List<int> indices;
  final int total;

  const _BookmarkTickMarkShape(this.indices, this.total);

  @override
  Size getPreferredSize({required SliderThemeData sliderTheme, bool? isEnabled}) =>
      const Size(12, 12);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    Animation<double>? enableAnimation,
    Offset? thumbCenter,
    bool? isEnabled,
    bool? isDiscrete,
    TextDirection? textDirection,
  }) {
    final fraction = center.dx / parentBox.size.width;
    final index = (fraction * (total - 1)).round();
    if (!indices.contains(index)) return;
    final paint = Paint()
      ..color = sliderTheme.activeTrackColor ?? Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    const radius = 4.0;
    context.canvas.drawCircle(Offset(center.dx, center.dy), radius, paint);
  }
}

class _SearchSheet extends StatefulWidget {
  final List<Flashcard> flashcards;
  final int currentIndex;
  const _SearchSheet({required this.flashcards, required this.currentIndex});

  @override
  State<_SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends State<_SearchSheet> {
  String _query = '';

  List<int> _searchIndices() {
    final asNumber = int.tryParse(_query);
    if (asNumber != null) {
      final index = asNumber - 1;
      if (index >= 0 && index < widget.flashcards.length) {
        return [index];
      }
      return [];
    }
    final matches = <int>[];
    for (var i = 0; i < widget.flashcards.length; i++) {
      final card = widget.flashcards[i];
      if (card.term.contains(_query) || card.reading.contains(_query)) {
        matches.add(i);
      }
    }
    return matches;
  }

  @override
  Widget build(BuildContext context) {
    final indices = _searchIndices();
    final results = [for (final i in indices) widget.flashcards[i]];
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: '検索',
                  prefixIcon: Icon(Icons.search),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'[<>/\\]')),
                ],
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: results.length,
                itemBuilder: (context, i) {
                  final index = indices[i];
                  final card = results[i];
                  return ListTile(
                    title: Text(card.term),
                    onTap: () => Navigator.of(context).pop(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
