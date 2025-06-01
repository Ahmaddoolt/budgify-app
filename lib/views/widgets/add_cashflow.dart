import 'package:budgify/core/utils/snackbar_helper.dart';
import 'package:budgify/viewmodels/providers/sound_toggle_provider.dart';
import 'package:budgify/core/utils/date_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import '../../core/themes/app_colors.dart';
import '../../domain/models/expense.dart';
import '../../domain/models/category.dart';
import '../../domain/models/wallet.dart';
import '../../viewmodels/providers/switchOnOffIncome.dart';
import '../../viewmodels/providers/total_expenses_amount.dart';
import '../../viewmodels/providers/total_expenses_monthly.dart';
import '../../viewmodels/providers/total_incomes.dart';
import '../../viewmodels/providers/total_incomes_monthly.dart';
import '../../viewmodels/providers/wallet_provider.dart';
import '../pages/categories_wallets/categories_view/add_category_showing.dart';
import '../pages/categories_wallets/wallets_view/add_wallet.dart';
import '../pages/categories_wallets/categories_view/categories_list.dart';

class AddExpenseView extends ConsumerStatefulWidget {
  final Function(CashFlow) onAdd;

  const AddExpenseView({super.key, required this.onAdd});

  @override
  // ignore: library_private_types_in_public_api
  _AddExpenseViewState createState() => _AddExpenseViewState();
}

class _AddExpenseViewState extends ConsumerState<AddExpenseView> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  double _amount = 0.0;
  String _notes = '';
  Category? _category;
  DateTime _date = DateTime.now();
  bool isSelectedDate = false;
  String _transactionType = 'Expense';
  Wallet? _selectedWallet;

  Wallet addNewWalletPlaceholder = Wallet(
    id: 'add_wallet',
    name: 'Add new wallet',
    type: WalletType.bank,
  );

  @override
  Widget build(BuildContext context) {
    final categoriesState = ref.watch(categoryProvider);
    final walletsState = ref.watch(walletProvider);
    Color cardColor = Theme.of(context).appBarTheme.backgroundColor!;

    final switchState = ref.watch(switchProvider);
    final categoryRepository = ref.read(categoryProvider.notifier).repository;

    return SizedBox(
      width: double.maxFinite,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title field
              TextFormField(
                style: const TextStyle(color: Colors.grey),
                decoration: InputDecoration(
                  labelText: 'Title'.tr,
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
                  prefixIcon: const Icon(Icons.title, color: Colors.white),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title.'.tr;
                  }
                  return null;
                },
                onChanged: (value) {
                  _title = value;
                },
              ),

              // Amount field
              TextFormField(
                style: const TextStyle(color: Colors.grey),
                decoration: InputDecoration(
                  labelText: 'Amount'.tr,
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
                  prefixIcon: const Icon(Icons.money, color: Colors.white),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount.'.tr;
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number.'.tr;
                  }
                  return null;
                },
                onChanged: (value) {
                  _amount = double.tryParse(value) ?? 0.0;
                },
              ),

              // Transaction Type dropdown
              if (switchState.isSwitched)
                DropdownButtonFormField<String>(
                  dropdownColor: cardColor,
                  style: const TextStyle(color: Colors.grey),
                  decoration: InputDecoration(
                    labelText: 'CashFlow Type'.tr,
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
                    prefixIcon: const Icon(
                      Icons.swap_vert,
                      color: Colors.white,
                    ),
                  ),
                  value: _transactionType,
                  items: [
                    DropdownMenuItem(value: 'Income', child: Text('Income'.tr)),
                    DropdownMenuItem(
                      value: 'Expense',
                      child: Text('Expense'.tr),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _transactionType = value!;
                      _category = null; // Reset category when type changes
                    });
                  },
                ),

              // Category dropdown
              categoriesState.isEmpty
                  ? const CircularProgressIndicator()
                  : DropdownButtonFormField<Category>(
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
                      prefixIcon: const Icon(
                        Icons.category,
                        color: Colors.white,
                      ),
                    ),
                    value:
                        categoriesState.contains(_category) ? _category : null,
                    items: [
                      ...categoriesState
                          .where(
                            (category) =>
                                category.type ==
                                (_transactionType == 'Income'
                                    ? CategoryType.income
                                    : CategoryType.expense),
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
                          }),
                      DropdownMenuItem<Category>(
                        value: Category(
                          id: 'add',
                          name: 'Add new category',
                          description: '',
                          iconKey: "category",
                          color: AppColors.accentColor,
                          isNew: true,
                          type: CategoryType.expense,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add, color: AppColors.accentColor),
                            SizedBox(width: 8),
                            Text(
                              'Add new category'.tr,
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                    validator: (value) {
                      if (value == null && _category == null) {
                        return 'Please select a category.'.tr;
                      }
                      return null;
                    },
                    onChanged: (value) {
                      if (value != null && value.id == 'add') {
                        showModalBottomSheet(
                          backgroundColor:
                              Theme.of(context).appBarTheme.backgroundColor!,
                          context: context,
                          builder: (context) {
                            return AddCategoryModal(
                              categoryRepository: categoryRepository,
                              onCategoryAdded: (category) {
                                setState(() {
                                  _category = category;
                                });
                              },
                            );
                          },
                        );
                      } else {
                        setState(() {
                          _category = value;
                        });
                      }
                    },
                  ),

              // Wallet dropdown
              DropdownButtonFormField<Wallet>(
                dropdownColor: cardColor,
                style: const TextStyle(color: Colors.grey),
                decoration: InputDecoration(
                  labelText: 'Wallet'.tr,
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
                  prefixIcon: const Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                  ),
                ),
                value: _selectedWallet,
                items: [
                  ...walletsState.map((wallet) {
                    return DropdownMenuItem<Wallet>(
                      value: wallet,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.account_balance_wallet,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            wallet.name.tr,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  }),
                  DropdownMenuItem<Wallet>(
                    value: Wallet(
                      id: 'add_wallet',
                      name: 'Add new wallet',
                      type: WalletType.bank,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.add, color: AppColors.accentColor),
                        SizedBox(width: 8),
                        Text(
                          'Add new wallet'.tr,
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
                validator: (value) {
                  if (value == null || value.id == 'add_wallet') {
                    return 'Please select a wallet.'.tr;
                  }
                  return null;
                },
                onChanged: (value) {
                  if (value != null && value.id == 'add_wallet') {
                    showModalBottomSheet(
                      context: context,
                      builder:
                          (context) => AddWalletModal(
                            onWalletAdded: (newWallet) {
                              setState(() {
                                _selectedWallet = newWallet;
                              });
                            },
                          ),
                    );
                  } else {
                    setState(() {
                      _selectedWallet = value;
                    });
                  }
                },
              ),

              // Notes field
              TextFormField(
                style: const TextStyle(color: Colors.grey),
                decoration: InputDecoration(
                  labelText: 'Notes (optional)'.tr,
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
                  prefixIcon: const Icon(Icons.note, color: Colors.white),
                ),
                onChanged: (value) {
                  _notes = value;
                },
              ),

              const SizedBox(height: 16),

              // Date selection
              DatePickerWidget(
                initialDate: _date,
                isSelected: isSelectedDate,
                onDateSelected: (pickedDate) {
                  setState(() {
                    _date = DateTime(
                      pickedDate.year,
                      pickedDate.month,
                      pickedDate.day,
                    );
                    isSelectedDate = true;
                    debugPrint('Selected date: $_date');
                  });
                },
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                errorText: isSelectedDate ? null : 'Please select a date'.tr,
              ),
              const SizedBox(height: 30),

              // Add CashFlow button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    // <-- Add this shape property
                    borderRadius: BorderRadius.circular(
                      12.0,
                    ), // <-- Set desired radius (e.g., 12)
                  ),
                  backgroundColor: AppColors.accentColor,
                ),
                onPressed: () {
                  Get.find<SoundService>().playButtonClickSound();
                  if (_formKey.currentState!.validate() &&
                      _category != null &&
                      _selectedWallet != null &&
                      isSelectedDate) {
                    final expense = CashFlow(
                      id: DateTime.now().toString(),
                      title: _title,
                      amount: _amount,
                      date: _date,
                      category: _category!,
                      notes: _notes,
                      isIncome: _transactionType == 'Income',
                      walletType: _selectedWallet!,
                    );

                    debugPrint('Adding CashFlow with date: ${expense.date}');
                    widget.onAdd(expense);

                    final now = DateTime.now();
                    final isCurrentMonth =
                        (expense.date.year == now.year &&
                            expense.date.month == now.month);

                    // Update providers
                    if (expense.isIncome) {
                      ref
                          .read(totalIncomesAmountProvider.notifier)
                          .increment(expense.amount);
                      if (isCurrentMonth) {
                        ref
                            .read(monthlyIncomesAmountProvider.notifier)
                            .increment(expense.amount);
                      }
                    } else {
                      ref
                          .read(totalAmountProvider.notifier)
                          .increment(expense.amount);
                      if (isCurrentMonth) {
                        ref
                            .read(monthlyAmountProvider.notifier)
                            .increment(expense.amount);
                      }
                    }

                    // Reset form
                    setState(() {
                      _formKey.currentState!.reset();
                      _title = '';
                      _amount = 0.0;
                      _notes = '';
                      _category = null;
                      _selectedWallet = null;
                      _date = DateTime.now();
                      isSelectedDate = false;
                    });

                    showFeedbackSnackbar(
                      context,
                      'CashFlow added successfully'.tr,
                    );
                  } else {
                    String errorMessage = 'Please fill all fields'.tr;
                    if (!isSelectedDate) {
                      errorMessage = 'Please select a date'.tr;
                    }

                    showFeedbackSnackbar(context, errorMessage);
                  }
                },
                child: Text('Add CashFlow'.tr),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
