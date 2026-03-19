import 'dart:io';
import 'package:cash_flow/data/user.dart';
import 'package:cash_flow/features/auth/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/appcolors.dart';
import '../../../data/database.dart';
import '../../viewmodel/viewmodel.dart'; // Add to pubspec.yaml

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // State Variables
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  String _selectedCurrency = "USD";
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);
  File? _image;

  // Logic: Image Picker
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Logic: Time Picker for Reminder
  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked != null && picked != _reminderTime) {
      setState(() {
        _reminderTime = picked;
      });
    }
  }

  // Logic: Currency Selection Modal
  void _showCurrencyPicker() {
    final List<String> currencies = [
      "USD",
      "EUR",
      "GBP",
      "JPY",
      "AUD",
      "CAD",
      "CHF",
      "CNY",
      "INR",
      "SGD",
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: currencies.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(
                  currencies[index],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  setState(() => _selectedCurrency = currencies[index]);
                  Navigator.pop(context);
                },
              );
            },
          ),
        );
      },
    );
  }

  // Logic: Sign Out Dialog
  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Dialog takes only required height
            children: [
              // 1. Alert Icon
              Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Colors.redAccent,
                  size: 36,
                ),
              ),
              const SizedBox(height: 24),

              // 2. Title
              const Text(
                "Sign Out",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 12),

              // 3. Message
              const Text(
                "Are you sure you want to sign out? You will need to login again to access your data.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.secondaryText,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // 4. Action Buttons (Side by Side)
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            color: AppColors.secondaryText,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          context.read<UserViewModel>().signOut();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Sign Out",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserViewModel>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(
            color: AppColors.darkText,
            fontWeight: FontWeight.bold,
          ),
        ),
        // leading: const BackButton(color: AppColors.darkText),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            _buildProfileHeader(
              userProvider.currentUser,
              userProvider.currentUser?.photoURL,
            ),
            const SizedBox(height: 32),

            // Preferences Section
            _buildSectionLabel("PREFERENCES"),
            _buildSettingTile(
              icon: Icons.monetization_on_outlined,
              title: "Currency",
              subtitle: "Standard transaction currency",
              trailingText: _selectedCurrency,
              onTap: _showCurrencyPicker,
            ),
            _buildSettingTile(
              icon: _isDarkMode
                  ? Icons.wb_sunny_outlined
                  : Icons.nightlight_round_outlined,
              title: _isDarkMode ? "Light Mode" : "Dark Mode",
              trailing: Switch(
                value: _isDarkMode,
                onChanged: (val) => setState(() => _isDarkMode = val),
                activeColor: AppColors.primaryBlue,
              ),
            ),

            const SizedBox(height: 24),
            // Notifications Section
            _buildSectionLabel("NOTIFICATIONS"),
            _buildSettingTile(
              icon: Icons.notifications_none_outlined,
              title: "Daily Reminder",
              subtitle: "At ${_reminderTime.format(context)}",
              onTap: _selectTime,
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (val) => setState(() => _notificationsEnabled = val),
                activeColor: AppColors.primaryBlue,
              ),
            ),

            const SizedBox(height: 24),
            // Account Section
            _buildSectionLabel("ACCOUNT"),
            _buildSettingTile(
              icon: Icons.person_outline,
              title: "Edit User Details",
              showArrow: true,
              onTap: () {},
            ),
            _buildSettingTile(
              icon: Icons.lock_outline,
              title: "Change Password",
              showArrow: true,
              onTap: () {},
            ),
            _buildSettingTile(
              icon: Icons.logout,
              title: "Sign Out",
              titleColor: Colors.red,
              iconColor: Colors.red,
              onTap: _showSignOutDialog,
            ),
          ],
        ),
      ),
    );
  }

  // --- REUSABLE COMPONENTS FOR THIS SCREEN ---

  Widget _buildProfileHeader(AppUser? user, String? imageUrl) {
    return Row(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 45,
              backgroundColor: AppColors.border,
              // Keeping the network image as default since we aren't updating the UI yet
              backgroundImage: NetworkImage(
                imageUrl ??
                    'https://th.bing.com/th/id/OIP.lcdOc6CAIpbvYx3XHfoJ0gHaF3?w=188&h=149&c=7&r=0&o=7&dpr=2&pid=1.7&rm=3',
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                height: 32,
                width: 32,
                decoration: const BoxDecoration(
                  color: AppColors.primaryBlue,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  padding: EdgeInsets.zero, // Centers the icon
                  iconSize: 16,
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: () async {
                    await _pickImage();
                    if (_image != null) {
                      final imageURL = await ImageDatabaseServices.uploadImage(
                        image: _image!,
                        userId: user!.uid!,
                      );
                      FirebaseAuth.instance.currentUser?.updatePhotoURL(
                        imageURL['url'],
                      );
                    }
                  }, // Calls the image picker
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${user!.username}",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            Text(
              user.email ?? 'example@gmail.com',
              style: const TextStyle(color: AppColors.secondaryText),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.secondaryText,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    String? trailingText,
    bool showArrow = false,
    Color? iconColor,
    Color? titleColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.primaryBlue).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor ?? AppColors.primaryBlue),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: titleColor ?? AppColors.darkText,
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(fontSize: 12))
          : null,
      trailing:
          trailing ??
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (trailingText != null)
                Text(
                  trailingText,
                  style: const TextStyle(
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              if (showArrow)
                const Icon(Icons.chevron_right, color: AppColors.secondaryText),
            ],
          ),
      onTap: onTap,
    );
  }
}
