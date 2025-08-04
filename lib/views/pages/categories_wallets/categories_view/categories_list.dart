// UPDATED: Import the new responsive utility
import 'package:budgify/core/utils/scale_config.dart';
import 'package:budgify/core/utils/snackbar_helper.dart';
import 'package:budgify/viewmodels/providers/lang_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../domain/models/category.dart';
import '../../../../data/repo/category_repositry.dart';
import '../../../../data/repo/expenses_repository.dart';
import '../../../../viewmodels/providers/category_list_provider.dart';
import '../../../../viewmodels/providers/switchOnOffIncome.dart';

final categoryProvider =
    StateNotifierProvider<CategoryNotifier, List<Category>>((ref) {
      final categoryBox = Hive.box<Category>('categories');
      return CategoryNotifier(CategoryRepository(categoryBox));
    });

class CategoryListPage extends ConsumerStatefulWidget {
  const CategoryListPage({super.key});

  @override
  _CategoryListPageState createState() => _CategoryListPageState();
}

class _CategoryListPageState extends ConsumerState<CategoryListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    // UPDATED: Use the new responsive extension
    final responsive = context.responsive;
    final categories = ref.watch(categoryProvider);
    final switchState = ref.watch(switchProvider).isSwitched;

    final sortedIncomeCategories = [
      ...categories.where(
        (category) => category.type == CategoryType.income && !category.isNew,
      ),
      ...categories.where(
        (category) => category.type == CategoryType.income && category.isNew,
      ),
    ];

    final sortedExpenseCategories = [
      ...categories.where(
        (category) => category.type == CategoryType.expense && !category.isNew,
      ),
      ...categories.where(
        (category) => category.type == CategoryType.expense && category.isNew,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0.0,
        bottom: TabBar(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          controller: _tabController,
          indicatorColor: AppColors.accentColor,
          tabs:
              switchState
                  ? [Tab(text: 'Expense'.tr), Tab(text: 'Income'.tr)]
                  : [Tab(text: 'Expense'.tr)],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCategoryGrid(sortedExpenseCategories, context, ref, responsive),
          if (switchState)
            _buildCategoryGrid(
              sortedIncomeCategories,
              context,
              ref,
              responsive,
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid(
    List<Category> categories,
    BuildContext context,
    WidgetRef ref,
    ResponsiveUtil responsive,
  ) {
    bool isArabic =
        ref.watch(languageProvider).toString() == "ar" ? true : false;

    return GridView.builder(
      padding: EdgeInsets.all(responsive.setWidth(16.0)),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: responsive.isTablet ? 2.2 : 2,
        crossAxisSpacing: responsive.setWidth(14.0),
        mainAxisSpacing:
            responsive.isTablet
                ? responsive.setHeight(8.0)
                : responsive.setHeight(10.0),
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return GestureDetector(
          onTap: () {},
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.transparent.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(responsive.setWidth(12)),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.setWidth(10),
                    vertical: responsive.setHeight(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: responsive.setHeight(47),
                        width: responsive.setWidth(47),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              responsive.setWidth(12),
                            ),
                          ),
                          color: category.color.withOpacity(0.8),
                          child: Icon(
                            category.icon,
                            color: Colors.white,
                            size: responsive.setWidth(24),
                          ),
                        ),
                      ),
                      SizedBox(width: responsive.setWidth(4)),
                      Expanded(
                        child: Text(
                          category.name.tr,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: responsive.setSp(9),
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (category.isNew)
                Positioned(
                  top: 0,
                  left: isArabic ? 0 : null,
                  right: isArabic ? null : 0,
                  child: IconButton(
                    icon: Icon(
                      Icons.close,
                      color: AppColors.accentColor2,
                      size: responsive.setWidth(17),
                    ),
                    onPressed: () async {
                      showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: Row(
                                children: [
                                  const Icon(
                                    Icons.warning_amber_rounded,
                                    color: AppColors.accentColor,
                                  ),
                                  SizedBox(width: responsive.setWidth(6)),
                                  Text(
                                    'Delete Category'.tr,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.accentColor2,
                                      fontSize: responsive.setSp(13),
                                    ),
                                  ),
                                ],
                              ),
                              content: Text(
                                'Are you sure you want to delete this category? This action cannot be undone.'
                                    .tr,
                                style: TextStyle(
                                  fontSize: responsive.setSp(11),
                                  color: Colors.white,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text(
                                    'Cancel'.tr,
                                    style: TextStyle(
                                      color: AppColors.accentColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: responsive.setSp(12),
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    ref
                                        .read(categoryProvider.notifier)
                                        .removeCategoryById(category.id);

                                    final repository = ExpensesRepository();
                                    await repository.deleteAllByCategoryName(
                                      category.name,
                                    );

                                    showFeedbackSnackbar(
                                      context,
                                      'Deleted all expenses for the category'
                                          .tr,
                                    );

                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    'Delete'.tr,
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: responsive.setSp(12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
