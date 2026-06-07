import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/state/finance_provider.dart';
import '../../../core/models/expense.dart';
import '../../../core/widgets/expense_card.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  ExpenseCategory? _selectedCategoryFilter;
  DateTimeRange? _selectedDateRange;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedCategoryFilter = null;
      _selectedDateRange = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);
    final glassTheme = Theme.of(context).extension<GlassThemeExtension>();

    // Apply filters
    List<Expense> filteredExpenses = provider.expenses.where((expense) {
      // 1. Search Query Filter
      final noteMatches = expense.note.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          expense.category.displayName.toLowerCase().contains(_searchQuery.toLowerCase());
      if (!noteMatches) return false;

      // 2. Category Filter
      if (_selectedCategoryFilter != null && expense.category != _selectedCategoryFilter) {
        return false;
      }

      // 3. Date Range Filter
      if (_selectedDateRange != null) {
        final start = DateTime(_selectedDateRange!.start.year, _selectedDateRange!.start.month, _selectedDateRange!.start.day);
        final end = DateTime(_selectedDateRange!.end.year, _selectedDateRange!.end.month, _selectedDateRange!.end.day, 23, 59, 59);
        if (expense.date.isBefore(start) || expense.date.isAfter(end)) {
          // Check if it's within range
          return false;
        }
      }

      return true;
    }).toList();

    // Group filtered expenses by date
    final groupedExpenses = _groupExpensesByDate(filteredExpenses);

    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.bgGradient,
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Screen Header & Search Bar
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 16),
              child: Text(
                'Transaction History',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 12),

            // Search and Date Filter Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  // Search Bar Input
                  Expanded(
                    child: Container(
                      height: 52,
                      decoration: glassTheme?.inputDecoration ?? BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Search transactions...',
                          hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.6)),
                          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                          suffixIcon: _searchQuery.isNotEmpty 
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, color: AppColors.textSecondary),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Date Range Picker Button
                  Container(
                    height: 52,
                    width: 52,
                    decoration: glassTheme?.cardDecoration ?? BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.date_range_rounded,
                        color: _selectedDateRange != null ? AppColors.accentCyan : AppColors.textSecondary,
                      ),
                      onPressed: () async {
                        final picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime.now().subtract(const Duration(days: 365)),
                          lastDate: DateTime.now(),
                          initialDateRange: _selectedDateRange,
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.dark(
                                  primary: AppColors.primaryBlue,
                                  surface: AppColors.surface,
                                  onPrimary: Colors.white,
                                  onSurface: AppColors.textPrimary,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setState(() {
                            _selectedDateRange = picked;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Horizontal Filter Chips
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: ExpenseCategory.values.length + 1,
                itemBuilder: (context, index) {
                  final isAll = index == 0;
                  final category = isAll ? null : ExpenseCategory.values[index - 1];
                  final isSelected = _selectedCategoryFilter == category;
                  final chipColor = isAll ? AppColors.primaryBlue : category!.color;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(
                        isAll ? 'All' : category!.displayName,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategoryFilter = category;
                        });
                      },
                      selectedColor: chipColor.withOpacity(0.25),
                      backgroundColor: AppColors.surface.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected ? chipColor : Colors.white.withOpacity(0.05),
                          width: 1,
                        ),
                      ),
                      showCheckmark: false,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Show active date-range filter summary
            if (_selectedDateRange != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Date range: ${_formatSimpleDate(_selectedDateRange!.start)} - ${_formatSimpleDate(_selectedDateRange!.end)}',
                      style: const TextStyle(fontSize: 12, color: AppColors.accentCyan, fontWeight: FontWeight.w500),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDateRange = null;
                        });
                      },
                      child: const Text(
                        'Reset Range',
                        style: TextStyle(fontSize: 12, color: AppColors.dangerRed, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

            // 4. Grouped Transactions List View
            Expanded(
              child: filteredExpenses.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.builder(
                      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 90, top: 8),
                      itemCount: groupedExpenses.keys.length,
                      itemBuilder: (context, index) {
                        final dateHeader = groupedExpenses.keys.elementAt(index);
                        final expensesForDate = groupedExpenses[dateHeader]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Date header separator
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 4),
                              child: Text(
                                dateHeader,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                              ),
                            ),
                            ...expensesForDate.map((expense) => Dismissible(
                              key: Key(expense.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.dangerRed.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(Icons.delete_forever_rounded, color: AppColors.dangerRed),
                              ),
                              onDismissed: (direction) {
                                provider.deleteExpense(expense.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Transaction "${expense.note.isEmpty ? expense.category.displayName : expense.note}" deleted.'),
                                    backgroundColor: AppColors.dangerRed,
                                    action: SnackBarAction(
                                      label: 'UNDO',
                                      textColor: Colors.white,
                                      onPressed: () {
                                        provider.addExpense(
                                          amount: expense.amount,
                                          category: expense.category,
                                          note: expense.note,
                                          date: expense.date,
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                              child: ExpenseCard(expense: expense),
                            )),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              color: AppColors.textSecondary,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search query, selecting\na different category, or resetting filters.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: _clearFilters,
            child: const Text('Clear All Filters'),
          ),
        ],
      ),
    );
  }

  Map<String, List<Expense>> _groupExpensesByDate(List<Expense> expenses) {
    final Map<String, List<Expense>> groups = {};
    
    // Sort expenses descending by date
    final sortedExpenses = List<Expense>.from(expenses)
      ..sort((a, b) => b.date.compareTo(a.date));

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final expense in sortedExpenses) {
      final expDate = DateTime(expense.date.year, expense.date.month, expense.date.day);
      String key;

      if (expDate == today) {
        key = 'TODAY';
      } else if (expDate == yesterday) {
        key = 'YESTERDAY';
      } else {
        key = '${_getDayName(expense.date.weekday)}, ${_getMonthName(expense.date.month)} ${expense.date.day}';
      }

      if (!groups.containsKey(key)) {
        groups[key] = [];
      }
      groups[key]!.add(expense);
    }

    return groups;
  }

  String _formatSimpleDate(DateTime date) {
    return '${_getMonthName(date.month)} ${date.day}';
  }

  String _getDayName(int day) {
    const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    return days[day % 7];
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}
