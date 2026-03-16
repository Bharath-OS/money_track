import 'package:cash_flow/core/constants/appcolors.dart';
import 'package:flutter/material.dart';

class AppFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;

  const AppFloatingActionButton({
    super.key,
    required this.onPressed,
    this.icon = Icons.add,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: AppColors.primaryBlue,
      shape: const CircleBorder(),
      elevation: 4,
      child: Icon(icon, color: Colors.white, size: 30),
    );
  }
}
