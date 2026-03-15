import 'package:cash_flow/presentation/auth/login.dart';
import 'package:cash_flow/presentation/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../core/constants/appcolors.dart';
import '../../core/widgets/componets.dart';
import 'package:google_sign_in/google_sign_in.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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
              'CREATE ACCOUNT',
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
                // children: textFieldMap.map((key,value) => AppTextFields.authInputField(hintText: value[0], controller: value[1]))toList(),
                children: [
                  AppTextFields.authInputField(
                    hintText: 'Rakesh Sharma',
                    controller: nameController,
                  ),
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
                    text: 'Sign Up',
                    onTap: () async {
                      if (_key.currentState!.validate()) {
                        try {
                          await FirebaseAuth.instance
                              .createUserWithEmailAndPassword(
                                email: emailController.text,
                                password: passwordController.text,
                              );
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                          );
                        } on FirebaseAuthException catch (e) {
                          String message;
                          switch (e.code) {
                            case 'email-already-in-use':
                              message =
                                  'This email is already registered. Try login instead';
                              break;
                            case 'invalid-email':
                              message = 'Invalid email format.';
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
                          const SnackBar(content: Text('Fill all the fields')),
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
              text: 'Sign Up With Google',
              onTap: () async{
                try{
                  print('Attempting Google Sign In');
                  UserCredential? user = await signInWithGoogle();
                  if(user != null && user.user != null){
                    print('User signed in: ${user.user!.email}');
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomeScreen(userCredential: user,)));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Successfully authenticated')),
                    );
                  } else {
                    print('Sign in cancelled or failed');
                  }
                }catch(err){
                  print('Error during Google Sign In: $err');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Something went wrong. Try again later')),
                  );
                }
              },
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: 'Already have an account? ',
                style: TextStyle(fontSize: 18),
                children: [
                  TextSpan(
                    text: 'Sign in',
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                        );
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

Future<UserCredential> signInWithGoogle() async {
  final googleUser = await GoogleSignIn.instance.authenticate();
  final googleAuth = await googleUser.authentication;

  final credential = GoogleAuthProvider.credential(
    idToken: googleAuth.idToken,
  );

  return await FirebaseAuth.instance.signInWithCredential(credential);
}
