// lib/tabs_content/favorites_tab_content.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../flashcard_model.dart';
import '../app_view.dart';
import '../flashcard_repository.dart';
import '../star_color.dart';
import '../constants.dart';

class FavoritesTabContent extends StatefulWidget {
  final Function(AppScreen screen, {ScreenArguments? args}) navigateTo;

  const FavoritesTabContent({Key? key, required this.navigateTo})
      : super(key: key);

  @override
  _FavoritesTabContentState createState() => _FavoritesTabContentState();
}

class _FavoritesTabContentState extends State<FavoritesTabContent> {
  late Box<Map> _favoritesBox;
  List<Flashcard> _allFlashcards = [];
  bool _isInitialLoading = true;
  String? _initialError;
  final Set<StarColor> _activeFilters = {};
  bool _useAndFilter = true; // true: AND, false: OR

  @override
  void initState() {
    super.initState();
    _favoritesBox = Hive.box<Map>(favoritesBoxName);
    _loadAllFlashcards();
  }

  Future<void> _loadAllFlashcards() async {
    if (!mounted) return;
    setState(() {
      _isInitialLoading = true;
      _initialError = null;
    });

    try {
      final loadedCards = await FlashcardRepository.loadAll();
      if (!mounted) return;
      setState(() {
        _allFlashcards = loadedCards;
        _isInitialLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _initialError = '単語データの読み込みに失敗しました。';
        _isInitialLoading = false;
      });
    }
  }

  Widget _buildFavoriteStarsIndicator(String wordId) {
    final Map<dynamic, dynamic>? favoriteStatusRaw = _favoritesBox.get(wordId);
    if (favoriteStatusRaw == null) return SizedBox.shrink();

    final Map<String, bool> favoriteStatus =
        favoriteStatusRaw.map((k, v) => MapEntry(k.toString(), v as bool));

    List<Widget> stars = [];
    if (favoriteStatus[StarColor.red.name] == true) {
      stars.add(Icon(Icons.star,
          color: Theme.of(context).colorScheme.error, size: 16));
    }
    if (favoriteStatus[StarColor.yellow.name] == true) {
      stars.add(Icon(Icons.star,
          color: Theme.of(context).colorScheme.secondary, size: 16));
    }
    if (favoriteStatus[StarColor.blue.name] == true) {
      stars.add(Icon(Icons.star,
          color: Theme.of(context).colorScheme.primary, size: 16));
    }
    if (stars.isEmpty) return SizedBox.shrink(); // どの星もONでなければ何も表示しない
    return Row(mainAxisSize: MainAxisSize.min, children: stars);
  }

  void _toggleFilter(StarColor colorKey) {
    setState(() {
      if (_activeFilters.contains(colorKey)) {
        _activeFilters.remove(colorKey);
      } else {
        _activeFilters.add(colorKey);
      }
    });
  }

  Widget _buildFilterStar(StarColor colorKey, Color color) {
    final bool isSelected = _activeFilters.contains(colorKey);
    return IconButton(
      icon: Icon(
        isSelected ? Icons.star : Icons.star_border,
        color: isSelected ? color : Theme.of(context).colorScheme.outline,
        size: 24,
      ),
      onPressed: () => _toggleFilter(colorKey),
      tooltip:
          '${colorKey == StarColor.red ? '赤' : colorKey == StarColor.yellow ? '黄' : '青'}星で絞り込む',
    );
  }

  bool _passesFilter(Map<String, bool> status) {
    if (_activeFilters.isEmpty) {
      return status.values.any((v) => v == true);
    }
    final wordStars = status.entries
        .where((entry) => entry.value == true)
        .map((entry) => StarColor.values.firstWhere((c) => c.name == entry.key))
        .toSet();

    if (_useAndFilter) {
      return wordStars.length == _activeFilters.length &&
          wordStars.every((color) => _activeFilters.contains(color));
    } else {
      return wordStars.any((color) => _activeFilters.contains(color));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('単語データを読込中...', style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      );
    }

    if (_initialError != null) {
      return Center(
          child: Text(
        _initialError!,
        style: Theme.of(context)
            .textTheme
            .bodyLarge
            ?.copyWith(color: Theme.of(context).colorScheme.error),
      ));
    }

    return ValueListenableBuilder<Box<Map>>(
      valueListenable: _favoritesBox.listenable(),
      builder: (context, box, _) {
        // print("FavoritesTab ValueListenableBuilder triggered. Hive box has ${box.length} entries."); // デバッグ用
        List<Flashcard> favoritedFlashcards = [];
        final favoriteKeys = box.keys;
        // print("Favorite keys from Hive: ${favoriteKeys.toList()}"); // デバッグ用

        for (var key in favoriteKeys) {
          final String wordId = key as String;
          final Map<dynamic, dynamic>? favoriteStatusRaw = box.get(wordId);
          // print("Processing key: $wordId, raw status: $favoriteStatusRaw"); // デバッグ用

          if (favoriteStatusRaw != null) {
            final Map<String, bool> favoriteStatus = favoriteStatusRaw
                .map((k, v) => MapEntry(k.toString(), v as bool));
            if (_passesFilter(favoriteStatus)) {
              try {
                // orElse を使って、見つからない場合にエラーを回避するか、明確にログを出す
                final flashcard = _allFlashcards
                    .firstWhere((card) => card.id == wordId, orElse: () {
                  // print("!!! CRITICAL: Flashcard with id '$wordId' NOT FOUND in _allFlashcards during favorite filtering !!!");
                  // ここでエラーをスローする代わりに、見つからなかったことを示すダミーを返すか、リストに追加しない
                  // 今回はエラーをスローせずにスキップするために、nullを返すような処理はできないので、
                  // リストに追加しないようにする（firstWhereは要素が見つからないとエラーをスローする）
                  // そのため、先にIDが存在するか確認する方が安全
                  throw StateError("Flashcard with id '$wordId' not found.");
                });
                // print("Found favorited flashcard: ${flashcard.term}"); // デバッグ用
                favoritedFlashcards.add(flashcard);
              } catch (e) {
                // print('Error finding flashcard for $wordId in _allFlashcards: $e'); // デバッグ用
              }
            }
          }
        }
        favoritedFlashcards
            .sort((a, b) => b.importance.compareTo(a.importance));
        // print("Final favoritedFlashcards count: ${favoritedFlashcards.length}"); // デバッグ用

        final listWidget = favoritedFlashcards.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _activeFilters.isEmpty
                        ? 'お気に入り登録された単語はまだありません。\n単語詳細画面で星をタップして登録しましょう！'
                        : '選択した星のお気に入りはありません。',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                        height: 1.5),
                  ),
                ),
              )
            : ListView.builder(
                itemCount: favoritedFlashcards.length,
                itemBuilder: (context, index) {
                  final card = favoritedFlashcards[index];
                  return Card(
                    elevation: 1.0,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 5.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      title: Text(
                        card.term,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 3.0),
                        child: _buildFavoriteStarsIndicator(card.id),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios,
                          size: 14,
                          color: Theme.of(context).colorScheme.outline),
                      onTap: () {
                        widget.navigateTo(
                          AppScreen.wordDetail,
                          args: ScreenArguments(
                            flashcards: favoritedFlashcards,
                            initialIndex: index,
                          ),
                        );
                      },
                    ),
                  );
                },
              );

        return Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ToggleButtons(
                    isSelected: [_useAndFilter, !_useAndFilter],
                    onPressed: (index) {
                      setState(() {
                        _useAndFilter = index == 0;
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
            Expanded(child: listWidget),
          ],
        );
      },
    );
  }
}
