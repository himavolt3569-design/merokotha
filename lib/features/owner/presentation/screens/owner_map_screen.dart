import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:merokotha/shared/widgets/owner_botton_nav.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/models/listing_model.dart';
import '../../../../shared/widgets/mk_widgets.dart';
import '../../providers/owner_providers.dart';

class OwnerMapScreen extends ConsumerStatefulWidget {
  const OwnerMapScreen({super.key});

  @override
  ConsumerState<OwnerMapScreen> createState() => _OwnerMapScreenState();
}

class _OwnerMapScreenState extends ConsumerState<OwnerMapScreen> {
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
                  ? BitmapDescriptor.hueAzure
                  : BitmapDescriptor.hueGreen,
            ),
            infoWindow: InfoWindow(title: l.title),
            onTap: () => setState(() => _selectedListing = l),
          ),
        )
        .toSet();
  }

  @override
  Widget build(BuildContext context) {
    final listingsAsync = ref.watch(ownerListingsProvider);

    return Scaffold(
      body: Stack(
        children: [
          // ── Map ──
          listingsAsync.when(
            loading: () => const MkLoading(),
            error: (e, _) => MkErrorWidget(message: e.toString()),
            data: (listings) {
              final withLocation = listings
                  .where((l) => l.geoPoint != null)
                  .toList();

              // Auto-fit camera to markers on first load
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_mapController != null && withLocation.isNotEmpty) {
                  final bounds = _boundsFromLatLngList(
                    withLocation
                        .map(
                          (l) => LatLng(
                            l.geoPoint!.latitude,
                            l.geoPoint!.longitude,
                          ),
                        )
                        .toList(),
                  );
                  _mapController!.animateCamera(
                    CameraUpdate.newLatLngBounds(bounds, 80),
                  );
                }
              });

              return GoogleMap(
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
              );
            },
          ),

          // ── Top bar ──
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            right: 12,
            child: Row(
              children: [
                _MapBtn(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => context.pop(),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
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
                          Icons.house_rounded,
                          size: 16,
                          color: AppColors.ownerPrimary,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'My listing locations',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.grey800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _MapBtn(
                  icon: Icons.add_location_alt_outlined,
                  onTap: () => context.go(AppRoutes.uploadListing),
                ),
              ],
            ),
          ),

          // ── Listing count pill ──
          listingsAsync.when(
            data: (listings) {
              final count = listings.where((l) => l.geoPoint != null).length;
              return Positioned(
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
                      color: AppColors.ownerPrimary,
                      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.ownerPrimary.withOpacity(0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Text(
                      count == 0
                          ? 'No pinned listings'
                          : '$count listing${count == 1 ? '' : 's'} on map',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // ── No listings hint ──
          listingsAsync.when(
            data: (listings) {
              final noPins = listings.every((l) => l.geoPoint == null);
              if (!noPins) return const SizedBox.shrink();
              return Positioned(
                bottom: 100,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.add_location_alt_outlined,
                        size: 32,
                        color: AppColors.grey400,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'No listing locations yet',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.grey800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'When you add a listing with a map pin, it will appear here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.grey400,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 42,
                        child: ElevatedButton(
                          onPressed: () => context.go(AppRoutes.uploadListing),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.ownerPrimary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusMd,
                              ),
                            ),
                          ),
                          child: const Text('Add listing'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // ── Selected listing card ──
          if (_selectedListing != null)
            Positioned(
              bottom: 90,
              left: 12,
              right: 12,
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
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 64,
                              height: 64,
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
                          PriceBadge(amount: _selectedListing!.rentPerMonth),
                          const SizedBox(height: 4),
                          _statusBadge(_selectedListing!.status),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      children: [
                        // Edit pin location
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: AppColors.grey50,
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusMd,
                              ),
                            ),
                            child: const Icon(
                              Icons.edit_location_alt_outlined,
                              size: 16,
                              color: AppColors.grey600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: const OwnerBottomNav(currentIndex: 4),
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

  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double? minLat, maxLat, minLng, maxLng;
    for (final p in list) {
      if (minLat == null || p.latitude < minLat) minLat = p.latitude;
      if (maxLat == null || p.latitude > maxLat) maxLat = p.latitude;
      if (minLng == null || p.longitude < minLng) minLng = p.longitude;
      if (maxLng == null || p.longitude > maxLng) maxLng = p.longitude;
    }
    return LatLngBounds(
      southwest: LatLng(minLat!, minLng!),
      northeast: LatLng(maxLat!, maxLng!),
    );
  }
}

class _MapBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _MapBtn({required this.icon, required this.onTap});

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
