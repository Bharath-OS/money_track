import 'package:cash_flow/presentation/auth/register.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  await GoogleSignIn.instance.initialize(
    clientId: "349379008181-qaksk6u6iunqu2556d9vsmadl9ghkmor.apps.googleusercontent.com",
    serverClientId: "349379008181-qaksk6u6iunqu2556d9vsmadl9ghkmor.apps.googleusercontent.com",
  );

  runApp(CashFlow());
}

class CashFlow extends StatelessWidget {
  const CashFlow({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RegisterScreen(),
    );
  }
}

