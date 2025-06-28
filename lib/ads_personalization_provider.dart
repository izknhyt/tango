import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive/hive.dart';

import 'constants.dart';

final bannerReloadProvider = StateProvider<int>((ref) => 0);

void reloadBannerAds(Ref ref) {
  ref.read(bannerReloadProvider.notifier).state++;
}

class AdsPersonalizationNotifier extends StateNotifier<bool> {
  AdsPersonalizationNotifier(this._box, this._ref) : super(false);

  final Ref _ref;
  final Box _box;
  static const String key = 'adsPersonalized';

  Future<void> load() async {
    final stored = _box.get(key);
    final value = stored is bool ? stored : false;
    state = value;
    await _applyConfig(value);
  }

  Future<void> setPersonalized(bool value) async {
    state = value;
    await _box.put(key, value);
    await _applyConfig(value);
  }

  Future<void> toggle() async {
    await setPersonalized(!state);
    reloadBannerAds(_ref);
  }

  bool get hasValue => _box.containsKey(key);

  Future<void> _applyConfig(bool personalized) {
    if (personalized) {
      return MobileAds.instance
          .updateRequestConfiguration(RequestConfiguration());
    } else {
      return MobileAds.instance.updateRequestConfiguration(RequestConfiguration(
        testDeviceIds: [],
        tagForChildDirectedTreatment: TagForChildDirectedTreatment.unspecified,
        maxAdContentRating: MaxAdContentRating.g,
      ));
    }
  }
}

final adsPersonalizationProvider =
    StateNotifierProvider<AdsPersonalizationNotifier, bool>((ref) {
  final box = Hive.box(settingsBoxName);
  final notifier = AdsPersonalizationNotifier(box, ref);
  notifier.load();
  return notifier;
});
