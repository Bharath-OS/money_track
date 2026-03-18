import 'package:cash_flow/data/database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/appcolors.dart';
import '../../../core/widgets/buttons.dart';
import '../../../data/models/transaction_model.dart';

class EditTransactionScreen extends StatefulWidget {
  final TransactionModel transaction;

  const EditTransactionScreen({super.key, required this.transaction});

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  // State Variables
  late bool _isExpense;
  String? _selectedCategory;
  late String _paymentMode;
  late DateTime _selectedDate;

  // Controllers
  late TextEditingController _amountController;
  late TextEditingController _titleController;
  final _dateController = TextEditingController();
  late TextEditingController _noteController;

  // Categories
  final List<String> _expenseCategories = [
    'Shopping',
    'Personal care',
    'Entertainment',
    'Food',
    'Medical',
    'Taxes',
    'Bills & Utilities',
    'Education',
    'Insurance',
    'Rent',
    'Gifts and donation',
    'Other',
  ];

  final List<String> _incomeCategories = [
    'Salary',
    'Sold items',
    'Coupons',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _isExpense = widget.transaction.isExpense;
    _selectedCategory = widget.transaction.category;
    _paymentMode = widget.transaction.paymentMode;
    _selectedDate = widget.transaction.date;

    _amountController = TextEditingController(
      text: widget.transaction.amount.toString(),
    );
    _titleController = TextEditingController(text: widget.transaction.title);
    _dateController.text = DateFormat('MM/dd/yyyy').format(_selectedDate);
    _noteController = TextEditingController(text: widget.transaction.note);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _dateController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // --- Logic Methods ---

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('MM/dd/yyyy').format(picked);
      });
    }
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      // You mentioned you will do the backend work, so we just create the updated model here.
      final updatedTransaction = widget.transaction.copyWith(
        isExpense: _isExpense,
        title: _titleController.text,
        amount:
            double.tryParse(_amountController.text) ??
            widget.transaction.amount,
        category: _selectedCategory,
        date: _selectedDate,
        paymentMode: _paymentMode,
        note: _noteController.text,
      );
      try {
        await DatabaseServices.updateTransaction(
          transaction: updatedTransaction,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
      Navigator.pop(context, updatedTransaction);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Edit Transaction',
          style: TextStyle(
            color: AppColors.darkText,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: const BackButton(color: AppColors.darkText),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              _buildTypeToggle(),

              const SizedBox(height: 40),
              const Text(
                'AMOUNT',
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              _buildAmountField(),

              const SizedBox(height: 30),
              _buildLabel('Title'),
              _buildTitleField(),

              const SizedBox(height: 20),
              _buildLabel('Category'),
              _buildCategoryDropdown(),

              const SizedBox(height: 20),
              _buildLabel('Date'),
              _buildIconField(
                controller: _dateController,
                icon: Icons.calendar_today_outlined,
                onTap: _pickDate,
              ),

              const SizedBox(height: 20),
              _buildLabel('Payment Mode'),
              _buildPaymentModeRadio(),

              const SizedBox(height: 20),
              _buildLabel('Description'),
              _buildNoteField(),

              const SizedBox(height: 20),
              _buildAttachmentButton(),

              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Cancel',
                      type: ButtonType.outlined,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppButton(text: 'Save', onPressed: _handleSave),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // --- REUSABLE COMPONENT METHODS ---

  Widget _buildTypeToggle() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _toggleItem('Income', !_isExpense),
          _toggleItem('Expense', _isExpense),
        ],
      ),
    );
  }

  Widget _toggleItem(String title, bool active) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _isExpense = title == 'Expense';
          _selectedCategory = null; // Reset category on type change
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: active ? AppColors.primaryBlue : AppColors.secondaryText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 56,
        fontWeight: FontWeight.bold,
        color: AppColors.darkText,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: const InputDecoration(
        prefixText: '\$',
        prefixStyle: TextStyle(fontSize: 56),
        border: InputBorder.none,
      ),
      validator: (val) {
        if (val == null || val.isEmpty) return 'Please enter an amount';
        final amount = double.tryParse(val);
        if (amount == null) return 'Please enter a valid number';
        if (amount == 0) return 'Amount cannot be zero';
        if (amount < 0) return 'Please enter a positive value';
        return null;
      },
    );
  }

  Widget _buildLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.darkText,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    List<String> currentList = _isExpense
        ? _expenseCategories
        : _incomeCategories;

    // If the selected category is not in the list (e.g., from an old category), we add it temporarily or set it to null
    if (_selectedCategory != null && !currentList.contains(_selectedCategory)) {
      _selectedCategory = null;
    }

    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: _inputDecoration(prefixIcon: Icons.category_outlined),
      hint: const Text('Select category'),
      items: currentList
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: (val) => setState(() => _selectedCategory = val),
      validator: (val) => val == null ? 'Please select a category' : null,
    );
  }

  Widget _buildIconField({
    required TextEditingController controller,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      decoration: _inputDecoration(prefixIcon: icon),
    );
  }

  Widget _buildPaymentModeRadio() {
    return Row(
      children: ['Cash', 'Bank']
          .map(
            (mode) => Row(
              children: [
                Radio<String>(
                  value: mode,
                  groupValue: _paymentMode,
                  activeColor: AppColors.primaryBlue,
                  onChanged: (val) => setState(() => _paymentMode = val!),
                ),
                Text(mode),
                const SizedBox(width: 20),
              ],
            ),
          )
          .toList(),
    );
  }

  Widget _buildNoteField() {
    return TextFormField(
      controller: _noteController,
      maxLines: 3,
      decoration: _inputDecoration(
        prefixIcon: Icons.notes,
        hint: 'Add a note...',
      ),
    );
  }

  Widget _buildAttachmentButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border, style: BorderStyle.none),
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFFF8FAFD),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_upload_outlined,
            color: AppColors.primaryBlue,
            size: 32,
          ),
          const SizedBox(height: 8),
          const Text(
            'Change Attachment',
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: _inputDecoration(
        prefixIcon: Icons.title,
        hint: 'Enter title (e.g. Groceries)',
      ),
      validator: (val) =>
          val == null || val.isEmpty ? 'Please enter a title' : null,
    );
  }

  InputDecoration _inputDecoration({IconData? prefixIcon, String? hint}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(prefixIcon, color: AppColors.secondaryText, size: 20),
      filled: true,
      fillColor: const Color(0xFFF8FAFD),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 18),
    );
  }
}
