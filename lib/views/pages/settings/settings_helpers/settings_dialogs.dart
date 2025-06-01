import 'package:budgify/core/themes/app_colors.dart';
import 'package:flutter/material.dart';


class SettingsDialogs {
  static Future<bool?> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String content,
    required String confirmText,
    required String cancelText,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.warning_rounded,
              color: AppColors.accentColor2,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        content: Text(content, style: const TextStyle(fontSize: 14)),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              cancelText,
              style: TextStyle(
                color: Theme.of(context).hintColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              confirmText,
              style: const TextStyle(
                color: AppColors.accentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}