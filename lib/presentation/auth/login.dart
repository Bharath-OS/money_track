import 'package:cash_flow/core/constants/appcolors.dart';
import 'package:cash_flow/core/services/auth.dart';
import 'package:cash_flow/core/widgets/buttons.dart';
import 'package:cash_flow/core/widgets/nav_bar.dart';
import 'package:cash_flow/core/widgets/social_auth_buttons.dart';
import 'package:cash_flow/core/widgets/textFields.dart';
import 'package:cash_flow/data/user.dart';
import 'package:cash_flow/presentation/auth/register.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 40),
                // App Logo
                Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    color: AppColors.iconBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.monetization_on_outlined,
                    size: 48,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.darkText,
                  ),
                ),
                const Text(
                  'Please enter your details to sign in',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 32),

                AppTextField(
                  label: 'Email',
                  hintText: 'Enter your email',
                  controller: _emailController,
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Password',
                  hintText: 'Enter your password',
                  controller: _passwordController,
                  isPassword: true,
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),
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
                            builder: (context) => MainNavigationScreen(),
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

                // Social Auth Buttons
                SocialAuthButton(
                  text: 'Continue with Google',
                  iconPath: '',
                  onPressed: () {},
                ),
                const SizedBox(height: 12),
                SocialAuthButton(
                  text: 'Continue with Microsoft',
                  iconPath: '',
                  onPressed: () {},
                ),

                const SizedBox(height: 32),

                // Navigation Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(color: AppColors.secondaryText),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignupScreen(),
                        ),
                      ),
                      child: const Text(
                        'Sign Up',
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
      ),
    );
  }

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
}
