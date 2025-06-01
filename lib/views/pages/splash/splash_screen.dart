import 'package:budgify/views/pages/splash/splash_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  final _controller = SplashController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.initializeAndNavigate(context, ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).appBarTheme.backgroundColor;

    return ValueListenableBuilder<bool>(
      valueListenable: _controller.hasError,
      builder: (context, hasError, _) {
        if (hasError) {
          return _buildErrorScreen(backgroundColor);
        }
        return ValueListenableBuilder<bool>(
          valueListenable: _controller.isInitialized,
          builder: (context, isInitialized, _) {
            return _buildSplashScreen(backgroundColor, isInitialized);
          },
        );
      },
    );
  }

  Widget _buildErrorScreen(Color? backgroundColor) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 60),
            const SizedBox(height: 20),
            const Text(
              'Failed to initialize the app.',
              style: TextStyle(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _controller.retryInitialization(context, ref),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSplashScreen(Color? backgroundColor, bool isInitialized) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Lottie.asset(
              "assets/bud_splash.json",
              width: MediaQuery.of(context).size.width * 0.8,
              fit: BoxFit.contain,
            ),
          ),
          if (!isInitialized) const SizedBox(height: 20),
          if (!isInitialized)
            Center(
              child: Text(
                "Speak money fluently".tr,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}