import 'package:budgify/core/themes/app_colors.dart';
import 'package:budgify/views/pages/alarm/add_alarm/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:intl/intl.dart';
import 'package:alarm/alarm.dart';
import 'package:budgify/initialization.dart';
import 'package:budgify/views/pages/alarm/alarmservices/alarm_handlers.dart';
import 'package:budgify/views/pages/alarm/add_alarm/alarm_list_utils.dart';

class AlarmListView extends StatelessWidget {
  final List<AlarmSettings> alarms;
  final bool loadingAlarms;
  final Set<int> repeatingAlarmIds;
  final Function(int) onDelete;
  final Function(String, {bool isError}) onFeedback;
  final Function(Set<int>) updateRepeatingAlarmIds;

  const AlarmListView({
    super.key,
    required this.alarms,
    required this.loadingAlarms,
    required this.repeatingAlarmIds,
    required this.onDelete,
    required this.onFeedback,
    required this.updateRepeatingAlarmIds,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (loadingAlarms) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.accentColor),
      );
    }
    if (alarms.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(kPadding * 2),
          child: Text(
            'No alarms scheduled.\nUse the form above to add one!'.tr,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.hintColor,
            ),
          ),
        ),
      );
    }

    return FutureBuilder<Map<int, Map<String, dynamic>>>(
      future: loadStoppedAlarms(sharedPreferences),
      builder: (context, snapshot) {
        final stoppedAlarms = snapshot.data ?? {};
        if (snapshot.hasError) {
          debugPrint(
            "AlarmListView: Error loading stopped alarms: ${snapshot.error}",
          );
        }

        final activeAlarms =
            alarms.where((a) => !stoppedAlarms.containsKey(a.id)).toList();
        final stoppedAlarmsList =
            alarms.where((a) => stoppedAlarms.containsKey(a.id)).toList();

        return ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: kPadding / 2,
            vertical: kPadding / 2,
          ),
          children: [
            if (activeAlarms.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(kPadding),
                child: Text(
                  'Active Alarms'.tr,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...activeAlarms.asMap().entries.map(
                (entry) =>
                    _buildAlarmItem(context, entry.value, stoppedAlarms, false),
              ),
            ],
            if (stoppedAlarmsList.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(kPadding),
                child: Text(
                  'Stopped Alarms'.tr,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...stoppedAlarmsList.asMap().entries.map(
                (entry) =>
                    _buildAlarmItem(context, entry.value, stoppedAlarms, true),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildAlarmItem(
    BuildContext context,
    AlarmSettings alarm,
    Map<int, Map<String, dynamic>> stoppedAlarms,
    bool isStopped,
  ) {
    final theme = Theme.of(context);
    final bool isRepeating = repeatingAlarmIds.contains(alarm.id);
    final String displayTitle =
        alarm.notificationSettings.title.isNotEmpty
            ? alarm.notificationSettings.title
            : 'Payment Reminder'.tr;

    return Dismissible(
      key: Key(alarm.id.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        onDelete(alarm.id);
      },
      background: Container(
        color: applyOpacity(theme.colorScheme.error, 0.9),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: const Icon(Icons.delete_sweep_outlined, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        elevation: 1.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kCardRadius * 0.7),
        ),
        child: ListTile(
          leading: Icon(
            isStopped
                ? Icons.check_circle_outline
                : Icons.account_balance_wallet,
            color: isStopped ? theme.hintColor : AppColors.accentColor,
            size: 30,
            semanticLabel:
                isStopped ? 'Stopped Payment Reminder'.tr : 'Payment Reminder'.tr,
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                formatAlarmListItemTime(alarm.dateTime),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isStopped ? theme.hintColor : null,
                ),
              ),
              Row(
                children: [
                  if (isStopped)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        'Stopped'.tr,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  if (isRepeating)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Tooltip(
                        message: "Repeats Monthly",
                        child: Icon(
                          Icons.repeat_on_rounded,
                          size: 18,
                          color: AppColors.accentColor,
                          semanticLabel: "Repeats Monthly",
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          subtitle: Text(
            '$displayTitle - ${formatAlarmListItemDate(alarm.dateTime)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isStopped ? theme.hintColor : theme.hintColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            icon: Icon(Icons.delete_outline, color: AppColors.accentColor2),
            tooltip: 'Delete Alarm'.tr,
            onPressed:
                () => _showDeleteConfirmation(
                  context,
                  alarm,
                  applyOpacity,
                  isRepeating,
                  theme,
                ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: kPadding,
            vertical: kPadding * 0.5,
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    AlarmSettings alarm,
    Color Function(Color, double) applyOpacity,
    bool isRepeating,
    ThemeData theme,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kCardRadius),
          ),
          backgroundColor: theme.cardColor,
          title:  Text('Delete Payment Reminder?'.tr),
          content:  SingleChildScrollView(
            child: Row(
              children: [
                Text('Are you sure you want to delete this payment reminder?'.tr),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'.tr, style: TextStyle(color: theme.hintColor)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text(
                'Delete'.tr,
                style: TextStyle(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onDelete(alarm.id);
              },
            ),
          ],
        );
      },
    );
  }
}
