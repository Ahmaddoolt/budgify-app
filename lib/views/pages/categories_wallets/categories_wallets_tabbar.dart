import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:budgify/core/themes/app_colors.dart';
import '../../../viewmodels/providers/switchOnOffIncome.dart';
import 'categories_view/categories_list.dart';
import 'wallets_view/wallets_screen.dart';
import 'categories_view/add_category_showing.dart';
import 'wallets_view/add_wallet.dart';

class CategoriesWalletsTabBar extends ConsumerStatefulWidget {
  const CategoriesWalletsTabBar({super.key});

  @override
  ConsumerState<CategoriesWalletsTabBar> createState() =>
      _CategoriesWalletsTabBarState();
}

class _CategoriesWalletsTabBarState
    extends ConsumerState<CategoriesWalletsTabBar>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final switchState = ref.watch(switchProvider).isSwitched;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text(
            'Categories & Wallets'.tr,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          bottom: _buildTabBar(switchState),
        ),
        body: _buildTabBarView(switchState),
      ),
    );
  }

  PreferredSizeWidget _buildTabBar(bool switchState) {
    return TabBar(
      labelColor: Colors.white, // Color for selected tab text
      unselectedLabelColor: Colors.grey,
      controller: _tabController,
      indicatorColor: AppColors.accentColor2,
      tabs:
          switchState
              ? [_buildCategoriesTab(), _buildWalletsTab()]
              : [_buildCategoriesTab()],
    );
  }

  Widget _buildCategoriesTab() {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Categories'.tr),
          const SizedBox(width: 7),
          IconButton(
            onPressed: () => _showAddCategoryModal(context, ref),
            icon: const Icon(
              Icons.add_circle,
              color: AppColors.accentColor,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletsTab() {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Wallets'.tr),
          const SizedBox(width: 7),
          IconButton(
            onPressed: () => _showAddWalletModal(context),
            icon: const Icon(
              Icons.add_circle,
              color: AppColors.accentColor,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBarView(bool switchState) {
    return TabBarView(
      controller: _tabController,
      children:
          switchState
              ? [const CategoryListPage(), const WalletsSummaryPage()]
              : [const CategoryListPage()],
    );
  }

  void _showAddWalletModal(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor!,
      context: context,
      builder:
          (context) => AddWalletModal(
            onWalletAdded: (newWallet) {},
            pageContext: context,
          ),
    );
  }

  void _showAddCategoryModal(BuildContext context, WidgetRef ref) {
    final categoryRepository = ref.read(categoryProvider.notifier).repository;
    showModalBottomSheet(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor!,
      context: context,
      builder:
          (context) => AddCategoryModal(
            categoryRepository: categoryRepository,
            onCategoryAdded: (newCategory) {
              ref.read(categoryProvider.notifier).addCategory(newCategory);
            },
          ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
