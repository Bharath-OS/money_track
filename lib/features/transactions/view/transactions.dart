import 'package:cash_flow/core/services/auth.dart';
import 'package:cash_flow/data/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/appcolors.dart';
import '../../../data/models/transaction_model.dart';
import 'transaction_details.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All'; // 'All', 'Income', 'Expense'
  DateTimeRange? _selectedDateRange;

  // Function to open the Date Range Picker
  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              onSurface: AppColors.darkText,
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
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Transactions',
          style: TextStyle(
            color: AppColors.darkText,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.calendar_month_outlined,
              color: _selectedDateRange != null
                  ? AppColors.primaryBlue
                  : AppColors.darkText,
            ),
            onPressed: _selectDateRange,
          ),
          if (_selectedDateRange != null)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red, size: 20),
              onPressed: () => setState(() => _selectedDateRange = null),
            ),
        ],
      ),
      body: Column(
        children: [
          // 1. Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: _buildSearchField(),
          ),

          // 2. Filter Tabs (All, Income, Expense)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildFilterTab('All'),
                  const SizedBox(width: 12),
                  _buildFilterTab('Income'),
                  const SizedBox(width: 12),
                  _buildFilterTab('Expense'),
                ],
              ),
            ),
          ),

          // 3. Transactions List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: DatabaseServices.transactions
                  .where('userId', isEqualTo: AuthServices().currentUser?.uid)
                  .snapshots(),
              builder: (context, snapshots) {
                if (snapshots.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshots.hasData || snapshots.data!.docs.isEmpty) {
                  return const Center(child: Text('No transactions found'));
                }

                // Filtering logic applied locally to the stream data
                final filteredDocs = snapshots.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  // Filter by Type (Income/Expense)
                  if (_selectedFilter == 'Income' && data['isExpense'] == true)
                    return false;
                  if (_selectedFilter == 'Expense' &&
                      data['isExpense'] == false)
                    return false;

                  // Filter by Search Text
                  final title = data['title']?.toString().toLowerCase() ?? '';
                  final search = _searchController.text.toLowerCase();
                  if (search.isNotEmpty && !title.contains(search))
                    return false;

                  // Filter by Date Range
                  if (_selectedDateRange != null) {
                    final timestamp = data['date'] as Timestamp?;
                    if (timestamp == null) return false;
                    final date = timestamp.toDate();

                    // Normalize to start of day for comparison
                    final startDate = DateTime(
                      _selectedDateRange!.start.year,
                      _selectedDateRange!.start.month,
                      _selectedDateRange!.start.day,
                    );
                    final endDate = DateTime(
                      _selectedDateRange!.end.year,
                      _selectedDateRange!.end.month,
                      _selectedDateRange!.end.day,
                      23,
                      59,
                      59,
                    );

                    if (date.isBefore(startDate) || date.isAfter(endDate))
                      return false;
                  }

                  return true;
                }).toList();

                if (filteredDocs.isEmpty) {
                  return const Center(
                    child: Text('No matching transactions found'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final map =
                        filteredDocs[index].data() as Map<String, dynamic>;
                    final transactionModel = TransactionModel.fromMap(
                      map,
                      map['id'] ?? '',
                    );

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TransactionDetailsScreen(
                              transaction: transactionModel,
                            ),
                          ),
                        );
                      },
                      child: _buildTransactionCard(
                        title: transactionModel.title,
                        category: transactionModel.category,
                        amount: transactionModel.amount,
                        isExpense: transactionModel.isExpense,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- REUSABLE WIDGET METHODS FOR THIS SCREEN ---

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search transactions',
        hintStyle: const TextStyle(color: AppColors.secondaryText),
        prefixIcon: const Icon(Icons.search, color: AppColors.secondaryText),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
              )
            : null,
        filled: true,
        fillColor: const Color(0xFFF1F4F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
      ),
      onChanged: (value) {
        setState(() {}); // Trigger rebuild to apply filter in StreamBuilder
      },
    );
  }

  Widget _buildFilterTab(String title) {
    bool isSelected = _selectedFilter == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : const Color(0xFFE8EEF5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.secondaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard({
    required String title,
    required String category,
    required double amount,
    required bool isExpense,
  }) {
    bool isNegative = amount < 0;
    String formattedAmount = isNegative
        ? "-\$${amount.abs().toStringAsFixed(2)}"
        : "+\$${amount.toStringAsFixed(2)}";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isExpense
                  ? AppColors.expense.withOpacity(0.1)
                  : AppColors.income.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isExpense
                  ? Icons.money_off
                  : Icons.account_balance_wallet_outlined,
              color: isExpense ? AppColors.expense : AppColors.income,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.darkText,
                  ),
                ),
                Text(
                  category,
                  style: const TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Text(
            formattedAmount,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isNegative ? AppColors.expense : AppColors.income,
            ),
          ),
        ],
      ),
    );
  }
}
