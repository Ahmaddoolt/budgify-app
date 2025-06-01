// lib/data/models/category.dart
import 'package:flutter/material.dart';

enum CategoryType { income, expense }

class Category {
  final String id;
  final String name;
  final String? description;
  final String iconKey; // Changed from IconData to String
  final Color color;
  final bool isNew;
  final CategoryType type;

  Category({
    required this.id,
    required this.name,
    this.description,
    required this.iconKey,
    required this.color,
    required this.isNew,
    required this.type,
  });

  // Get the IconData from the iconKey
  IconData get icon => iconMap[iconKey] ?? Icons.category;

  // Static map of icon keys to IconData
  static const Map<String, IconData> iconMap = {
    'fastfood': Icons.fastfood,
    'directions_bus': Icons.directions_bus,
    'shopping_cart': Icons.shopping_cart,
    'receipt_long': Icons.receipt_long,
    'diversity_3': Icons.diversity_3,
    'card_membership': Icons.card_membership,
    'health_and_safety': Icons.health_and_safety,
    'attractions': Icons.attractions,
    'volunteer_activism': Icons.volunteer_activism,
    'airplane_ticket': Icons.airplane_ticket,
    'work': Icons.work,
    'trending_up': Icons.trending_up,
    'card_giftcard': Icons.card_giftcard,
    'business_center': Icons.business_center,
    'home': Icons.home,
    'laptop_mac': Icons.laptop_mac,
    'attach_money': Icons.attach_money,
    'sync_alt': Icons.sync_alt,
    'move_to_inbox': Icons.move_to_inbox,
    'school': Icons.school,
    'pets': Icons.pets,
    'fitness_center': Icons.fitness_center,
    'sports': Icons.sports,
    'checkroom': Icons.checkroom,
    'cable': Icons.cable,
    'local_gas_station': Icons.local_gas_station,
    'monitor_heart': Icons.monitor_heart,
    'directions_car': Icons.directions_car,
    'medication': Icons.medication,
    'key': Icons.key,
    'category': Icons.category,
  };
}

List<Category> categoriess = [
  Category(
    id: '1',
    name: 'Food',
    iconKey: 'fastfood',
    color: const Color(0xffFF7F50),
    isNew: false,
    type: CategoryType.expense,
  ),
  Category(
    id: '2',
    name: 'Transport',
    iconKey: 'directions_bus',
    color: const Color(0xff4682B4),
    isNew: false,
    type: CategoryType.expense,
  ),
  Category(
    id: '3',
    name: 'Shopping',
    iconKey: 'shopping_cart',
    color: const Color(0xffFFD700),
    isNew: false,
    type: CategoryType.expense,
  ),
  Category(
    id: '4',
    name: 'Bills',
    iconKey: 'receipt_long',
    color: const Color(0xff00FF7F),
    isNew: false,
    type: CategoryType.expense,
  ),
  Category(
    id: '5',
    name: 'Family',
    iconKey: 'diversity_3',
    color: const Color(0xff8B4513),
    isNew: false,
    type: CategoryType.expense,
  ),
  Category(
    id: '6',
    name: 'Subscribers',
    iconKey: 'card_membership',
    color: const Color(0xffFF69B4),
    isNew: false,
    type: CategoryType.expense,
  ),
  Category(
    id: '7',
    name: 'Health',
    iconKey: 'health_and_safety',
    color: const Color(0xff40E0D0),
    isNew: false,
    type: CategoryType.expense,
  ),
  Category(
    id: '8',
    name: 'Fun',
    iconKey: 'attractions',
    color: const Color(0xffDC143C),
    isNew: false,
    type: CategoryType.expense,
  ),
  Category(
    id: '9',
    name: 'Donations',
    iconKey: 'volunteer_activism',
    color: const Color(0xff9932CC),
    isNew: false,
    type: CategoryType.expense,
  ),
  Category(
    id: '10',
    name: 'Tourism',
    iconKey: 'airplane_ticket',
    color: const Color(0xff006400),
    isNew: false,
    type: CategoryType.expense,
  ),
  Category(
    id: '11',
    name: 'Salary',
    iconKey: 'work',
    color: const Color(0xff2E8B57),
    isNew: false,
    type: CategoryType.income,
  ),
  Category(
    id: '12',
    name: 'Investments',
    iconKey: 'trending_up',
    color: const Color(0xff8A2BE2),
    isNew: false,
    type: CategoryType.income,
  ),
  Category(
    id: '13',
    name: 'Gifts',
    iconKey: 'card_giftcard',
    color: const Color(0xffFFD700),
    isNew: false,
    type: CategoryType.income,
  ),
  Category(
    id: '14',
    name: 'Business',
    iconKey: 'business_center',
    color: const Color(0xff4682B4),
    isNew: false,
    type: CategoryType.income,
  ),
  Category(
    id: '15',
    name: 'Rental Income',
    iconKey: 'home',
    color: const Color(0xffFF4500),
    isNew: false,
    type: CategoryType.income,
  ),
  Category(
    id: '16',
    name: 'Freelancing',
    iconKey: 'laptop_mac',
    color: const Color(0xff32CD32),
    isNew: false,
    type: CategoryType.income,
  ),
  Category(
    id: '17',
    name: 'Dividends',
    iconKey: 'attach_money',
    color: const Color(0xff4169E1),
    isNew: false,
    type: CategoryType.income,
  ),
  Category(
    id: '18',
    name: 'Debt',
    iconKey: 'attach_money',
    color: const Color(0xff8B0000),
    isNew: false,
    type: CategoryType.expense,
  ),
  Category(
    id: '19',
    name: 'Debt Collection',
    iconKey: 'attach_money',
    color: const Color(0xffFF6347),
    isNew: false,
    type: CategoryType.income,
  ),
  Category(
    id: '20',
    name: 'Transfer',
    iconKey: 'sync_alt',
    color: const Color(0xff1E90FF),
    isNew: false,
    type: CategoryType.expense,
  ),
  Category(
    id: '21',
    name: 'Transfer In',
    iconKey: 'move_to_inbox',
    color: const Color(0xff228B22),
    isNew: false,
    type: CategoryType.income,
  ),
];