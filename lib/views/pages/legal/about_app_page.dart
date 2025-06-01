import 'package:budgify/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import Get package for .tr

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        // Use translation key for the title
        title: Text('About Us'.tr, style: const TextStyle(fontSize: 18)),
        centerTitle: true,
        leading: IconButton(
          // Keep icon color consistent or use theme
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
                color:
                    AppColors
                        .accentColor, // Consider using Theme.of(context).colorScheme.primary
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  // Optional: Add a subtle shadow
                  BoxShadow(
                    // ignore: deprecated_member_use
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
                    'assets/1999.jpg', // Ensure this asset exists
                    width: 110,
                    height: 110,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25), // Slightly more space
            // Use translation key
            Text(
              'Budgify Application'.tr,
              style: TextStyle(
                // Use theme color for text
                color:
                    Theme.of(context).textTheme.bodyLarge?.color ??
                    Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8), // Slightly more space
            // Use translation key
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'App Version'
                      .tr, // This will now display "Version 1.0.1(93)" or its translation
                  style: TextStyle(
                    // Use a secondary theme color
                    color:
                        Theme.of(
                          context,
                        // ignore: deprecated_member_use
                        ).textTheme.bodyMedium?.color?.withOpacity(0.7) ??
                        Colors.white70,
                    fontSize: 16,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  '1.0.1'
                      .tr, // This will now display "Version 1.0.1(93)" or its translation
                  style: TextStyle(
                    // Use a secondary theme color
                    color:
                        Theme.of(
                          context,
                        // ignore: deprecated_member_use
                        ).textTheme.bodyMedium?.color?.withOpacity(0.7) ??
                        Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
