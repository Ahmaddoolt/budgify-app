// import 'package:google_mobile_ads/google_mobile_ads.dart';

// class RewardedAdManager {
//   RewardedAd? _rewardedAd;
//   bool _isAdLoaded = false;

//   /// Loads a rewarded ad.
//   void loadAd() {
//     RewardedAd.load(
//       adUnitId: 'ca-app-pub-3940256099942544/5224354917', // Test Ad Unit ID
//       request: const AdRequest(),
//       rewardedAdLoadCallback: RewardedAdLoadCallback(
//         onAdLoaded: (RewardedAd ad) {
//           _rewardedAd = ad;
//           _isAdLoaded = true;

//           // Set the full-screen content callback
//           _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
//             onAdDismissedFullScreenContent: (RewardedAd ad) {
//               ad.dispose();
//               _isAdLoaded = false; // Mark ad as not loaded
//               loadAd(); // Preload a new ad for future use
//             },
//             onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
//               ad.dispose();
//               _isAdLoaded = false; // Handle ad failing to show
//             },
//             onAdShowedFullScreenContent: (RewardedAd ad) {
//               // Optionally handle when the ad starts showing
//             },
//           );
//         },
//         onAdFailedToLoad: (LoadAdError error) {
//           _isAdLoaded = false; // Mark ad as not loaded
//           // print('Failed to load rewarded ad: $error');
//         },
//       ),
//     );
//   }

//   /// Displays the rewarded ad if it is loaded.
//   /// Requires a callback to handle when the user earns the reward.
//   void showAd({required Function(RewardItem reward) onUserEarnedReward}) {
//     if (_isAdLoaded && _rewardedAd != null) {
//       _rewardedAd?.show(
//         onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
//           onUserEarnedReward(reward);
//         },
//       );
//       _rewardedAd = null; // Clear the reference to the shown ad
//       _isAdLoaded = false; // Mark ad as not loaded
//     } else {
//       // print("Rewarded Ad not ready to show.");
//     }
//   }

//   /// Disposes the rewarded ad manually (optional).
//   void dispose() {
//     _rewardedAd?.dispose();
//   }
// }
