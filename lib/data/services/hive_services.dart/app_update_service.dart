import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- UPDATED CLASS ---
// A class to hold the result of our check, now including optional updates.
class UpdateResult {
  final bool isForced;
  final bool isOptional; // <-- ADDED
  final String storeUrl;

  UpdateResult({
    required this.isForced,
    required this.isOptional, // <-- ADDED
    this.storeUrl = '',
  });
}

class AppUpdateService {
  final _supabase = Supabase.instance.client;

  Future<UpdateResult> checkForUpdate() async {
    try {
      // 1. Get the app's current version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      debugPrint("UPDATE_CHECK: Current App Version: $currentVersion");

      // 2. Determine the platform (android or ios)
      final platform =
          defaultTargetPlatform == TargetPlatform.android ? 'android' : 'ios';

      // 3. Fetch the config from Supabase (including latest_version)
      final response = await _supabase
          .from('app_config')
          .select(
              'minimum_version, latest_version, store_url') // <-- UPDATED QUERY
          .eq('platform', platform)
          .single();

      final minimumVersion = response['minimum_version'] as String;
      final latestVersion = response['latest_version'] as String; // <-- ADDED
      final storeUrl = response['store_url'] as String;

      debugPrint("UPDATE_CHECK: Required Minimum Version: $minimumVersion");
      debugPrint("UPDATE_CHECK: Available Latest Version: $latestVersion");

      // 4. Compare versions
      final isForceUpdateNeeded =
          _isUpdateRequired(currentVersion, minimumVersion);

      // --- UPDATED LOGIC ---
      // Priority 1: Check for a forced update.
      if (isForceUpdateNeeded) {
        return UpdateResult(
          isForced: true,
          isOptional: false, // An optional update is irrelevant if it's forced.
          storeUrl: storeUrl,
        );
      }

      // Priority 2: If not forced, check for an optional update.
      final isOptionalUpdateNeeded =
          _isUpdateRequired(currentVersion, latestVersion);

      if (isOptionalUpdateNeeded) {
        return UpdateResult(
          isForced: false,
          isOptional: true,
          storeUrl: storeUrl,
        );
      }

      // If neither is true, the app is up-to-date.
      return UpdateResult(isForced: false, isOptional: false);
    } catch (e) {
      debugPrint(
        "UPDATE_CHECK: Error checking for update: $e. Allowing app to continue.",
      );
      // If there's any error, we don't block the user.
      return UpdateResult(isForced: false, isOptional: false);
    }
  }

  // Helper function for version comparison. No changes needed here.
  // Returns true if currentVersion is less than requiredVersion.
  bool _isUpdateRequired(String currentVersion, String requiredVersion) {
    // Return false if requiredVersion is empty or null to avoid errors
    if (requiredVersion.isEmpty) {
      return false;
    }

    final currentParts = currentVersion.split('.').map(int.parse).toList();
    final requiredParts = requiredVersion.split('.').map(int.parse).toList();

    for (var i = 0; i < requiredParts.length; i++) {
      if (i >= currentParts.length) {
        return true; // e.g., current 1.2, required 1.2.1
      }
      if (currentParts[i] < requiredParts[i]) {
        return true; // e.g., current 1.1, required 1.2
      }
      if (currentParts[i] > requiredParts[i]) {
        return false; // e.g., current 1.3, required 1.2
      }
    }
    return false; // Versions are identical
  }
}
