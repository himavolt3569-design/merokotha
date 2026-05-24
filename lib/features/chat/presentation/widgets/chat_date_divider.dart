import 'package:flutter/material.dart';
import 'package:merokotha/core/constants/app_colors.dart';
import 'package:merokotha/core/utils/formatters.dart';

class ChatDateDivider extends StatelessWidget {
  final DateTime date;
  const ChatDateDivider(this.date, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Expanded(child: Divider(color: AppColors.grey100, height: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              Formatters.date(date),
              style: const TextStyle(fontSize: 11, color: AppColors.grey400),
            ),
          ),
          const Expanded(child: Divider(color: AppColors.grey100, height: 1)),
        ],
      ),
    );
  }
}
