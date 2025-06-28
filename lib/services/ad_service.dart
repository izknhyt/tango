import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static Future<InitializationStatus> initialize() {
    return MobileAds.instance.initialize();
  }

  /// Ad unit IDs are provided via `--dart-define`.
  static const String bannerAdUnitId =
      String.fromEnvironment('BANNER_AD_UNIT_ID');
  static const String interstitialAdUnitId =
      String.fromEnvironment('INTERSTITIAL_AD_UNIT_ID');

  static BannerAd createBannerAd({String? adUnitId, bool nonPersonalized = false}) {
    return BannerAd(
      adUnitId: adUnitId ?? bannerAdUnitId,
      size: AdSize.banner,
      request: AdRequest(nonPersonalizedAds: nonPersonalized),
      listener: const BannerAdListener(),
    );
  }

  static Future<void> loadInterstitialAd({
    String? adUnitId,
    bool nonPersonalized = false,
    required void Function(InterstitialAd ad) onAdLoaded,
    void Function(LoadAdError error)? onAdFailedToLoad,
  }) {
    return InterstitialAd.load(
      adUnitId: adUnitId ?? interstitialAdUnitId,
      request: AdRequest(nonPersonalizedAds: nonPersonalized),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad ?? (error) {},
      ),
    );
  }

  static Future<void> showInterstitial({bool nonPersonalized = false}) async {
    final completer = Completer<void>();
    await loadInterstitialAd(
      nonPersonalized: nonPersonalized,
      onAdLoaded: (ad) {
        ad.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (ad) {
            ad.dispose();
            completer.complete();
          },
          onAdFailedToShowFullScreenContent: (ad, err) {
            ad.dispose();
            completer.complete();
          },
        );
        ad.show();
      },
      onAdFailedToLoad: (err) => completer.complete(),
    );
    await completer.future;
  }
}
