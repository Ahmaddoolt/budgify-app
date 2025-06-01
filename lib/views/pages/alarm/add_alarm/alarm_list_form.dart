import 'package:budgify/views/pages/alarm/add_alarm/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:budgify/core/themes/app_colors.dart';
import 'package:budgify/views/pages/alarm/alarmfunctions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlarmListForm extends StatefulWidget {
  final VoidCallback onAlarmSet;
  final Function(String, {bool isError}) onFeedback;
  final Set<int> repeatingAlarmIds;
  final Function(Set<int>) updateRepeatingAlarmIds;

  const AlarmListForm({
    super.key,
    required this.onAlarmSet,
    required this.onFeedback,
    required this.repeatingAlarmIds,
    required this.updateRepeatingAlarmIds,
  });

  @override
  State<AlarmListForm> createState() => _AlarmListFormState();
}

class _AlarmListFormState extends State<AlarmListForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  DateTime? _selectedDateTime;
  bool _isSaving = false;
  bool _repeatMonthly = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final theme = Theme.of(context);
    final Color pickerPrimaryColor = AppColors.accentColor;
    final Color pickerOnPrimaryColor = theme.colorScheme.onPrimary;

    DateTime now = DateTime.now();
    DateTime initialSelectDate =
        _selectedDateTime ?? now.add(const Duration(minutes: 1));
    if (initialSelectDate.isBefore(now)) {
      initialSelectDate = now.add(const Duration(minutes: 1));
    }
    final TimeOfDay initialTime = TimeOfDay.fromDateTime(initialSelectDate);

    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: initialSelectDate,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      helpText: "",
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: pickerPrimaryColor,
              onPrimary: pickerOnPrimaryColor,
              surface: theme.cardColor,
              onSurface: theme.textTheme.bodyLarge?.color,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: pickerPrimaryColor),
            ),
            dialogTheme: DialogTheme(
              backgroundColor: theme.scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kCardRadius),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (date == null || !mounted) return;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: '',
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: pickerPrimaryColor,
              onPrimary: pickerOnPrimaryColor,
              surface: theme.cardColor,
              onSurface: theme.textTheme.bodyLarge?.color,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: pickerPrimaryColor),
            ),
            timePickerTheme: TimePickerThemeData(
              dialBackgroundColor:
                  Theme.of(context).appBarTheme.backgroundColor,
              backgroundColor: theme.cardColor,
              hourMinuteTextColor: Colors.white,
              dialHandColor: pickerPrimaryColor,
              dialTextColor: theme.textTheme.bodyLarge?.color,
              entryModeIconColor: pickerPrimaryColor,
            ),
            dialogTheme: DialogTheme(
              backgroundColor: theme.scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kCardRadius),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (time == null || !mounted) return;

    var potentialDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    if (potentialDateTime.isBefore(
      DateTime.now().add(const Duration(seconds: 10)),
    )) {
      widget.onFeedback(
        "Please select a time at least a few seconds in the future.".tr,
        isError: true,
      );
      return;
    }
    setState(() {
      _selectedDateTime = potentialDateTime;
    });
  }

  Future<void> _setAlarm() async {
    if (_selectedDateTime == null) {
      widget.onFeedback('Please select a date and time.'.tr, isError: true);
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final alarmId = DateTime.now().millisecondsSinceEpoch % 100000;
    final String title =
        _titleController.text.trim().isNotEmpty
            ? _titleController.text.trim()
            : 'Budgify Reminder'.tr;

    try {
      debugPrint(
        "FORM: Calling setAlarm() for ID: $alarmId at $_selectedDateTime",
      );
      await setAlarm(_selectedDateTime!, alarmId, title);
      debugPrint("FORM: Alarm set successfully for ID $alarmId");

      if (mounted) {
        if (_repeatMonthly) {
          final newIds = {...widget.repeatingAlarmIds, alarmId};
          widget.updateRepeatingAlarmIds(newIds);
          // Save to SharedPreferences immediately
          final List<String> idStrings =
              newIds.map((id) => id.toString()).toList();
          final prefs = await SharedPreferences.getInstance();
          await prefs.setStringList(repeatMonthlyPrefsKey, idStrings);
          debugPrint("FORM: Saved repeating IDs to SharedPreferences: $newIds");
        }
        widget.onFeedback(
          'Alarm set for ${_formatDateTime(_selectedDateTime)}${_repeatMonthly ? ' (repeats monthly)' : ''}',
        );
        _resetForm();
        widget.onAlarmSet();
      }
    } catch (e) {
      debugPrint("FORM: Error setting alarm: $e");
      if (mounted) {
        widget.onFeedback(
          'An error occurred setting the alarm: $e',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _titleController.clear();
    if (mounted) {
      setState(() {
        _selectedDateTime = null;
        _repeatMonthly = false;
      });
    }
    FocusScope.of(context).unfocus();
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return 'Tap to select Date & Time'.tr;
    return DateFormat('EEE, MMM d \'at\' hh:mm a').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(kPadding),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: kPadding * 0.75),
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: 'Alarm Title (Optional)'.tr,
                  labelStyle: TextStyle(color: Colors.white),
                  hintText: 'E.g., Pay Rent, Take Pills'.tr,
                  prefixIcon: Icon(
                    Icons.label_outline,
                    color: AppColors.accentColor,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(kCardRadius),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(kCardRadius),
                    borderSide: BorderSide(
                      color: theme.dividerColor.withAlpha(150),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.accentColor,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(kCardRadius),
                  ),
                  filled: true,
                  fillColor:
                      theme.inputDecorationTheme.fillColor ??
                      theme.colorScheme.surfaceContainerHighest.withAlpha(75),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: kPadding,
                    vertical: kPadding * 0.9,
                  ),
                ),
                validator: (value) {
                  return null;
                },
              ),
              const SizedBox(height: kPadding * 1.25),
              Card(
                elevation: 1,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(kCardRadius),
                  side: BorderSide(
                    color: applyOpacity(theme.dividerColor, 0.5),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: _pickDateTime,
                  borderRadius: BorderRadius.circular(kCardRadius),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: kPadding,
                      vertical: kPadding * 0.85,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          color: AppColors.accentColor,
                          size: 28,
                        ),
                        const SizedBox(width: kPadding),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Date & Time'.tr,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDateTime(_selectedDateTime),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color:
                                      _selectedDateTime == null
                                          ? theme.hintColor
                                          : null,
                                  fontStyle:
                                      _selectedDateTime == null
                                          ? FontStyle.italic
                                          : FontStyle.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 18,
                          color: applyOpacity(theme.hintColor, 0.7),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_selectedDateTime == null)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, left: 12.0),
                  child: Text(
                    'Required'.tr,
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(height: kPadding),
              SwitchListTile(
                title: Text(
                  'Repeat Monthly'.tr,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Alarm will reschedule monthly after it rings.'.tr,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
                value: _repeatMonthly,
                onChanged: (bool value) {
                  setState(() {
                    _repeatMonthly = value;
                  });
                },
                activeColor: AppColors.accentColor,
                activeTrackColor: AppColors.accentColor,
                secondary: Icon(
                  Icons.repeat,
                  color:
                      _repeatMonthly ? AppColors.accentColor : theme.hintColor,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: kPadding / 2,
                ),
                visualDensity: VisualDensity.compact,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(kCardRadius * 0.75),
                ),
                tileColor: applyOpacity(
                  theme.colorScheme.surfaceContainerHighest,
                  0.2,
                ),
              ),
              const SizedBox(height: kPadding * 1.5),
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _setAlarm,
                icon:
                    _isSaving
                        ? Container(
                          width: 20,
                          height: 20,
                          padding: const EdgeInsets.all(2.0),
                          child: CircularProgressIndicator(
                            color: theme.colorScheme.onPrimary,
                            strokeWidth: 3,
                          ),
                        )
                        : Icon(
                          Icons.alarm_add_rounded,
                          color: theme.colorScheme.onPrimary,
                        ),
                label: Text(
                  _isSaving ? 'Saving...'.tr : 'Set Alarm'.tr,
                  style: TextStyle(color: theme.colorScheme.onPrimary),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentColor,
                  padding: const EdgeInsets.symmetric(vertical: kPadding * 0.9),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(kCardRadius * 1.5),
                  ),
                  elevation: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
