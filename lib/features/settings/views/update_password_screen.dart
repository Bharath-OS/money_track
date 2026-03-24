import 'package:flutter/material.dart';
import '../../../core/constants/appcolors.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/textFields.dart';

class UpdatePasswordScreen extends StatefulWidget {
  const UpdatePasswordScreen({super.key});

  @override
  State<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Change Password",
          style: TextStyle(
            color: AppColors.darkText,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.darkText, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Security",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Choose a strong password to protect your account.",
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: 32),
              AppTextField(
                label: "Current Password",
                hintText: "Enter current password",
                controller: _currentPasswordController,
                isPassword: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Current password is required";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              AppTextField(
                label: "New Password",
                hintText: "Enter new password",
                controller: _newPasswordController,
                isPassword: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "New password is required";
                  }
                  if (value.length < 6) {
                    return "Password must be at least 6 characters";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              AppTextField(
                label: "Confirm New Password",
                hintText: "Confirm your new password",
                controller: _confirmPasswordController,
                isPassword: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please confirm your password";
                  }
                  if (value != _newPasswordController.text) {
                    return "Passwords do not match";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),
              AppButton(
                text: "Update Password",
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Logic to be implemented by user
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Validation successful! Logic not implemented.")),
                    );
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
