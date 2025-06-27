import 'package:hive/hive.dart';

part 'review_queue.g.dart';

@HiveType(typeId: 6)
class ReviewQueue extends HiveObject {
  @HiveField(0)
  List<String> wordIds;

  ReviewQueue({List<String>? wordIds}) : wordIds = wordIds ?? [];
}
