import 'package:hive/hive.dart';
import '../../domain/models/budget.dart';
import '../../domain/models/category.dart';

class BudgetRepository {
  late final Box<Budget> _budgetBox;
  final List<Category> categories;

  BudgetRepository(this.categories);

  // Initialization method to open the box
  Future<void> init() async {
    _budgetBox = await Hive.openBox<Budget>('budgets');
  }

  // Add a new budget to the box
  Future<void> addBudget(Budget budget) async {
    await _budgetBox.add(budget);
  }

  // Check if a budget already exists for a given category
  bool doesBudgetExistForCategory(String categoryId) {
    return _budgetBox.values.any((budget) => budget.categoryId == categoryId);
  }

  // Load all budgets (useful for refreshing the budget list)
  List<Budget> loadBudgets() {
    return _budgetBox.values.toList();
  }
}
