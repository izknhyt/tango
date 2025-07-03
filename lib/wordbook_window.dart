import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'flashcard_model.dart';

/// Displays [MangaWordViewer] in a full screen modal with a semi-transparent background.
Future<void> showMangaWordViewer(
  BuildContext context, {
  required List<Flashcard> words,
  required int initialIndex,
}) {
  return showGeneralDialog(
    context: context,
    barrierColor: Colors.black54,
    barrierDismissible: true,
    pageBuilder: (context, _, __) => MangaWordViewer(
      words: words,
      initialIndex: initialIndex,
    ),
  );
}

/// Viewer widget that lets the user swipe through [words] like a manga reader.
class MangaWordViewer extends StatefulWidget {
  final List<Flashcard> words;
  final int initialIndex;

  const MangaWordViewer({
    super.key,
    required this.words,
    required this.initialIndex,
  });

  @override
  State<MangaWordViewer> createState() => _MangaWordViewerState();
}

class _MangaWordViewerState extends State<MangaWordViewer> {
  late PageController _controller;
  late int _currentIndex;
  bool _showBars = true;
  final Map<String, bool> _favorites = {};

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
    for (final c in widget.words) {
      _favorites[c.id] = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleBars() {
    setState(() => _showBars = !_showBars);
  }

  void _previous() {
    if (_currentIndex > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _next() {
    if (_currentIndex < widget.words.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _toggleFavorite() {
    final id = widget.words[_currentIndex].id;
    setState(() => _favorites[id] = !(_favorites[id] ?? false));
  }

  void _share() async {
    final word = widget.words[_currentIndex];
    await Clipboard.setData(ClipboardData(text: word.term));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('単語をコピーしました')),
    );
  }

  void _onSliderChanged(double value) {
    final index = value.round();
    _controller.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggleBars,
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: widget.words.length,
              onPageChanged: (i) => setState(() => _currentIndex = i),
              itemBuilder: (context, i) {
                final word = widget.words[i];
                return Center(
                  child: Text(
                    word.term,
                    style: Theme.of(context)
                        .textTheme
                        .displayLarge
                        ?.copyWith(color: Colors.white),
                  ),
                );
              },
            ),
            Positioned.fill(
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: _previous,
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: _toggleBars,
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: _next,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                opacity: _showBars ? 1 : 0,
                duration: const Duration(milliseconds: 300),
                child: SafeArea(
                  child: Container(
                    color: Colors.black54,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Expanded(
                          child: Text(
                            widget.words[_currentIndex].term,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            _favorites[widget.words[_currentIndex].id] == true
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.yellow,
                          ),
                          onPressed: _toggleFavorite,
                        ),
                        IconButton(
                          icon: const Icon(Icons.share, color: Colors.white),
                          onPressed: _share,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedOpacity(
                opacity: _showBars ? 1 : 0,
                duration: const Duration(milliseconds: 300),
                child: SafeArea(
                  child: Slider(
                    value: _currentIndex.toDouble(),
                    min: 0,
                    max: (widget.words.length - 1).toDouble(),
                    divisions: widget.words.length - 1,
                    onChanged: _onSliderChanged,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
