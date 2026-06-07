import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/expense.dart';
import '../models/debt.dart';
import '../models/insight.dart';
import '../models/reflection.dart';

class AIServiceResult {
  final List<Insight> insights;
  final WeeklyReflection reflection;

  AIServiceResult({
    required this.insights,
    required this.reflection,
  });
}

class AIService {
  static Future<AIServiceResult> generateFeedback({
    required String apiKey,
    required String userName,
    required double allowance,
    required List<Expense> expenses,
    required List<Debt> debts,
  }) async {
    // 1. Initialize Generative Model
    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(responseMimeType: 'application/json'),
    );

    // 2. Build deterministic details
    final totalSpent = expenses.fold(0.0, (sum, item) => sum + item.amount);
    final remaining = allowance - totalSpent;
    
    // Group spending by category
    final Map<String, double> categorySums = {};
    for (var expense in expenses) {
      final catName = expense.category.displayName;
      categorySums[catName] = (categorySums[catName] ?? 0.0) + expense.amount;
    }

    final categoryBreakdownText = categorySums.entries
        .map((e) => '- ${e.key}: ₱${e.value.toStringAsFixed(2)}')
        .join('\n');

    final expensesListText = expenses.take(15).map((e) {
      final dateStr = "${e.date.year}-${e.date.month}-${e.date.day}";
      return '- ₱${e.amount.toStringAsFixed(2)} on ${e.category.displayName} (${e.note}) on $dateStr';
    }).join('\n');

    final debtsListText = debts.map((d) {
      final direction = d.isIOwe ? "I owe them" : "They owe me";
      return '- ${d.name}: ₱${d.remainingAmount.toStringAsFixed(2)} outstanding / ₱${d.originalAmount.toStringAsFixed(2)} original ($direction, Status: ${d.status.name})';
    }).join('\n');

    // 3. Compose Prompt
    final prompt = '''
You are KwartaKo, an expert AI Personal Finance Coach for students and young professionals.
Analyze the user's weekly personal finance data and generate coaching insights and Saturday reflections.

USER PROFILE:
- Name: $userName
- Weekly Allowance: ₱${allowance.toStringAsFixed(2)}
- Current Total Spent: ₱${totalSpent.toStringAsFixed(2)}
- Current Remaining Allowance: ₱${remaining.toStringAsFixed(2)}

SPENDING BY CATEGORY:
${categoryBreakdownText.isEmpty ? 'No transactions logged yet.' : categoryBreakdownText}

DETAILED RECENT EXPENSES:
${expensesListText.isEmpty ? 'No transactions logged yet.' : expensesListText}

ACTIVE DEBTS & LOANS:
${debtsListText.isEmpty ? 'No active debts.' : debtsListText}

INSTRUCTIONS:
1. Generate up to 3 diagnostic coach insights summarizing warnings or praises.
2. Provide a weekly reflection summary (what went well, areas of improvement, and actionable coach suggestions).
3. Return the response strictly as a single JSON object conforming to the following schema:
{
  "insights": [
    {
      "id": "string (unique code like 'ai_in_1')",
      "title": "string (concise highlight, e.g. 'Impulse Warning')",
      "description": "string (actionable advice or alert, e.g. 'You spent ₱500 on Wants. Sleep on wants for 24h next time!')",
      "type": "string (must be one of: 'warning', 'tip', 'success', 'info')",
      "category": "string (optional, matching one of: 'Food', 'Transportation', 'School', 'Load/Internet', 'Wants', 'Emergency', 'Savings', 'Others')"
    }
  ],
  "reflection": {
    "whatWentWell": ["string", "string"],
    "needsImprovement": ["string", "string"],
    "aiCoachSuggestions": ["string", "string"],
    "comparisonText": "string (e.g. 'Compared to last week: Spent ₱120 less')",
    "motivationalQuote": "string (an inspiring finance quote)"
  }
}
''';

    // 4. Call API
    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);
    
    if (response.text == null) {
      throw Exception('Empty response received from Gemini API.');
    }

    // 5. Parse JSON Output
    final data = jsonDecode(response.text!) as Map<String, dynamic>;
    
    // Parse insights list
    final List<Insight> insights = [];
    if (data['insights'] != null) {
      for (var item in data['insights']) {
        insights.add(Insight.fromMap(item as Map<String, dynamic>));
      }
    }

    // Parse reflection safely and overlay deterministic math
    final reflData = data['reflection'] as Map<String, dynamic>? ?? {};
    
    final dailySpendingTrend = _calculateDailySpendingTrend(expenses);
    final topCategoriesMap = _calculateTopCategories(expenses);
    final savingsSum = categorySums['Savings'] ?? 0.0;

    List<String> parseStringList(dynamic value, List<String> fallback) {
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      return fallback;
    }

    final reflection = WeeklyReflection(
      allowance: allowance,
      totalSpent: totalSpent,
      remaining: remaining,
      savings: savingsSum,
      dailySpendingTrend: dailySpendingTrend,
      topCategories: topCategoriesMap,
      whatWentWell: parseStringList(reflData['whatWentWell'], ['Log transactions to start reflection!']),
      needsImprovement: parseStringList(reflData['needsImprovement'], ['No spending data recorded yet.']),
      aiCoachSuggestions: parseStringList(reflData['aiCoachSuggestions'], ['Use Sunday Planning to set your budget allocation.']),
      comparisonText: reflData['comparisonText'] as String? ?? 'No comparison data',
      motivationalQuote: reflData['motivationalQuote'] as String? ?? 'Keep saving!',
    );

    return AIServiceResult(
      insights: insights,
      reflection: reflection,
    );
  }

  // --- DETERMINISTIC MATHEMATICAL CALCULATIONS FOR REFLECTION ---
  static List<double> _calculateDailySpendingTrend(List<Expense> expenses) {
    final List<double> trend = List.filled(7, 0.0);
    final now = DateTime.now();
    final currentWeekday = now.weekday;
    final mondayOfThisWeek = now.subtract(Duration(days: currentWeekday - 1));
    final startOfDayMonday = DateTime(mondayOfThisWeek.year, mondayOfThisWeek.month, mondayOfThisWeek.day);

    for (var expense in expenses) {
      final difference = expense.date.difference(startOfDayMonday).inDays;
      if (difference >= 0 && difference < 7) {
        final index = expense.date.weekday - 1;
        if (index >= 0 && index < 7) {
          trend[index] += expense.amount;
        }
      }
    }
    return trend;
  }

  static Map<String, double> _calculateTopCategories(List<Expense> expenses) {
    final Map<String, double> sums = {};
    for (var expense in expenses) {
      final name = expense.category.displayName;
      sums[name] = (sums[name] ?? 0.0) + expense.amount;
    }
    
    final sortedEntries = sums.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
      
    return Map.fromEntries(sortedEntries);
  }
}
