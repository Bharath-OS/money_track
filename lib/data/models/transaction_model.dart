import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String userId;
  final String title;
  final bool isExpense;
  final double amount;
  final String category;
  final DateTime date;
  final String paymentMode;
  final String note;
  final String? attachmentUrl;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.isExpense,
    required this.amount,
    required this.category,
    required this.date,
    required this.paymentMode,
    required this.note,
    this.attachmentUrl,
  });

  TransactionModel copyWith({
    String? id,
    String? userId,
    String? title,
    bool? isExpense,
    double? amount,
    String? category,
    DateTime? date,
    String? paymentMode,
    String? note,
    String? attachmentUrl,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      isExpense: isExpense ?? this.isExpense,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      paymentMode: paymentMode ?? this.paymentMode,
      note: note ?? this.note,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'isExpense': isExpense,
      'amount': amount,
      'category': category,
      'date': date, // Store as DateTime (Firestore converts to Timestamp)
      'paymentMode': paymentMode,
      'note': note,
      'attachmentUrl': attachmentUrl,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map, String documentId) {
    DateTime parsedDate;
    if (map['date'] is Timestamp) {
      parsedDate = (map['date'] as Timestamp).toDate();
    } else if (map['date'] is int) {
      parsedDate = DateTime.fromMillisecondsSinceEpoch(map['date']);
    } else {
      parsedDate = DateTime.now();
    }

    return TransactionModel(
      id: documentId,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      isExpense: map['isExpense'] ?? true,
      amount: map['amount']?.toDouble() ?? 0.0,
      category: map['category'] ?? '',
      date: parsedDate,
      paymentMode: map['paymentMode'] ?? '',
      note: map['note'] ?? '',
      attachmentUrl: map['attachmentUrl'],
    );
  }
}

