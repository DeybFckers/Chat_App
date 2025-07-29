import 'package:flutter/material.dart';

class AuthField extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final IconData? icon;
  final Widget? suffixIcon;
  final bool isPasswordText;

  const AuthField({
    super.key,
    required this.labelText,
    required this.controller,
    this.icon,
    this.suffixIcon,
    this.isPasswordText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPasswordText,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        labelText: labelText,
        prefixIcon: icon != null ? Icon(icon, color: Colors.grey[700]): null,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0)
        )
      ),
      validator: (value){
        if(value == null || value.isEmpty){
          return "$labelText is missing!";
        }
        if(labelText == 'Email'){
          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
          if(!emailRegex.hasMatch(value)){
            return 'Enter a valid email address';
          }
        }
        if(labelText == "Password"){
          if (value.length < 8) {
            return "Password must be at least 8 characters long";
          }
          if (!RegExp(r'[A-Z]').hasMatch(value)) {
            return "Password must contain at least one uppercase letter";
          }
          if (!RegExp(r'[0-9]').hasMatch(value)) {
            return "Password must contain at least one number";
          }
          if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
            return "Password must include a special character";
          }
        }
        return null;
      },
    );
  }
}

