import 'package:budgify/core/themes/app_colors.dart';
import 'package:budgify/core/utils/scale_config.dart';
import 'package:budgify/viewmodels/providers/sound_toggle_provider.dart';
import 'package:budgify/core/navigation/navigation_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import '../../../core/constants/currencies.dart';
import '../../../domain/models/currency.dart';
import '../../../viewmodels/providers/currency_symbol.dart';
import '../../../viewmodels/providers/switchOnOffIncome.dart';
import '../../../viewmodels/providers/wallet_provider.dart';
import 'budget/add_budget.dart';
import '../celender_screen.dart';
import '../../widgets/cards/expense_card_no_incomes.dart';
import 'budget/list_budget.dart';
import 'most_spend.dart';
import '../../widgets/cards/status_money_card.dart';

final earningToggleProvider = StateProvider<bool>((ref) => false);

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responsive = context.responsive;
    final displayCurrency = ref.watch(currencyProvider).displayCurrency;
    final incomeSwitchState = ref.watch(switchProvider);
    final isTopEarning = ref.watch(earningToggleProvider);
    final showIncomes = incomeSwitchState.isSwitched;

    return Scaffold(
      appBar: _buildAppBar(context, ref, showIncomes, displayCurrency),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: responsive.setHeight(22)),
            _buildMoneyCard(showIncomes, displayCurrency),
            SizedBox(height: responsive.setHeight(7)),
            _buildTopSpendingHeader(context, ref, showIncomes, isTopEarning),
            HorizontalExpenseList(
              isIncome: isTopEarning && showIncomes,
              currencyCode: displayCurrency.code,
              currencySymbol: displayCurrency.symbol,
            ),
            _buildBudgetHeader(context, ref),
            SizedBox(
              height: responsive.setHeight(150),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: BudgetListView(
                  currencyCode: displayCurrency.code,
                  currencySymbol: displayCurrency.symbol,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, WidgetRef ref, bool showIncomes,
      Currency currentDisplayCurrency) {
    final allWallets = ref.watch(walletProvider);
    final responsive = context.responsive;

    final Map<String, Currency> uniqueCurrenciesMap = {};
    for (var wallet in allWallets) {
      if (!uniqueCurrenciesMap.containsKey(wallet.currencyCode)) {
        final currency = availableCurrencies.firstWhere(
            (c) => c.code == wallet.currencyCode,
            orElse: () => currentDisplayCurrency);
        uniqueCurrenciesMap[wallet.currencyCode] = currency;
      }
    }
    final List<Currency> usedCurrencies = uniqueCurrenciesMap.values.toList();

    String? dropdownValue;
    if (uniqueCurrenciesMap.containsKey(currentDisplayCurrency.code)) {
      dropdownValue = currentDisplayCurrency.code;
    } else {
      dropdownValue =
          usedCurrencies.isNotEmpty ? usedCurrencies.first.code : null;
    }

    return AppBar(
      title: Text(
        "Home page".tr,
        style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: responsive.setSp(18)),
      ),
      actions: [
        Row(
          children: [
            if (usedCurrencies.length > 1 && dropdownValue != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: dropdownValue,
                    icon: Icon(Icons.keyboard_arrow_down,
                        color: Theme.of(context).appBarTheme.backgroundColor,
                        size: responsive.setSp(2)),
                    dropdownColor: Theme.of(context).cardTheme.color,
                    // --- UPDATED WIDGET: selectedItemBuilder ---
                    // This defines how the selected item looks on the AppBar
                    selectedItemBuilder: (BuildContext context) {
                      return usedCurrencies.map<Widget>((Currency currency) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: responsive.setWidth(4)),
                            child: Text(
                              currency.symbol, // Show only the symbol
                              style: TextStyle(
                                color: AppColors.accentColor,
                                fontSize: responsive.setSp(20),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList();
                    },
                    // --- UPDATED WIDGET: items ---
                    // This defines how the items look inside the dropdown list
                    items: usedCurrencies.map((currency) {
                      return DropdownMenuItem<String>(
                        value: currency.code,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${currency.symbol} ', // Symbol with space
                              style: TextStyle(
                                  color: AppColors.accentColor,
                                  fontSize: responsive.setSp(15),
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              currency.code, // Clean currency code
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: responsive.setSp(13),
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (newCode) {
                      if (newCode != null) {
                        ref
                            .read(currencyProvider.notifier)
                            .changeDisplayCurrency(newCode);
                      }
                    },
                  ),
                ),
              ),
            IconButton(
              icon: Icon(Icons.calendar_month, color: AppColors.accentColor),
              onPressed: () {
                Get.find<SoundService>().playButtonClickSound();
                _navigateToCalendar(ref, showIncomes);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMoneyCard(bool showIncomes, Currency currency) {
    return showIncomes
        ? Center(child: SavingsCard(currency: currency))
        : Center(child: BalanceCard(currency: currency));
  }

  Widget _buildTopSpendingHeader(
    BuildContext context,
    WidgetRef ref,
    bool showIncomes,
    bool isTopEarning,
  ) {
    final responsive = context.responsive;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: responsive.setWidth(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildHeaderText(
            context: context,
            text: isTopEarning ? "Top Earning".tr : "Top Spending".tr,
            padding: EdgeInsets.symmetric(
              vertical: responsive.setHeight(16),
              horizontal: responsive.setWidth(4),
            ),
          ),
          if (showIncomes) _buildEarningDropdown(context, ref, isTopEarning),
        ],
      ),
    );
  }

  Widget _buildHeaderText({
    required BuildContext context,
    required String text,
    required EdgeInsets padding,
  }) {
    final responsive = context.responsive;
    return Padding(
      padding: padding,
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: responsive.setSp(18.4),
        ),
      ),
    );
  }

  Widget _buildEarningDropdown(
    BuildContext context,
    WidgetRef ref,
    bool isTopEarning,
  ) {
    final responsive = context.responsive;
    final theme = Theme.of(context);
    return Flexible(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: responsive.setWidth(12)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<bool>(
            icon: Icon(
              Icons.arrow_drop_down_circle,
              color: AppColors.accentColor,
              size: responsive.setWidth(20),
            ),
            value: isTopEarning,
            dropdownColor: theme.cardTheme.color,
            items: [
              _buildDropdownItem(
                context: context,
                value: false,
                icon: Icons.trending_down,
                isSelected: !isTopEarning,
              ),
              _buildDropdownItem(
                context: context,
                value: true,
                icon: Icons.trending_up,
                isSelected: isTopEarning,
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                Get.find<SoundService>().playButtonClickSound();
                ref.read(earningToggleProvider.notifier).state = value;
              }
            },
            selectedItemBuilder: (context) => const [SizedBox(), SizedBox()],
          ),
        ),
      ),
    );
  }

  DropdownMenuItem<bool> _buildDropdownItem({
    required bool value,
    required IconData icon,
    required bool isSelected,
    required BuildContext context,
  }) {
    final responsive = context.responsive;

    return DropdownMenuItem(
      value: value,
      child: Icon(
        icon,
        color: isSelected ? AppColors.accentColor : Colors.white,
        size: responsive.setWidth(18),
      ),
    );
  }

  Widget _buildBudgetHeader(BuildContext context, WidgetRef ref) {
    final responsive = context.responsive;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: responsive.setWidth(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildHeaderText(
            context: context,
            text: "Month Budget".tr,
            padding: EdgeInsets.symmetric(vertical: responsive.setHeight(17)),
          ),
          IconButton(
            onPressed: () {
              Get.find<SoundService>().playButtonClickSound();
              showBudgetBottomSheet(context);
            },
            icon: Icon(
              Icons.add_circle,
              color: AppColors.accentColor,
              size: responsive.setWidth(20),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToCalendar(WidgetRef ref, bool showIncomes) {
    final now = DateTime.now();
    navigateTo(
      ref.context,
      CalendarViewPage(
        month: now.month,
        year: now.year,
        showIncomes: showIncomes,
      ),
    );
  }
}
