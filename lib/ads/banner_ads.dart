import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdWidget extends StatefulWidget {
  final double width;

  const BannerAdWidget({
    super.key,
    required this.width,
  });

  @override
  // ignore: library_private_types_in_public_api
  _BannerAdWidgetState createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  double _adHeight = 0; // Variable to store the actual ad height

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  Future<void> _loadBannerAd() async {
    final adSize =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      widget.width.toInt(),
    );

    if (adSize != null) {
      _adHeight = adSize.height.toDouble(); // Update ad height
      _bannerAd = BannerAd(
        adUnitId: 'ca-app-pub-3940256099942544/6300978111', // Test Ad Unit ID
        size: adSize,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (_) {
            setState(() {
              _isAdLoaded = true;
            });
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            debugPrint('Ad failed to load: $error');
          },
        ),
      )..load();
    } else {
      debugPrint('Failed to get adaptive ad size.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _isAdLoaded && _bannerAd != null
          ? SizedBox(
              height: _adHeight, // Use the actual ad height
              width: widget.width, // Use the provided width
              child: AdWidget(ad: _bannerAd!),
            )
          : const SizedBox(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
}
