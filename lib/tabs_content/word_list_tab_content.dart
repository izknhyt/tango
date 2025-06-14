// lib/tabs_content/word_list_tab_content.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../flashcard_model.dart'; // lib/flashcard_model.dart
// import '../word_detail_screen.dart'; // MainScreen が管理するので直接は不要

class WordListTabContent extends StatefulWidget {
  final Function(List<Flashcard>, int) onWordTap; // 単語タップ時のコールバック

  const WordListTabContent({Key? key, required this.onWordTap})
      : super(key: key);

  @override
  _WordListTabContentState createState() => _WordListTabContentState();
}

class _WordListTabContentState extends State<WordListTabContent> {
  List<Flashcard> _allFlashcards = []; // JSONから読み込んだ全データ
  List<Flashcard> _filteredFlashcards = []; // 表示用（フィルタリング後）のデータ
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFlashcards();
    // 検索コントローラーの入力変更を監視し、フィルタリングを実行
    _searchController.addListener(_performFiltering);
  }

  @override
  void dispose() {
    _searchController.removeListener(_performFiltering); // リスナーを解除
    _searchController.dispose(); // コントローラーを破棄
    super.dispose();
  }

  Future<void> _loadFlashcards() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/words.json',
      );
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
          } else {
            // print('Skipping invalid item: ${item['id']}');
          }
        } catch (e) {
          // print('Error parsing item ${item['id']}: $e');
        }
      }
      // importance（重要度）の降順でソート
      loadedCards.sort((a, b) => b.importance.compareTo(a.importance));

      setState(() {
        _allFlashcards = loadedCards;
        _filteredFlashcards = loadedCards; // 初期状態ではフィルタリングせず全件表示
        _isLoading = false;
      });
    } catch (e) {
      // print('Failed to load words.json: $e');
      setState(() {
        _error = '単語データの読み込みに失敗しました。';
        _isLoading = false;
      });
    }
  }

  // 検索クエリに基づいて表示する単語リストをフィルタリングするメソッド
  void _performFiltering() {
    final query = _searchController.text.toLowerCase().trim(); // 入力の前後の空白を削除
    setState(() {
      if (query.isEmpty) {
        _filteredFlashcards = _allFlashcards; // クエリが空なら全件表示
      } else {
        _filteredFlashcards = _allFlashcards.where((card) {
          final termMatch = card.term.toLowerCase().contains(query);
          final readingMatch = card.reading.toLowerCase().contains(query);
          // 必要であれば他のフィールドも検索対象に追加
          // final descriptionMatch = card.description.toLowerCase().contains(query);
          return termMatch || readingMatch; // || descriptionMatch;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('単語を読込中...', style: TextStyle(fontSize: 16)),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Text(_error!, style: TextStyle(color: Colors.red, fontSize: 16)),
      );
    }

    // 検索バーは常に表示し、結果がない場合のメッセージはListViewの部分で制御
    // if (_allFlashcards.isEmpty && _searchController.text.isEmpty) {
    //   return Center(child: Text('登録されている単語がありません。', style: TextStyle(fontSize: 16)));
    // }

    return Column(
      children: [
        _buildSearchBar(context),
        if (_filteredFlashcards.isEmpty) // フィルタリングの結果、該当なしの場合
          Expanded(
            child: Center(
              child: Text(
                _searchController.text.isEmpty &&
                        _allFlashcards.isEmpty // 初期データも空の場合
                    ? '登録されている単語がありません。'
                    : '検索結果に一致する単語がありません。',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: _filteredFlashcards.length,
              itemBuilder: (context, index) {
                final card = _filteredFlashcards[index];
                return Card(
                  elevation: 1.0,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 5.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 16.0,
                    ),
                    title: Text(
                      card.term,
                      style: TextStyle(
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
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 6.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '単語名または読み方で検索...',
          prefixIcon: Icon(
            Icons.search,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey[600]),
                  onPressed: () {
                    _searchController.clear(); // 検索窓をクリア
                    // _performFiltering(); // クリア時にもフィルタリングを実行
                  },
                )
              : null,
          filled: true,
          fillColor: Theme.of(context).brightness == Brightness.light
              ? Colors.grey[100]
              : Colors.grey[800],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        ),
        // onChanged: (value) { // 入力ごとにフィルタリングする場合 (addListenerの代わり)
        //   _performFiltering();
        // },
      ),
    );
  }
}
