import 'dart:convert';

class WeeklyReflection {
  final double allowance;
  final double totalSpent;
  final double remaining;
  final double savings;
  final List<double> dailySpendingTrend; // Mon-Sun spending
  final Map<String, double> topCategories;
  final List<String> whatWentWell;
  final List<String> needsImprovement;
  final List<String> aiCoachSuggestions;
  final String comparisonText;
  final String motivationalQuote;

  WeeklyReflection({
    required this.allowance,
    required this.totalSpent,
    required this.remaining,
    required this.savings,
    required this.dailySpendingTrend,
    required this.topCategories,
    required this.whatWentWell,
    required this.needsImprovement,
    required this.aiCoachSuggestions,
    required this.comparisonText,
    required this.motivationalQuote,
  });

  Map<String, dynamic> toMap() {
    return {
      'allowance': allowance,
      'totalSpent': totalSpent,
      'remaining': remaining,
      'savings': savings,
      'dailySpendingTrend': jsonEncode(dailySpendingTrend),
      'topCategories': jsonEncode(topCategories),
      'whatWentWell': jsonEncode(whatWentWell),
      'needsImprovement': jsonEncode(needsImprovement),
      'aiCoachSuggestions': jsonEncode(aiCoachSuggestions),
      'comparisonText': comparisonText,
      'motivationalQuote': motivationalQuote,
    };
  }

  factory WeeklyReflection.fromMap(Map<String, dynamic> map) {
    return WeeklyReflection(
      allowance: (map['allowance'] as num).toDouble(),
      totalSpent: (map['totalSpent'] as num).toDouble(),
      remaining: (map['remaining'] as num).toDouble(),
      savings: (map['savings'] as num).toDouble(),
      dailySpendingTrend: List<double>.from(
        (jsonDecode(map['dailySpendingTrend'] as String) as List).map((x) => (x as num).toDouble()),
      ),
      topCategories: Map<String, double>.from(
        (jsonDecode(map['topCategories'] as String) as Map).map(
          (k, v) => MapEntry(k as String, (v as num).toDouble()),
        ),
      ),
      whatWentWell: List<String>.from(jsonDecode(map['whatWentWell'] as String) as List),
      needsImprovement: List<String>.from(jsonDecode(map['needsImprovement'] as String) as List),
      aiCoachSuggestions: List<String>.from(jsonDecode(map['aiCoachSuggestions'] as String) as List),
      comparisonText: map['comparisonText'] as String,
      motivationalQuote: map['motivationalQuote'] as String,
    );
  }

  static WeeklyReflection get emptyReflection {
    return WeeklyReflection(
      allowance: 0.0,
      totalSpent: 0.0,
      remaining: 0.0,
      savings: 0.0,
      dailySpendingTrend: const [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
      topCategories: const {},
      whatWentWell: const [
        'Plan a weekly allowance budget to get started.',
        'Log your daily transactions to analyze savings.',
      ],
      needsImprovement: const [
        'No transactions logged for this reflection period.',
      ],
      aiCoachSuggestions: const [
        'Use the Sunday Planning screen to allocate your budget.',
        'Record every purchase to track wants vs needs metrics.',
      ],
      comparisonText: 'No data comparison',
      motivationalQuote: '"Do not save what is left after spending, but spend what is left after saving." — Warren Buffett',
    );
  }

  static WeeklyReflection get mockReflection {
    return WeeklyReflection(
      allowance: 2000.00,
      totalSpent: 1464.00,
      remaining: 536.00,
      savings: 500.00,
      dailySpendingTrend: [165.0, 399.0, 650.0, 100.0, 150.0, 0.0, 0.0], // Mon-Sun spending
      topCategories: {
        'Food': 650.00,
        'Wants': 500.00,
        'School': 300.00,
        'Transportation': 14.00,
      },
      whatWentWell: [
        'Stayed under total weekly budget by ₱536.',
        'Had a 100% no-spend day on Saturday!',
        'Avoided eating out on Wednesday by bringing packed lunch.',
      ],
      needsImprovement: [
        'Too many impulse purchases on Wednesday (₱500 movie/snacks).',
        'Load/Internet cost was slightly higher than budget target.',
      ],
      aiCoachSuggestions: [
        'Reduce snack spending by ₱100 next week to boost your savings.',
        'Try purchasing 30-day mobile data plans instead of daily topups.',
        'Set aside a fixed ₱200 from your Sunday allowance immediately into savings.',
      ],
      comparisonText: 'Compared to last week: Spent ₱180 less',
      motivationalQuote: '"Do not save what is left after spending, but spend what is left after saving." — Warren Buffett',
    );
  }
}
