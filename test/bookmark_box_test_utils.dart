import 'dart:io';
import 'package:hive/hive.dart';
import 'package:tango/models/bookmark.dart';
import 'package:tango/constants.dart';

typedef BookmarkContext = ({Directory dir, Box<Bookmark> box});

Future<BookmarkContext> initBookmarkBox() async {
  final dir = await Directory.systemTemp.createTemp();
  Hive.init(dir.path);
  if (!Hive.isAdapterRegistered(BookmarkAdapter().typeId)) {
    Hive.registerAdapter(BookmarkAdapter());
  }
  final box = await Hive.openBox<Bookmark>(bookmarksBoxName);
  return (dir: dir, box: box);
}

Future<void> cleanBookmarkBox(BookmarkContext ctx) async {
  await ctx.box.close();
  await Hive.deleteBoxFromDisk(bookmarksBoxName);
  await Hive.close();
  await ctx.dir.delete(recursive: true);
}
