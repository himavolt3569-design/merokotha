import 'package:flutter/material.dart';
import 'package:merokotha/core/constants/app_colors.dart';

class InquiryStatusTracker extends StatelessWidget {
  final String status; // pending / accepted / declined

  const InquiryStatusTracker({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final steps = ['Sent', 'Pending', 'Response'];
    final activeIndex = status == 'pending'
        ? 1
        : status == 'accepted' || status == 'declined'
        ? 2
        : 0;

    return Row(
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          final lineActive = (i ~/ 2) < activeIndex;
          return Expanded(
            child: Container(
              height: 2,
              color: lineActive ? AppColors.primary : AppColors.grey100,
            ),
          );
        }
        final stepIndex = i ~/ 2;
        final isDone = stepIndex < activeIndex;
        final isActive = stepIndex == activeIndex;
        final isDeclined = status == 'declined' && stepIndex == activeIndex;
        return Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDeclined
                      ? AppColors.errorLight
                      : isDone || isActive
                      ? AppColors.primary
                      : AppColors.grey50,
                  border: Border.all(
                    color: isDeclined
                        ? AppColors.error
                        : isDone || isActive
                        ? AppColors.primary
                        : AppColors.grey100,
                  ),
                ),
                child: Icon(
                  isDeclined
                      ? Icons.close_rounded
                      : isDone || isActive
                      ? Icons.check_rounded
                      : Icons.circle_outlined,
                  size: 14,
                  color: isDeclined
                      ? AppColors.error
                      : isDone || isActive
                      ? Colors.white
                      : AppColors.grey400,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                stepIndex == 2
                    ? (status == 'accepted'
                          ? 'Accepted'
                          : status == 'declined'
                          ? 'Declined'
                          : 'Response')
                    : steps[stepIndex],
                style: TextStyle(
                  fontSize: 10,
                  color: isActive || isDone
                      ? AppColors.grey800
                      : AppColors.grey400,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      }),
    );
  }
}
