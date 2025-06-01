import 'package:budgify/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class SettingsSectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final double padding;

  const SettingsSectionCard({
    super.key,
    required this.title,
    required this.children,
    this.padding = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      margin: EdgeInsets.only(bottom: padding * 0.8),
      child: Padding(
        padding: EdgeInsets.all(padding * 0.75),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 10.0),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accentColor,
                ),
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: children.length,
              itemBuilder: (context, index) => children[index],
              separatorBuilder: (context, index) => const SizedBox(height: 8),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsSwitchRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final double cardRadius;

  const SettingsSwitchRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.cardRadius = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(cardRadius),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(cardRadius),
            color:
                value
                    ? AppColors.accentColor.withOpacity(0.1)
                    : Colors.transparent,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: AppColors.accentColor,
                inactiveTrackColor: Theme.of(
                  context,
                ).disabledColor.withOpacity(0.3),
                inactiveThumbColor: Theme.of(context).disabledColor,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsNavigationButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color iconColor;
  final double cardRadius;

  const SettingsNavigationButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.iconColor,
    this.cardRadius = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.secondary.withOpacity(0.05),
      borderRadius: BorderRadius.circular(cardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(cardRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: iconColor.withOpacity(0.8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
