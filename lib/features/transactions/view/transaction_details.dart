import 'package:cash_flow/features/transactions/viewmodel/transaction_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/appcolors.dart';
import '../../../data/models/transaction_model.dart';
import 'edit_transactions.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionDetailsScreen({super.key, required this.transaction});

  void _showZoomedImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(10),
          child: Stack(
            alignment: Alignment.center,
            children: [
              InteractiveViewer(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.broken_image,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionViewmodel>(
      builder: (context, transactionProvider, child) {
        // Find the most up-to-date version of this transaction
        final currentTransaction = transactionProvider.transactions.firstWhere(
          (t) => t.id == transaction.id,
          orElse: () => transaction,
        );

        // Format date string
        String formattedDate = DateFormat('MM/dd/yyyy').format(currentTransaction.date);

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text(
              'Transaction Details',
              style: TextStyle(
                color: AppColors.darkText,
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: const BackButton(color: AppColors.darkText),
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: AppColors.primaryBlue),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EditTransactionScreen(transaction: currentTransaction),
                    ),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                // Amount
                Text(
                  currentTransaction.isExpense
                      ? '-\$${currentTransaction.amount.abs().toStringAsFixed(2)}'
                      : '+\$${currentTransaction.amount.abs().toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: currentTransaction.isExpense ? Colors.red : Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                // Title
                Text(
                  currentTransaction.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 4),
                // Type
                Text(
                  currentTransaction.isExpense ? 'Expense' : 'Income',
                  style: const TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 40),

                // Details Container
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F4F9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow('Category', currentTransaction.category),
                      const Divider(height: 30, color: Colors.black12),
                      _buildDetailRow('Date', formattedDate),
                      const Divider(height: 30, color: Colors.black12),
                      _buildDetailRow('Payment Mode', currentTransaction.paymentMode),
                      if (currentTransaction.note.isNotEmpty) ...[
                        const Divider(height: 30, color: Colors.black12),
                        _buildDetailRow('Description', currentTransaction.note),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Attachment Section if exists
                if (currentTransaction.attachmentUrl != null &&
                    currentTransaction.attachmentUrl!.isNotEmpty) ...[
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Attachment',
                      style: TextStyle(
                        color: AppColors.darkText,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () =>
                        _showZoomedImage(context, currentTransaction.attachmentUrl!),
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black12),
                        image: DecorationImage(
                          image: NetworkImage(currentTransaction.attachmentUrl!),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.zoom_in,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.secondaryText,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppColors.darkText,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
