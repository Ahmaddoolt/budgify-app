// lib/views/pages/about_app_page.dart

import 'package:budgify/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart'; // Import the package

// Convert the widget to a StatefulWidget
class AboutAppPage extends StatefulWidget {
  const AboutAppPage({super.key});

  @override
  State<AboutAppPage> createState() => _AboutAppPageState();
}

class _AboutAppPageState extends State<AboutAppPage> {
  String _appVersion = '.....'; // Default text while loading

  @override
  void initState() {
    super.initState();
    // Fetch the version information when the widget is first created
    _getAppVersion();
  }

  // Asynchronous method to get the app's version
  Future<void> _getAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      // Combine version and build number for a complete version string
      setState(() {
        _appVersion = packageInfo.version; // This will now show "2.4.4"
      });
    } catch (e) {
      // If there's an error, display a fallback message
      setState(() {
        _appVersion = 'Unknown';
      });
      debugPrint("Could not get app version: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text('About Us'.tr, style: const TextStyle(fontSize: 18)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).iconTheme.color ?? Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.accentColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/1999.jpg',
                    width: 110,
                    height: 110,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
            Text(
              'Budgilo Application'.tr,
              style: TextStyle(
                color:
                    Theme.of(context).textTheme.bodyLarge?.color ??
                    Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'App Version'.tr,
                  style: TextStyle(
                    color:
                        Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withOpacity(0.7) ??
                        Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 10),
                // ================== PROBLEM FIXED HERE ==================
                // Display the dynamically fetched version from the state variable
                Text(
                  _appVersion,
                  style: TextStyle(
                    color:
                        Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withOpacity(0.7) ??
                        Colors.white70,
                    fontSize: 16,
                  ),
                ),
                // =======================================================
              ],
            ),
          ],
        ),
      ),
    );
  }
}
