import 'package:cash_flow/core/constants/appcolors.dart';
import 'package:cash_flow/core/services/auth.dart';
import 'package:cash_flow/core/widgets/buttons.dart';
import 'package:cash_flow/core/widgets/textFields.dart';
import 'package:cash_flow/data/user.dart';
import 'package:cash_flow/presentation/auth/login.dart';
import 'package:cash_flow/presentation/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
  final _confirmPasswordController = TextEditingController();

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkText),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 32,
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
                hintText: 'Enter your full name',
                controller: _nameController,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 20),
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
                hintText: 'Create a password',
                controller: _passwordController,
                isPassword: true,
                validator: (value) =>
                    value!.length < 6 ? 'Min 6 characters required' : null,
              ),
              const SizedBox(height: 20),
              AppTextField(
                label: 'Confirm Password',
                hintText: 'Repeat your password',
                controller: _confirmPasswordController,
                isPassword: true,
                validator: (value) => value != _passwordController.text
                    ? 'Passwords do not match'
                    : null,
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
                    if (user != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeScreen(user: user),
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
