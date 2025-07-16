// test/test_harness.dart
import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart';

// ↓あなたのモデル adapter を import
import 'package:tango/models/word.dart';
import 'package:tango/models/review_queue.dart';
import 'package:tango/models/theme_mode.dart';

Future<void> setUpHive() async {
  await setUpTestHive(); // メモリ上に tempDir
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(WordAdapter());
  if (!Hive.isAdapterRegistered(6)) Hive.registerAdapter(ReviewQueueAdapter());
  if (!Hive.isAdapterRegistered(7)) Hive.registerAdapter(ThemeModeAdapter());
}

Future<void> tearDownHive() async {
  await tearDownTestHive(); // Box close → tempDir 削除
}
