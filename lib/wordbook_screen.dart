import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'flashcard_model.dart';
import 'word_detail_content.dart';
import 'constants.dart';

class WordbookScreen extends StatefulWidget {
  final List<Flashcard> flashcards;
  final Future<SharedPreferences> Function() prefsProvider;
  final ValueChanged<int>? onIndexChanged;

  const WordbookScreen({
    Key? key,
    required this.flashcards,
    this.prefsProvider = SharedPreferences.getInstance,
    this.onIndexChanged,
  }) : super(key: key);

  @override
  State<WordbookScreen> createState() => WordbookScreenState();
}

class WordbookScreenState extends State<WordbookScreen> {
  static const _bookmarkKey = 'bookmark_pageIndex';
  late PageController _pageController;
  int _currentIndex = 0;
  bool _showSlider = false;
  double _sliderValue = 0;
  Timer? _hideTimer;

  int get currentIndex => _currentIndex;
  List<Flashcard> get flashcards => widget.flashcards;

  Future<void> openSearch() => _openSearch();

  void _toggleSliderVisibility() {
    setState(() => _showSlider = !_showSlider);
    _resetHideTimer();
  }

  void _resetHideTimer() {
    _hideTimer?.cancel();
    if (_showSlider) {
      _hideTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() => _showSlider = false);
        }
      });
    }
  }

  void _onSliderChanged(double value) {
    setState(() => _sliderValue = value);
    final index = value.round();
    _pageController.jumpToPage(index);
    setState(() => _currentIndex = index);
    _saveBookmark(index);
    widget.onIndexChanged?.call(index);
    _resetHideTimer();
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadBookmark();
  }

  Future<void> _loadBookmark() async {
    final prefs = await widget.prefsProvider();
    int index = prefs.getInt(_bookmarkKey) ?? 0;
    index = index.clamp(0, widget.flashcards.length - 1);
    if (!mounted) return;
    _pageController.jumpToPage(index);
    setState(() {
      _currentIndex = index;
      _sliderValue = index.toDouble();
    });
    widget.onIndexChanged?.call(index);
  }

  Future<void> _saveBookmark(int index) async {
    final prefs = await widget.prefsProvider();
    await prefs.setInt(_bookmarkKey, index);
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
      _saveBookmark(result);
      widget.onIndexChanged?.call(result);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTabletOrDesktop =
        MediaQuery.of(context).size.shortestSide >= kTabletBreakpoint;
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: widget.flashcards.length,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
              _sliderValue = index.toDouble();
            });
            _saveBookmark(index);
            widget.onIndexChanged?.call(index);
          },
          itemBuilder: (context, index) {
            return WordDetailContent(
              flashcards: [widget.flashcards[index]],
              initialIndex: 0,
              showNavigation: false,
            );
          },
        ),
        Positioned.fill(
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _currentIndex > 0
                      ? () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : null,
                ),
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _toggleSliderVisibility,
                ),
              ),
              SizedBox(
                width: 40,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _currentIndex < widget.flashcards.length - 1
                      ? () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : null,
                ),
              ),
            ],
          ),
        ),
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
        Positioned(
          left: 0,
          right: 0,
          bottom: 16,
          child: AnimatedOpacity(
            opacity: _showSlider ? 1 : 0,
            duration: const Duration(milliseconds: 300),
            child: Visibility(
              visible: _showSlider,
              child: Slider(
                value: _sliderValue,
                min: 0,
                max: (widget.flashcards.length - 1).toDouble(),
                divisions: widget.flashcards.length - 1,
                onChanged: _onSliderChanged,
              ),
            ),
          ),
        ),
      ],
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

class _SearchSheet extends StatefulWidget {
  final List<Flashcard> flashcards;
  final int currentIndex;
  const _SearchSheet({required this.flashcards, required this.currentIndex});

  @override
  State<_SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends State<_SearchSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final results = widget.flashcards
        .where((c) => c.term.contains(_query) || c.reading.contains(_query))
        .toList();
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
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: results.length,
                itemBuilder: (context, i) {
                  final card = results[i];
                  final index = widget.flashcards.indexOf(card);
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
