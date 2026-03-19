import 'package:cash_flow/data/database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/appcolors.dart';
import '../../../data/models/transaction_model.dart';
import 'edit_transactions.dart';

class TransactionDetailsScreen extends StatefulWidget {
  final TransactionModel transaction;

  const TransactionDetailsScreen({super.key, required this.transaction});

  @override
  State<TransactionDetailsScreen> createState() =>
      _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState extends State<TransactionDetailsScreen> {
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
    return StreamBuilder(
      stream: DatabaseServices.getTransactionStream(widget.transaction.id),
      builder: (context, snapShot) {
        if (snapShot.hasError) {
          return const Scaffold(body: Center(child: Text('Something went wrong')));
        }
        if (snapShot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (!snapShot.hasData || snapShot.data?.data() == null) {
          return const Scaffold(body: Center(child: Text('No transaction found')));
        }
        final transaction = TransactionModel.fromMap(
          snapShot.data!.data()! as Map<String, dynamic>,
          snapShot.data!.id,
        );

        // Format date string INSIDE the builder
        String formattedDate = DateFormat('MM/dd/yyyy').format(transaction.date);

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
                          EditTransactionScreen(transaction: transaction),
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
                  transaction.isExpense
                      ? '-\$${transaction.amount.abs().toStringAsFixed(2)}'
                      : '+\$${transaction.amount.abs().toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: transaction.isExpense ? Colors.red : Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                // Title
                Text(
                  transaction.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 4),
                // Type
                Text(
                  transaction.isExpense ? 'Expense' : 'Income',
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
                      _buildDetailRow('Category', transaction.category),
                      const Divider(height: 30, color: Colors.black12),
                      _buildDetailRow('Date', formattedDate),
                      const Divider(height: 30, color: Colors.black12),
                      _buildDetailRow('Payment Mode', transaction.paymentMode),
                      if (transaction.note.isNotEmpty) ...[
                        const Divider(height: 30, color: Colors.black12),
                        _buildDetailRow('Description', transaction.note),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Attachment Section if exists
                if (transaction.attachmentUrl != null &&
                    transaction.attachmentUrl!.isNotEmpty) ...[
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
                        _showZoomedImage(context, transaction.attachmentUrl!),
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black12),
                        image: DecorationImage(
                          image: NetworkImage(transaction.attachmentUrl!),
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
