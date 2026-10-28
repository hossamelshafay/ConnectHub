import 'package:flutter/material.dart';
import 'package:connecthub/core/utils/app_theme.dart';

class PasswordStrengthBar extends StatelessWidget {
  final int strength; // 0: none, 1: weak, 2: medium, 3: strong

  const PasswordStrengthBar({
    super.key,
    required this.strength,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 1; i <= 3; i++) ...[
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 3,
              margin: EdgeInsets.only(right: i < 3 ? 6.0 : 0.0),
              decoration: BoxDecoration(
                color: strength >= i
                    ? (strength == 1
                        ? AppColors.error
                        : strength == 2
                            ? AppColors.warning
                            : AppColors.success)
                    : AppColors.glassBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
