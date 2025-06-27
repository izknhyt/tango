import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import 'constants.dart';

class AnalyticsNotifier extends StateNotifier<bool> {
  AnalyticsNotifier(this._box) : super(false);

  final Box _box;
  static const String key = 'analyticsEnabled';

  Future<void> load() async {
    final stored = _box.get(key);
    state = (stored is bool) ? stored : false;
    try {
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(state);
    } catch (_) {}
  }

  Future<void> setEnabled(bool enable) async {
    state = enable;
    await _box.put(key, enable);
    try {
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(enable);
    } catch (_) {}
  }

  bool get hasValue => _box.containsKey(key);
}

final analyticsProvider = StateNotifierProvider<AnalyticsNotifier, bool>((ref) {
  final box = Hive.box(settingsBoxName);
  final notifier = AnalyticsNotifier(box);
  notifier.load();
  return notifier;
});
