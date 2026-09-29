import 'package:flutter/material.dart';
import 'package:pebble_type/core/constants/app_colors.dart';

class PasswordStrength extends StatelessWidget {
  final TextEditingController passwordController;
  const PasswordStrength({super.key, required this.passwordController});

  int _score(String password) {
    int score = 0;
    if (password.length >= 8) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*,.?]'))) score++;
    return score;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: passwordController,
      builder: (context, value, child) {
        final score = _score(value.text);
        final colors = [
          AppColors.error,
          AppColors.error.withValues(alpha: 0.6),
          Color(0xFFBA7517),
          Color(0xFF1D9E75),
        ];
        final labels = [
          '',
          'Weak',
          'Medium — add symbols',
          'Medium',
          'Strong ✓',
        ];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: List.generate(
                4,
                (i) => Expanded(
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                    height: 3,
                    decoration: BoxDecoration(
                      color: i < score ? colors[score - 1] : AppColors.border,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              ),
            ),
            if (score > 0) ...[
              SizedBox(height: 4),
              Text(labels[score], style: TextStyle(color: colors[score - 1])),
            ],
          ],
        );
      },
    );
  }
}
