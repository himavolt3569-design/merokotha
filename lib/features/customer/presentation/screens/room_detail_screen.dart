import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import 'package:merokotha/core/constants/app_colors.dart';
import 'package:merokotha/core/constants/app_sizes.dart';
import 'package:merokotha/core/router/app_routes.dart';
import 'package:merokotha/core/utils/formatters.dart';
import 'package:merokotha/features/auth/providers/auth_provider.dart';
import 'package:merokotha/features/customer/providers/customers_providers.dart';
import 'package:merokotha/shared/models/listing_model.dart';
import 'package:merokotha/shared/widgets/mk_widgets.dart';
import 'package:merokotha/features/ads/data/ad_model.dart';
import 'package:merokotha/features/ads/presentation/widgets/ad_banner.dart';

class RoomDetailScreen extends ConsumerStatefulWidget {
  final String listingId;
  const RoomDetailScreen({super.key, required this.listingId});

  @override
  ConsumerState<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends ConsumerState<RoomDetailScreen> {
  int _photoIndex = 0;

  @override
  Widget build(BuildContext context) {
    final listingAsync = ref.watch(listingDetailProvider(widget.listingId));
    final isFav = ref.watch(isListingFavouritedProvider(widget.listingId));
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: listingAsync.when(
        loading: () => const MkLoading(),
        error: (e, _) => MkErrorWidget(message: e.toString()),
        data: (listing) {
          if (listing == null) {
            return const MkErrorWidget(message: 'Listing not found');
          }
          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // Photo carousel
                  SliverToBoxAdapter(
                    child: _PhotoSection(
                      listing: listing,
                      currentIndex: _photoIndex,
                      onPageChanged: (i) => setState(() => _photoIndex = i),
                      isFavourited: isFav,
                      onFavourite: () =>
                          ref.read(favouriteProvider.notifier).toggle(listing),
                      onBack: () => context.pop(),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.pagePadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title + type badge
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  listing.title,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.grey900,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.customerLight,
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.radiusFull,
                                  ),
                                ),
                                child: Text(
                                  listing.roomTypeLabel,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.customerPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Location
                          if (listing.address != null)
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 14,
                                  color: AppColors.grey400,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    listing.address!,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.grey400,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                          const SizedBox(height: 16),

                          // Price + floor/furnishing
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  PriceBadge(
                                    amount: listing.rentPerMonth,
                                    fontSize: 20,
                                  ),
                                  if (listing.depositAmount > 0)
                                    Text(
                                      'Deposit: ${Formatters.npr(listing.depositAmount)}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.grey400,
                                      ),
                                    ),
                                ],
                              ),
                              const Spacer(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Floor ${listing.floor}/${listing.totalFloors}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.grey600,
                                    ),
                                  ),
                                  Text(
                                    listing.furnishingLabel,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.grey600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          _Divider(),

                          // Available from
                          _InfoRow(
                            icon: Icons.calendar_today_outlined,
                            label: 'Available from',
                            value: Formatters.date(listing.availableFrom),
                          ),

                          _Divider(),

                          // Facilities
                          if (listing.facilities.isNotEmpty) ...[
                            const _SectionTitle('Facilities'),
                            const SizedBox(height: 10),
                            _FacilitiesGrid(listing.facilities),
                            const SizedBox(height: 16),
                            _Divider(),
                          ],

                          // Description
                          const _SectionTitle('About this room'),
                          const SizedBox(height: 8),
                          Text(
                            listing.description,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.grey600,
                              height: 1.6,
                            ),
                          ),

                          const SizedBox(height: 20),
                          _Divider(),

                          // Owner card
                          const _SectionTitle('Listed by'),
                          const SizedBox(height: 10),
                          _OwnerCard(listing: listing),

                          const SizedBox(height: 20),
                          _Divider(),

                          // Map preview (flutter_map static)
                          if (listing.geoPoint != null) ...[
                            const _SectionTitle('Location'),
                            const SizedBox(height: 10),
                            if (listing.nearbyLandmarks != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.near_me_outlined,
                                      size: 14,
                                      color: AppColors.grey400,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        listing.nearbyLandmarks!,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.grey500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            _StaticMapPreview(
                              lat: listing.geoPoint!.latitude,
                              lng: listing.geoPoint!.longitude,
                            ),
                            const SizedBox(height: 20),
                            _Divider(),
                          ],

                          // Stats
                          Row(
                            children: [
                              const Icon(
                                Icons.visibility_outlined,
                                size: 14,
                                color: AppColors.grey400,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${listing.viewCount} views',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.grey400,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Icon(
                                Icons.access_time_rounded,
                                size: 14,
                                color: AppColors.grey400,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Listed ${Formatters.timeAgo(listing.createdAt)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.grey400,
                                ),
                              ),
                            ],
                          ),

                          // ── Ad banner after stats ──
                          const AdBanner(
                            placement: AdPlacement.roomDetail,
                            padding: EdgeInsets.symmetric(vertical: 8),
                          ),

                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Bottom CTA
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _BottomCTA(listing: listing, userAsync: userAsync),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Static map preview with flutter_map ───────────────────────────

class _StaticMapPreview extends StatelessWidget {
  final double lat;
  final double lng;
  const _StaticMapPreview({required this.lat, required this.lng});

  @override
  Widget build(BuildContext context) {
    final point = LatLng(lat, lng);
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: SizedBox(
        height: 180,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: point,
            initialZoom: 15,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.none,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.merokotha.app',
              maxZoom: 19,
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: point,
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.location_on_rounded,
                    size: 40,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────

class _PhotoSection extends StatelessWidget {
  final ListingModel listing;
  final int currentIndex;
  final void Function(int) onPageChanged;
  final bool isFavourited;
  final VoidCallback onFavourite;
  final VoidCallback onBack;

  const _PhotoSection({
    required this.listing,
    required this.currentIndex,
    required this.onPageChanged,
    required this.isFavourited,
    required this.onFavourite,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final photos = listing.photoUrls;
    return Stack(
      children: [
        SizedBox(
          height: 280,
          child: photos.isNotEmpty
              ? PageView.builder(
                  itemCount: photos.length,
                  onPageChanged: onPageChanged,
                  itemBuilder: (_, i) => Image.network(
                    photos[i],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => _placeholder,
                  ),
                )
              : _placeholder,
        ),
        // Dot indicators
        if (photos.length > 1)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                photos.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: i == currentIndex ? 16 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: i == currentIndex
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  ),
                ),
              ),
            ),
          ),
        // Back
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 12,
          child: _CircleBtn(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: onBack,
          ),
        ),
        // Fav
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          right: 12,
          child: _CircleBtn(
            icon: isFavourited
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            iconColor: isFavourited ? AppColors.error : AppColors.grey600,
            onTap: onFavourite,
          ),
        ),
      ],
    );
  }

  Widget get _placeholder => Container(
    height: 280,
    color: AppColors.grey50,
    child: const Center(
      child: Icon(Icons.image_outlined, size: 64, color: AppColors.grey100),
    ),
  );
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;
  const _CircleBtn({required this.icon, required this.onTap, this.iconColor});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6),
        ],
      ),
      child: Icon(icon, size: 18, color: iconColor ?? AppColors.grey700),
    ),
  );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 16),
    child: Divider(height: 1, color: AppColors.grey50),
  );
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      color: AppColors.grey900,
    ),
  );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Icon(icon, size: 16, color: AppColors.grey400),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.grey400),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.grey800,
          ),
        ),
      ],
    ),
  );
}

const _facilityIcons = <String, IconData>{
  'wifi': Icons.wifi_rounded,
  'parking': Icons.local_parking_rounded,
  'water': Icons.water_drop_outlined,
  'electricity': Icons.bolt_rounded,
  'kitchen': Icons.kitchen_outlined,
  'laundry': Icons.local_laundry_service_outlined,
  'lift': Icons.elevator_outlined,
  'security': Icons.security_outlined,
};

class _FacilitiesGrid extends StatelessWidget {
  final List<String> facilities;
  const _FacilitiesGrid(this.facilities);

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: facilities.map((f) {
      final icon = _facilityIcons[f] ?? Icons.check_circle_outlined;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.grey50,
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.grey600),
            const SizedBox(width: 5),
            Text(
              f[0].toUpperCase() + f.substring(1),
              style: const TextStyle(fontSize: 12, color: AppColors.grey700),
            ),
          ],
        ),
      );
    }).toList(),
  );
}

class _OwnerCard extends StatelessWidget {
  final ListingModel listing;
  const _OwnerCard({required this.listing});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSizes.md),
    decoration: BoxDecoration(
      color: AppColors.grey50,
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

class _BottomCTA extends ConsumerWidget {
  final ListingModel listing;
  final AsyncValue userAsync;
  const _BottomCTA({required this.listing, required this.userAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Container(
    padding: EdgeInsets.fromLTRB(
      AppSizes.pagePadding,
      AppSizes.md,
      AppSizes.pagePadding,
      MediaQuery.of(context).padding.bottom + AppSizes.md,
    ),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(color: AppColors.grey50)),
    ),
    child: Row(
      children: [
        // Share
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.grey100),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          child: const Icon(
            Icons.share_outlined,
            size: 20,
            color: AppColors.grey600,
          ),
        ),
        const SizedBox(width: 12),
        // Inquire
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                final user = userAsync.asData?.value;
                if (user == null) return;
                context.push(
                  AppRoutes.inquire.replaceAll(':id', listing.id),
                  extra: listing,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.customerPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
              ),
              icon: const Icon(Icons.message_outlined, size: 18),
              label: const Text(
                'Message owner',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
