import 'package:cash_flow/core/constants/appcolors.dart';
import 'package:cash_flow/core/services/auth.dart';
import 'package:cash_flow/core/widgets/buttons.dart';
import 'package:cash_flow/core/widgets/textFields.dart';
import 'package:cash_flow/data/user.dart';
import 'package:cash_flow/presentation/auth/register.dart';
import 'package:cash_flow/presentation/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Reusable divider widget within this file
  Widget _buildDivider() {
    return const Row(
      children: [
        Expanded(child: Divider(color: AppColors.border, thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.border, thickness: 1)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'CashFlow',
          style: TextStyle(
            color: AppColors.darkText,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              // App Logo
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: AppColors.iconBg,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.monetization_on_outlined,
                  size: 60,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkText,
                ),
              ),
              const Text(
                'Please enter your details to sign in',
                style: TextStyle(fontSize: 16, color: AppColors.secondaryText),
              ),
              const SizedBox(height: 32),
              AppTextField(
                label: 'Email',
                hintText: 'Enter your email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value!.contains('@') ? null : 'Enter a valid email',
              ),
              const SizedBox(height: 20),
              AppTextField(
                label: 'Password',
                hintText: 'Enter your password',
                controller: _passwordController,
                isPassword: true,
                validator: (value) =>
                    value!.length < 6 ? 'Password too short' : null,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(color: AppColors.primaryBlue),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              AppButton(
                text: 'Sign In',
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    AppUser? user = await AuthServices()
                        .signInWithEmailAndPassword(
                          _emailController.text.trim(),
                          _passwordController.text.trim(),
                          context,
                        );
                    if (user != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeScreen(user: user),
                        ),
                      );
                    } else {
                      print('The user is null');
                    }
                  }
                },
              ),
              const SizedBox(height: 24),
              _buildDivider(),
              const SizedBox(height: 24),
              AppButton(
                text: 'Create Account',
                type: ButtonType.outlined,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignupScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
