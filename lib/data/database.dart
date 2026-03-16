import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DatabaseServices {
  static final db = FirebaseFirestore.instance;
  static final CollectionReference quotes = db.collection('quotes');
  static void updateQuote({
    required String title,
    required String quote,
  }) async {
    await quotes
        .add({'title': title, 'quote': quote})
        .then(
          (_) => ScaffoldMessenger(
            child: SnackBar(content: Text('quote successfully added')),
          ),
        );
  }

  static void printQuotes() async {
    await db.collection("users").get().then((event) {
      for (var doc in event.docs) {
        print("${doc.id} => ${doc.data()}");
      }
    });
  }
}
