import 'package:budgify/core/utils/format_amount.dart';
import 'package:budgify/core/utils/scale_config.dart';
import 'package:budgify/viewmodels/providers/lang_provider.dart';
import 'package:budgify/viewmodels/providers/wallet_provider.dart';
import 'package:budgify/views/pages/categories_wallets/wallets_view/transfer_history_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:budgify/core/themes/app_colors.dart';
import 'package:budgify/domain/models/wallet.dart';
import 'package:budgify/views/widgets/cards/progress_row.dart';

import 'package:budgify/views/pages/categories_wallets/wallets_view/wallet_details_page.dart';
import 'package:budgify/views/pages/categories_wallets/wallets_view/transfer_dialog.dart';
import 'package:budgify/views/pages/categories_wallets/wallets_view/wallet_editor_modal.dart';

class WalletsSummaryPage extends ConsumerWidget {
  const WalletsSummaryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallets = ref.watch(walletProvider);
    final responsive = context.responsive;
    return Column(
      children: [
        SizedBox(height: responsive.setHeight(10)),
        _buildActionButtons(
          context,
          ref,
          wallets,
          responsive,
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(responsive.setWidth(24.0)),
            child: _buildWalletsList(context, ref, wallets, responsive),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    List<Wallet> wallets,
    ResponsiveUtil responsive,
  ) {
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      padding: EdgeInsets.symmetric(
        horizontal: responsive.setWidth(16),
        vertical: responsive.setHeight(12),
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(responsive.setWidth(12)),
      ),
    );

    final textStyle = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: responsive.setSp(12),
    );

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.isTablet
            ? responsive.widthPercent(0.05)
            : responsive.widthPercent(0.04),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => showTransferDialog(context, ref, wallets),
              icon: Icon(
                Icons.swap_horiz,
                color: AppColors.accentColor,
                size: responsive.setWidth(20),
              ),
              label: Text("Transfer".tr, style: textStyle),
              style: buttonStyle,
            ),
          ),
          SizedBox(width: responsive.setWidth(12)),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => const TransferHistoryPage(),
                  ),
                );
              },
              icon: Icon(
                Icons.history_rounded,
                color: AppColors.accentColor,
                size: responsive.setWidth(20),
              ),
              label: Text("History".tr, style: textStyle),
              style: buttonStyle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletsList(
    BuildContext context,
    WidgetRef ref,
    List<Wallet> wallets,
    ResponsiveUtil responsive,
  ) {
    if (wallets.isEmpty) {
      return Center(
        child: Text(
          "No wallets yet. Add one to get started!".tr,
          style: TextStyle(color: Colors.white70),
        ),
      );
    }
    final sortedWallets = List<Wallet>.from(wallets)
      ..sort((a, b) {
        if (a.isDefault && !b.isDefault) return -1;
        if (!a.isDefault && b.isDefault) return 1;
        return 0;
      });

    final Map<String, List<Wallet>> walletsByCurrency = {};
    for (var wallet in sortedWallets) {
      if (!walletsByCurrency.containsKey(wallet.currencySymbol)) {
        walletsByCurrency[wallet.currencySymbol] = [];
      }
      walletsByCurrency[wallet.currencySymbol]!.add(wallet);
    }
    return ListView(
      children: sortedWallets.map((wallet) {
        final totalForCurrency = walletsByCurrency[wallet.currencySymbol]!
            .fold<double>(0, (sum, w) => sum + (w.value > 0 ? w.value : 0));
        final double progress = (totalForCurrency > 0 && wallet.value > 0)
            ? (wallet.value / totalForCurrency)
            : 0.0;
        return _buildWalletCard(context, ref, wallet, progress, responsive);
      }).toList(),
    );
  }

  Widget _buildWalletCard(
    BuildContext context,
    WidgetRef ref,
    Wallet wallet,
    double progress,
    ResponsiveUtil responsive,
  ) {
    final cardHeight = responsive.isTablet ? 150.0 : 162.0;
    Color? themeColor = Theme.of(context).appBarTheme.backgroundColor;
    final isArabic = ref.watch(languageProvider).toString() == "ar";
    final decoration = _getCardDecoration(
      wallet,
      responsive,
      themeColor!,
      isArabic,
    );

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(responsive.setWidth(12)),
      ),
      margin: EdgeInsets.only(bottom: responsive.setHeight(24)),
      clipBehavior: Clip.antiAlias,
      child: Opacity(
        opacity: wallet.isEnabled ? 1.0 : 0.5,
        child: Container(
          height: cardHeight,
          decoration: decoration,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => WalletDetailsPage(walletId: wallet.id),
                  ),
                );
              },
              child: Padding(
                padding: EdgeInsets.all(responsive.setWidth(12)),
                child: Row(
                  children: [
                    _buildWalletInfo(
                      context,
                      ref,
                      wallet,
                      progress,
                      responsive,
                    ),
                    _buildWalletVisual(context, ref, wallet, responsive),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _getCardDecoration(
    Wallet wallet,
    ResponsiveUtil responsive,
    Color themeColor,
    bool isArabic,
  ) {
    final backgroundGradient = LinearGradient(
      colors: [
        Colors.black,
        themeColor.withOpacity(0.0),
        themeColor.withOpacity(0.0),
        Colors.black,
      ],
      begin: isArabic ? Alignment.topRight : Alignment.topLeft,
      end: isArabic ? Alignment.bottomLeft : Alignment.bottomRight,
    );
    if (wallet.allowedTransactionType == WalletFunctionality.both) {
      return BoxDecoration(
        borderRadius: BorderRadius.circular(responsive.setWidth(12)),
        gradient: backgroundGradient,
        border: Border.fromBorderSide(BorderSide.none),
      ).copyWith(
        border: GradientBoxBorder(
          gradient: LinearGradient(
            colors: [AppColors.accentColor, AppColors.accentColor2],
            begin: isArabic ? Alignment.centerRight : Alignment.centerLeft,
            end: isArabic ? Alignment.centerLeft : Alignment.centerRight,
          ),
          width: 3,
        ),
      );
    } else {
      Color borderColor;
      switch (wallet.allowedTransactionType) {
        case WalletFunctionality.income:
          borderColor = AppColors.accentColor;
          break;
        case WalletFunctionality.expense:
          borderColor = AppColors.accentColor2;
          break;
        default:
          borderColor = Colors.transparent;
      }
      return BoxDecoration(
        borderRadius: BorderRadius.circular(responsive.setWidth(12)),
        gradient: backgroundGradient,
        border: Border.all(color: borderColor, width: 1.5),
      );
    }
  }

  Widget _buildWalletInfo(
    BuildContext context,
    WidgetRef ref,
    Wallet wallet,
    double progress,
    ResponsiveUtil responsive,
  ) {
    Widget _buildMinMaxInfo() {
      if (wallet.minValue == null && wallet.maxValue == null)
        return const SizedBox.shrink();
      String minText = wallet.minValue != null
          ? 'Min: ${getFormattedAmount(wallet.minValue!, ref)}'
          : '';
      String maxText = wallet.maxValue != null
          ? 'Max: ${getFormattedAmount(wallet.maxValue!, ref)}'
          : '';
      String text = (minText.isNotEmpty && maxText.isNotEmpty)
          ? '$minText / $maxText'
          : '$minText$maxText';
      return Text(
        text,
        style: TextStyle(
          fontSize: responsive.setSp(9),
          color: Colors.white70,
          fontWeight: FontWeight.w300,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    return Expanded(
      flex: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            wallet.name.tr,
            style: TextStyle(
              fontSize: responsive.setSp(14),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Text(
            '${wallet.currencySymbol} ${getFormattedAmount(wallet.value, ref)}',
            style: TextStyle(
              fontSize: responsive.setSp(18),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textDirection: TextDirection.ltr,
          ),
          SizedBox(height: responsive.setHeight(4)),
          _buildMinMaxInfo(),
          const Spacer(),
          ProgressRow(
            progress: progress.clamp(0.0, 1.0),
            label: '${wallet.type.name.capitalizeFirst}'.tr,
            amount: getFormattedAmount(progress * 100, ref) + '%',
            progressColor:
                wallet.allowedTransactionType == WalletFunctionality.expense
                    ? AppColors.accentColor2
                    : AppColors.accentColor,
            type: wallet.type.name.capitalizeFirst!,
          ),
        ],
      ),
    );
  }

  Widget _buildWalletVisual(
    BuildContext context,
    WidgetRef ref,
    Wallet wallet,
    ResponsiveUtil responsive,
  ) {
    final isArabic = ref.watch(languageProvider).toString() == "ar";
    Widget getFunctionalityIndicator() {
      IconData icon;
      Color color;
      switch (wallet.allowedTransactionType) {
        case WalletFunctionality.income:
          icon = Icons.arrow_upward;
          color = AppColors.accentColor;
          break;
        case WalletFunctionality.expense:
          icon = Icons.arrow_downward;
          color = AppColors.accentColor2;
          break;
        case WalletFunctionality.both:
          icon = Icons.swap_vert;
          color = Colors.blue.shade300;
          break;
      }
      return Icon(icon, color: color, size: responsive.setSp(16));
    }

    return Expanded(
      flex: 1,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Lottie.asset(
              wallet.type == WalletType.bank
                  ? "assets/bank+.json"
                  : wallet.type == WalletType.cash
                      ? "assets/cash_money_wallet.json"
                      : "assets/digital2.json",
              width: responsive.setWidth(90),
              height: responsive.setHeight(90),
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            top: -8,
            right: isArabic ? null : -8,
            left: isArabic ? -8 : null,
            child: PopupMenuButton<String>(
              color: Theme.of(context).appBarTheme.backgroundColor,
              icon: Icon(
                Icons.more_vert,
                color: Colors.white70,
                size: responsive.setWidth(20),
              ),
              onSelected: (v) {
                if (v == 'Update') {
                  _showUpdateWalletModal(context, ref, wallet);
                } else if (v == 'Delete') {
                  _showDeleteWalletDialog(context, ref, wallet);
                } else if (v == 'Toggle') {
                  final updatedWallet = wallet.copyWith(
                    isEnabled: !wallet.isEnabled,
                  );
                  ref.read(walletProvider.notifier).updateWallet(updatedWallet);
                }
              },
              itemBuilder: (ctx) {
                List<PopupMenuEntry<String>> menuItems = [];

                menuItems.add(PopupMenuItem<String>(
                  value: 'Update',
                  child: Row(children: [
                    Icon(Icons.edit,
                        size: responsive.setWidth(18), color: Colors.white),
                    SizedBox(width: responsive.setWidth(8)),
                    Text('Update'.tr,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: responsive.setSp(12))),
                  ]),
                ));

                menuItems.add(PopupMenuItem<String>(
                  value: 'Toggle',
                  child: Row(children: [
                    Icon(wallet.isEnabled ? Icons.toggle_on : Icons.toggle_off,
                        size: responsive.setWidth(18),
                        color: wallet.isEnabled
                            ? AppColors.accentColor
                            : Colors.grey),
                    SizedBox(width: responsive.setWidth(8)),
                    Text(wallet.isEnabled ? 'Turn Off'.tr : 'Turn On'.tr,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: responsive.setSp(12))),
                  ]),
                ));

                if (!wallet.isDefault) {
                  menuItems.add(PopupMenuItem<String>(
                    value: 'Delete',
                    child: Row(children: [
                      Icon(Icons.delete,
                          color: Colors.red, size: responsive.setWidth(18)),
                      SizedBox(width: responsive.setWidth(8)),
                      Text('Delete'.tr,
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: responsive.setSp(12))),
                    ]),
                  ));
                }

                return menuItems;
              },
            ),
          ),
          Positioned(
            bottom: 0,
            right: isArabic ? null : 0,
            left: isArabic ? 0 : null,
            child: getFunctionalityIndicator(),
          ),
        ],
      ),
    );
  }

  void _showUpdateWalletModal(
    BuildContext context,
    WidgetRef ref,
    Wallet wallet,
  ) {
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
  }

  // --- MODIFIED DIALOG ---
  void _showDeleteWalletDialog(
    BuildContext context,
    WidgetRef ref,
    Wallet wallet,
  ) {
    final responsive = context.responsive;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor!,
        title: Text(
          'Delete wallet?'.trParams({
            'walletName': wallet.name,
          }),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'This wallet may have transactions linked to it. Please choose an option:'
                  .tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: responsive.setSp(14),
              ),
            ),
            SizedBox(height: responsive.setHeight(20)),
            // Option 1: Delete wallet and transactions
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                minimumSize: Size(double.infinity, responsive.setHeight(45)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(responsive.setWidth(10)),
                ),
              ),
              onPressed: () {
                // NOTE: You need to implement this method in your WalletProvider.
                // It should delete the wallet AND all cashflows associated with its ID.
                ref
                    .read(walletProvider.notifier)
                    .deleteWalletAndTransactions(wallet.id);
                Navigator.of(context).pop();
              },
              child: Text(
                'Delete Wallet & All Transactions'.tr,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: responsive.setSp(12),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: responsive.setHeight(12)),
            // Option 2: Delete wallet only
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.accentColor, width: 1.5),
                minimumSize: Size(double.infinity, responsive.setHeight(45)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(responsive.setWidth(10)),
                ),
              ),
              onPressed: () {
                // NOTE: You need to implement this method in your WalletProvider.
                // It should only delete the wallet, leaving the cashflows.
                ref.read(walletProvider.notifier).deleteWalletOnly(wallet.id);
                Navigator.of(context).pop();
              },
              child: Text(
                'Delete Wallet Only'.tr,
                style: TextStyle(
                  color: AppColors.accentColor,
                  fontSize: responsive.setSp(12),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel'.tr,
              style: TextStyle(
                color: Colors.white,
                fontSize: responsive.setSp(14),
              ),
            ),
          ),
        ],
        actionsAlignment: MainAxisAlignment.center,
      ),
    );
  }
}

class GradientBoxBorder extends BoxBorder {
  final Gradient gradient;
  final double width;
  const GradientBoxBorder({required this.gradient, this.width = 1.0});
  @override
  BorderSide get bottom => BorderSide.none;
  @override
  BorderSide get top => BorderSide.none;
  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(width);
  @override
  bool get isUniform => true;
  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    TextDirection? textDirection,
    BoxShape shape = BoxShape.rectangle,
    BorderRadius? borderRadius,
  }) {
    if (borderRadius != null) {
      final RRect rrect = borderRadius.toRRect(rect);
      final Paint paint = Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = width;
      canvas.drawRRect(rrect, paint);
    }
  }

  @override
  ShapeBorder scale(double t) =>
      GradientBoxBorder(gradient: gradient.scale(t), width: width * t);
}
