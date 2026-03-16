import 'package:cash_flow/core/constants/appcolors.dart';
import 'package:flutter/material.dart';

class SocialAuthButton extends StatelessWidget {
  final String text;
  final String iconPath; // You would typically use an SVG or Image asset here
  final VoidCallback onPressed;

  const SocialAuthButton({
    super.key,
    required this.text,
    required this.iconPath,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Using icons as placeholders for branding logos
            Icon(
              text.contains('Google') ? Icons.g_mobiledata : Icons.window,
              color: AppColors.darkText,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                color: AppColors.darkText,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
