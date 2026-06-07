import 'package:flutter/material.dart';

enum ExpenseCategory {
  food,
  transportation,
  school,
  loadInternet,
  wants,
  emergency,
  savings,
  others,
}

extension ExpenseCategoryExtension on ExpenseCategory {
  String get displayName {
    switch (this) {
      case ExpenseCategory.food:
        return 'Food';
      case ExpenseCategory.transportation:
        return 'Transportation';
      case ExpenseCategory.school:
        return 'School';
      case ExpenseCategory.loadInternet:
        return 'Load/Internet';
      case ExpenseCategory.wants:
        return 'Wants';
      case ExpenseCategory.emergency:
        return 'Emergency';
      case ExpenseCategory.savings:
        return 'Savings';
      case ExpenseCategory.others:
        return 'Others';
    }
  }

  IconData get icon {
    switch (this) {
      case ExpenseCategory.food:
        return Icons.fastfood_rounded;
      case ExpenseCategory.transportation:
        return Icons.directions_bus_rounded;
      case ExpenseCategory.school:
        return Icons.school_rounded;
      case ExpenseCategory.loadInternet:
        return Icons.wifi_rounded;
      case ExpenseCategory.wants:
        return Icons.shopping_bag_rounded;
      case ExpenseCategory.emergency:
        return Icons.warning_amber_rounded;
      case ExpenseCategory.savings:
        return Icons.savings_rounded;
      case ExpenseCategory.others:
        return Icons.category_rounded;
    }
  }

  Color get color {
    switch (this) {
      case ExpenseCategory.food:
        return const Color(0xFFF2C94C); // Warning Yellow
      case ExpenseCategory.transportation:
        return const Color(0xFF56CCF2); // Secondary Blue
      case ExpenseCategory.school:
        return const Color(0xFF2F80ED); // Primary Blue
      case ExpenseCategory.loadInternet:
        return const Color(0xFF00D1FF); // Accent Cyan
      case ExpenseCategory.wants:
        return const Color(0xFFEB5757); // Danger Red
      case ExpenseCategory.emergency:
        return const Color(0xFFEB5757); // Danger Red for Emergency
      case ExpenseCategory.savings:
        return const Color(0xFF27AE60); // Success Green
      case ExpenseCategory.others:
        return const Color(0xFFAAB7C8); // Secondary Text
    }
  }
}

class Expense {
  final String id;
  final double amount;
  final ExpenseCategory category;
  final String note;
  final DateTime date;

  Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.note,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category.name,
      'note': note,
      'date': date.toIso8601String(),
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as String,
      amount: (map['amount'] as num).toDouble(),
      category: ExpenseCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => ExpenseCategory.others,
      ),
      note: map['note'] as String,
      date: DateTime.parse(map['date'] as String),
    );
  }

  // Generate realistic mock data for screen display
  static List<Expense> get mockExpenses {
    final now = DateTime.now();
    return [
      Expense(
        id: '1',
        amount: 120.00,
        category: ExpenseCategory.food,
        note: 'Lunch at school cafeteria',
        date: now,
      ),
      Expense(
        id: '2',
        amount: 45.00,
        category: ExpenseCategory.transportation,
        note: 'Jeepney ride to campus',
        date: now,
      ),
      Expense(
        id: '3',
        amount: 300.00,
        category: ExpenseCategory.school,
        note: 'Photocopy of readings & materials',
        date: now.subtract(const Duration(days: 1)),
      ),
      Expense(
        id: '4',
        amount: 99.00,
        category: ExpenseCategory.loadInternet,
        note: 'Prepaid data promo registration',
        date: now.subtract(const Duration(days: 1)),
      ),
      Expense(
        id: '5',
        amount: 500.00,
        category: ExpenseCategory.wants,
        note: 'Weekend movie ticket & snacks',
        date: now.subtract(const Duration(days: 2)),
      ),
      Expense(
        id: '6',
        amount: 150.00,
        category: ExpenseCategory.food,
        note: 'Dinner - Jollibee meal',
        date: now.subtract(const Duration(days: 2)),
      ),
      Expense(
        id: '7',
        amount: 250.00,
        category: ExpenseCategory.emergency,
        note: 'Medicine for sore throat',
        date: now.subtract(const Duration(days: 3)),
      ),
    ];
  }
}
