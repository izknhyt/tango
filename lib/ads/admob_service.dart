import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Provides initialization and ad loading helpers for AdMob.
class AdmobService {
  /// Default test ad unit ID for banner ads. Replace with a real ID for release.
  static const String bannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';

  /// Default test ad unit ID for interstitial ads. Replace with a real ID later.
  static const String interstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';

  /// Initialize the Google Mobile Ads SDK.
  static Future<InitializationStatus> initialize() {
    return MobileAds.instance.initialize();
  }

  /// Create a banner [BannerAd]. Call `load()` on the returned instance.
  static BannerAd createBannerAd({String? adUnitId}) {
    return BannerAd(
      adUnitId: adUnitId ?? bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: const BannerAdListener(),
    );
  }

  /// Load an interstitial ad and receive the [InterstitialAd] in [onAdLoaded].
  static Future<void> loadInterstitialAd({
    String? adUnitId,
    required void Function(InterstitialAd ad) onAdLoaded,
    void Function(LoadAdError error)? onAdFailedToLoad,
  }) {
    return InterstitialAd.load(
      adUnitId: adUnitId ?? interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad ?? (LoadAdError error) {},
      ),
    );
  }
}
