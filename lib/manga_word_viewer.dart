import 'package:flutter/material.dart';

import 'models/word.dart';

/// Simple viewer showing [Word] details in a full-screen pager.
class MangaWordViewer extends StatefulWidget {
  final List<Word> words;
  final int initialIndex;

  const MangaWordViewer({
    Key? key,
    required this.words,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<MangaWordViewer> createState() => _MangaWordViewerState();
}

class _MangaWordViewerState extends State<MangaWordViewer> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.8),
      body: SafeArea(
        child: PageView.builder(
          controller: _controller,
          itemCount: widget.words.length,
          itemBuilder: (context, index) {
            final word = widget.words[index];
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      word.term,
                      style: const TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      word.description,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
