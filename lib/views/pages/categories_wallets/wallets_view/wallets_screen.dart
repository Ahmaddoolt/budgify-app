import 'package:budgify/core/utils/parrot_animation_waiting.dart';
import 'package:budgify/viewmodels/providers/lang_provider.dart';
import 'package:budgify/viewmodels/providers/wallet_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:budgify/core/themes/app_colors.dart';
import 'package:budgify/domain/models/expense.dart';
import 'package:budgify/domain/models/wallet.dart';
import 'package:budgify/data/services/hive_services.dart/expenses_adaptar.dart';
import 'package:budgify/data/repo/expenses_repository.dart';
import 'package:budgify/viewmodels/providers/currency_symbol.dart';
import 'package:budgify/views/widgets/cards/progress_row.dart';
import 'package:budgify/views/pages/categories_wallets/wallets_view/transfer_method.dart';
import '../../../../core/utils/scale_config.dart';

class WalletsSummaryPage extends ConsumerWidget {
  const WalletsSummaryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(currencyProvider).currencySymbol;
    final selectedItemCurrency = currency.isNotEmpty ? currency : '\$';
    final wallets = ref.watch(walletProvider);
    final scaleConfig = ScaleConfig(context);

    Future.microtask(() => CashFlowAdapter().preloadWallets());

    return Column(
      children: [
        SizedBox(height: scaleConfig.scale(10)),
        _buildTransferButton(context, ref, wallets, scaleConfig),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(scaleConfig.scale(24.0)),
            child: _buildWalletsList(
              context,
              ref,
              selectedItemCurrency,
              scaleConfig,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransferButton(
    BuildContext context,
    WidgetRef ref,
    List<Wallet> wallets,
    ScaleConfig scaleConfig,
  ) {
    final sortedWallets = List<Wallet>.from(wallets)
      ..sort((a, b) => b.isDefault ? 1 : -1);

    return SizedBox(
      width: scaleConfig.isTablet
          ? scaleConfig.widthPercentage(0.9)
          : scaleConfig.widthPercentage(0.92),
      child: ElevatedButton.icon(
        onPressed: () => showTransferDialog(context, ref, sortedWallets),
        icon: Icon(
          Icons.swap_horiz,
          color: AppColors.accentColor,
          size: scaleConfig.scale(20),
        ),
        label: Text(
          "Transfer".tr,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: scaleConfig.tabletScaleText(12),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          padding: EdgeInsets.symmetric(
            horizontal: scaleConfig.scale(16),
            vertical: scaleConfig.scale(12),
          ),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(scaleConfig.scale(12)),
          ),
        ),
      ),
    );
  }

  Widget _buildWalletsList(
    BuildContext context,
    WidgetRef ref,
    String currency,
    ScaleConfig scaleConfig,
  ) {
    return StreamBuilder<List<CashFlow>>(
      stream: ExpensesRepository().getExpensesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ParrotAnimation();
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: TextStyle(
                fontSize: scaleConfig.tabletScaleText(16),
                color: Colors.red,
              ),
            ),
          );
        }

        final expenses = snapshot.data ?? [];
        final wallets = ref.read(walletProvider);
        final sortedWallets = List<Wallet>.from(wallets)
          ..sort((a, b) => b.isDefault ? 1 : -1);

        final totalBalance = expenses.fold<double>(
          0,
          (sum, e) => e.isIncome ? sum + e.amount : sum - e.amount,
        );

        return ListView(
          children:
              sortedWallets.map((wallet) {
                final walletData = _calculateWalletData(
                  wallet,
                  expenses,
                  totalBalance,
                );
                return _buildWalletCard(
                  context,
                  wallet,
                  walletData['balance'],
                  currency,
                  ref,
                  walletData['progress'],
                  scaleConfig,
                );
              }).toList(),
        );
      },
    );
  }

  Map<String, dynamic> _calculateWalletData(
    Wallet wallet,
    List<CashFlow> expenses,
    double totalBalance,
  ) {
    final walletExpenses =
        expenses.where((e) => e.walletType.id == wallet.id).toList();
    final income = walletExpenses
        .where((e) => e.isIncome)
        .fold<double>(0, (sum, e) => sum + e.amount);
    final expense = walletExpenses
        .where((e) => !e.isIncome)
        .fold<double>(0, (sum, e) => sum + e.amount);
    final balance = income - expense;

    double calculatedProgress;

    if (balance <= 0) {
      calculatedProgress = 0.0;
    } else {
      if (totalBalance <= 0) {
        calculatedProgress =
            (totalBalance != 0 ? (balance / totalBalance).abs() : 1.0);
      } else {
        calculatedProgress = balance / totalBalance;
      }
    }

    return {'balance': balance, 'progress': calculatedProgress.clamp(0.0, 1.0)};
  }

  Widget _buildWalletCard(
    BuildContext context,
    Wallet wallet,
    double balance,
    String currency,
    WidgetRef ref,
    double progress,
    ScaleConfig scaleConfig,
  ) {
    final cardWidth = scaleConfig.isTablet
        ? scaleConfig.widthPercentage(0.88)
        : scaleConfig.widthPercentage(0.9);
    final cardHeight = scaleConfig.isTablet
        ? scaleConfig.scale(150)
        : scaleConfig.scale(162);
    Color? themeColor = Theme.of(context).appBarTheme.backgroundColor;

    final gradient = _getWalletGradient(wallet.type, themeColor!);
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(scaleConfig.scale(12)),
      ),
      margin: EdgeInsets.only(bottom: scaleConfig.scale(24)),
      child: Container(
        height: cardHeight,
        width: cardWidth,
        padding: EdgeInsets.all(scaleConfig.scale(12)),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(scaleConfig.scale(12)),
        ),
        child: Row(
          children: [
            _buildWalletInfo(
              wallet,
              balance < 0 ? 0 : balance,
              currency,
              progress,
              scaleConfig,
            ),
            _buildWalletVisual(context, wallet, scaleConfig, ref),
          ],
        ),
      ),
    );
  }

  LinearGradient _getWalletGradient(WalletType type, Color themeColor) {
    return LinearGradient(
      colors: [
        Colors.black,
        type == WalletType.bank
            ? themeColor.withOpacity(0.0)
            : type == WalletType.digital
            ? themeColor.withOpacity(0.0)
            : themeColor.withOpacity(0.0),
        type == WalletType.bank
            ? AppColors.accentColor2.withOpacity(0.1)
            : type == WalletType.digital
            ? AppColors.accentColor2.withOpacity(0.1)
            : AppColors.accentColor2.withOpacity(0.1),
        type == WalletType.bank
            ? AppColors.accentColor2.withOpacity(0.8)
            : type == WalletType.digital
            ? AppColors.accentColor2.withOpacity(0.8)
            : AppColors.accentColor2.withOpacity(0.8),
        Colors.black,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  Widget _buildWalletInfo(
    Wallet wallet,
    double balance,
    String currency,
    double progress,
    ScaleConfig scaleConfig,
  ) {
    return Expanded(
      flex: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            wallet.name.tr,
            style: TextStyle(
              fontSize: scaleConfig.tabletScaleText(14),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '$currency ${balance.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: scaleConfig.tabletScaleText(18),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          ProgressRow(
            progress: progress,
            label: '${wallet.name} Progress',
            amount: '$currency ${balance.toStringAsFixed(1)}',
            progressColor:
                wallet.type == WalletType.bank
                    ? AppColors.accentColor2
                    : AppColors.accentColor,
            type:
                wallet.type == WalletType.bank
                    ? "Bank"
                    : wallet.type == WalletType.cash
                    ? "Cash"
                    : "Digital",
          ),
        ],
      ),
    );
  }

  Widget _buildWalletVisual(
    BuildContext context,
    Wallet wallet,
    ScaleConfig scaleConfig,
    WidgetRef ref,
  ) {
    bool isArabic =
        ref.watch(languageProvider).toString() == "ar" ? true : false;

    return Expanded(
      flex: 1,
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Align(
            alignment: Alignment.center,
            child: Lottie.asset(
              wallet.type == WalletType.bank
                  ? "assets/bank+.json"
                  : wallet.type == WalletType.cash
                  ? "assets/cash_money_wallet.json"
                  : "assets/digital2.json",
              width: scaleConfig.scale(90),
              height: scaleConfig.scale(90),
              fit: BoxFit.contain,
            ),
          ),
          if (!wallet.isDefault)
            Positioned(
              top: 0,
              right: isArabic ? null : 0,
              left: isArabic ? 0 : null,
              child: PopupMenuButton<String>(
                color: Theme.of(context).appBarTheme.backgroundColor,
                icon: Icon(
                  Icons.more_vert,
                  color: Colors.white,
                  size: scaleConfig.scale(20),
                ),
                onSelected: (String value) {
                  if (value == 'Update') {
                    _showUpdateWalletModal(context, ref, wallet);
                  } else if (value == 'Delete') {
                    _showDeleteWalletDialog(context, ref, wallet);
                  }
                },
                itemBuilder:
                    (BuildContext context) => [
                      PopupMenuItem<String>(
                        value: 'Update',
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit,
                              size: scaleConfig.scale(18),
                              color: Colors.white,
                            ),
                            SizedBox(width: scaleConfig.scale(2)),
                            Text(
                              'Update'.tr,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: scaleConfig.tabletScaleText(12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'Delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: scaleConfig.scale(18),
                            ),
                            SizedBox(width: scaleConfig.scale(2)),
                            Text(
                              'Delete'.tr,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: scaleConfig.tabletScaleText(12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
              ),
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
    final walletNameController = TextEditingController(text: wallet.name);
    WalletType walletType = wallet.type;
    final scaleConfig = ScaleConfig(context);

    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor!,
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(scaleConfig.scale(24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: walletNameController,
                decoration: InputDecoration(
                  labelText: 'Wallet Name'.tr,
                  labelStyle: TextStyle(
                    color: Colors.white,
                    fontSize: scaleConfig.tabletScaleText(14),
                  ),
                ),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: scaleConfig.tabletScaleText(14),
                ),
              ),
              DropdownButton<WalletType>(
                value: walletType,
                dropdownColor: Theme.of(context).appBarTheme.backgroundColor!,
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: Colors.white,
                  size: scaleConfig.scale(20),
                ),
                onChanged: (WalletType? newValue) {
                  walletType = newValue!;
                },
                items:
                    WalletType.values
                        .map(
                          (type) => DropdownMenuItem(
                            value: type,
                            child: Text(
                              type.toString() == "WalletType.digital"
                                  ? "Digital".tr
                                  : type.toString() == "WalletType.cash"
                                  ? "Cash".tr
                                  : "Bank".tr,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: scaleConfig.tabletScaleText(14),
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(scaleConfig.scale(8)),
                  ),
                  backgroundColor: AppColors.accentColor,
                  padding: EdgeInsets.symmetric(
                    vertical: scaleConfig.scale(12),
                    horizontal: scaleConfig.scale(16),
                  ),
                ),
                onPressed: () {
                  wallet.name = walletNameController.text;
                  wallet.type = walletType;
                  ref.read(walletProvider.notifier).updateWallet(wallet);
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Update Wallet'.tr,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: scaleConfig.tabletScaleText(14),
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteWalletDialog(
    BuildContext context,
    WidgetRef ref,
    Wallet wallet,
  ) {
    final scaleConfig = ScaleConfig(context);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor!,
            title: Text(
              'Delete Wallet'.tr,
              style: TextStyle(
                color: Colors.white,
                fontSize: scaleConfig.tabletScaleText(16),
              ),
            ),
            content: Text(
              'Are you sure you want to delete ${wallet.name}?'.tr,
              style: TextStyle(
                color: Colors.white,
                fontSize: scaleConfig.tabletScaleText(14),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel'.tr,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: scaleConfig.tabletScaleText(14),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  ref.read(walletProvider.notifier).deleteWallet(wallet);
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Delete'.tr,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: scaleConfig.tabletScaleText(14),
                  ),
                ),
              ),
            ],
          ),
    );
  }
}