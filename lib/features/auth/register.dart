import 'package:cash_flow/core/constants/appcolors.dart';
import 'package:cash_flow/core/services/auth.dart';
import 'package:cash_flow/core/widgets/buttons.dart';
import 'package:cash_flow/core/widgets/nav_bar.dart';
import 'package:cash_flow/core/widgets/social_auth_buttons.dart';
import 'package:cash_flow/core/widgets/textFields.dart';
import 'package:cash_flow/data/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/alerts.dart';
import '../viewmodel/viewmodel.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserViewModel>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.darkText),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkText,
                ),
              ),
              const Text(
                'Fill in the details to get started',
                style: TextStyle(fontSize: 16, color: AppColors.secondaryText),
              ),
              const SizedBox(height: 32),

              AppTextField(
                label: 'Full Name',
                hintText: 'Enter your name',
                controller: _nameController,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Email',
                hintText: 'Enter your email',
                controller: _emailController,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Password',
                hintText: 'Create a password',
                controller: _passwordController,
                isPassword: true,
              ),

              const SizedBox(height: 32),
              AppButton(
                text: 'Sign Up',
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    AppUser? user = await AuthServices()
                        .createUserWithEmailAndPassword(
                          _nameController.text.trim(),
                          _emailController.text.trim(),
                          _passwordController.text.trim(),
                          context,
                        );
                    userProvider.setCurrentUser = user;
                    if (user != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MainNavigationScreen(),
                        ),
                      );
                    }
                  }
                },
              ),
              const SizedBox(height: 24),
              const Row(
                children: [
                  Expanded(child: Divider(color: AppColors.border)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR',
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: AppColors.border)),
                ],
              ),
              const SizedBox(height: 24),

              SocialAuthButton(
                text: 'Sign up with Google',
                iconPath: '',
                onPressed: () async {
                  Map<AppUser?, String> user = await AuthServices()
                      .signInWithGoogle(context);
                  if (!user.keys.contains(null)) {
                    userProvider.setCurrentUser = user.keys.first;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainNavigationScreen(),
                      ),
                    );
                  }
                  AppAlerts.showSnackBar(user.values.first, context);
                },
              ),
              const SizedBox(height: 12),
              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account?",
                    style: TextStyle(color: AppColors.secondaryText),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
