import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/models/listing_model.dart';
import '../../../../shared/models/inquiry_model.dart';

// ── UserAvatar ────────────────────────────────────────────────────────────────
class UserAvatar extends StatelessWidget {
  final String name;
  final String? photoUrl;
  final double size;

  const UserAvatar({
    super.key,
    required this.name,
    this.photoUrl,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: AppColors.primaryLight,
      backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
      child: photoUrl == null
          ? Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(
                fontSize: size * 0.4,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            )
          : null,
    );
  }
}

// ── StatsCard ─────────────────────────────────────────────────────────────────
class StatsCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const StatsCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.grey50),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.grey400,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── OwnerListingCard ──────────────────────────────────────────────────────────
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
          // Thumbnail
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
              // Status badge
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

          // Details
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
                    // Action buttons
                    Row(
                      children: [
                        // View
                        _IconBtn(
                          icon: Icons.visibility_outlined,
                          color: AppColors.info,
                        onTap: () => context.push(
  AppRoutes.roomDetail.replaceAll(':id', listing.id),
),
                        ),
                        const SizedBox(width: 6),
                        // Edit
                        _IconBtn(
                          icon: Icons.edit_outlined,
                          color: AppColors.grey600,
                        onTap: () => context.push(
                            '${AppRoutes.uploadListing}?id=${listing.id}',
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Toggle (hide if rented)
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
                        // Delete
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

  const _IconBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}

// ── InquiryCard ───────────────────────────────────────────────────────────────
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.grey50),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
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
              // Status chip
              _StatusChip(status: inquiry.status),
            ],
          ),

          // Message
          if (inquiry.message.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              inquiry.message,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.grey600,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          // Action buttons
          if (onAccept != null || onDecline != null || onOpenChat != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (onDecline != null) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onDecline,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusMd,
                          ),
                        ),
                      ),
                      child: const Text(
                        'Decline',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (onAccept != null)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusMd,
                          ),
                        ),
                      ),
                      child: const Text(
                        'Accept',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                if (onOpenChat != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onOpenChat,
                      icon: const Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 15,
                      ),
                      label: const Text(
                        'Open chat',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusMd,
                          ),
                        ),
                      ),
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

class _StatusChip extends StatelessWidget {
  final InquiryStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case InquiryStatus.pending:
        color = AppColors.warning;
        label = 'Pending';
        break;
      case InquiryStatus.accepted:
        color = AppColors.success;
        label = 'Accepted';
        break;
      case InquiryStatus.declined:
        color = AppColors.error;
        label = 'Declined';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── FacilitiesSelector ────────────────────────────────────────────────────────
class FacilitiesSelector extends StatefulWidget {
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;
  const FacilitiesSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  State<FacilitiesSelector> createState() => _FacilitiesSelectorState();
}

class _FacilitiesSelectorState extends State<FacilitiesSelector> {
  static const _options = [
    'WiFi',
    'Parking',
    'Water',
    'Electricity',
    'Kitchen',
    'Laundry',
    'Security',
    'Lift',
    'CCTV',
    'Generator',
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _options.map((f) {
        final selected = widget.selected.contains(f);
        return FilterChip(
          label: Text(f),
          selected: selected,
          onSelected: (_) {
            final updated = [...widget.selected];
            selected ? updated.remove(f) : updated.add(f);
            widget.onChanged(updated);
          },
          selectedColor: AppColors.primaryLight,
          checkmarkColor: AppColors.primary,
          labelStyle: TextStyle(
            fontSize: 12,
            color: selected ? AppColors.primary : AppColors.grey600,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
          side: BorderSide(
            color: selected ? AppColors.primary : AppColors.grey100,
          ),
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 4),
        );
      }).toList(),
    );
  }
}
