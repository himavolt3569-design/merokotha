import 'package:flutter/material.dart';
import 'package:merokotha/core/constants/app_colors.dart';
import 'package:merokotha/core/constants/app_sizes.dart';
import 'package:merokotha/shared/models/inquiry_model.dart';
import 'package:merokotha/shared/widgets/mk_button.dart';
import 'package:merokotha/shared/widgets/status_badge.dart';

class InquiryCard extends StatelessWidget {
  final InquiryModel inquiry;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final VoidCallback? onOpenChat;

  const InquiryCard({
    super.key,
    required this.inquiry,
    this.onAccept,
    this.onDecline,
    this.onOpenChat,
  });

  Widget _statusBadge() {
    switch (inquiry.status) {
      case InquiryStatus.pending:
        return StatusBadge.pending();
      case InquiryStatus.accepted:
        return StatusBadge.accepted();
      case InquiryStatus.declined:
        return StatusBadge.declined();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: AppSizes.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primaryLight,
                backgroundImage: inquiry.customerPhotoUrl != null
                    ? NetworkImage(inquiry.customerPhotoUrl!)
                    : null,
                child: inquiry.customerPhotoUrl == null
                    ? Text(
                        inquiry.customerName.isNotEmpty
                            ? inquiry.customerName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      inquiry.customerName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey900,
                      ),
                    ),
                    Text(
                      inquiry.listingTitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.grey400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              _statusBadge(),
            ],
          ),

          if (inquiry.message.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              child: Text(
                inquiry.message,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.grey600,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],

          if (onAccept != null || onDecline != null || onOpenChat != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (onDecline != null) ...[
                  Expanded(
                    child: MkButton(
                      label: 'Decline',
                      onPressed: onDecline,
                      variant: MkButtonVariant.danger,
                      height: 40,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (onAccept != null)
                  Expanded(
                    child: MkButton(
                      label: 'Accept',
                      onPressed: onAccept,
                      height: 40,
                    ),
                  ),
                if (onOpenChat != null)
                  Expanded(
                    child: MkButton(
                      label: 'Open chat',
                      onPressed: onOpenChat,
                      prefixIcon: Icons.chat_bubble_outline_rounded,
                      height: 40,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
