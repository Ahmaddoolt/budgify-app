// lib/views/pages/transfer_history_page.dart

import 'package:budgify/core/themes/app_colors.dart';
import 'package:budgify/core/utils/format_amount.dart';
import 'package:budgify/core/utils/scale_config.dart';
import 'package:budgify/core/utils/snackbar_helper.dart';
import 'package:budgify/data/repo/transfer_repository.dart';
import 'package:budgify/domain/models/transfer%20.dart';
import 'package:budgify/viewmodels/providers/wallet_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart'; // Import for groupBy

// Enum to represent the sorting options
enum SortBy { date, amount }

// State provider to hold the current sorting choice
final sortProvider = StateProvider<SortBy>((ref) => SortBy.date);

class TransferHistoryPage extends ConsumerWidget {
  const TransferHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(transferHistoryProvider);
    final responsive = context.responsive;

    return Scaffold(
      appBar: AppBar(
        title: Text('Transfer History'.tr),
        // --- AppBar is now clean, with only a title ---
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: historyAsync.when(
        data: (transfers) {
          if (transfers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_toggle_off_rounded,
                    size: 80,
                    color: Colors.white30,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No transfers have been made yet.'.tr,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: responsive.setSp(14),
                    ),
                  ),
                ],
              ),
            );
          }

          // --- All main logic is now wrapped in a Column for the new header ---
          return Column(
            children: [
              _buildControlsHeader(context, ref, responsive),
              Expanded(child: _buildSortedList(transfers, ref, responsive)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (err, stack) => Center(
              child: Text(
                'Error loading history'.tr,
                style: const TextStyle(color: Colors.red),
              ),
            ),
      ),
    );
  }

  // --- NEW: Header widget for a cleaner layout ---
  Widget _buildControlsHeader(
    BuildContext context,
    WidgetRef ref,
    ResponsiveUtil responsive,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          _buildSortControls(context, ref, responsive),
          const Spacer(),
          TextButton.icon(
            onPressed: () => _showDeleteAllConfirmationDialog(context, ref),
            icon: Icon(
              Icons.delete_sweep_outlined,
              color: AppColors.accentColor2,
              size: 18,
            ),
            label: Text(
              "Clear All".tr,
              style: TextStyle(
                color: AppColors.accentColor2,
                fontSize: responsive.setSp(11),
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- NEW: Extracted the sorted list into its own widget ---
  Widget _buildSortedList(
    List<Transfer> transfers,
    WidgetRef ref,
    ResponsiveUtil responsive,
  ) {
    final currentSort = ref.watch(sortProvider);
    final sortedTransfers = List<Transfer>.from(transfers);
    if (currentSort == SortBy.date) {
      sortedTransfers.sort((a, b) => b.date.compareTo(a.date));
    } else {
      sortedTransfers.sort((a, b) => b.amountSent.compareTo(a.amountSent));
    }

    final groupedTransfers =
        currentSort == SortBy.date
            ? groupBy(
              sortedTransfers,
              (Transfer t) => DateFormat('MMMM yyyy').format(t.date),
            )
            : {'All Transfers By Amount': sortedTransfers};

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(transferHistoryProvider),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder:
            (child, animation) =>
                FadeTransition(opacity: animation, child: child),
        child: ListView.builder(
          key: ValueKey(currentSort),
          itemCount: groupedTransfers.keys.length,
          itemBuilder: (context, index) {
            final groupTitle = groupedTransfers.keys.elementAt(index);
            final groupItems = groupedTransfers[groupTitle]!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
                  child: Text(
                    groupTitle.tr,
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      fontSize: responsive.setSp(12),
                    ),
                  ),
                ),
                ...groupItems.map(
                  (transfer) => _buildTransferListItem(
                    transfer,
                    ref,
                    responsive,
                    context,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSortControls(
    BuildContext context,
    WidgetRef ref,
    ResponsiveUtil responsive,
  ) {
    final currentSort = ref.watch(sortProvider);
    return SegmentedButton<SortBy>(
      style: SegmentedButton.styleFrom(
        backgroundColor: Theme.of(
          context,
        ).appBarTheme.backgroundColor!.withOpacity(0.5),
        foregroundColor: Colors.white70,
        selectedForegroundColor: Colors.black,
        selectedBackgroundColor: AppColors.accentColor,
        visualDensity: VisualDensity.compact,
      ),
      segments: <ButtonSegment<SortBy>>[
        ButtonSegment<SortBy>(
          value: SortBy.date,
          label: Text(
            'Date'.tr,
            style: TextStyle(fontSize: responsive.setSp(10)),
          ),
          icon: Icon(Icons.calendar_today_rounded, size: responsive.setSp(12)),
        ),
        ButtonSegment<SortBy>(
          value: SortBy.amount,
          label: Text(
            'Amount'.tr,
            style: TextStyle(fontSize: responsive.setSp(10)),
          ),
          icon: Icon(Icons.unfold_more_rounded, size: responsive.setSp(12)),
        ),
      ],
      selected: {currentSort},
      onSelectionChanged: (newSelection) {
        ref.read(sortProvider.notifier).state = newSelection.first;
      },
    );
  }

  Widget _buildTransferListItem(
    Transfer transfer,
    WidgetRef ref,
    ResponsiveUtil responsive,
    BuildContext context,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: responsive.setWidth(16),
        vertical: responsive.setHeight(5),
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).appBarTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap:
              () => _showDeleteConfirmationDialog(
                context,
                ref,
                transfer,
              ), // Tap anywhere on the item to bring up options
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.swap_horiz_rounded,
                  color: AppColors.accentColor,
                  size: responsive.setSp(24),
                ),
                SizedBox(width: responsive.setWidth(12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              transfer.fromWalletName.tr,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: responsive.setSp(11),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.0),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              size: 14,
                              color: Colors.white54,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              transfer.toWalletName.tr,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: responsive.setSp(11),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        DateFormat.yMMMd().format(transfer.date),
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: responsive.setSp(10),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildAmountDisplay(transfer, ref, responsive),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountDisplay(
    Transfer transfer,
    WidgetRef ref,
    ResponsiveUtil responsive,
  ) {
    final sentText =
        '${transfer.fromCurrency} ${getFormattedAmount(transfer.amountSent, ref)}';
    final bool wasExchange =
        transfer.fromCurrency != transfer.toCurrency ||
        transfer.amountSent.toStringAsFixed(2) !=
            transfer.amountReceived.toStringAsFixed(2);
    final receivedText =
        wasExchange
            ? '${transfer.toCurrency} ${getFormattedAmount(transfer.amountReceived, ref)}'
            : null;

    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '- $sentText',
            style: TextStyle(
              color: Colors.red[300],
              fontWeight: FontWeight.bold,
              fontSize: responsive.setSp(12),
            ),
          ),
          if (receivedText != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                '+ $receivedText',
                style: TextStyle(
                  color: Colors.green[300],
                  fontWeight: FontWeight.bold,
                  fontSize: responsive.setSp(12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --- UPDATED DIALOG: A much cleaner, more modern design ---
  void _showDeleteConfirmationDialog(
    BuildContext context,
    WidgetRef ref,
    Transfer transfer,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true, // Allow dismissing by tapping outside
      builder:
          (ctx) => AlertDialog(
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Delete Transfer?'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Choose an option to delete this transfer record.'.tr,
                  style: TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _buildDialogButton(
                  context: ctx,
                  ref: ref,
                  label: 'Delete & Reverse'.tr,
                  description: 'Adjusts wallet balances.'.tr,
                  icon: Icons.published_with_changes_rounded,
                  color: Colors.red[400]!,
                  onPressed: () async {
                    try {
                      ref
                          .read(walletProvider.notifier)
                          .reverseTransfer(
                            fromWalletId: transfer.fromWalletId,
                            toWalletId: transfer.toWalletId,
                            amountSent: transfer.amountSent,
                            amountReceived: transfer.amountReceived,
                          );
                      await ref
                          .read(transferRepositoryProvider)
                          .deleteTransfer(transfer.id);
                      ref.invalidate(transferHistoryProvider);
                      showFeedbackSnackbar(
                        context,
                        'Transfer deleted and reversed'.tr,
                      );
                    } catch (e) {
                      showFeedbackSnackbar(
                        context,
                        'Error'.tr,
                        isError: true,
                      );
                    }
                  },
                ),
                const SizedBox(height: 12),
                _buildDialogButton(
                  context: ctx,
                  ref: ref,
                  label: 'Delete Record Only'.tr,
                  description: 'Balances will not change.'.tr,
                  icon: Icons.delete_outline_rounded,
                  color: Colors.amber[600]!,
                  onPressed: () async {
                    try {
                      await ref
                          .read(transferRepositoryProvider)
                          .deleteTransfer(transfer.id);
                      ref.invalidate(transferHistoryProvider);
                      showFeedbackSnackbar(
                        context,
                        'Transfer record deleted.'.tr,
                      );
                    } catch (e) {
                      showFeedbackSnackbar(
                        context,
                        'Error'.tr,
                        isError: true,
                      );
                    }
                  },
                ),
              ],
            ),
            actions: [
              Center(
                child: TextButton(
                  child: Text(
                    'Cancel'.tr,
                    style: TextStyle(color: AppColors.accentColor),
                  ),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ),
            ],
          ),
    );
  }

  void _showDeleteAllConfirmationDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: Color.fromARGB(255, 35, 40, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.red[300]),
                SizedBox(width: 10),
                Expanded(child: Text('Delete All History?'.tr)),
              ],
            ),
            content: Text(
              'This action is irreversible and will permanently delete all transfer records. It will NOT adjust your current wallet balances.'
                  .tr,
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                child: Text('Cancel'.tr),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                ),
                child: Text(
                  'Confirm Delete'.tr,
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  await ref
                      .read(transferRepositoryProvider)
                      .deleteAllTransfers();
                  ref.invalidate(transferHistoryProvider);
                  showFeedbackSnackbar(
                    context,
                    'All transfer history has been deleted'.tr,
                  );
                },
              ),
            ],
          ),
    );
  }

  // --- NEW: A helper for creating the custom dialog buttons ---
  Widget _buildDialogButton({
    required BuildContext context,
    required WidgetRef ref,
    required String label,
    required String description,
    required IconData icon,
    required Color color,
    required Function onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.15),
          foregroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: color.withOpacity(0.5)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          elevation: 0,
        ),
        onPressed: () {
          Navigator.of(context).pop();
          onPressed();
        },
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Icon(icon),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: color.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
