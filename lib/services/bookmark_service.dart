import 'package:hive/hive.dart';

import '../constants.dart';
import '../models/bookmark.dart';

class BookmarkService {
  final Box<Bookmark> _box;
  final Box<dynamic> _pageBox;

  BookmarkService([Box<Bookmark>? box, Box<dynamic>? pageBox])
      : _box = box ?? Hive.box<Bookmark>(bookmarksBoxName),
        _pageBox = pageBox ?? Hive.box<dynamic>('bookmark_box');

  Future<void> addBookmark(int pageIndex) async {
    final entry = Bookmark(pageIndex: pageIndex, updated: DateTime.now());
    await _box.put(pageIndex, entry);
  }

  Future<void> removeBookmark(int pageIndex) async {
    await _box.delete(pageIndex);
  }

  bool isBookmarked(int pageIndex) => _box.containsKey(pageIndex);

  List<Bookmark> allBookmarks() {
    final bookmarks = _box.values.toList();
    bookmarks.sort((a, b) => a.pageIndex.compareTo(b.pageIndex));
    return bookmarks;
  }

  Future<int?> fetch() async => _pageBox.get('page') as int?;
}
