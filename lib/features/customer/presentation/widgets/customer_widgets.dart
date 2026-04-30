import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:merokotha/core/constants/app_colors.dart';
import 'package:merokotha/core/constants/app_sizes.dart';
import 'package:merokotha/core/router/app_routes.dart';
import 'package:merokotha/features/chat/providers/chat_providers.dart';
import 'package:merokotha/shared/models/listing_model.dart';
import 'package:merokotha/shared/widgets/mk_widgets.dart';

// ─────────────────────────── Listing Card ───────────────────────────

class ListingCard extends StatelessWidget {
  final ListingModel listing;
  final bool isFavourited;
  final VoidCallback? onFavourite;
  final VoidCallback? onTap;

  const ListingCard({
    super.key,
    required this.listing,
    this.isFavourited = false,
    this.onFavourite,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          onTap ??
          () =>
              context.push(AppRoutes.roomDetail.replaceAll(':id', listing.id)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: AppColors.grey50),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo area
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppSizes.radiusLg),
                    topRight: Radius.circular(AppSizes.radiusLg),
                  ),
                  child: listing.photoUrls.isNotEmpty
                      ? Image.network(
                          listing.photoUrls.first,
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _photoPlaceholder,
                        )
                      : _photoPlaceholder,
                ),
                // Room type badge
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                    ),
                    child: Text(
                      listing.roomTypeLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey800,
                      ),
                    ),
                  ),
                ),
                // Favourite button
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onFavourite,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        isFavourited
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 18,
                        color: isFavourited
                            ? AppColors.error
                            : AppColors.grey400,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Info section
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    listing.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Location
                  if (listing.address != null)
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: AppColors.grey400,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            listing.address!,
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

                  // Price row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PriceBadge(amount: listing.rentPerMonth),
                      Flexible(
                        child: Text(
                          listing.furnishingLabel,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.grey400,
                          ),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget get _photoPlaceholder => Container(
    height: 160,
    color: AppColors.grey50,
    child: const Center(
      child: Icon(Icons.image_outlined, size: 40, color: AppColors.grey100),
    ),
  );
}

// ─────────────────────────── Filter Chip Row ───────────────────────────

class FilterChipRow extends StatelessWidget {
  final String? selectedCategoryId;
  final List<({String id, String name})> categories;
  final void Function(String?) onCategoryChanged;

  const FilterChipRow({
    super.key,
    this.selectedCategoryId,
    required this.categories,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
      child: Row(
        children: [
          _Chip(
            label: 'All',
            isSelected: selectedCategoryId == null,
            onTap: () => onCategoryChanged(null),
          ),
          const SizedBox(width: 8),
          ...categories.map(
            (c) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _Chip(
                label: c.name,
                isSelected: selectedCategoryId == c.id,
                onTap: () =>
                    onCategoryChanged(selectedCategoryId == c.id ? null : c.id),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.grey100,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Colors.white : AppColors.grey600,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────── Facilities Filter Row ───────────────────────────

const _facilityOptions = [
  ('wifi', 'WiFi', Icons.wifi_rounded),
  ('parking', 'Parking', Icons.local_parking_rounded),
  ('water', 'Water', Icons.water_drop_outlined),
  ('electricity', 'Electricity', Icons.bolt_rounded),
  ('kitchen', 'Kitchen', Icons.kitchen_outlined),
  ('laundry', 'Laundry', Icons.local_laundry_service_outlined),
];

class FacilityFilterRow extends StatelessWidget {
  final List<String> selected;
  final void Function(List<String>) onChanged;

  const FacilityFilterRow({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _facilityOptions.map((f) {
        final isOn = selected.contains(f.$1);
        return GestureDetector(
          onTap: () {
            final updated = List<String>.from(selected);
            isOn ? updated.remove(f.$1) : updated.add(f.$1);
            onChanged(updated);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: isOn ? AppColors.customerLight : Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              border: Border.all(
                color: isOn ? AppColors.customerPrimary : AppColors.grey100,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  f.$3,
                  size: 14,
                  color: isOn ? AppColors.customerPrimary : AppColors.grey400,
                ),
                const SizedBox(width: 5),
                Text(
                  f.$2,
                  style: TextStyle(
                    fontSize: 12,
                    color: isOn ? AppColors.customerPrimary : AppColors.grey600,
                    fontWeight: isOn ? FontWeight.w600 : FontWeight.w400,
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

// ─────────────────────────── Price Range Slider ───────────────────────────

class PriceRangeSlider extends StatefulWidget {
  final double? minValue;
  final double? maxValue;
  final void Function(double? min, double? max) onChanged;

  const PriceRangeSlider({
    super.key,
    this.minValue,
    this.maxValue,
    required this.onChanged,
  });

  @override
  State<PriceRangeSlider> createState() => _PriceRangeSliderState();
}

class _PriceRangeSliderState extends State<PriceRangeSlider> {
  static const _min = 0.0;
  static const _max = 100000.0;

  late RangeValues _values;

  @override
  void initState() {
    super.initState();
    _values = RangeValues(widget.minValue ?? _min, widget.maxValue ?? _max);
  }

  String _label(double v) {
    if (v >= 100000) return 'Any';
    if (v >= 1000) return 'NPR ${(v / 1000).toStringAsFixed(0)}K';
    return 'NPR ${v.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _label(_values.start),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.grey800,
              ),
            ),
            Text(
              _label(_values.end),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.grey800,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.customerPrimary,
            inactiveTrackColor: AppColors.grey100,
            thumbColor: AppColors.customerPrimary,
            overlayColor: AppColors.customerLight,
            trackHeight: 3,
          ),
          child: RangeSlider(
            values: _values,
            min: _min,
            max: _max,
            divisions: 100,
            onChanged: (v) {
              setState(() => _values = v);
              widget.onChanged(
                v.start <= _min ? null : v.start,
                v.end >= _max ? null : v.end,
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────── Inquiry Status Tracker ───────────────────────────

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

// ─────────────────────────── Customer Bottom Nav ───────────────────────────

class CustomerBottomNav extends ConsumerWidget {
  final int currentIndex;
  const CustomerBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(totalUnreadProvider).asData?.value ?? 0;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.grey50)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.customerPrimary,
        unselectedItemColor: AppColors.grey400,
        selectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        onTap: (i) {
          switch (i) {
            case 0:
              context.push(AppRoutes.customerHome);
              break;
            case 1:
              context.push(AppRoutes.search);
              break;
            case 2:
              context.push(AppRoutes.chatList);
              break;
            case 3:
              context.push(AppRoutes.favourites);
              break;
            case 4:
              context.push(AppRoutes.customerProfile);
              break;
          }
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search_rounded),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: _ChatBadge(unread: unread, filled: false),
            activeIcon: _ChatBadge(unread: unread, filled: true),
            label: 'Messages',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline_rounded),
            activeIcon: Icon(Icons.favorite_rounded),
            label: 'Saved',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _ChatBadge extends StatelessWidget {
  final int unread;
  final bool filled;
  const _ChatBadge({required this.unread, required this.filled});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          filled
              ? Icons.chat_bubble_rounded
              : Icons.chat_bubble_outline_rounded,
        ),
        if (unread > 0)
          Positioned(
            top: -4,
            right: -6,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                unread > 9 ? '9+' : '$unread',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
