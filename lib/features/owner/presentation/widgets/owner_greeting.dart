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
          style: const TextStyle(fontSize: 14, color: AppColors.grey400),
        ),
        Text(
          name.split(' ').first,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: AppColors.grey900,
          ),
        ),
      ],
    );
  }
}
