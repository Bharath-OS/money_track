import 'package:cash_flow/data/database.dart';
import 'package:cash_flow/data/models/transaction_model.dart';
import 'package:flutter/material.dart';

class TransactionViewmodel extends ChangeNotifier {
  List<TransactionModel> transactions = [];
  bool isLoading = false;

  TransactionViewmodel() {
    getTransactions();
  }

  Future<void> getTransactions() async {
    isLoading = true;
    notifyListeners();
    try {
      final value = await DatabaseServices.transactions.get();
      transactions = value.docs
          .map(
            (e) => TransactionModel.fromMap(
              e.data() as Map<String, dynamic>,
              e.id,
            ),
          )
          .toList();
    } catch (e) {
      print("Error fetching transactions: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addTransaction(TransactionModel transaction) async {
    final result = await DatabaseServices.addTransactions(transaction: transaction);
    if (result) {
      await getTransactions(); // Refresh list after adding
      return true;
    }
    return false;
  }

  Future<bool> updateTransaction(TransactionModel transaction) async {
    final result = await DatabaseServices.updateTransaction(transaction: transaction);
    if (result) {
      await getTransactions(); // Refresh list after updating
      return true;
    }
    return false;
  }
}

