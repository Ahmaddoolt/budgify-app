// c:\Users\Asus\budgify\lib\core\navigation\bottom_nativgation\bottom_navigation_bar.dart

import 'package:budgify/viewmodels/providers/screen_index_provider.dart';
import 'package:budgify/viewmodels/providers/sound_toggle_provider.dart';
import 'package:budgify/views/pages/homescreen/home_page.dart';
import 'package:budgify/views/pages/settings/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import '../../themes/app_colors.dart';
import '../../../domain/models/expense.dart';
import '../../../data/repo/expenses_repository.dart';
import '../../../views/widgets/add_cashflow.dart';
import '../../../views/pages/graphscreen/graph_screen.dart';
import '../../../views/pages/categories_wallets/categories_wallets_tabbar.dart';
import 'bottom_nav_icon.dart';

class Bottom extends ConsumerWidget {
  const Bottom({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var screens = [
      const HomePage(),
      const ChartsScreen(),
      const CategoriesWalletsTabBar(),
      const SettingsPage(),
    ];

    final ExpensesRepository repository = ExpensesRepository();
    var screenIndex = ref.watch(counterProvider);

    void showAddExpenseDialog() {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor!,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Add CashFlow'.tr,
                    style: const TextStyle(color: Colors.white)),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: AddExpenseView(
                onAdd: (CashFlow expense) {
                  repository.addExpense(expense);
                  Navigator.of(context).pop();
                },
              ),
            ),
          );
        },
      );
    }

    final double bottomBarHeight = MediaQuery.of(context).size.height * 0.07;

    return Scaffold(
      body: screens[screenIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: showAddExpenseDialog,
        backgroundColor: AppColors.accentColor,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        height: bottomBarHeight,
        shape: const CircularNotchedRectangle(),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Home Button
              IconButton(
                onPressed: () {
                  Get.find<SoundService>().playButtonClickSound();
                  ref.read(counterProvider.notifier).setToZero();
                },
                icon: BottomNavIcon(
                  icon: Icons.home,
                  isSelected: screenIndex == 0,
                ),
              ),

              // Pie Chart Button
              IconButton(
                onPressed: () {
                  Get.find<SoundService>().playButtonClickSound();
                  ref.read(counterProvider.notifier).setToOne();
                },
                icon: BottomNavIcon(
                  icon: Icons.pie_chart,
                  isSelected: screenIndex == 1,
                ),
              ),

              // Spacer for the FloatingActionButton
              const SizedBox(width: 40),

              // Widgets Button
              IconButton(
                onPressed: () {
                  Get.find<SoundService>().playButtonClickSound();
                  ref.read(counterProvider.notifier).setToTwo();
                },
                icon: BottomNavIcon(
                  icon: Icons.widgets,
                  isSelected: screenIndex == 2,
                ),
              ),

              // Settings Button
              IconButton(
                onPressed: () {
                  Get.find<SoundService>().playButtonClickSound();
                  ref.read(counterProvider.notifier).setToThree();
                },
                icon: BottomNavIcon(
                  icon: Icons.settings_applications,
                  isSelected: screenIndex == 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
