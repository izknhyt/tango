import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:tango/history_entry_model.dart';
import 'package:tango/services/history_service.dart';
import 'package:tango/constants.dart';

void main() {
  late Directory dir;
  late Box<HistoryEntry> box;
  late HistoryService service;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp();
    Hive.init(dir.path);
    Hive.registerAdapter(HistoryEntryAdapter());
    box = await Hive.openBox<HistoryEntry>(historyBoxName);
    service = HistoryService(box);
  });

  tearDown(() async {
    await box.close();
    await Hive.deleteBoxFromDisk(historyBoxName);
    await dir.delete(recursive: true);
  });

  test('adds unique entries', () async {
    await service.addView('1');
    final ts = box.get('1')!.timestamp;
    await service.addView('1');
    expect(box.length, 1);
    expect(box.get('1')!.timestamp.isAfter(ts), isTrue);
  });
}
