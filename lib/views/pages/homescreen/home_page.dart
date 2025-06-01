import 'package:budgify/core/themes/app_colors.dart';
import 'package:budgify/core/utils/scale_config.dart';
import 'package:budgify/viewmodels/providers/sound_toggle_provider.dart';
import 'package:budgify/views/navigation/navigation_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import '../../../viewmodels/providers/currency_symbol.dart';
import '../../../viewmodels/providers/switchOnOffIncome.dart';
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
    final scale = context.scaleConfig;
    final currencyState = ref.watch(currencyProvider);
    final incomeSwitchState = ref.watch(switchProvider);
    final isTopEarning = ref.watch(earningToggleProvider);
    final showIncomes = incomeSwitchState.isSwitched;

    return Scaffold(
      appBar: _buildAppBar(ref, showIncomes),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: scale.scale(22)),
            _buildMoneyCard(showIncomes, currencyState.currencySymbol),
            SizedBox(height: scale.scale(7)),
            _buildTopSpendingHeader(context, ref, showIncomes, isTopEarning),
            HorizontalExpenseList(isIncome: isTopEarning && showIncomes),
            _buildBudgetHeader(context, ref),
            SizedBox(
              height: scale.scale(150),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: BudgetListView(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(WidgetRef ref, bool showIncomes) {
    return AppBar(
      title: Text(
        "Home page".tr,
        style: const TextStyle(fontWeight: FontWeight.bold , fontSize: 18),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.calendar_month, color: AppColors.accentColor),
          onPressed: () {
            Get.find<SoundService>().playButtonClickSound();
            _navigateToCalendar(ref, showIncomes);
          },
        ),
      ],
    );
  }

  Widget _buildMoneyCard(bool showIncomes, String currencySymbol) {
    return showIncomes
        ? const Center(child: SavingsCard())
        : Center(child: BalanceCard(currenySympol: currencySymbol));
  }

  Widget _buildTopSpendingHeader(
    BuildContext context,
    WidgetRef ref,
    bool showIncomes,
    bool isTopEarning,
  ) {
    final scale = context.scaleConfig;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: scale.scale(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildHeaderText(
            context: context,
            text: isTopEarning ? "Top Earning".tr : "Top Spending".tr,
            padding: EdgeInsets.symmetric(
              vertical: scale.scale(16),
              horizontal: scale.scale(4),
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
    final scale = context.scaleConfig;
    return Padding(
      padding: padding,
      child: Text(
        text.tr,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: scale.scaleText(18.4),
        ),
      ),
    );
  }

  Widget _buildEarningDropdown(
    BuildContext context,
    WidgetRef ref,
    bool isTopEarning,
  ) {
    final scale = context.scaleConfig;
    final theme = Theme.of(context);
    return Flexible(
      child: Padding(
        padding: EdgeInsets.only(right: scale.scale(12) , left: scale.scale(12)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<bool>(
            icon: Icon(
              Icons.arrow_drop_down_circle,
              color: AppColors.accentColor,
              size: scale.scale(20),
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
    final scale = context.scaleConfig;

    return DropdownMenuItem(
      value: value,
      child: Icon(
        icon,
        color: isSelected ? AppColors.accentColor : Colors.white,
        size: scale.scale(18),
      ),
    );
  }

  Widget _buildBudgetHeader(BuildContext context, WidgetRef ref) {
    final scale = context.scaleConfig;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: scale.scale(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildHeaderText(
            context: context,
            text: "Month Budget".tr,
            padding: EdgeInsets.symmetric(vertical: scale.scale(17)),
          ),
          IconButton(
            onPressed: () {
              Get.find<SoundService>().playButtonClickSound();
              showBudgetBottomSheet(context);
            },
            icon: Icon(
              Icons.add_circle,
              color: AppColors.accentColor,
              size: scale.scale(20),
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
