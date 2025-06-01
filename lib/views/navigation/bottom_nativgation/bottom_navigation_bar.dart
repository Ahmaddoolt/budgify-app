import 'package:budgify/viewmodels/providers/screen_index_provider.dart';
import 'package:budgify/viewmodels/providers/sound_toggle_provider.dart';
import 'package:budgify/views/pages/homescreen/home_page.dart';
import 'package:budgify/views/pages/settings/settings_page.dart';
// import 'package:budgify/views/pages/settings/settings_page.dart';
// import 'package:budgify/widgets/ads/intilized_ads.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import '../../../core/themes/app_colors.dart';
import '../../../domain/models/expense.dart';
import '../../../data/repo/expenses_repository.dart';
import '../../widgets/add_cashflow.dart';
import '../../pages/graphscreen/graph_screen.dart';
// import '../../pages/settings/settng_page.dart';
import '../../pages/categories_wallets/categories_wallets_tabbar.dart';
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
    // final adManager = InterstitialAdManager();
    // adManager.loadAd();

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
                Text('Add CashFlow'.tr, style: TextStyle(color: Colors.white)),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: AddExpenseView(
                onAdd: (CashFlow expense) {
                  repository.addExpense(expense);
                  // adManager.showAd();
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
        child: Padding(
          padding: const EdgeInsets.only(top: 7.5, bottom: 7.5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () {
                  Get.find<SoundService>().playButtonClickSound();

                  // ref.read(audioPlayerProvider).playTapSound();
                  ref.read(counterProvider.notifier).setToZero();
                },
                child: BottomNavIcon(
                  icon: Icons.home,
                  isSelected: screenIndex == 0,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // await ref.read(
                  //   playBudgifySoundProvider,
                  // )(); // This is the one-liner!

                  Get.find<SoundService>().playButtonClickSound();
                  // ref.read(audioPlayerProvider).playTapSound();

                  ref.read(counterProvider.notifier).setToOne();
                },
                child: BottomNavIcon(
                  icon: Icons.pie_chart,
                  isSelected: screenIndex == 1,
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  // Get.find<SoundService>().playTapSound();
                  // ref.read(audioPlayerProvider).playTapSound();
                  Get.find<SoundService>().playButtonClickSound();

                  ref.read(counterProvider.notifier).setToTwo();
                },
                child: BottomNavIcon(
                  icon: Icons.widgets,
                  isSelected: screenIndex == 2,
                ),
              ),
              GestureDetector(
                onTap: () async {
                  // Get.find<SoundService>().playTapSound();
                  // ref.read(audioPlayerProvider).playTapSound();
                  Get.find<SoundService>().playButtonClickSound();

                  ref.read(counterProvider.notifier).setToThree();
                },
                child: BottomNavIcon(
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
