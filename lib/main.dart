import 'package:cash_flow/core/services/auth.dart';
import 'package:cash_flow/features/auth/login.dart';
import 'package:cash_flow/features/viewmodel/viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/widgets/nav_bar.dart';
import 'data/user.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GoogleSignIn.instance.initialize(
    clientId:
        "349379008181-qaksk6u6iunqu2556d9vsmadl9ghkmor.apps.googleusercontent.com",
    serverClientId:
        "349379008181-qaksk6u6iunqu2556d9vsmadl9ghkmor.apps.googleusercontent.com",
  );

  runApp(CashFlow());
}

class CashFlow extends StatelessWidget {
  const CashFlow({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserViewModel(),
      builder: (context, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Cash Flow',
        home: Consumer<UserViewModel>(
          builder: (context, userProvider, child) {
            return StreamBuilder(
              stream: AuthServices().user,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  userProvider.setLoading(true);
                  return Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.data == null) {
                  userProvider.updateUser(null);
                  return LoginScreen();
                } else {
                  // Convert your Firebase user to AppUser
                  final firebaseUser = snapshot.data;
                  final appUser = AppUser(
                    uid: firebaseUser?.uid,
                    username: firebaseUser?.displayName,
                    email: firebaseUser?.email,
                    photoURL: firebaseUser?.photoURL,
                  );
                  userProvider.updateUser(appUser);
                  return MainNavigationScreen();
                }
              },
            );
          },
        ),
      ),
    );
  }
}
