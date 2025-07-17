import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:tango/history_screen.dart';
import 'package:tango/models/session_log.dart';
import 'package:tango/constants.dart';

void main() {
  setUp(() async {
    Hive.init('./testdb_empty');
    if (!Hive.isAdapterRegistered(SessionLogAdapter().typeId)) {
      Hive.registerAdapter(SessionLogAdapter());
    }
    await Hive.openBox<SessionLog>(sessionLogBoxName);
  });

  tearDown(() async {
    await Hive.deleteBoxFromDisk(sessionLogBoxName);
    await Hive.close();
    Hive.reset();
    final dir = Directory('./testdb_empty');
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  testWidgets('shows empty message when no data', (tester) async {
    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(home: HistoryScreen()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('データがありません'), findsOneWidget);
  });
}
