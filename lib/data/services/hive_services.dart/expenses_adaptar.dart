import 'package:budgify/data/repo/category_repositry.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../../domain/models/expense.dart';
import '../../../domain/models/category.dart';
import '../../../domain/models/wallet.dart';

// ignore: must_be_immutable
class CashFlowAdapter extends TypeAdapter<CashFlow> {
  @override
  final int typeId = 0;

  // Singleton instance
  static final CashFlowAdapter _instance = CashFlowAdapter._internal();

  factory CashFlowAdapter() => _instance;

  CashFlowAdapter._internal();

  final Map<String, Category> _categoriesCache = {};
  final Map<String, Wallet> _walletsCache = {};
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    await Future.wait([
      preloadCategories(),
      preloadWallets(),
    ]);
    _isInitialized = true;
    debugPrint('CashFlowAdapter initialized: ${_categoriesCache.length} categories, ${_walletsCache.length} wallets');
  }

  Future<void> preloadCategories() async {
    _categoriesCache.clear();
    try {
      final categoryBox = await Hive.openBox<Category>('categories');
      for (var category in categoryBox.values) {
        _categoriesCache[category.id] = category;
      }
      debugPrint('Categories preloaded: ${_categoriesCache.length}');
      // Ensure standard categories are populated if box is empty
      if (_categoriesCache.isEmpty) {
        final categoryRepository = CategoryRepository(categoryBox);
        categoryRepository.prepopulateStandardCategories();
        for (var category in categoryBox.values) {
          _categoriesCache[category.id] = category;
        }
        debugPrint('Categories repopulated and preloaded: ${_categoriesCache.length}');
      }
    } catch (e) {
      debugPrint('Error preloading categories: $e');
    }
  }

  Future<void> preloadWallets() async {
    _walletsCache.clear();
    try {
      final walletBox = await Hive.openBox<Wallet>('wallets');
      debugPrint('Wallets in box: ${walletBox.values.map((w) => 'ID: ${w.id}, Name: ${w.name}').toList()}');
      for (var wallet in walletBox.values) {
        _walletsCache[wallet.id] = wallet;
      }
      debugPrint('Wallets preloaded: ${_walletsCache.length}');
    } catch (e) {
      debugPrint('Error preloading wallets: $e');
    }
  }

  Category getCategoryById(String id) {
    if (_categoriesCache.containsKey(id)) {
      debugPrint('Category cache hit for ID: $id');
      return _categoriesCache[id]!;
    }

    try {
      final categoryBox = Hive.box<Category>('categories');
      final category = categoryBox.get(id);
      if (category != null) {
        _categoriesCache[id] = category;
        debugPrint('Category $id loaded from Hive');
        return category;
      }
    } catch (e) {
      debugPrint('Error accessing category $id: $e');
    }

    // Fallback: Check standard categories
    final standardCategory = categoriess.firstWhere(
      (cat) => cat.id == id,
      orElse: () => Category(
        id: 'unknown',
        name: 'Unknown',
        iconKey: 'help',
        color: Colors.grey,
        isNew: false,
        type: CategoryType.expense,
      ),
    );

    if (standardCategory.id != 'unknown') {
      _categoriesCache[id] = standardCategory;
      // Save to Hive to prevent future misses
      Hive.box<Category>('categories').put(id, standardCategory);
      debugPrint('Category $id restored from standard categories and saved to Hive');
      return standardCategory;
    }

    debugPrint('Category $id not found, returning Unknown');
    return Category(
      id: 'unknown',
      name: 'Unknown',
      iconKey: 'help',
      color: Colors.grey,
      isNew: false,
      type: CategoryType.expense,
    );
  }

  Wallet getWalletById(String id) {
    if (_walletsCache.containsKey(id)) {
      debugPrint('Wallet cache hit for ID: $id');
      return _walletsCache[id]!;
    }

    try {
      final walletBox = Hive.box<Wallet>('wallets');
      final wallet = walletBox.get(id);
      if (wallet != null) {
        _walletsCache[id] = wallet;
        debugPrint('Wallet $id loaded from Hive');
        return wallet;
      }
    } catch (e) {
      debugPrint('Error accessing wallet $id: $e');
    }

    debugPrint('Wallet $id not found, returning default wallet');
    return Wallet(
      id: id,
      name: 'Unknown',
      type: WalletType.cash,
    );
  }

  @override
  CashFlow read(BinaryReader reader) {
    try {
      final expenseId = reader.readString();
      final title = reader.readString();
      final amount = reader.readDouble();
      final date = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
      final categoryId = reader.readString();
      final notes = reader.readString();
      final isIncome = reader.readBool();
      final walletId = reader.readString();

      final category = getCategoryById(categoryId);
      final wallet = getWalletById(walletId);

      debugPrint('Deserialized CashFlow: ID=$expenseId, Category=${category.name}, Wallet=${wallet.name}');

      return CashFlow(
        id: expenseId,
        title: title,
        amount: amount,
        date: date,
        category: category,
        notes: notes.isEmpty ? null : notes,
        isIncome: isIncome,
        walletType: wallet,
      );
    } catch (e) {
      debugPrint('Error reading CashFlow: $e');
      rethrow;
    }
  }

  @override
  void write(BinaryWriter writer, CashFlow obj) {
    try {
      writer.writeString(obj.id);
      writer.writeString(obj.title);
      writer.writeDouble(obj.amount);
      writer.writeInt(obj.date.millisecondsSinceEpoch);
      writer.writeString(obj.category.id);
      writer.writeString(obj.notes ?? '');
      writer.writeBool(obj.isIncome);
      writer.writeString(obj.walletType.id);

      debugPrint('Serialized CashFlow: ID=${obj.id}, Category=${obj.category.name}, Wallet=${obj.walletType.name}');
    } catch (e) {
      debugPrint('Error writing CashFlow: $e');
      rethrow;
    }
  }
}