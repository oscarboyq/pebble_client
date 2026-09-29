import 'package:flutter/material.dart';
import 'package:pebble_type/core/constants/app_colors.dart';

class StepProgressBar extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  const StepProgressBar({
    super.key,
    required this.totalSteps,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        totalSteps,
        (index) => [
          if (index > 0) SizedBox(width: 4),
          Expanded(
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              height: 3,

              decoration: BoxDecoration(
                color: index + 1 <= currentStep
                    ? AppColors.primary
                    : index + 1 == currentStep + 1
                    ? AppColors.primary.withValues(alpha: 0.3)
                    : AppColors.border,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        ],
      ).expand((e) => e).toList(),
    );
  }
}
