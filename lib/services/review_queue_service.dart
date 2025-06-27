import 'package:hive/hive.dart';

import '../models/review_queue.dart';
import '../constants.dart';

class ReviewQueueService {
  final Box<ReviewQueue> _box;

  ReviewQueueService([Box<ReviewQueue>? box])
      : _box = box ?? Hive.box<ReviewQueue>(reviewQueueBoxName);

  ReviewQueue get _queue => _box.get('queue') ?? ReviewQueue();

  Future<void> pushAll(List<String> ids) async {
    final q = _queue;
    for (final id in ids) {
      if (!q.wordIds.contains(id)) {
        q.wordIds.add(id);
        if (q.wordIds.length > 200) {
          q.wordIds.removeAt(0);
        }
      }
    }
    await _box.put('queue', q);
  }
}
