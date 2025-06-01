// import 'package:flutter/material.dart';
// import 'package:alarm/alarm.dart';
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:budgify/core/themes/app_colors.dart';
// import 'package:budgify/views/alarm/alarmfunctions.dart';

// // --- Constants ---
// const double kPadding = 16.0;
// const double kCardRadius = 12.0;

// // --- Shared Preferences Key (must match the one in main.dart) ---
// const String _repeatMonthlyPrefsKey = 'repeatMonthlyAlarmIds';

// class AlarmListPage extends StatefulWidget {
//   const AlarmListPage({super.key});

//   @override
//   State<AlarmListPage> createState() => _AlarmListPageState();
// }

// class _AlarmListPageState extends State<AlarmListPage> {
//   List<AlarmSettings> _alarms = [];
//   bool _loadingAlarms = true;

//   final _formKey = GlobalKey<FormState>();
//   final _titleController = TextEditingController();
//   DateTime? _selectedDateTime;
//   bool _isSaving = false;
//   bool _repeatMonthly = false;

//   Set<int> _repeatingAlarmIds = {};

//   @override
//   void initState() {
//     super.initState();
//     _loadAlarmsAndRepeatingStatus();
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadAlarmsAndRepeatingStatus() async {
//     await _loadRepeatingAlarmIdsFromPrefs();
//     await _loadAlarms();
//   }

//   Future<void> _loadRepeatingAlarmIdsFromPrefs() async {
//     debugPrint("PAGE: Loading repeating alarm IDs...");
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.reload();
//       final List<String> idStrings = prefs.getStringList(_repeatMonthlyPrefsKey) ?? [];
//       if (mounted) {
//         setState(() {
//           _repeatingAlarmIds = idStrings.map((id) => int.parse(id)).toSet();
//         });
//         debugPrint("PAGE: Loaded repeating IDs: $_repeatingAlarmIds");
//       }
//     } catch (e) {
//       debugPrint("PAGE: Error loading repeating alarm IDs: $e");
//       if (mounted) {
//         setState(() {
//           _repeatingAlarmIds = {};
//         });
//         _showFeedbackSnackbar("Error loading repeating status.", isError: true);
//       }
//     }
//   }

//   Future<void> _saveRepeatingAlarmIdsToPrefs() async {
//     debugPrint("PAGE: Saving repeating alarm IDs: $_repeatingAlarmIds");
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final List<String> idStrings = _repeatingAlarmIds.map((id) => id.toString()).toList();
//       await prefs.setStringList(_repeatMonthlyPrefsKey, idStrings);
//       debugPrint("PAGE: Saved repeating IDs successfully.");
//     } catch (e) {
//       debugPrint("PAGE: Error saving repeating alarm IDs: $e");
//       if (mounted) {
//         _showFeedbackSnackbar("Error saving repeating status.", isError: true);
//       }
//     }
//   }

//   Future<void> _loadAlarms() async {
//     if (!mounted) return;
//     setState(() {
//       _loadingAlarms = true;
//     });
//     try {
//       final List<AlarmSettings> alarms = await Alarm.getAlarms();
//       alarms.sort((a, b) => a.dateTime.compareTo(b.dateTime));
//       if (mounted) {
//         setState(() {
//           _alarms = alarms;
//           _loadingAlarms = false;
//           debugPrint(
//             "PAGE: Loaded alarms: ${_alarms.map((a) => '${a.id} (${a.dateTime})').toList()}",
//           );
//           _pruneOrphanedRepeatingIds();
//         });
//       }
//     } catch (e) {
//       debugPrint("PAGE: Error loading alarms: $e");
//       if (mounted) {
//         setState(() {
//           _loadingAlarms = false;
//         });
//         _showFeedbackSnackbar("Error loading alarms.", isError: true);
//       }
//     }
//   }

//   void _pruneOrphanedRepeatingIds() {
//     if (!mounted) return;
//     final currentAlarmIds = _alarms.map((a) => a.id).toSet();
//     final initialCount = _repeatingAlarmIds.length;

//     _repeatingAlarmIds.retainWhere((id) => currentAlarmIds.contains(id));

//     final finalCount = _repeatingAlarmIds.length;

//     if (initialCount != finalCount) {
//       debugPrint(
//         "PAGE: Pruned orphaned repeating IDs (Count changed from $initialCount to $finalCount). Current repeating IDs: $_repeatingAlarmIds",
//       );
//       _saveRepeatingAlarmIdsToPrefs();
//     }
//   }

//   Future<void> _pickDateTime() async {
//     final theme = Theme.of(context);
//     final Color pickerPrimaryColor = AppColors.accentColor;
//     final Color pickerOnPrimaryColor = theme.colorScheme.onPrimary;

//     DateTime now = DateTime.now();
//     DateTime initialSelectDate = _selectedDateTime ?? now.add(const Duration(minutes: 1));
//     if (initialSelectDate.isBefore(now)) {
//       initialSelectDate = now.add(const Duration(minutes: 1));
//     }
//     final TimeOfDay initialTime = TimeOfDay.fromDateTime(initialSelectDate);

//     final DateTime? date = await showDatePicker(
//       context: context,
//       initialDate: initialSelectDate,
//       firstDate: DateTime(now.year, now.month, now.day),
//       lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
//       helpText: 'SELECT ALARM DATE',
//       builder: (context, child) {
//         return Theme(
//           data: theme.copyWith(
//             colorScheme: theme.colorScheme.copyWith(
//               primary: pickerPrimaryColor,
//               onPrimary: pickerOnPrimaryColor,
//               surface: theme.cardColor,
//               onSurface: theme.textTheme.bodyLarge?.color,
//             ),
//             textButtonTheme: TextButtonThemeData(
//               style: TextButton.styleFrom(foregroundColor: pickerPrimaryColor),
//             ),
//             dialogTheme: DialogTheme(
//               backgroundColor: theme.scaffoldBackgroundColor,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(kCardRadius),
//               ),
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//     if (date == null || !mounted) return;

//     final TimeOfDay? time = await showTimePicker(
//       context: context,
//       initialTime: initialTime,
//       helpText: 'SELECT ALARM TIME',
//       builder: (context, child) {
//         return Theme(
//           data: theme.copyWith(
//             colorScheme: theme.colorScheme.copyWith(
//               primary: pickerPrimaryColor,
//               onPrimary: pickerOnPrimaryColor,
//               surface: theme.cardColor,
//               onSurface: theme.textTheme.bodyLarge?.color,
//             ),
//             textButtonTheme: TextButtonThemeData(
//               style: TextButton.styleFrom(foregroundColor: pickerPrimaryColor),
//             ),
//             timePickerTheme: TimePickerThemeData(
//               dialBackgroundColor: Theme.of(context).appBarTheme.backgroundColor,
//               backgroundColor: theme.cardColor,
//               hourMinuteTextColor: Colors.white,
//               dialHandColor: pickerPrimaryColor,
//               dialTextColor: theme.textTheme.bodyLarge?.color,
//               entryModeIconColor: pickerPrimaryColor,
//             ),
//             dialogTheme: DialogTheme(
//               backgroundColor: theme.scaffoldBackgroundColor,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(kCardRadius),
//               ),
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//     if (time == null || !mounted) return;

//     var potentialDateTime = DateTime(
//       date.year,
//       date.month,
//       date.day,
//       time.hour,
//       time.minute,
//     );

//     if (potentialDateTime.isBefore(DateTime.now().add(const Duration(seconds: 10)))) {
//       _showFeedbackSnackbar(
//         "Please select a time at least a few seconds in the future.",
//         isError: true,
//       );
//       return;
//     }
//     setState(() {
//       _selectedDateTime = potentialDateTime;
//     });
//   }

//   String _formatDateTime(DateTime? dt) {
//     if (dt == null) return 'Tap to select Date & Time';
//     return DateFormat('EEE, MMM d \'at\' hh:mm a').format(dt);
//   }

//   String _formatAlarmListItemTime(DateTime dt) {
//     return DateFormat('hh:mm a').format(dt);
//   }

//   String _formatAlarmListItemDate(DateTime dt) {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final tomorrow = today.add(const Duration(days: 1));
//     final alarmDate = DateTime(dt.year, dt.month, dt.day);

//     if (alarmDate == today) return 'Today';
//     if (alarmDate == tomorrow) return 'Tomorrow';
//     return DateFormat('EEE, MMM d, yyyy').format(dt);
//   }

//   Future<void> _setAlarm() async {
//     if (_selectedDateTime == null) {
//       _showFeedbackSnackbar('Please select a date and time.', isError: true);
//       return;
//     }

//     setState(() {
//       _isSaving = true;
//     });

//     final alarmId = DateTime.now().millisecondsSinceEpoch % 100000;
//     final String title = _titleController.text.trim().isNotEmpty
//         ? _titleController.text.trim()
//         : 'Budgify Reminder';

//     try {
//       debugPrint("PAGE: Calling setAlarm() for ID: $alarmId at $_selectedDateTime");
//       await setAlarm(_selectedDateTime!, alarmId, title);
//       debugPrint("PAGE: Alarm set successfully for ID $alarmId");

//       if (mounted) {
//         if (_repeatMonthly) {
//           setState(() {
//             _repeatingAlarmIds.add(alarmId);
//           });
//           await _saveRepeatingAlarmIdsToPrefs();
//           debugPrint("PAGE: Added repeating ID $alarmId to SharedPreferences.");
//         }
//         _showFeedbackSnackbar(
//           'Alarm set for ${_formatDateTime(_selectedDateTime)}${_repeatMonthly ? ' (repeats monthly)' : ''}',
//         );
//         _resetForm();
//         await _loadAlarms();
//       }
//     } catch (e) {
//       debugPrint("PAGE: Error setting alarm: $e");
//       if (mounted) {
//         _showFeedbackSnackbar(
//           'An error occurred setting the alarm: $e',
//           isError: true,
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isSaving = false;
//         });
//       }
//     }
//   }

//   Future<void> _deleteAlarm(int id) async {
//     debugPrint("PAGE: Attempting to delete alarm ID: $id");
//     try {
//       final bool success = await Alarm.stop(id);
//       debugPrint("PAGE: Alarm.stop result for ID $id: $success");

//       if (mounted) {
//         bool uiNeedsUpdate = false;
//         bool wasRepeating = _repeatingAlarmIds.remove(id);
//         if (wasRepeating) {
//           await _saveRepeatingAlarmIdsToPrefs();
//           uiNeedsUpdate = true;
//           debugPrint("PAGE: Removed repeating ID $id from SharedPreferences.");
//         }

//         int initialLen = _alarms.length;
//         _alarms.removeWhere((alarm) => alarm.id == id);
//         bool removedFromUI = _alarms.length < initialLen;
//         if (removedFromUI) {
//           uiNeedsUpdate = true;
//           debugPrint("PAGE: Removed alarm ID $id from UI list.");
//         } else {
//           debugPrint("PAGE: Alarm ID $id was not found in the current UI list.");
//         }

//         if (success) {
//           _showFeedbackSnackbar('Alarm deleted.', isError: false);
//         } else if (removedFromUI) {
//           _showFeedbackSnackbar('Alarm removed from list.', isError: false);
//         } else {
//           _showFeedbackSnackbar('Alarm not found or already stopped.', isError: true);
//           await _loadAlarms();
//           return;
//         }

//         if (uiNeedsUpdate) {
//           setState(() {});
//         }
//       }
//     } catch (e) {
//       debugPrint("PAGE: Error deleting alarm $id: $e");
//       if (mounted) {
//         _showFeedbackSnackbar('An error occurred deleting the alarm.', isError: true);
//         await _loadAlarms();
//       }
//     }
//   }

//   void _resetForm() {
//     _formKey.currentState?.reset();
//     _titleController.clear();
//     if (mounted) {
//       setState(() {
//         _selectedDateTime = null;
//         _repeatMonthly = false;
//       });
//     }
//     FocusScope.of(context).unfocus();
//   }

//   void _showFeedbackSnackbar(String message, {bool isError = false}) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).removeCurrentSnackBar();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: isError ? AppColors.accentColor2 : AppColors.accentColor,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(kCardRadius * 0.8),
//         ),
//         margin: const EdgeInsets.all(kPadding),
//         duration: Duration(seconds: isError ? 5 : 3),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final Color appBarColor = theme.appBarTheme.backgroundColor ?? theme.primaryColor;
//     final Color primaryButtonColor = AppColors.accentColor;


//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//         ),
//         title: const Text('Alarm Reminders'),
//         elevation: 1.0,
//         backgroundColor: appBarColor,
//         foregroundColor: theme.appBarTheme.foregroundColor ?? theme.colorScheme.onPrimary,
//       ),
//       body: Column(
//         children: [
//           _buildAddNewAlarmForm(theme, primaryButtonColor, applyOpacity),
//           Divider(
//             height: kPadding,
//             thickness: 1,
//             color: applyOpacity(theme.dividerColor, 0.5),
//             indent: kPadding,
//             endIndent: kPadding,
//           ),
//           Expanded(child: _buildAlarmList(theme, appBarColor, applyOpacity)),
//         ],
//       ),
//     );
//   }

//   Widget _buildAlarmList(
//     ThemeData theme,
//     Color headerColor,
//     Color Function(Color, double) applyOpacity,
//   ) {
//     if (_loadingAlarms) {
//       return Center(
//         child: CircularProgressIndicator(color: AppColors.accentColor),
//       );
//     }
//     if (_alarms.isEmpty) {
//       return Center(
//         child: Padding(
//           padding: const EdgeInsets.all(kPadding * 2),
//           child: Text(
//             'No alarms scheduled.\nUse the form above to add one!',
//             textAlign: TextAlign.center,
//             style: theme.textTheme.titleMedium?.copyWith(
//               color: theme.hintColor,
//             ),
//           ),
//         ),
//       );
//     }

//     final localRepeatingIds = _repeatingAlarmIds;

//     return ListView.builder(
//       padding: const EdgeInsets.symmetric(
//         horizontal: kPadding / 2,
//         vertical: kPadding / 2,
//       ),
//       itemCount: _alarms.length,
//       itemBuilder: (context, index) {
//         final alarm = _alarms[index];
//         final bool isRepeating = localRepeatingIds.contains(alarm.id);
//         final String displayTitle = alarm.notificationSettings.title.isNotEmpty
//             ? alarm.notificationSettings.title
//             : 'Alarm';

//         return Dismissible(
//           key: Key(alarm.id.toString()),
//           direction: DismissDirection.endToStart,
//           onDismissed: (direction) {
//             _deleteAlarm(alarm.id);
//           },
//           background: Container(
//             color: applyOpacity(theme.colorScheme.error, 0.9),
//             alignment: Alignment.centerRight,
//             padding: const EdgeInsets.symmetric(horizontal: 20.0),
//             child: const Icon(Icons.delete_sweep_outlined, color: Colors.white),
//           ),
//           child: Card(
//             margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
//             elevation: 1.5,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(kCardRadius * 0.7),
//             ),
//             child: ListTile(
//               leading: Icon(
//                 Icons.alarm,
//                 color: AppColors.accentColor,
//                 size: 30,
//               ),
//               title: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Text(
//                     _formatAlarmListItemTime(alarm.dateTime),
//                     style: theme.textTheme.headlineSmall?.copyWith(
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   if (isRepeating)
//                     Padding(
//                       padding: const EdgeInsets.only(left: 8.0),
//                       child: Tooltip(
//                         message: "Repeats Monthly",
//                         child: Icon(
//                           Icons.repeat_on_rounded,
//                           size: 18,
//                           color: AppColors.accentColor,
//                           semanticLabel: "Repeats Monthly",
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//               subtitle: Text(
//                 '$displayTitle - ${_formatAlarmListItemDate(alarm.dateTime)}',
//                 style: theme.textTheme.bodyMedium?.copyWith(
//                   color: theme.hintColor,
//                 ),
//                 overflow: TextOverflow.ellipsis,
//               ),
//               trailing: IconButton(
//                 icon: Icon(
//                   Icons.delete_outline,
//                   color: AppColors.accentColor2,
//                 ),
//                 tooltip: 'Delete Alarm',
//                 onPressed: () => _showDeleteConfirmation(alarm, applyOpacity, isRepeating, theme),
//               ),
//               contentPadding: const EdgeInsets.symmetric(
//                 horizontal: kPadding,
//                 vertical: kPadding * 0.5,
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Future<void> _showDeleteConfirmation(
//     AlarmSettings alarm,
//     Color Function(Color, double) applyOpacity,
//     bool isRepeating,
//     ThemeData theme,
//   ) async {
//     return showDialog<void>(
//       context: context,
//       barrierDismissible: true,
//       builder: (BuildContext dialogContext) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(kCardRadius),
//           ),
//           backgroundColor: theme.cardColor,
//           title: const Text('Delete Alarm?'),
//           content: const SingleChildScrollView(
//             child: Row(
//               children: [
//                 Text('Are you sure you want to delete the alarm?'),
//               ],
//             ),
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: Text('Cancel', style: TextStyle(color: theme.hintColor)),
//               onPressed: () {
//                 Navigator.of(dialogContext).pop();
//               },
//             ),
//             TextButton(
//               child: Text(
//                 'Delete',
//                 style: TextStyle(
//                   color: theme.colorScheme.error,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               onPressed: () {
//                 Navigator.of(dialogContext).pop();
//                 _deleteAlarm(alarm.id);
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildAddNewAlarmForm(
//     ThemeData theme,
//     Color primaryButtonColor,
//     Color Function(Color, double) applyOpacity,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.all(kPadding),
//       child: SingleChildScrollView(
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const SizedBox(height: kPadding * 0.75),
//               TextFormField(
//                 controller: _titleController,
//                 textCapitalization: TextCapitalization.sentences,
//                 decoration: InputDecoration(
//                   labelText: 'Alarm Title (Optional)',
//                   hintText: 'E.g., Pay Rent, Take Pills',
//                   prefixIcon: Icon(
//                     Icons.label_outline,
//                     color: AppColors.accentColor,
//                   ),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(kCardRadius),
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(kCardRadius),
//                     borderSide: BorderSide(
//                       color: theme.dividerColor.withAlpha(150),
//                     ),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(
//                       color: AppColors.accentColor,
//                       width: 2.0,
//                     ),
//                     borderRadius: BorderRadius.circular(kCardRadius),
//                   ),
//                   filled: true,
//                   fillColor: theme.inputDecorationTheme.fillColor ??
//                       applyOpacity(theme.colorScheme.surfaceContainerHighest, 0.3),
//                   contentPadding: const EdgeInsets.symmetric(
//                     horizontal: kPadding,
//                     vertical: kPadding * 0.9,
//                   ),
//                 ),
//                 validator: (value) {
//                   return null;
//                 },
//               ),
//               const SizedBox(height: kPadding * 1.25),
//               Card(
//                 elevation: 1,
//                 margin: EdgeInsets.zero,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(kCardRadius),
//                   side: BorderSide(
//                     color: applyOpacity(theme.dividerColor, 0.5),
//                   ),
//                 ),
//                 clipBehavior: Clip.antiAlias,
//                 child: InkWell(
//                   onTap: _pickDateTime,
//                   borderRadius: BorderRadius.circular(kCardRadius),
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: kPadding,
//                       vertical: kPadding * 0.85,
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.calendar_today_outlined,
//                           color: AppColors.accentColor,
//                           size: 28,
//                         ),
//                         const SizedBox(width: kPadding),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Date & Time',
//                                 style: theme.textTheme.titleMedium?.copyWith(
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 _formatDateTime(_selectedDateTime),
//                                 style: theme.textTheme.bodyMedium?.copyWith(
//                                   color: _selectedDateTime == null ? theme.hintColor : null,
//                                   fontStyle: _selectedDateTime == null ? FontStyle.italic : FontStyle.normal,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Icon(
//                           Icons.arrow_forward_ios_rounded,
//                           size: 18,
//                           color: applyOpacity(theme.hintColor, 0.7),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               if (_selectedDateTime == null)
//                 Padding(
//                   padding: const EdgeInsets.only(top: 4.0, left: 12.0),
//                   child: Text(
//                     'Required',
//                     style: TextStyle(
//                       color: theme.colorScheme.error,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ),
//               const SizedBox(height: kPadding),
//               SwitchListTile(
//                 title: Text(
//                   'Repeat Monthly',
//                   style: theme.textTheme.titleMedium?.copyWith(
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 subtitle: Text(
//                   'Alarm will reschedule monthly after it rings.',
//                   style: theme.textTheme.bodySmall?.copyWith(
//                     color: theme.hintColor,
//                   ),
//                 ),
//                 value: _repeatMonthly,
//                 onChanged: (bool value) {
//                   setState(() {
//                     _repeatMonthly = value;
//                   });
//                 },
//                 activeColor: AppColors.accentColor,
//                 activeTrackColor: applyOpacity(AppColors.accentColor, 0.5),
//                 secondary: Icon(
//                   Icons.repeat,
//                   color: _repeatMonthly ? AppColors.accentColor : theme.hintColor,
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: kPadding / 2,
//                 ),
//                 visualDensity: VisualDensity.compact,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(kCardRadius * 0.75),
//                 ),
//                 tileColor: applyOpacity(theme.colorScheme.surfaceContainerHighest, 0.2),
//               ),
//               const SizedBox(height: kPadding * 1.5),
//               ElevatedButton.icon(
//                 onPressed: _isSaving ? null : _setAlarm,
//                 icon: _isSaving
//                     ? Container(
//                         width: 20,
//                         height: 20,
//                         padding: const EdgeInsets.all(2.0),
//                         child: CircularProgressIndicator(
//                           color: theme.colorScheme.onPrimary,
//                           strokeWidth: 3,
//                         ),
//                       )
//                     : Icon(
//                         Icons.alarm_add_rounded,
//                         color: theme.colorScheme.onPrimary,
//                       ),
//                 label: Text(
//                   _isSaving ? 'Saving...' : 'Set Alarm',
//                   style: TextStyle(
//                     color: theme.colorScheme.onPrimary,
//                   ),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: primaryButtonColor,
//                   padding: const EdgeInsets.symmetric(vertical: kPadding * 0.9),
//                   textStyle: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(kCardRadius * 1.5),
//                   ),
//                   elevation: 3,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }