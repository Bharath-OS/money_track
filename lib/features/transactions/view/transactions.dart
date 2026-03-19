import 'package:cash_flow/core/services/auth.dart';
import 'package:cash_flow/data/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/appcolors.dart';
import 'package:provider/provider.dart';
import 'transaction_details.dart';
import '../viewmodel/transaction_viewmodel.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All'; // 'All', 'Income', 'Expense'
  DateTimeRange? _selectedDateRange;

  // Dummy data representing transactions
  final List<Map<String, dynamic>> _allTransactions = [
    {
      'title': 'Apple Store',
      'category': 'Gadgets & Tech',
      'amount': -999.00,
      'icon': Icons.shopping_bag_outlined,
      'color': Colors.blue,
    },
    {
      'title': 'Salary Deposit',
      'category': 'Monthly Income',
      'amount': 4500.00,
      'icon': Icons.account_balance_wallet_outlined,
      'color': AppColors.income,
    },
    {
      'title': 'Starbucks Coffee',
      'category': 'Food & Drink',
      'amount': -12.50,
      'icon': Icons.restaurant_menu_outlined,
      'color': Colors.orange,
    },
    {
      'title': 'Uber Trip',
      'category': 'Transport',
      'amount': -24.00,
      'icon': Icons.directions_car_filled_outlined,
      'color': Colors.blueAccent,
    },
    {
      'title': 'Netflix Subscription',
      'category': 'Entertainment',
      'amount': -15.99,
      'icon': Icons.movie_outlined,
      'color': Colors.purple,
    },
    {
      'title': 'Freelance Work',
      'category': 'Side Hustle',
      'amount': 1200.00,
      'icon': Icons.work_outline,
      'color': Colors.teal,
    },
  ];

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
      // Handle your filtering logic here based on 'picked'
      print("Selected Range: ${picked.start} to ${picked.end}");
    }
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
            icon: const Icon(
              Icons.calendar_month_outlined,
              color: AppColors.darkText,
            ),
            onPressed: _selectDateRange,
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
          StreamBuilder(
            stream: DatabaseServices.transactions
                .where('userId', isEqualTo: AuthServices().currentUser?.uid)
                .snapshots(),
            builder: (context, snapshots) {
              if (snapshots.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final transactions = transactionProvider.transactions;
              
              if (transactions.isEmpty) {
                return const Center(child: Text('No transactions found'));
              }

              return Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transactionModel = transactions[index];

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
                ),
              );
            },
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
        filled: true,
        fillColor: const Color(0xFFF1F4F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
      ),
      onChanged: (value) {
        // Implement real-time search logic
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
