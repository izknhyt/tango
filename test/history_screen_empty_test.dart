import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:tango/history_screen.dart';
import 'package:tango/models/session_log.dart';
import 'package:tango/constants.dart';
import 'test_harness.dart' hide setUpAll;

void main() {
  late Directory hiveTempDir;

  setUpAll(() async {
    hiveTempDir = await initHiveForTests();
    await openAllBoxes();
  });

  tearDownAll(() async {
    await closeHiveForTests(hiveTempDir);
  });

  testWidgets('shows empty message when no data', (tester) async {
    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(home: HistoryScreen()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('データがありません'), findsOneWidget);
  });
}
