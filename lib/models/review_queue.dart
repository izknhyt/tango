import 'package:hive/hive.dart';

part 'review_queue.g.dart';

@HiveType(typeId: 6)
class ReviewQueue extends HiveObject {
  @HiveField(0)
  List<String> wordIds;

  ReviewQueue({List<String>? wordIds}) : wordIds = wordIds ?? [];

  /// Current number of items in the queue.
  int get size => wordIds.length;

  /// Push [id] to the tail if not already present.
  /// Keeps at most 200 entries by dropping the oldest one.
  void push(String id) {
    if (wordIds.contains(id)) return;
    wordIds.add(id);
    if (wordIds.length > 200) {
      wordIds.removeAt(0);
    }
  }

  /// Remove and return up to [n] items from the head of the queue.
  List<String> popMany(int n) {
    final count = n.clamp(0, wordIds.length);
    final result = wordIds.take(count).toList();
    wordIds.removeRange(0, count);
    return result;
  }

  /// Remove all occurrences of [id] from the queue.
  void clearWeak(String id) {
    wordIds.removeWhere((e) => e == id);
  }
}
