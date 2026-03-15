import 'package:cash_flow/presentation/auth/register.dart';
import 'package:cash_flow/presentation/home.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../core/constants/appcolors.dart';
import '../../core/widgets/componets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController nameController,
      emailController,
      passwordController;

  late final Map<String, List<dynamic>> textFieldMap = {};
  final _key = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    textFieldMap.addAll({
      'field1': ['Rakesh Sharma', nameController],
      'field2': ['example@gmail.com', emailController],
      'field3': ['password', passwordController],
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 34,
          children: [
            Text(
              'LOGIN THE CASHFLOW',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 30),
            ),
            Form(
              key: _key,
              child: Column(
                // mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 20,
                // children: textFieldMap.map((key,value) => inputField(hintText: value[0], controller: value[1]))toList(),
                children: [
                  AppTextFields.authInputField(
                    hintText: 'example@gmail.com',
                    controller: emailController,
                    isEmail: true,
                  ),
                  AppTextFields.authInputField(
                    hintText: 'password',
                    controller: passwordController,
                  ),
                  AppButtons.primaryButton(
                    text: 'Sign In',
                    onTap: () async {
                      if (_key.currentState!.validate()) {
                        User.username = nameController.text;
                        User.email = emailController.text;
                        try {
                          final user = await FirebaseAuth.instance
                              .signInWithEmailAndPassword(
                                email: emailController.text,
                                password: passwordController.text,
                              );
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen(userCredential: user,)));
                        } on FirebaseAuthException catch (e) {
                          String message;
                          switch (e.code) {
                            case 'network-request-failed':
                              message = 'Check your internet connection.';
                              break;
                            case 'email-already-in-use':
                              message = 'This email is already registered.';
                              break;
                            case 'invalid-email':
                              message = 'Invalid email format.';
                              break;
                            case 'user-not-found':
                              message = 'No account found with this email. Sign up instead';
                              break;
                            case 'wrong-password':
                              message = 'Incorrect password. Try again.';
                              break;
                            case 'weak-password':
                              message =
                                  'Password should be at least 6 characters.';
                              break;
                            default:
                              message =
                                  'Registration failed. Please try again.';
                          }
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(message)));
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('An unexpected error occurred.'),
                            ),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Fill all the fields'),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            Row(
              spacing: 10,
              children: [
                Expanded(
                  child: Divider(thickness: 2, color: AppColors.greyTextColor),
                ),
                Text(
                  'Or',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.greyTextColor,
                  ),
                ),
                Expanded(
                  child: Divider(thickness: 2, color: AppColors.greyTextColor),
                ),
              ],
            ),
            AppButtons.googleAuthButton(
              text: 'Sign In With Google',
              onTap: () {
                if (User.username.isEmpty) {
                  print('Register first');
                }
              },
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: 'Create an account? ',
                style: TextStyle(fontSize: 18),
                children: [
                  TextSpan(
                    text: 'Sign up',
                    recognizer: TapGestureRecognizer()..onTap = (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> RegisterScreen()));
                    },
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
