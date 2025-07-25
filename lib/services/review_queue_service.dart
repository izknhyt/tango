import 'package:hive/hive.dart';

import '../models/review_queue.dart';
import '../constants.dart';
import '../hive_utils.dart';

class ReviewQueueService {
  final Box<ReviewQueue> _box;

  ReviewQueueService._(this._box);

  ReviewQueueService([Box<ReviewQueue>? box])
      : _box = box ?? Hive.box<ReviewQueue>(reviewQueueBoxName);

  static Future<ReviewQueueService> open() async {
    if (!Hive.isAdapterRegistered(ReviewQueueAdapter().typeId)) {
      Hive.registerAdapter<ReviewQueue>(ReviewQueueAdapter());
    }
    final box = await openTypedBox<ReviewQueue>(reviewQueueBoxName);
    return ReviewQueueService._(box);
  }

  ReviewQueue get _queue => _box.get('queue') ?? ReviewQueue();

  Future<void> push(String id) async {
    final q = _queue;
    q.push(id);
    await _box.put('queue', q);
  }

  Future<void> pushAll(List<String> ids) async {
    final q = _queue;
    for (final id in ids) {
      q.push(id);
    }
    await _box.put('queue', q);
  }

  Future<List<String>> popMany(int n) async {
    final q = _queue;
    final items = q.popMany(n);
    await _box.put('queue', q);
    return items;
  }

  int get size => _queue.size;

  Future<void> clearWeak(String id) async {
    final q = _queue;
    q.clearWeak(id);
    await _box.put('queue', q);
  }
}
