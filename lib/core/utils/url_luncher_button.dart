import 'package:url_launcher/url_launcher.dart';

/// A utility function to launch a URL in an external application (like a browser).
///
/// Throws an [Exception] if the URL is invalid or if it fails to launch for any reason.
/// This allows the calling widget to handle the error (e.g., show a SnackBar or a dialog).
///
/// - [url]: The URL string to launch.
Future<void> launchExternalUrl(String url) async {
  final Uri uri = Uri.parse(url);

  try {
    // Check if the device can launch the given URI
    if (!await canLaunchUrl(uri)) {
      throw Exception('Could not launch $url');
    }

    // Launch the URL. `launchUrl` returns a boolean indicating success.
    // We set it to use an external application (e.g., Chrome, Safari).
    final bool launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched) {
      throw Exception('Failed to launch $url');
    }
  } catch (e) {
    // Re-throw the exception with a more descriptive message
    // to make debugging easier.
    throw Exception('Error launching URL: $url. Reason: $e');
  }
}