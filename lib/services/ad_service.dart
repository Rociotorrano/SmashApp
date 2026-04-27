import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pantheon/ad_helper.dart';
import 'package:flutter/foundation.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  bool isPremium = false;
  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoading = false;

  Future<void> init() async {
    if (isPremium) return;
    await MobileAds.instance.initialize();
  }

  BannerAd createBannerAd({
    required Function(Ad) onAdLoaded,
    required Function(Ad, LoadAdError) onAdFailedToLoad,
  }) {
    return BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          onAdFailedToLoad(ad, error);
        },
      ),
    );
  }

  void loadInterstitialAd() {
    if (isPremium || _isInterstitialLoading || _interstitialAd != null) return;

    _isInterstitialLoading = true;

    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoading = false;
          debugPrint('InterstitialAd loaded.');

          _interstitialAd!.fullScreenContentCallback =
              FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              debugPrint('InterstitialAd dismissed.');
              ad.dispose();
              _interstitialAd = null;
              loadInterstitialAd(); // Reload automatically as requested
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('InterstitialAd failed to show: $error');
              ad.dispose();
              _interstitialAd = null;
              loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('InterstitialAd failed to load: $error');
          _interstitialAd = null;
          _isInterstitialLoading = false;
        },
      ),
    );
  }

  void showInterstitialAd() {
    if (isPremium) {
      debugPrint('Ad omitted: User is Premium');
      return;
    }

    if (_interstitialAd == null) {
      debugPrint('Ad not ready yet, loading it for next time.');
      loadInterstitialAd();
      return;
    }

    _interstitialAd!.show();
  }
}
