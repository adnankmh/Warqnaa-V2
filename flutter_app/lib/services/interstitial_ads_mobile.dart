import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

InterstitialAd? _interstitial;
Future<void>? _loading;
DateTime? _lastShown;
bool _sdkReady = false;

String get _interstitialId {
  if (Platform.isAndroid) {
    return const String.fromEnvironment(
      'ADMOB_INTERSTITIAL_ANDROID_ID',
      defaultValue: 'ca-app-pub-3940256099942544/1033173712',
    );
  }
  return const String.fromEnvironment(
    'ADMOB_INTERSTITIAL_IOS_ID',
    defaultValue: 'ca-app-pub-3940256099942544/4411468910',
  );
}

Future<void> initializeInterstitialAds() async {
  if (!Platform.isAndroid && !Platform.isIOS) return;
  try {
    await MobileAds.instance.initialize().timeout(const Duration(seconds: 7));
    _sdkReady = true;
    unawaited(_loadInterstitial());
  } catch (error, stack) {
    _sdkReady = false;
    debugPrint('Interstitial ads disabled for this session: $error\n$stack');
  }
}

Future<void> _loadInterstitial() {
  if (!_sdkReady || _interstitial != null) return Future<void>.value();
  final existing = _loading;
  if (existing != null) return existing;
  final completer = Completer<void>();
  _loading = completer.future;
  InterstitialAd.load(
    adUnitId: _interstitialId,
    request: const AdRequest(),
    adLoadCallback: InterstitialAdLoadCallback(
      onAdLoaded: (ad) {
        _interstitial = ad;
        _loading = null;
        if (!completer.isCompleted) completer.complete();
      },
      onAdFailedToLoad: (error) {
        _interstitial = null;
        _loading = null;
        debugPrint('Interstitial unavailable: $error');
        if (!completer.isCompleted) completer.complete();
      },
    ),
  );
  return completer.future.timeout(const Duration(seconds: 10), onTimeout: () { _loading = null; });
}

Future<bool> showInterstitialAdIfEligible({int minMinutes = 12}) async {
  if (!Platform.isAndroid && !Platform.isIOS) return false;
  final now = DateTime.now();
  if (_lastShown != null && now.difference(_lastShown!).inMinutes < minMinutes) return false;
  if (!_sdkReady) await initializeInterstitialAds();
  if (!_sdkReady) return false;
  if (_interstitial == null) await _loadInterstitial();
  final ad = _interstitial;
  if (ad == null) return false;
  _interstitial = null;
  final completer = Completer<bool>();
  ad.fullScreenContentCallback = FullScreenContentCallback(
    onAdShowedFullScreenContent: (_) => _lastShown = DateTime.now(),
    onAdDismissedFullScreenContent: (closed) {
      closed.dispose();
      if (!completer.isCompleted) completer.complete(true);
      unawaited(_loadInterstitial());
    },
    onAdFailedToShowFullScreenContent: (failed, error) {
      failed.dispose();
      debugPrint('Interstitial failed to show: $error');
      if (!completer.isCompleted) completer.complete(false);
      unawaited(_loadInterstitial());
    },
  );
  ad.show();
  return completer.future.timeout(const Duration(minutes: 2), onTimeout: () => false);
}
