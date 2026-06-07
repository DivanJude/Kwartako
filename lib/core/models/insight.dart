import 'package:flutter/material.dart';

enum InsightType {
  warning,
  tip,
  success,
  info,
}

extension InsightTypeExtension on InsightType {
  Color get color {
    switch (this) {
      case InsightType.warning:
        return const Color(0xFFF2C94C); // Warning Yellow
      case InsightType.tip:
        return const Color(0xFF00D1FF); // Accent Cyan
      case InsightType.success:
        return const Color(0xFF27AE60); // Success Green
      case InsightType.info:
        return const Color(0xFF2F80ED); // Primary Blue
    }
  }

  IconData get icon {
    switch (this) {
      case InsightType.warning:
        return Icons.warning_rounded;
      case InsightType.tip:
        return Icons.lightbulb_outline_rounded;
      case InsightType.success:
        return Icons.emoji_events_rounded;
      case InsightType.info:
        return Icons.info_outline_rounded;
    }
  }
}

class Insight {
  final String id;
  final String title;
  final String description;
  final InsightType type;
  final String? category; // e.g., 'Food', 'Wants'

  Insight({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'category': category,
    };
  }

  factory Insight.fromMap(Map<String, dynamic> map) {
    return Insight(
      id: (map['id'] ?? DateTime.now().millisecondsSinceEpoch.toString()).toString(),
      title: (map['title'] ?? 'Insight Alert').toString(),
      description: (map['description'] ?? 'No details provided.').toString(),
      type: InsightType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => InsightType.info,
      ),
      category: map['category']?.toString(),
    );
  }

  static List<Insight> get mockInsights {
    return [
      Insight(
        id: 'in1',
        title: 'Small Expense Detector',
        description: 'You spent ₱320 on 8 purchases below ₱50 this week. Small taps add up quickly!',
        type: InsightType.warning,
        category: 'Others',
      ),
      Insight(
        id: 'in2',
        title: 'Pacing Suggestion',
        description: 'Food spending is higher than usual this week. Let\'s pace ourselves for the next 3 days!',
        type: InsightType.info,
        category: 'Food',
      ),
      Insight(
        id: 'in3',
        title: 'No-Spend Day Streak',
        description: 'Awesome! You maintained a 3-day no-spend streak earlier this week. Keep it up!',
        type: InsightType.success,
      ),
      Insight(
        id: 'in4',
        title: 'Allowance Tip',
        description: 'Based on your last 4 weeks, allocating 35% of your allowance to food is recommended.',
        type: InsightType.tip,
        category: 'Food',
      ),
      Insight(
        id: 'in5',
        title: 'Debt Alert',
        description: 'You have an overdue payment of ₱3,500 to Landlord. Plan this in Sunday\'s allowance!',
        type: InsightType.warning,
      ),
    ];
  }
}
