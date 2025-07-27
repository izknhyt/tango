import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:tango/constants.dart';
import 'package:tango/models/review_queue.dart';
import 'package:tango/services/review_queue_service.dart';
import 'test_harness.dart';

void main() {
  initTestHarness();
  late Box<ReviewQueue> box;
  late ReviewQueueService service;

  setUp(() async {
    box = Hive.box<ReviewQueue>(reviewQueueBoxName);
    service = ReviewQueueService(box);
  });

  tearDown(() async {
    await box.clear();
  });


  test('push limits queue to 200 and drops oldest', () async {
    for (var i = 0; i < 205; i++) {
      await service.push('id\$i');
    }
    expect(service.size, 200);
    expect(await service.popMany(1), ['id5']);
  });

  test('popMany dequeues items in FIFO order', () async {
    await service.pushAll(['a', 'b', 'c', 'd']);
    final popped = await service.popMany(3);
    expect(popped, ['a', 'b', 'c']);
    expect(service.size, 1);
  });
}
