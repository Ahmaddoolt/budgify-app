import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/category.dart'; // Import your Category model
import '../../data/repo/category_repositry.dart';

class CategoryNotifier extends StateNotifier<List<Category>> {
  final CategoryRepository _categoryRepository;

  CategoryNotifier(this._categoryRepository) : super([]) {
    prepopulateCategories(); // Populate categories on initialization
  }

  CategoryRepository get repository => _categoryRepository; // Expose the repository

  // Load categories from Hive
  void loadCategories() {
    state = _categoryRepository.loadCategories(); // Load from repository
  }

  // Add a new category
  void addCategory(Category category) {
    _categoryRepository.addCategory(category); // Add to repository
    loadCategories(); // Reload categories to reflect changes
  }

  // Remove a category by ID
  void removeCategoryById(String id) {
    _categoryRepository.removeCategoryById(id); // Remove from repository
    loadCategories(); // Reload categories to reflect changes
  }

  // Prepopulate standard categories if they don't exist
  void prepopulateCategories() {
    _categoryRepository.prepopulateStandardCategories(); // Add standard categories to repository
    loadCategories(); // Reload categories after prepopulation
  }
}
