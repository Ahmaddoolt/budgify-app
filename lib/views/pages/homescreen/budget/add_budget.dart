// lib/views/pages/home_page/budget/add_budget.dart

import 'package:budgify/core/utils/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../../../core/constants/currencies.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../data/repo/budget_repostiry.dart';
import '../../../../data/repo/category_repositry.dart';
import '../../../../domain/models/budget.dart';
import '../../../../domain/models/category.dart';
import '../../../../domain/models/currency.dart';
import '../../../../domain/models/wallet.dart';
import '../../../../initialization.dart';
import '../../../../viewmodels/providers/multi_currency_provider.dart';
import '../../../../viewmodels/providers/wallet_provider.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  Category? _category;
  double _budgetAmount = 0.0;
  Currency? _budgetCurrency;

  late CategoryRepository _categoryRepository;
  late BudgetRepository _budgetRepository;
  List<Category> categoriesState = [];
  List<Budget> existingBudgets = [];

  @override
  void initState() {
    super.initState();
    _budgetCurrency = _getPermanentDefaultCurrency();
    _loadCategoriesAndBudgets();
  }

  Currency _getPermanentDefaultCurrency() {
    final defaultCode = sharedPreferences.getString('currency_code') ?? 'USD';
    return findCurrencyByCode(defaultCode);
  }

  Future<void> _loadCategoriesAndBudgets() async {
    final categoryBox = await Hive.openBox<Category>('categories');
    _categoryRepository = CategoryRepository(categoryBox);

    setState(() {
      categoriesState = _categoryRepository.loadCategories();
    });

    _budgetRepository = BudgetRepository(categoriesState);
    await _budgetRepository.init();
    existingBudgets = _budgetRepository.loadBudgets();
  }

  bool _isCategoryAlreadyBudgeted(Category category, Currency currency) {
    return existingBudgets.any((budget) =>
        budget.categoryId == category.id &&
        budget.currencyCode == currency.code);
  }

  @override
  Widget build(BuildContext context) {
    Color cardColor = Theme.of(context).colorScheme.primary;
    final isMultiCurrencyEnabled = ref.watch(multiCurrencyProvider);

    // --- NEW LOGIC: Determine which currencies are in use ---
    final allWallets = ref.watch(walletProvider);
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
        _budgetCurrency ?? _getPermanentDefaultCurrency();

    return Form(
      key: _formKey,
      child: Container(
        width: double.infinity,
        color: cardColor,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Text(
              'Add Budget'.tr,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 16),
            categoriesState.isEmpty
                ? const CircularProgressIndicator()
                : DropdownButtonFormField<Category>(
                    value: _category,
                    dropdownColor: cardColor,
                    style: const TextStyle(color: Colors.grey),
                    decoration: InputDecoration(
                      labelText: 'Category'.tr,
                      labelStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white54),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.accentColor),
                      ),
                    ),
                    items: categoriesState
                        .where(
                      (category) => category.type == CategoryType.expense,
                    )
                        .map((category) {
                      return DropdownMenuItem<Category>(
                        value: category,
                        child: Row(
                          children: [
                            Icon(category.icon, color: category.color),
                            const SizedBox(width: 8),
                            Text(
                              category.name.tr,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a category.'.tr;
                      }
                      if (_isCategoryAlreadyBudgeted(value, currencyToUse)) {
                        return 'Budget already exists for this category/currency.'
                            .tr;
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _category = value;
                      });
                    },
                  ),
            if (canChangeCurrency)
              DropdownButtonFormField<Currency>(
                value: _budgetCurrency,
                dropdownColor: cardColor,
                style: const TextStyle(color: Colors.grey),
                decoration: InputDecoration(
                  labelText: 'Currency'.tr,
                  labelStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                // --- THE FIX: Use the filtered list of used currencies ---
                items: usedCurrencies.map((currency) {
                  return DropdownMenuItem<Currency>(
                    value: currency,
                    child: Text(
                      '${currency.code.tr} (${currency.symbol})',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _budgetCurrency = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a currency.'.tr : null,
              ),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Budget Amount'.tr,
                labelStyle: const TextStyle(color: Colors.white),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white54),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.accentColor),
                ),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a budget amount.'.tr;
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid amount.'.tr;
                }
                return null;
              },
              onChanged: (value) {
                _budgetAmount = double.tryParse(value) ?? 0.0;
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                backgroundColor: AppColors.accentColor,
              ),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final budget = Budget(
                    categoryId: _category!.id,
                    budgetAmount: _budgetAmount,
                    currencyCode: currencyToUse.code,
                    currencySymbol: currencyToUse.symbol,
                  );

                  await _budgetRepository.addBudget(budget);
                  showFeedbackSnackbar(
                    context,
                    'Budget added successfully!'.tr,
                  );

                  setState(() {
                    _formKey.currentState?.reset();
                    _category = null;
                    _budgetAmount = 0.0;
                    _budgetCurrency = _getPermanentDefaultCurrency();
                    existingBudgets = _budgetRepository.loadBudgets();
                  });

                  Navigator.of(context).pop();
                }
              },
              child: Text(
                'Add'.tr,
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

void showBudgetBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.mainDarkColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: const BudgetScreen(),
    ),
  );
}
