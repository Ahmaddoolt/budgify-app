import 'package:budgify/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlLauncherButton extends StatelessWidget {
  final String url;
  final String? label;

  const UrlLauncherButton({super.key, required this.url, this.label});

  Future<void> _launchUrl(BuildContext context) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid URL')));
      return;
    }

    try {
      final canLaunch = await canLaunchUrl(uri);
      if (!canLaunch) {
        ScaffoldMessenger.of(
          // ignore: use_build_context_synchronously
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not launch URL')));
        return;
      }

      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication, // Use external browser
      );

      if (!launched) {
        ScaffoldMessenger.of(
          // ignore: use_build_context_synchronously
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to launch URL')));
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(SnackBar(content: Text('Error launching URL: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _launchUrl(context),
      icon: Icon(Icons.public, size: 22, color: AppColors.accentColor),
    );
  }
}
