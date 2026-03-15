import 'package:flutter/material.dart';

import '../constants/appcolors.dart';

class AppButtons {
  static ElevatedButton primaryButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xff345DEB),
        foregroundColor: Colors.white,
        padding: EdgeInsetsGeometry.symmetric(vertical: 18,horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      onPressed: onTap,
      child: Text(text, style: TextStyle(fontSize: 18)),
    );
  }

  static ElevatedButton googleAuthButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: AppColors.background,
        padding: EdgeInsetsGeometry.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      onPressed: onTap,
      child: Text(text, style: TextStyle(fontSize: 18)),
    );
  }
}

class User{
  static String username = '';
  static String email = '';
}

class AppTextFields{
  static Widget authInputField({
    required String hintText,
    TextEditingController? controller,
    bool isObscure = false,
    bool isEmail = false
  }) {
    return TextFormField(
      obscureText: isObscure,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }else if(isEmail){
          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
          if (!emailRegex.hasMatch(value.trim())) {
            return 'Enter a valid email';
          }
        }
        return null;
      },
      style: TextStyle(color: Colors.white),
      cursorColor: AppColors.greyTextColor,
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Color(0xff192727),
        hintText: hintText,
        hintStyle: TextStyle(color: Color(0xff6A7878)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.white, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Color(0xff6A7878), width: 3),
        ),
      ),
    );
  }
}
