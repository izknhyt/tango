import 'dart:io';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:tango/controllers/word_history_controller.dart';
import 'package:tango/history_entry_model.dart';
import 'package:tango/services/history_service.dart';
import 'package:tango/flashcard_model.dart';
import 'package:tango/constants.dart';

Flashcard _card(String id) => Flashcard(
      id: id,
      term: id,
      reading: id,
      description: 'd',
      categoryLarge: 'A',
      categoryMedium: 'B',
      categorySmall: 'C',
      categoryItem: 'D',
      importance: 1,
    );

void main() {
  late Directory dir;
  late Box<HistoryEntry> box;
  late HistoryService service;
  late WordHistoryController controller;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp();
    Hive.init(dir.path);
    if (!Hive.isAdapterRegistered(HistoryEntryAdapter().typeId)) {
      Hive.registerAdapter(HistoryEntryAdapter());
    }
    box = await Hive.openBox<HistoryEntry>(historyBoxName);
    service = HistoryService(box);
    controller = WordHistoryController(service);
  });

  tearDown(() async {
    controller.dispose();
    await box.close();
    await Hive.deleteBoxFromDisk(historyBoxName);
    await Hive.close();
    await dir.delete(recursive: true);
  });

  test('records view after delay', () {
    fakeAsync((async) {
      controller.initialize([_card('1')], 0);
      async.elapse(const Duration(seconds: 5));
      async.flushMicrotasks();
    });
    expect(box.get('1'), isNotNull);
  });

  test('cancels record if page changes quickly', () {
    fakeAsync((async) {
      controller.initialize([_card('1'), _card('2')], 0);
      controller.setPage(1);
      async.elapse(const Duration(seconds: 5));
      async.flushMicrotasks();
    });
    expect(box.get('1'), isNull);
    expect(box.get('2'), isNotNull);
  });
}
