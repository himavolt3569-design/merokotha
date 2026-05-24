import 'package:flutter/material.dart';
import 'package:merokotha/core/constants/app_colors.dart';

class PriceBadge extends StatelessWidget {
  final double amount;
  final bool showPerMonth;
  final double fontSize;

  const PriceBadge({
    super.key,
    required this.amount,
    this.showPerMonth = true,
    this.fontSize = 15,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'NPR ${_format(amount)}',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          if (showPerMonth)
            TextSpan(
              text: '/mo',
              style: TextStyle(
                fontSize: fontSize - 3,
                fontWeight: FontWeight.w400,
                color: AppColors.grey400,
              ),
            ),
        ],
      ),
    );
  }

  String _format(double v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }
}
