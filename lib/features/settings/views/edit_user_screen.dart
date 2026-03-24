import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/appcolors.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/textFields.dart';
import '../../viewmodel/viewmodel.dart';

class EditUserScreen extends StatefulWidget {
  const EditUserScreen({super.key});

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserViewModel>().currentUser;
    _nameController = TextEditingController(text: user?.username ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Edit Profile",
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
                "Personal Information",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Update your profile details below.",
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: 32),
              AppTextField(
                label: "Full Name",
                hintText: "Enter your full name",
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Full name is required";
                  }
                  if (value.length < 3) {
                    return "Name must be at least 3 characters";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              AppTextField(
                label: "Email Address",
                hintText: "Enter your email address",
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Email is required";
                  }
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(value)) {
                    return "Enter a valid email address";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),
              AppButton(
                text: "Save Changes",
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
