import 'dart:io';

import 'package:cash_flow/data/models/transaction_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ImageDatabaseServices {
  static const _bucketName = 'CashFlow';
  static final supabase = Supabase.instance.client;

  static Future<Map<String, String?>> uploadImage({
    required File image,
    required String userId,
  }) async {
    final objectKey = '$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';

    try {
      await supabase.storage.from(_bucketName).upload(objectKey, image);
      final url = await supabase.storage
          .from(_bucketName)
          .getPublicUrl(objectKey);

      return {'url': url, 'message': 'Image uploaded successfully'};
    } on SocketException {
      return {'url': null, 'message': 'Check your internet connection'};
    } on AuthException {
      return {'url': null, 'message': 'You are not authorized'};
    } catch (e) {
      print('here is the error: $e');
      return {'url': null, 'message': 'Unexpected error occurred'};
    }
  }
}

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

  static Stream<DocumentSnapshot> getTransactionStream(String id) {
    return transactions.doc(id).snapshots();
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
