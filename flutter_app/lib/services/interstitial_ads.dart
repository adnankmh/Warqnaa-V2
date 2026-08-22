import 'interstitial_ads_stub.dart'
    if (dart.library.io) 'interstitial_ads_mobile.dart' as implementation;

/// R10.1 interstitial advertising is deliberately restricted to non-game
/// transitions. The mobile implementation also enforces a minimum spacing.
class InterstitialAds {
  static Future<void> initialize() => implementation.initializeInterstitialAds();
  static Future<bool> showIfEligible({int minMinutes = 12}) => implementation.showInterstitialAdIfEligible(minMinutes: minMinutes);
}
