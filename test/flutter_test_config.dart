// test/flutter_test_config.dart
import 'dart:async';
import 'test_harness.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await setUpHive();
  await testMain();
  await tearDownHive();
}
