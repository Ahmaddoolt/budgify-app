// lib/views/widgets/add_cashflow.dart

import 'package:budgify/core/utils/snackbar_helper.dart';
import 'package:budgify/core/utils/date_picker_widget.dart';
import 'package:budgify/initialization.dart';
import 'package:budgify/viewmodels/providers/multi_currency_provider.dart';
import 'package:budgify/viewmodels/providers/sound_toggle_provider.dart';
import 'package:budgify/viewmodels/providers/switchOnOffIncome.dart';
import 'package:budgify/viewmodels/providers/total_expenses_amount.dart';
import 'package:budgify/viewmodels/providers/total_expenses_monthly.dart';
import 'package:budgify/viewmodels/providers/total_incomes.dart';
import 'package:budgify/viewmodels/providers/total_incomes_monthly.dart';
import 'package:budgify/viewmodels/providers/wallet_provider.dart';
import 'package:budgify/views/pages/categories_wallets/categories_view/categories_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import '../../core/constants/currencies.dart';
import '../../core/themes/app_colors.dart';
import '../../domain/models/expense.dart';
import '../../domain/models/category.dart';
import '../../domain/models/currency.dart';
import '../../domain/models/wallet.dart';
import '../pages/categories_wallets/categories_view/add_category_showing.dart';
import '../pages/categories_wallets/wallets_view/add_wallet.dart';

class AddExpenseView extends ConsumerStatefulWidget {
  final Function(CashFlow) onAdd;
  const AddExpenseView({super.key, required this.onAdd});
  @override
  AddExpenseViewState createState() => AddExpenseViewState();
}

class AddExpenseViewState extends ConsumerState<AddExpenseView> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  double _amount = 0.0;
  String _notes = '';
  Category? _category;
  DateTime _date = DateTime.now();
  bool isSelectedDate = false;
  String _transactionType = 'Expense';
  Wallet? _selectedWallet;

  Currency? _transactionCurrency;
  String? _errorMessage;

  final Wallet _addWalletPlaceholder = Wallet(
    id: 'add_wallet_placeholder',
    name: 'Add new wallet',
    type: WalletType.bank,
    currencyCode: '',
    currencySymbol: '',
  );

  @override
  void initState() {
    super.initState();
    _transactionCurrency = _getPermanentDefaultCurrency();
  }

  Currency _getPermanentDefaultCurrency() {
    final defaultCode = sharedPreferences.getString('currency_code') ?? 'USD';
    return findCurrencyByCode(defaultCode);
  }

  void _submitTransaction() {
    setState(() => _errorMessage = null);
    final Currency? currencyForTransaction = _transactionCurrency;

    if (!_formKey.currentState!.validate() ||
        _category == null ||
        _selectedWallet == null ||
        currencyForTransaction == null ||
        !isSelectedDate) {
      setState(() => _errorMessage = 'Please fill all required fields'.tr);
      return;
    }

    Get.find<SoundService>().playButtonClickSound();

    final isIncome = _transactionType == 'Income';
    final wallet = _selectedWallet!;

    if (!isIncome) {
      if (wallet.minValue != null &&
          wallet.value >= wallet.minValue! &&
          (wallet.value - _amount) < wallet.minValue!) {
        setState(() => _errorMessage =
            'This expense would bring ${wallet.name} below its minimum value of ${wallet.minValue}'
                .tr);
        return;
      }
    } else {
      if (wallet.maxValue != null &&
          (wallet.value + _amount) > wallet.maxValue!) {
        setState(() => _errorMessage =
            'This income would push ${wallet.name} above its maximum value of ${wallet.maxValue}'
                .tr);
        return;
      }
    }

    final newTransaction = CashFlow(
      id: DateTime.now().toString(),
      title: _title,
      amount: _amount,
      currencyCode: currencyForTransaction.code,
      currencySymbol: currencyForTransaction.symbol,
      date: _date,
      category: _category!,
      notes: _notes,
      isIncome: isIncome,
      walletType: wallet,
    );
    widget.onAdd(newTransaction);

    final now = DateTime.now();
    final isCurrentMonth = (newTransaction.date.year == now.year &&
        newTransaction.date.month == now.month);

    if (newTransaction.isIncome) {
      ref
          .read(totalIncomesAmountProvider.notifier)
          .increment(newTransaction.amount);
      if (isCurrentMonth) {
        ref
            .read(monthlyIncomesAmountProvider.notifier)
            .increment(newTransaction.amount);
      }
    } else {
      ref.read(totalAmountProvider.notifier).increment(newTransaction.amount);
      if (isCurrentMonth) {
        ref
            .read(monthlyAmountProvider.notifier)
            .increment(newTransaction.amount);
      }
    }

    ref
        .read(walletProvider.notifier)
        .updateWalletValue(wallet.id, _amount, isIncome: isIncome);

    Navigator.of(context).pop();
    showFeedbackSnackbar(context, 'CashFlow added successfully'.tr);
  }

  Widget _buildErrorMessage() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Container(
        padding: EdgeInsets.only(bottom: _errorMessage == null ? 0 : 16.0),
        child: _errorMessage == null
            ? const SizedBox.shrink()
            : Text(
                _errorMessage!,
                style: TextStyle(color: Colors.redAccent[100], fontSize: 13),
                textAlign: TextAlign.center,
              ),
      ),
    );
  }

  /// Opens a dialog to select a currency from the list of currencies
  /// currently in use in the user's wallets.
  void _openCurrencySearchDialog(List<Currency> usedCurrencies) async {
    final result = await showDialog<Currency>(
      context: context,
      builder: (context) => _CurrencySearchDialog(currencies: usedCurrencies),
    );

    if (result != null && mounted) {
      setState(() {
        _transactionCurrency = result;
        _selectedWallet = null;
        _errorMessage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesState = ref.watch(categoryProvider);
    final allWallets = ref.watch(walletProvider);
    Color cardColor = Theme.of(context).appBarTheme.backgroundColor!;
    final switchState = ref.watch(switchProvider);
    final categoryRepository = ref.read(categoryProvider.notifier).repository;
    final isMultiCurrencyEnabled = ref.watch(multiCurrencyProvider);

    // --- NEW LOGIC: Determine which currencies are in use ---
    final uniqueUsedCurrencyCodes =
        allWallets.map((w) => w.currencyCode).toSet();
    final usedCurrencies = availableCurrencies
        .where((c) => uniqueUsedCurrencyCodes.contains(c.code))
        .toList();

    // The currency dropdown should only be available if the user has it enabled
    // AND has more than one currency across all wallets.
    final canChangeCurrency =
        isMultiCurrencyEnabled && usedCurrencies.length > 1;

    final Currency currencyToUse =
        _transactionCurrency ?? _getPermanentDefaultCurrency();

    final walletsForSelectedCurrency = allWallets.where((wallet) {
      bool isAllowedByType = false;
      if (wallet.isEnabled) {
        if (wallet.allowedTransactionType == WalletFunctionality.both) {
          isAllowedByType = true;
        } else if (_transactionType == 'Income' &&
            wallet.allowedTransactionType == WalletFunctionality.income) {
          isAllowedByType = true;
        } else if (_transactionType == 'Expense' &&
            wallet.allowedTransactionType == WalletFunctionality.expense) {
          isAllowedByType = true;
        }
      }
      if (!isAllowedByType) return false;
      return wallet.currencyCode == currencyToUse.code;
    }).toList();

    final availableCategories = categoriesState
        .where((c) =>
            c.type ==
            (_transactionType == 'Income'
                ? CategoryType.income
                : CategoryType.expense))
        .toList();
    if (_category != null &&
        !availableCategories.any((c) => c.id == _category!.id)) {
      availableCategories.insert(0, _category!);
    }

    return SizedBox(
      width: double.maxFinite,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                style: const TextStyle(color: Colors.grey),
                decoration: InputDecoration(
                    labelText: 'Title'.tr,
                    labelStyle: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700),
                    prefixIcon: const Icon(Icons.title, color: Colors.white)),
                validator: (v) =>
                    v!.isEmpty ? 'Please enter a title.'.tr : null,
                onChanged: (v) => setState(() {
                  _title = v;
                  _errorMessage = null;
                }),
              ),
              TextFormField(
                style: const TextStyle(color: Colors.grey),
                decoration: InputDecoration(
                    labelText: 'Amount'.tr,
                    labelStyle: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700),
                    prefixIcon: const Icon(Icons.money, color: Colors.white)),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    (v == null || v.isEmpty || double.tryParse(v) == null)
                        ? 'Please enter a valid number.'.tr
                        : null,
                onChanged: (v) => setState(() {
                  _amount = double.tryParse(v) ?? 0.0;
                  _errorMessage = null;
                }),
              ),
              if (canChangeCurrency)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: InkWell(
                    onTap: () => _openCurrencySearchDialog(usedCurrencies),
                    child: InputDecorator(
                      decoration: InputDecoration(
                          labelText: 'Currency'.tr,
                          labelStyle: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w700),
                          prefixIcon: const Icon(Icons.currency_exchange,
                              color: Colors.white),
                          contentPadding:
                              const EdgeInsets.fromLTRB(12, 16, 12, 16),
                          enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey))),
                      child: Text(
                        '${currencyToUse.code.tr} (${currencyToUse.symbol})',
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                  ),
                ),
              if (switchState.isSwitched)
                DropdownButtonFormField<String>(
                  dropdownColor: cardColor,
                  style: const TextStyle(color: Colors.grey),
                  decoration: InputDecoration(
                      labelText: 'CashFlow Type'.tr,
                      labelStyle: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700),
                      prefixIcon:
                          const Icon(Icons.swap_vert, color: Colors.white)),
                  value: _transactionType,
                  items: [
                    DropdownMenuItem(value: 'Income', child: Text('Income'.tr)),
                    DropdownMenuItem(
                        value: 'Expense', child: Text('Expense'.tr)),
                  ],
                  onChanged: (v) => setState(() {
                    _transactionType = v!;
                    _category = null;
                    _selectedWallet = null;
                    _errorMessage = null;
                  }),
                ),
              categoriesState.isEmpty
                  ? const CircularProgressIndicator()
                  : DropdownButtonFormField<Category>(
                      dropdownColor: cardColor,
                      style: const TextStyle(color: Colors.grey),
                      decoration: InputDecoration(
                          labelText: 'Category'.tr,
                          labelStyle: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w700),
                          prefixIcon:
                              const Icon(Icons.category, color: Colors.white)),
                      value: availableCategories.contains(_category)
                          ? _category
                          : null,
                      items: [
                        ...availableCategories.map((c) =>
                            DropdownMenuItem<Category>(
                              value: c,
                              child: Row(children: [
                                Icon(c.icon, color: c.color),
                                const SizedBox(width: 8),
                                Text(c.name.tr,
                                    style: const TextStyle(color: Colors.white))
                              ]),
                            )),
                        DropdownMenuItem<Category>(
                          value: Category(
                              id: 'add',
                              name: 'Add new category',
                              description: '',
                              iconKey: "category",
                              color: AppColors.accentColor,
                              isNew: true,
                              type: CategoryType.expense),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.add, color: AppColors.accentColor),
                            const SizedBox(width: 8),
                            Text('Add new category'.tr,
                                style: const TextStyle(color: Colors.white))
                          ]),
                        ),
                      ],
                      validator: (v) => (v == null && _category == null)
                          ? 'Please select a category.'.tr
                          : null,
                      onChanged: (v) {
                        setState(() => _errorMessage = null);
                        if (v != null && v.id == 'add') {
                          showModalBottomSheet(
                            backgroundColor:
                                Theme.of(context).appBarTheme.backgroundColor!,
                            context: context,
                            builder: (ctx) => AddCategoryModal(
                              categoryRepository: categoryRepository,
                              onCategoryAdded: (c) =>
                                  setState(() => _category = c),
                            ),
                          );
                        } else {
                          setState(() => _category = v);
                        }
                      },
                    ),
              DropdownButtonFormField<Wallet>(
                dropdownColor: cardColor,
                style: const TextStyle(color: Colors.grey),
                decoration: InputDecoration(
                    labelText: 'Wallet'.tr,
                    labelStyle: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700),
                    prefixIcon: const Icon(Icons.account_balance_wallet,
                        color: Colors.white)),
                value: walletsForSelectedCurrency.contains(_selectedWallet)
                    ? _selectedWallet
                    : null,
                items: [
                  ...walletsForSelectedCurrency
                      .map((w) => DropdownMenuItem<Wallet>(
                            value: w,
                            child: Row(children: [
                              Icon(
                                  w.type == WalletType.cash
                                      ? Icons.money_rounded
                                      : w.type == WalletType.bank
                                          ? Icons.account_balance
                                          : Icons.credit_card,
                                  color: Colors.white),
                              const SizedBox(width: 8),
                              Text(w.name,
                                  style: const TextStyle(color: Colors.white))
                            ]),
                          )),
                  DropdownMenuItem<Wallet>(
                    value: _addWalletPlaceholder,
                    child: Row(children: [
                      const Icon(Icons.add, color: AppColors.accentColor),
                      const SizedBox(width: 8),
                      Text('Add new wallet'.tr,
                          style: const TextStyle(color: Colors.white))
                    ]),
                  ),
                ],
                validator: (v) =>
                    v == null ? 'Please select a wallet.'.tr : null,
                onChanged: (v) {
                  setState(() => _errorMessage = null);
                  if (v != null && v.id == _addWalletPlaceholder.id) {
                    setState(() => _selectedWallet = null);
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (ctx) => AddWalletModal(
                        onWalletAdded: (w) {
                          setState(() {
                            if (w.isEnabled &&
                                w.currencyCode == currencyToUse.code &&
                                (w.allowedTransactionType ==
                                        WalletFunctionality.both ||
                                    (w.allowedTransactionType ==
                                            WalletFunctionality.income &&
                                        _transactionType == 'Income') ||
                                    (w.allowedTransactionType ==
                                            WalletFunctionality.expense &&
                                        _transactionType == 'Expense'))) {
                              _selectedWallet = w;
                            }
                          });
                        },
                        pageContext: context,
                      ),
                    );
                  } else {
                    setState(() => _selectedWallet = v);
                  }
                },
              ),
              TextFormField(
                style: const TextStyle(color: Colors.grey),
                decoration: InputDecoration(
                    labelText: 'Notes (optional)'.tr,
                    labelStyle: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700),
                    prefixIcon: const Icon(Icons.note, color: Colors.white)),
                onChanged: (v) => setState(() => _notes = v),
              ),
              const SizedBox(height: 16),
              DatePickerWidget(
                initialDate: _date,
                isSelected: isSelectedDate,
                onDateSelected: (d) => setState(() {
                  _date = d;
                  isSelectedDate = true;
                  _errorMessage = null;
                }),
                firstDate: DateTime(2000),
                lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                errorText: isSelectedDate ? null : 'Please select a date'.tr,
              ),
              const SizedBox(height: 16),
              _buildErrorMessage(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                    backgroundColor: AppColors.accentColor),
                onPressed: _submitTransaction,
                child: Text(
                  'Add'.tr,
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CurrencySearchDialog extends ConsumerStatefulWidget {
  final List<Currency> currencies;
  const _CurrencySearchDialog({required this.currencies});
  @override
  ConsumerState<_CurrencySearchDialog> createState() =>
      _CurrencySearchDialogState();
}

class _CurrencySearchDialogState extends ConsumerState<_CurrencySearchDialog> {
  late final TextEditingController _searchController;
  String _searchQuery = '';
  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredCurrencies = widget.currencies.where((currency) {
      final query = _searchQuery.toLowerCase();
      final translatedName = currency.code.tr.toLowerCase();
      return translatedName.contains(query) ||
          currency.code.toLowerCase().contains(query);
    }).toList();
    return AlertDialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: Text('Select Currency'.tr),
      contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0),
      content: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search by name or code...'.tr,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filteredCurrencies.length,
                itemBuilder: (context, index) {
                  final currency = filteredCurrencies[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('${currency.code.tr} (${currency.code})'),
                    trailing: Text(currency.symbol),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).pop(currency);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'.tr),
        ),
      ],
    );
  }
}
