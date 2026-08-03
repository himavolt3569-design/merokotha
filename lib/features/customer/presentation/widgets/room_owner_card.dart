import 'package:flutter/material.dart';
import 'package:merokotha/core/constants/app_colors.dart';
import 'package:merokotha/core/constants/app_sizes.dart';
import 'package:merokotha/shared/models/listing_model.dart';
import 'package:merokotha/shared/widgets/mk_widgets.dart';

class RoomOwnerCard extends StatelessWidget {
  final ListingModel listing;
  const RoomOwnerCard({super.key, required this.listing});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSizes.md),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
    ),
    child: Row(
      children: [
        UserAvatar(
          name: listing.ownerName,
          photoUrl: listing.ownerPhotoUrl,
          size: 44,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              listing.ownerName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.grey900,
              ),
            ),
            const Text(
              'House Owner',
              style: TextStyle(fontSize: 12, color: AppColors.grey400),
            ),
          ],
        ),
      ],
    ),
  );
}
