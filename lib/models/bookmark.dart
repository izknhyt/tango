import 'package:hive/hive.dart';

part 'bookmark.g.dart';

@HiveType(typeId: 9)
class Bookmark extends HiveObject {
  @HiveField(0)
  final int pageIndex;

  @HiveField(1)
  DateTime updated;

  Bookmark({required this.pageIndex, DateTime? updated})
      : updated = updated ?? DateTime.now();
}
