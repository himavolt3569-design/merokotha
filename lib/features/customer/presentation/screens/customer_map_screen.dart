import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:merokotha/features/customer/providers/customers_providers.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/models/listing_model.dart';
import '../../../../shared/widgets/mk_widgets.dart';
import '../widgets/customer_widgets.dart';

class CustomerMapScreen extends ConsumerStatefulWidget {
  const CustomerMapScreen({super.key});

  @override
  ConsumerState<CustomerMapScreen> createState() => _CustomerMapScreenState();
}

class _CustomerMapScreenState extends ConsumerState<CustomerMapScreen> {
  GoogleMapController? _mapController;
  ListingModel? _selectedListing;

  static const _kathmandu = LatLng(27.7172, 85.3240);

  Set<Marker> _buildMarkers(List<ListingModel> listings) {
    return listings
        .where((l) => l.geoPoint != null)
        .map(
          (l) => Marker(
            markerId: MarkerId(l.id),
            position: LatLng(l.geoPoint!.latitude, l.geoPoint!.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              l.id == _selectedListing?.id
                  ? BitmapDescriptor.hueViolet
                  : BitmapDescriptor.hueGreen,
            ),
            onTap: () => setState(() => _selectedListing = l),
          ),
        )
        .toSet();
  }

  @override
  Widget build(BuildContext context) {
    final listingsAsync = ref.watch(mapListingsProvider);
    final favIds = ref.watch(favouriteIdsProvider).value ?? [];

    return Scaffold(
      body: Stack(
        children: [
          // ── Map ──
          listingsAsync.when(
            loading: () => const MkLoading(),
            error: (e, _) => MkErrorWidget(message: e.toString()),
            data: (listings) => GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: _kathmandu,
                zoom: 13,
              ),
              markers: _buildMarkers(listings),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              onMapCreated: (c) => _mapController = c,
              onTap: (_) => setState(() => _selectedListing = null),
            ),
          ),

          // ── Top bar ──
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            right: 12,
            child: Row(
              children: [
                // Back
                _MapButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => context.pop(),
                ),
                const SizedBox(width: 8),
                // Search bar
                Expanded(
                  child: GestureDetector(
                    onTap: () => context.go(AppRoutes.search),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.search_rounded,
                            size: 18,
                            color: AppColors.grey400,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Search on map...',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.grey400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // My location
                _MapButton(
                  icon: Icons.my_location_rounded,
                  onTap: () async {
                    _mapController?.animateCamera(
                      CameraUpdate.newLatLng(_kathmandu),
                    );
                  },
                ),
              ],
            ),
          ),

          // ── Listing count badge ──
          listingsAsync.when(
            data: (listings) => Positioned(
              top: MediaQuery.of(context).padding.top + 64,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.customerPrimary,
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.customerPrimary.withOpacity(0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Text(
                    '${listings.length} rooms',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // ── Selected listing bottom sheet ──
          if (_selectedListing != null)
            Positioned(
              bottom: 90,
              left: 12,
              right: 12,
              child: GestureDetector(
                onTap: () => context.push(
                  AppRoutes.roomDetail.replaceAll(':id', _selectedListing!.id),
                ),
                child: Container(
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Photo
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        child: _selectedListing!.photoUrls.isNotEmpty
                            ? Image.network(
                                _selectedListing!.photoUrls.first,
                                width: 72,
                                height: 72,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 72,
                                height: 72,
                                color: AppColors.grey50,
                                child: const Icon(
                                  Icons.image_outlined,
                                  color: AppColors.grey100,
                                ),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedListing!.title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.grey900,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            if (_selectedListing!.address != null)
                              Text(
                                _selectedListing!.address!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.grey400,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            const SizedBox(height: 6),
                            PriceBadge(amount: _selectedListing!.rentPerMonth),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Fav button
                      GestureDetector(
                        onTap: () => ref
                            .read(favouriteProvider.notifier)
                            .toggle(_selectedListing!),
                        child: Icon(
                          favIds.contains(_selectedListing!.id)
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: favIds.contains(_selectedListing!.id)
                              ? AppColors.error
                              : AppColors.grey400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: const CustomerBottomNav(currentIndex: 2),
    );
  }
}

class _MapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _MapButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8),
          ],
        ),
        child: Icon(icon, size: 20, color: AppColors.grey800),
      ),
    );
  }
}
