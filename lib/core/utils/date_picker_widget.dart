import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../themes/app_colors.dart';

class DatePickerWidget extends StatelessWidget {
  final DateTime initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool isSelected;
  final Function(DateTime) onDateSelected;
  final String? labelText;
  final String? errorText;
  final double borderRadius;

  const DatePickerWidget({
    super.key,
    required this.initialDate,
    required this.onDateSelected,
    this.firstDate,
    this.lastDate,
    this.isSelected = false,
    this.labelText,
    this.errorText,
    this.borderRadius = 12.0,
  });

  Future<void> _selectDate(BuildContext context) async {
    final theme0 = Theme.of(context);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2101),
      helpText: "",
      // helpText: 'SELECT DATE'.tr,
      confirmText: 'Ok'.tr, // Translated "OK"
      cancelText: 'Cancel'.tr,
      builder: (context, child) {

        return Theme(
          data: theme0.copyWith(
            colorScheme: theme0.colorScheme.copyWith(
              primary: AppColors.accentColor,
              onPrimary: Colors.white,
              onSurface: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.accentColor,
              ),
            ),
            dialogTheme: DialogTheme(
              backgroundColor: Colors.red, // ✅ Works in Flutter 3.27+
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: InputDecoration(
          // labelText: labelText ?? 'Date'.tr,
          labelStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
          prefixIcon: Icon(
            Icons.calendar_today,
            color: isSelected ? AppColors.accentColor : AppColors.accentColor2,
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: errorText != null ? Colors.red : Colors.white54,
            ),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.accentColor),
          ),
          errorText: errorText,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isSelected
                  ? DateFormat('yyyy-MM-dd').format(initialDate)
                  : 'Select'.tr,
              style: TextStyle(
                color:
                    isSelected ? AppColors.accentColor : AppColors.accentColor2,
              ),
            ),
            !isSelected
                ? TextButton(
                  onPressed: () => _selectDate(context),
                  child: Text(
                    'Pick Date'.tr,
                    style: TextStyle(color: AppColors.accentColor2),
                  ),
                )
                : IconButton(
                  onPressed: () => _selectDate(context),
                  icon: Icon(Icons.check, color: AppColors.accentColor),
                ),
          ],
        ),
      ),
    );
  }
}
