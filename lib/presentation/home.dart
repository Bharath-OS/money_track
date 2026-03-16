import 'package:cash_flow/core/widgets/componets.dart' hide User;
import 'package:cash_flow/data/database.dart';
import 'package:cash_flow/data/user.dart';
import 'package:cash_flow/presentation/auth/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  AppUser? user;
  HomeScreen({this.user, super.key});
  final titleController = TextEditingController();
  final quoteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Welcome ${user?.username}"),
            AppButtons.primaryButton(
              text: 'Logout',
              onTap: () async {
                try {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                } catch (e) {
                  print('something went wrong. Try again later');
                }
              },
            ),
            TextField(controller: titleController),
            TextField(controller: quoteController),
            AppButtons.primaryButton(
              text: 'Add',
              onTap: () async {
                DatabaseServices.updateQuote(
                  title: titleController.text.trim(),
                  quote: quoteController.text.trim(),
                );
              },
            ),
            AppButtons.primaryButton(
              text: 'Print',
              onTap: () async {
                DatabaseServices.printQuotes();
              },
            ),
          ],
        ),
      ),
    );
  }
}
