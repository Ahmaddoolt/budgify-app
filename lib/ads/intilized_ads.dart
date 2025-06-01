import 'package:google_mobile_ads/google_mobile_ads.dart';

class InterstitialAdManager {
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;

  /// Loads an interstitial ad.
  void loadAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712', // Test Ad Unit ID
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _isAdLoaded = true;

          // Set the full-screen content callback
          _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
              ad.dispose();
              _isAdLoaded = false; // Mark ad as not loaded
              loadAd(); // Preload a new ad for future use
            },
            onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
              ad.dispose();
              _isAdLoaded = false; // Handle ad failing to show
            },
            onAdShowedFullScreenContent: (InterstitialAd ad) {
              // Optionally handle when the ad starts showing
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          _isAdLoaded = false; // Mark ad as not loaded
          // print('Failed to load interstitial ad: $error');
        },
      ),
    );
  }

  /// Displays the interstitial ad if it is loaded.
  void showAd() {
    if (_isAdLoaded && _interstitialAd != null) {
      _interstitialAd?.show();
      _interstitialAd = null; // Clear the reference to the shown ad
      _isAdLoaded = false; // Mark ad as not loaded
    } else {
      // print("Ad not ready to show.");
    }
  }

  /// Disposes the interstitial ad manually (optional).
  void dispose() {
    _interstitialAd?.dispose();
  }
}
