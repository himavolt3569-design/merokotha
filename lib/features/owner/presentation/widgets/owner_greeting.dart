import 'package:flutter/material.dart';
import 'package:merokotha/core/constants/app_colors.dart';

class OwnerGreeting extends StatelessWidget {
  final String name;
  const OwnerGreeting({super.key, required this.name});

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$_greeting,',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.grey600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          name.split(' ').first,
          style: const TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
            color: AppColors.grey900,
          ),
        ),
      ],
    );
  }
}
