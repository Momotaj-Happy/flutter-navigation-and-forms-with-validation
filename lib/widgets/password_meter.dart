import 'package:flutter/material.dart';

class PasswordStrengthMeter extends StatelessWidget {
  final double strength;

  const PasswordStrengthMeter({Key? key, required this.strength}) : super(key: key);

  Color get _color {
    if (strength <= 0.25) return Colors.red;
    if (strength <= 0.50) return Colors.orange;
    if (strength <= 0.75) return Colors.amber;
    return Colors.green;
  }

  String get _label {
    if (strength <= 0.25) return 'Weak';
    if (strength <= 0.50) return 'Fair';
    if (strength <= 0.75) return 'Good';
    return 'Strong';
  }

  @override
  Widget build(BuildContext context) {
    if (strength == 0.0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: strength,
                color: _color,
                backgroundColor: Colors.grey[200],
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _label,
            style: TextStyle(color: _color, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }
}