import 'package:hive/hive.dart';
import '../../domain/models/category.dart';

class CategoryRepository {
  final Box<Category> categoryBox;

  CategoryRepository(this.categoryBox);

  // Load all categories from Hive
  List<Category> loadCategories() {
    return categoryBox.values.toList();
  }

  // Add a new category to Hive
  void addCategory(Category category) {
    categoryBox.put(category.id, category); // Use put with category.id to ensure unique keys
  }

  // Remove a category by its ID
  void removeCategoryById(String id) {
    categoryBox.delete(id); // Delete the category with the specified ID
  }

  // Prepopulate standard categories if they don't exist
  void prepopulateStandardCategories() {
    for (var standardCategory in categoriess) {  // Assuming 'categories' is the list of predefined categories
      // Check if the category already exists
      if (!categoryBox.values.any((category) => category.id == standardCategory.id)) {
        categoryBox.put(standardCategory.id, standardCategory); // Use put with category.id for unique keys
      }
    }
  }
}
