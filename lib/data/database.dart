import 'package:cash_flow/data/models/transaction_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DatabaseServices {
  static final db = FirebaseFirestore.instance;
  static final CollectionReference transactions = db.collection('transactions');

  static Future<bool> addTransactions({
    required TransactionModel transaction,
  }) async {
    try {
      await transactions.doc(transaction.id).set(transaction.toMap());
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future<bool> updateTransaction({
    required TransactionModel transaction,
  }) async {
    try {
      await transactions.doc(transaction.id).update({
        'id': transaction.id,
        'userId': transaction.userId,
        'title': transaction.title,
        'isExpense': transaction.isExpense,
        'amount': transaction.amount,
        'category': transaction.category,
        'date': transaction.date,
        'paymentMode': transaction.paymentMode,
        'note': transaction.note,
        'attachmentUrl': transaction.attachmentUrl,
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }
}
