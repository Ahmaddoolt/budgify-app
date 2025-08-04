// lib/views/pages/categories_wallets/wallets_view/wallet_details_page.dart

import 'package:budgify/domain/models/transfer%20.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/utils/format_amount.dart';
import '../../../../core/utils/scale_config.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../data/repo/transfer_repository.dart';
import '../../../../domain/models/wallet.dart';
import '../../../../viewmodels/providers/wallet_provider.dart';
import 'wallet_editor_modal.dart';

class WalletDetailsPage extends ConsumerWidget {
  final String walletId;

  const WalletDetailsPage({super.key, required this.walletId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(
      walletProvider.select((wallets) {
        return wallets.firstWhere(
          (w) => w.id == walletId,
          orElse: () {
            if (context.mounted) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pop();
              });
            }
            // Return a temporary, empty wallet to prevent a crash before the pop.
            return Wallet(
              id: '',
              name: 'Deleted',
              type: WalletType.cash,
              currencyCode: '',
              currencySymbol: '',
            );
          },
        );
      }),
    );

    if (wallet.name == 'Deleted') {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final transfersAsync = ref.watch(walletTransfersProvider(walletId));
    final responsive = context.responsive;

    return Scaffold(
      appBar: AppBar(
        // CORRECTED: Do not translate user-generated wallet names.
        title: Text(wallet.name),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          if (!wallet.isDefault)
            IconButton(
              icon: Icon(Icons.edit_outlined, color: Colors.white70),
              tooltip: 'Edit Wallet'.tr,
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (ctx) => WalletEditorModal(
                    pageContext: context,
                    walletToUpdate: wallet,
                    onWalletSaved: (updatedWallet) {},
                  ),
                );
              },
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(walletProvider);
          ref.invalidate(walletTransfersProvider(walletId));
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildWalletDetailsCard(wallet, ref, responsive, context),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text(
                  'Recent Transfers'.tr,
                  style: TextStyle(
                    fontSize: responsive.setSp(16),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            transfersAsync.when(
              data: (transfers) {
                if (transfers.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 50.0),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.receipt_long_rounded,
                              size: 60,
                              color: Colors.white24,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No transfers for this wallet yet.'.tr,
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final transfer = transfers[index];
                    return _buildTransferListItem(
                      context,
                      transfer,
                      walletId,
                      ref,
                      responsive,
                    );
                  }, childCount: transfers.length),
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
              error: (err, stack) => SliverToBoxAdapter(
                // CORRECTED: Handle dynamic error translation safely.
                child: Center(
                    child: Text('An unexpected error occurred: %s'
                        .tr
                        .replaceAll('%s', err.toString()))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletDetailsCard(
    Wallet wallet,
    WidgetRef ref,
    ResponsiveUtil responsive,
    BuildContext context,
  ) {
    return Card(
      margin: const EdgeInsets.all(16),
      color: Theme.of(context).cardColor.withOpacity(0.8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Balance'.tr,
              style: TextStyle(
                color: Colors.white70,
                fontSize: responsive.setSp(12),
              ),
            ),
            SizedBox(height: 8),
            Text(
              '${wallet.currencySymbol} ${getFormattedAmount(wallet.value, ref)}',
              style: TextStyle(
                color: Colors.white,
                fontSize: responsive.setSp(28),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              wallet.currencyCode,
              style: TextStyle(
                color: Colors.white54,
                fontSize: responsive.setSp(12),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 20),
            Divider(color: Colors.white24),
            SizedBox(height: 10),
            _buildInfoRow(
              Icons.credit_card_outlined,
              'Type'.tr,
              wallet.type.name.capitalizeFirst.toString().tr,
              responsive,
            ),
            _buildInfoRow(
              Icons.swap_horiz_rounded,
              'Transactions'.tr,
              wallet.allowedTransactionType.name.capitalizeFirst.toString().tr,
              responsive,
            ),
            _buildBooleanInfoRow(
              Icons.toggle_on_outlined,
              'Wallet Enabled'.tr,
              wallet.isEnabled,
              responsive,
            ),
            _buildBooleanInfoRow(
              Icons.double_arrow_rounded,
              'Transfers Enabled'.tr,
              wallet.isTransferEnabled,
              responsive,
            ),
            if (wallet.minValue != null || wallet.maxValue != null) ...[
              SizedBox(height: 10),
              Divider(color: Colors.white24.withOpacity(0.1)),
              SizedBox(height: 10),
              _buildInfoRow(
                Icons.remove_circle_outline,
                'Min Limit'.tr,
                wallet.minValue != null
                    ? '${wallet.currencySymbol} ${getFormattedAmount(wallet.minValue!, ref)}'
                    : 'N/A'.tr,
                responsive,
              ),
              _buildInfoRow(
                Icons.add_circle_outline,
                'Max Limit'.tr,
                wallet.maxValue != null
                    ? '${wallet.currencySymbol} ${getFormattedAmount(wallet.maxValue!, ref)}'
                    : 'N/A'.tr,
                responsive,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    ResponsiveUtil responsive,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          SizedBox(width: 16),
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: responsive.setSp(12),
            ),
          ),
          Spacer(),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: responsive.setSp(12),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBooleanInfoRow(
    IconData icon,
    String label,
    bool value,
    ResponsiveUtil responsive,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          SizedBox(width: 16),
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: responsive.setSp(12),
            ),
          ),
          Spacer(),
          Text(
            value ? 'Yes'.tr : 'No'.tr,
            style: TextStyle(
              color: value ? AppColors.accentColor : Colors.grey[400],
              fontSize: responsive.setSp(12),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransferListItem(
    BuildContext context,
    Transfer transfer,
    String currentWalletId,
    WidgetRef ref,
    ResponsiveUtil responsive,
  ) {
    final bool isOutgoing = transfer.fromWalletId == currentWalletId;
    final Color amountColor =
        isOutgoing ? Colors.red[300]! : Colors.green[300]!;
    final IconData directionIcon =
        isOutgoing ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showDeleteConfirmationDialog(context, ref, transfer),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(
                  directionIcon,
                  color: amountColor,
                  size: responsive.setSp(22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // CORRECTED: Translate the prefix, not the user data.
                      Text(
                        isOutgoing
                            ? '${'To:'.tr} ${transfer.toWalletName}'
                            : '${'From:'.tr} ${transfer.fromWalletName}',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: responsive.setSp(12),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
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
                Text(
                  '${isOutgoing ? '-' : '+'} ${getFormattedAmount(isOutgoing ? transfer.amountSent : transfer.amountReceived, ref)} ${isOutgoing ? transfer.fromCurrency : transfer.toCurrency}',
                  style: TextStyle(
                    color: amountColor,
                    fontWeight: FontWeight.bold,
                    fontSize: responsive.setSp(13),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    WidgetRef ref,
    Transfer transfer,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        backgroundColor: Color.fromARGB(255, 35, 40, 50),
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
                  ref.read(walletProvider.notifier).reverseTransfer(
                        fromWalletId: transfer.fromWalletId,
                        toWalletId: transfer.toWalletId,
                        amountSent: transfer.amountSent,
                        amountReceived: transfer.amountReceived,
                      );
                  await ref
                      .read(transferRepositoryProvider)
                      .deleteTransfer(transfer.id);
                  ref.invalidate(walletTransfersProvider(walletId));
                  ref.invalidate(transferHistoryProvider);
                  showFeedbackSnackbar(
                    context,
                    'Transfer deleted and reversed'.tr,
                  );
                } catch (e) {
                  // CORRECTED: Handle dynamic error translation safely.
                  showFeedbackSnackbar(
                    context,
                    'An unexpected error occurred: %s'
                        .tr
                        .replaceAll('%s', e.toString()),
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
                  ref.invalidate(walletTransfersProvider(walletId));
                  ref.invalidate(transferHistoryProvider);
                  showFeedbackSnackbar(
                    context,
                    'Transfer record deleted.'.tr,
                  );
                } catch (e) {
                  // CORRECTED: Handle dynamic error translation safely.
                  showFeedbackSnackbar(
                    context,
                    'An unexpected error occurred: %s'
                        .tr
                        .replaceAll('%s', e.toString()),
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
              child: Text('Cancel'.tr),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ),
        ],
      ),
    );
  }

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
