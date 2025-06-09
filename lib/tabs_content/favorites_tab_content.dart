// lib/tabs_content/favorites_tab_content.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../flashcard_model.dart';
import '../app_view.dart';

const String favoritesBoxName = 'favorites_box_v2';

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
      final String jsonString =
          await DefaultAssetBundle.of(context).loadString('assets/words.json');
      final List<dynamic> jsonData = json.decode(jsonString) as List<dynamic>;
      List<Flashcard> loadedCards = [];
      for (var item in jsonData) {
        try {
          if (item is Map<String, dynamic> &&
              item['id'] != null &&
              item['id'].toString().toLowerCase() != 'nan' &&
              item['term'] != null &&
              item['term'].toString().toLowerCase() != 'nan' &&
              item['importance'] != null &&
              item['importance'].toString().toLowerCase() != 'nan') {
            loadedCards.add(Flashcard.fromJson(item));
          }
        } catch (e) {
          // print('Error parsing item in favorites load: ${item['id']}: $e');
        }
      }
      if (!mounted) return;
      setState(() {
        _allFlashcards = loadedCards;
        _isInitialLoading = false;
      });
      print(
          "_allFlashcards loaded in FavoritesTab: ${_allFlashcards.length} items"); // デバッグ用
    } catch (e) {
      // print('Failed to load words.json for favorites tab: $e');
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
    if (favoriteStatus['red'] == true) {
      stars.add(Icon(Icons.star, color: Colors.redAccent, size: 16));
    }
    if (favoriteStatus['yellow'] == true) {
      stars.add(Icon(Icons.star, color: Colors.orangeAccent, size: 16));
    }
    if (favoriteStatus['blue'] == true) {
      stars.add(Icon(Icons.star, color: Colors.blueAccent, size: 16));
    }
    if (stars.isEmpty) return SizedBox.shrink(); // どの星もONでなければ何も表示しない
    return Row(mainAxisSize: MainAxisSize.min, children: stars);
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('単語データを読込中...', style: TextStyle(fontSize: 16)),
          ],
        ),
      );
    }

    if (_initialError != null) {
      return Center(
          child: Text(_initialError!,
              style: TextStyle(color: Colors.red, fontSize: 16)));
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
            if (favoriteStatus['red'] == true ||
                favoriteStatus['yellow'] == true ||
                favoriteStatus['blue'] == true) {
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

        if (favoritedFlashcards.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'お気に入り登録された単語はまだありません。\n単語詳細画面で星をタップして登録しましょう！',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16, color: Colors.grey[700], height: 1.5),
              ),
            ),
          );
        }

        return ListView.builder(
          itemCount: favoritedFlashcards.length,
          itemBuilder: (context, index) {
            final card = favoritedFlashcards[index];
            return Card(
              elevation: 1.0,
              margin:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                title: Text(card.term,
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 3.0),
                  child: _buildFavoriteStarsIndicator(card.id),
                ),
                trailing: Icon(Icons.arrow_forward_ios,
                    size: 14, color: Colors.grey[400]),
                onTap: () {
                  widget.navigateTo(AppScreen.wordDetail,
                      args: ScreenArguments(flashcard: card));
                },
              ),
            );
          },
        );
      },
    );
  }
}
