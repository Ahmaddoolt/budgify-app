import 'package:budgify/core/utils/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../domain/models/budget.dart';
import '../../../../domain/models/category.dart';
import '../../../../data/repo/category_repositry.dart';
import '../../../../data/repo/budget_repostiry.dart';
// import '../../../widgets/ads/intilized_ads.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  late Category _category;
  double _budgetAmount = 0.0;
  late CategoryRepository _categoryRepository;
  late BudgetRepository _budgetRepository;
  List<Category> categoriesState = [];
  List<Budget> existingBudgets = [];

  @override
  void initState() {
    super.initState();
    _loadCategoriesAndBudgets();
  }

  Future<void> _loadCategoriesAndBudgets() async {
    final categoryBox = await Hive.openBox<Category>('categories');
    _categoryRepository = CategoryRepository(categoryBox);

    setState(() {
      categoriesState = _categoryRepository.loadCategories();
      if (categoriesState.isNotEmpty) {
        _category = categoriesState.first;
      }
    });

    _budgetRepository = BudgetRepository(categoriesState);
    await _budgetRepository.init();
    existingBudgets = _budgetRepository.loadBudgets();
  }

  bool _isCategoryAlreadyBudgeted(Category category) {
    return existingBudgets.any((budget) => budget.categoryId == category.id);
  }

  @override
  Widget build(BuildContext context) {
    Color cardColor = Theme.of(context).colorScheme.primary;
    // final adManager = InterstitialAdManager(); // Instantiate the ad manager
    // adManager.loadAd();
    return Form(
      key: _formKey,
      child: Container(
        width: double.infinity, // Makes the container take up the full width
        color: cardColor, // Set the desired background color
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              CrossAxisAlignment.center, // Aligns content to the start
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
                  items:
                      categoriesState
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
                          })
                          .toList(),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a category.'.tr;
                    }
                    if (_isCategoryAlreadyBudgeted(value)) {
                      return 'Budget already exists for this category.'.tr;
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _category = value!;
                    });
                  },
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
                  // <-- Add this shape property
                  borderRadius: BorderRadius.circular(
                    12.0,
                  ), // <-- Set desired radius (e.g., 12)
                ),
                backgroundColor: AppColors.accentColor,
              ),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final budget = Budget(
                    categoryId: _category.id,
                    budgetAmount: _budgetAmount,
                  );

                  await _budgetRepository.addBudget(budget);
                  showFeedbackSnackbar(
                    // ignore: use_build_context_synchronously
                    context,
                    'Budget added successfully!'.tr,
                  );

                  setState(() {
                    _category = categoriesState.first;
                    _budgetAmount = 0.0;
                    existingBudgets =
                        _budgetRepository.loadBudgets(); // Refresh budget list
                  });

                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop(); // Close the bottom sheet
                  // adManager.showAd();
                }
              },
              child: Text(
                'Add'.tr,
                style: const TextStyle(fontWeight: FontWeight.bold),
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
    builder:
        (context) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: const BudgetScreen(),
        ),
  );
}
