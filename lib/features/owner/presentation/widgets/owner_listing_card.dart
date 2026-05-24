import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:merokotha/core/constants/app_colors.dart';
import 'package:merokotha/core/constants/app_sizes.dart';
import 'package:merokotha/core/router/app_routes.dart';
import 'package:merokotha/shared/models/listing_model.dart';

class OwnerListingCard extends StatelessWidget {
  final ListingModel listing;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const OwnerListingCard({
    super.key,
    required this.listing,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = listing.status == ListingStatus.active;
    final isRented = listing.status == ListingStatus.rented;

    Color statusColor;
    String statusLabel;
    if (isActive) {
      statusColor = AppColors.success;
      statusLabel = 'Active';
    } else if (isRented) {
      statusColor = AppColors.primary;
      statusLabel = 'Rented';
    } else {
      statusColor = AppColors.warning;
      statusLabel = 'Paused';
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.grey50),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSizes.radiusLg),
                ),
                child: listing.photoUrls.isNotEmpty
                    ? Image.network(
                        listing.photoUrls.first,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _PlaceholderImage(),
                      )
                    : _PlaceholderImage(),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  listing.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 13,
                      color: AppColors.grey400,
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        listing.address ?? '',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.grey400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rs ${listing.rentPerMonth.toStringAsFixed(0)}/mo',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    Row(
                      children: [
                        _IconBtn(
                          icon: Icons.visibility_outlined,
                          color: AppColors.info,
                          onTap: () => context.push(
                            AppRoutes.roomDetail.replaceAll(':id', listing.id),
                          ),
                        ),
                        const SizedBox(width: 6),
                        _IconBtn(
                          icon: Icons.edit_outlined,
                          color: AppColors.grey600,
                          onTap: () => context.push(
                            '${AppRoutes.uploadListing}?id=${listing.id}',
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (!isRented)
                          _IconBtn(
                            icon: isActive
                                ? Icons.pause_circle_outline_rounded
                                : Icons.play_circle_outline_rounded,
                            color: isActive
                                ? AppColors.warning
                                : AppColors.success,
                            onTap: onToggle,
                          ),
                        if (!isRented) const SizedBox(width: 6),
                        _IconBtn(
                          icon: Icons.delete_outline_rounded,
                          color: AppColors.error,
                          onTap: onDelete,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      width: double.infinity,
      color: AppColors.grey50,
      child: const Icon(
        Icons.house_outlined,
        size: 48,
        color: AppColors.grey400,
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _IconBtn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}
