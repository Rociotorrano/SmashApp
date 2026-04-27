import 'dart:io';
import 'package:flutter/foundation.dart';

class AdHelper {
  // Real IDs from user
  static const String androidAppId = 'ca-app-pub-3940256099942544~3347511713';
  // 'ca-app-pub-2614775856970860~6806588366'
  static const String androidBannerUnitId =
      'ca-app-pub-2614775856970860/7189296971';
  static const String androidInterstitialUnitId =
      'ca-app-pub-2614775856970860/5900700807';

  // Test IDs from Google
  static const String testBannerUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String testInterstitialUnitId =
      'ca-app-pub-3940256099942544/1033173712';

  static String get bannerAdUnitId {
    if (kDebugMode) {
      return testBannerUnitId;
    }
    if (Platform.isAndroid) {
      return androidBannerUnitId;
    }
    // Placeholder for iOS if needed
    return testBannerUnitId;
  }

  static String get interstitialAdUnitId {
    if (kDebugMode) {
      return testInterstitialUnitId;
    }
    if (Platform.isAndroid) {
      return androidInterstitialUnitId;
    }
    // Placeholder for iOS if needed
    return testInterstitialUnitId;
  }
}
