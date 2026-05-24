import 'package:flutter/material.dart';
import 'package:merokotha/core/constants/app_colors.dart';
import 'package:merokotha/core/constants/app_sizes.dart';

/// Horizontal rule used between content sections.
class MkDivider extends StatelessWidget {
  const MkDivider({super.key});

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: AppSizes.md),
    child: Divider(height: 1, color: AppColors.grey50),
  );
}

/// Bold section heading with optional accent bar on the left.
class MkSectionTitle extends StatelessWidget {
  final String text;
  final bool showAccent;
  final Color? accentColor;

  const MkSectionTitle(
    this.text, {
    super.key,
    this.showAccent = false,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    if (!showAccent) {
      return Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.grey900,
        ),
      );
    }

    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: accentColor ?? AppColors.primary,
            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.grey900,
          ),
        ),
      ],
    );
  }
}
