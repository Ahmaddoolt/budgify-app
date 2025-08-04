// lib/providers/repository_providers.dart

import 'package:budgify/data/repo/expenses_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// This FutureProvider creates, initializes, and provides our single repository instance.
final expensesRepositoryProvider = FutureProvider<ExpensesRepository>((ref) async {
  final repository = ExpensesRepository();
  await repository.openBox(); // Wait for the box to be ready
  return repository; // Return the fully initialized repository
});