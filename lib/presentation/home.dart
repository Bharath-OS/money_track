import 'package:cash_flow/presentation/auth/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/widgets/componets.dart';

class HomeScreen extends StatelessWidget {
  UserCredential userCredential;
  HomeScreen({required this.userCredential, super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        Text("Welcome ${userCredential.user?.email}"),
        AppButtons.primaryButton(text: 'Logout',onTap: () async{
          try{
            await FirebaseAuth.instance.signOut();
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
          }catch(e){
            print('something went wrong. Try again later');
          }
        })
        ],
      )),
    );
  }
}
