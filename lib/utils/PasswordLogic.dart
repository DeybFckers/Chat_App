import 'package:flutter/material.dart';


const int kDefaultStrengthLength = 8;

abstract class PasswordStrengthItem{
  Color get statusColor;
  double get widthPerc;
  Widget? get statusWidget => null;

}

enum PasswordStrength implements PasswordStrengthItem {
  weak,
  medium,
  strong,
  secure;

  @override
  Color get statusColor {
    switch (this) {
      case PasswordStrength.weak:
        return Colors.red;
      case PasswordStrength.medium:
        return Colors.orange;
      case PasswordStrength.strong:
        return Colors.green;
      case PasswordStrength.secure:
        return const Color(0xFF0B6C0E);
      default:
        return Colors.red;
    }
  }

  double get widthPerc{
    switch(this){
      case PasswordStrength.weak:
        return 0.15;
      case PasswordStrength.medium:
        return 0.4;
      case PasswordStrength.strong:
        return 0.75;
      case PasswordStrength.secure:
        return 1.0;
    }
  }

  Widget? get statusWidget{
    switch (this){
      case PasswordStrength.weak:
        return const Text('Weak');
      case PasswordStrength.medium:
        return const Text('Medium');
      case PasswordStrength.strong:
        return const Text('Strong');
      case PasswordStrength.secure:
        return Row(
          children: [
            const Text('Secure'),
            const SizedBox(width: 5),
            Icon(Icons.check_circle, color: statusColor)
          ],
        );
      default:
        return null;
    }
  }

  static PasswordStrength? calculate({required String text}){
    if (text.isEmpty){
      return null;
    }
    if (text.length < kDefaultStrengthLength){
      return PasswordStrength.weak;
    }

    var counter = 0;
    if (text.contains(RegExp(r'[a-z]'))) counter++;
    if (text.contains(RegExp(r'[A-Z]'))) counter++;
    if (text.contains(RegExp(r'[0-9]'))) counter++;
    if (text.contains(RegExp(r'[!@#\$%&*()?£\-_=]'))) counter++;

    switch (counter){
      case 1:
        return PasswordStrength.weak;
      case 2:
        return PasswordStrength.medium;
      case 3:
        return PasswordStrength.strong;
      case 4:
        return PasswordStrength.secure;
      default:
        return PasswordStrength.weak;
    }
  }
  static List<Widget> buildInstructionChecklist(String text) {
    final rules = <Map<String, bool>>[
      {
        'At least $kDefaultStrengthLength characters': text.length >= kDefaultStrengthLength,
      },
      {
        'At least 1 lowercase letter': RegExp(r'[a-z]').hasMatch(text),
      },
      {
        'At least 1 uppercase letter': RegExp(r'[A-Z]').hasMatch(text),
      },
      {
        'At least 1 digit': RegExp(r'[0-9]').hasMatch(text),
      },
      {
        'At least 1 special character': RegExp(r'[!@#\$%&*()?£\-_=]').hasMatch(text),
      },
    ];

    return rules.map((rule) {
      final text = rule.keys.first;
      final passed = rule.values.first;
      return Row(
        children: [
          Icon(
            passed ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 18,
            color: passed ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: passed ? Colors.green[800] : Colors.grey[700],
              fontSize: 14,
            ),
          ),
        ],
      );
    }).toList();
  }
}
