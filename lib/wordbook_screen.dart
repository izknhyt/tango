import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'flashcard_model.dart';
import 'word_detail_content.dart';
import 'services/ad_service.dart';
import 'ads_personalization_provider.dart';

class WordbookScreen extends ConsumerStatefulWidget {
  final List<Flashcard> flashcards;
  final Future<SharedPreferences> Function() prefsProvider;
  const WordbookScreen({
    Key? key,
    required this.flashcards,
    this.prefsProvider = SharedPreferences.getInstance,
  }) : super(key: key);

  @override
  ConsumerState<WordbookScreen> createState() => _WordbookScreenState();
}

class _WordbookScreenState extends ConsumerState<WordbookScreen> {
  static const _bookmarkKey = 'bookmark_pageIndex';
  late PageController _pageController;
  int _currentIndex = 0;
  late BannerAd _bannerAd;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadBookmark();
    final personalized = ref.read(adsPersonalizationProvider);
    _bannerAd = AdService.createBannerAd(nonPersonalized: !personalized)
      ..load();
  }

  Future<void> _loadBookmark() async {
    final prefs = await widget.prefsProvider();
    final index = prefs.getInt(_bookmarkKey) ?? 0;
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_pageController.hasClients) {
        _pageController.jumpToPage(index);
      }
      setState(() {
        _currentIndex = index;
      });
    });
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
    }
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('単語帳'),
            Text(
              '現在 ${_currentIndex + 1} / 全 ${widget.flashcards.length}',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _openSearch,
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.flashcards.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
          _saveBookmark(index);
        },
        itemBuilder: (context, index) {
          return WordDetailContent(
            flashcards: [widget.flashcards[index]],
            initialIndex: 0,
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: SizedBox(
          width: _bannerAd.size.width.toDouble(),
          height: _bannerAd.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd),
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
