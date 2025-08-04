// lib/data/adapters/cash_flow_adapter.dart

import 'package:budgify/domain/models/category.dart';
import 'package:budgify/domain/models/expense.dart';
import 'package:budgify/domain/models/wallet.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

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
    await Future.wait([preloadCategories(), preloadWallets()]);
    _isInitialized = true;
    debugPrint(
      'CashFlowAdapter initialized: ${_categoriesCache.length} categories, ${_walletsCache.length} wallets',
    );
  }

  Future<void> preloadCategories() async {
    _categoriesCache.clear();
    try {
      final categoryBox = await Hive.openBox<Category>('categories');
      for (var category in categoryBox.values) {
        _categoriesCache[category.id] = category;
      }
      debugPrint('Categories preloaded: ${_categoriesCache.length}');
      if (_categoriesCache.isEmpty) {
        for (var category in categoriess) {
          _categoriesCache[category.id] = category;
        }
        debugPrint(
          'Categories repopulated from static list: ${_categoriesCache.length}',
        );
      }
    } catch (e) {
      debugPrint('Error preloading categories: $e');
    }
  }

  Future<void> preloadWallets() async {
    _walletsCache.clear();
    try {
      final walletBox = await Hive.openBox<Wallet>('wallets');
      debugPrint(
        'Wallets in box: ${walletBox.values.map((w) => 'ID: ${w.id}, Name: ${w.name}').toList()}',
      );
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
    return standardCategory;
  }

  Wallet getWalletById(String id) {
    if (_walletsCache.containsKey(id)) {
      debugPrint('Wallet cache hit for ID: $id');
      return _walletsCache[id]!;
    }
    debugPrint('Wallet $id not found, returning default wallet');
    // --- THE FIX: The fallback Wallet now needs a currencyCode too ---
    return Wallet(
      id: id,
      name: 'Unknown Wallet',
      type: WalletType.cash,
      currencyCode: 'USD', // Default unknown code
      currencySymbol: '\$', // Default unknown symbol
      isDefault: false,
      isEnabled: false,
      allowedTransactionType: WalletFunctionality.both,
      value: 0.0,
    );
  }

  @override
  CashFlow read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    // Get the associated wallet once to use for fallbacks
    final wallet = getWalletById(fields[7] as String);

    return CashFlow(
      id: fields[0] as String,
      title: fields[1] as String,
      amount: fields[2] as double,
      date: fields[3] as DateTime,
      category: getCategoryById(fields[4] as String),
      notes: fields[5] as String?,
      isIncome: fields[6] as bool,
      walletType: wallet,

      // --- THE FIX: Read both fields with robust fallbacks for old data ---
      // This ensures the app won't crash when reading data saved with the old adapter.
      currencySymbol: fields[8] as String? ?? wallet.currencySymbol,
      currencyCode: fields[9] as String? ?? wallet.currencyCode,
    );
  }

  @override
  void write(BinaryWriter writer, CashFlow obj) {
    writer
      // --- THE FIX: Increased field count from 9 to 10 for the new field ---
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.category.id)
      ..writeByte(5)
      ..write(obj.notes)
      ..writeByte(6)
      ..write(obj.isIncome)
      ..writeByte(7)
      ..write(obj.walletType.id)
      ..writeByte(8)
      ..write(obj.currencySymbol)
      // --- THE FIX: Write the new currencyCode field at index 9 ---
      ..writeByte(9)
      ..write(obj.currencyCode);
  }
}

// Define this if it's not globally available to this file
const List<Category> categoriess = [];
