import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/models/inquiry_model.dart';
import '../../../../shared/models/listing_model.dart';
import '../../../../shared/widgets/mk_widgets.dart';
import '../../../../core/utils/formatters.dart';

// ─────────────────────────── Stats Card ───────────────────────────

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
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.grey50),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.grey900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.grey400),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── Inquiry Card ───────────────────────────

class InquiryCard extends StatelessWidget {
  final InquiryModel inquiry;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final VoidCallback? onTap;

  const InquiryCard({
    super.key,
    required this.inquiry,
    this.onAccept,
    this.onDecline,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                UserAvatar(
                  name: inquiry.customerName,
                  photoUrl: inquiry.customerPhotoUrl,
                  size: 40,
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
                        Formatters.timeAgo(inquiry.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.grey400,
                        ),
                      ),
                    ],
                  ),
                ),
                _statusBadge(inquiry.status),
              ],
            ),

            const SizedBox(height: 10),

            // Room name
            Row(
              children: [
                const Icon(
                  Icons.home_outlined,
                  size: 14,
                  color: AppColors.grey400,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    inquiry.listingTitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.grey600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // Move-in date
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: AppColors.grey400,
                ),
                const SizedBox(width: 4),
                Text(
                  'Move in: ${Formatters.date(inquiry.moveInDate)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.grey600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Message preview
            Text(
              inquiry.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.grey800,
                height: 1.4,
              ),
            ),

            // Action buttons (only for pending)
            if (inquiry.isPending && (onAccept != null || onDecline != null))
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    if (onDecline != null)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onDecline,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                            minimumSize: const Size(0, 38),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusMd,
                              ),
                            ),
                          ),
                          child: const Text(
                            'Decline',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                    if (onAccept != null && onDecline != null)
                      const SizedBox(width: 8),
                    if (onAccept != null)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onAccept,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 38),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusMd,
                              ),
                            ),
                          ),
                          child: const Text(
                            'Accept',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(InquiryStatus status) {
    switch (status) {
      case InquiryStatus.pending:
        return StatusBadge.pending();
      case InquiryStatus.accepted:
        return StatusBadge.accepted();
      case InquiryStatus.declined:
        return StatusBadge.declined();
    }
  }
}

// ─────────────────────────── Facilities Selector ───────────────────────────

const _allFacilities = [
  ('wifi', 'WiFi', Icons.wifi_rounded),
  ('parking', 'Parking', Icons.local_parking_rounded),
  ('water', 'Water', Icons.water_drop_outlined),
  ('electricity', 'Electricity', Icons.bolt_rounded),
  ('kitchen', 'Kitchen', Icons.kitchen_outlined),
  ('laundry', 'Laundry', Icons.local_laundry_service_outlined),
  ('lift', 'Lift', Icons.elevator_outlined),
  ('security', 'Security', Icons.security_outlined),
];

class FacilitiesSelector extends StatefulWidget {
  final List<String> selected;
  final void Function(List<String>) onChanged;

  const FacilitiesSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  State<FacilitiesSelector> createState() => _FacilitiesSelectorState();
}

class _FacilitiesSelectorState extends State<FacilitiesSelector> {
  late List<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.selected);
  }

  void _toggle(String key) {
    setState(() {
      _selected.contains(key) ? _selected.remove(key) : _selected.add(key);
    });
    widget.onChanged(_selected);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _allFacilities.map((f) {
        final isSelected = _selected.contains(f.$1);
        return GestureDetector(
          onTap: () => _toggle(f.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryLight : Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.grey100,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  f.$3,
                  size: 15,
                  color: isSelected ? AppColors.primary : AppColors.grey400,
                ),
                const SizedBox(width: 6),
                Text(
                  f.$2,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? AppColors.primary : AppColors.grey600,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────── Listing Row Card (owner view) ───────────────────────────

class OwnerListingCard extends StatelessWidget {
  final ListingModel listing;
  final VoidCallback? onEdit;
  final VoidCallback? onToggle;
  final VoidCallback? onDelete;

  const OwnerListingCard({
    super.key,
    required this.listing,
    this.onEdit,
    this.onToggle,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.grey50),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo placeholder / image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppSizes.radiusLg),
              topRight: Radius.circular(AppSizes.radiusLg),
            ),
            child: listing.photoUrls.isNotEmpty
                ? Image.network(
                    listing.photoUrls.first,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 140,
                    color: AppColors.grey50,
                    child: const Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 40,
                        color: AppColors.grey100,
                      ),
                    ),
                  ),
          ),

          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + status
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        listing.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.grey900,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _statusBadge(listing.status),
                  ],
                ),

                const SizedBox(height: 6),

                // Price
                PriceBadge(amount: listing.rentPerMonth),

                const SizedBox(height: 12),

                // Action row
                Row(
                  children: [
                    _ActionChip(
                      label: listing.isActive ? 'Pause' : 'Activate',
                      icon: listing.isActive
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: AppColors.warning,
                      onTap: onToggle,
                    ),
                    const SizedBox(width: 8),
                    _ActionChip(
                      label: 'Edit',
                      icon: Icons.edit_outlined,
                      color: AppColors.info,
                      onTap: onEdit,
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        size: 20,
                        color: AppColors.error,
                      ),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
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

  Widget _statusBadge(ListingStatus status) {
    switch (status) {
      case ListingStatus.active:
        return StatusBadge.active();
      case ListingStatus.paused:
        return StatusBadge.paused();
      case ListingStatus.rented:
        return StatusBadge.rented();
    }
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _ActionChip({
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
