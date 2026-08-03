import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:merokotha/core/constants/app_colors.dart';
import 'package:merokotha/core/constants/app_sizes.dart';
import 'package:merokotha/core/router/app_routes.dart';
import 'package:merokotha/core/utils/formatters.dart';
import 'package:merokotha/features/auth/providers/auth_provider.dart';
import 'package:merokotha/features/customer/providers/customers_providers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:merokotha/shared/models/listing_model.dart';
import 'package:merokotha/shared/widgets/login_sheet.dart';
import 'package:merokotha/shared/widgets/shimmer_loading.dart';

class MoreRoomsSection extends ConsumerWidget {
  final String excludeListingId;

  const MoreRoomsSection({super.key, required this.excludeListingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final similarAsync = ref.watch(similarListingsProvider(excludeListingId));
    final userAsync = ref.watch(currentUserProvider);

    return similarAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (listings) {
        if (listings.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      'More rooms for you',
                      style: GoogleFonts.dmSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.grey900,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  Text(
                    '${listings.length} found',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppColors.grey400,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.67,
                ),
                itemCount: listings.length,
                itemBuilder: (ctx, i) {
                  final listing = listings[i];
                  final isFav = ref.watch(
                    isListingFavouritedProvider(listing.id),
                  );
                  return _RoomGridCard(
                    listing: listing,
                    isFav: isFav,
                    onFavourite: () {
                      if (userAsync.asData?.value == null) {
                        showLoginSheet(context);
                        return;
                      }
                      ref.read(favouriteProvider.notifier).toggle(listing);
                    },
                    onTap: () => context.push(
                      AppRoutes.roomDetail.replaceAll(':id', listing.id),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── 2x2 grid card ─────────────────────────────────────────────────────────────

class _RoomGridCard extends StatelessWidget {
  final ListingModel listing;
  final bool isFav;
  final VoidCallback onFavourite;
  final VoidCallback onTap;

  const _RoomGridCard({
    required this.listing,
    required this.isFav,
    required this.onFavourite,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppSizes.shadowCard,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo with rounded top corners
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: listing.photoUrls.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: listing.photoUrls.first,
                            fit: BoxFit.cover,
                            placeholder: (_, _) =>
                                ShimmerLoading(child: ShimmerBox(borderRadius: BorderRadius.zero)),
                            errorWidget: (_, _, _) => _placeholder,
                          )
                        : _placeholder,
                  ),

                  // Room type badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        listing.roomTypeLabel,
                        style: GoogleFonts.dmSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: AppColors.grey900,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),

                  // Favourite button
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: onFavourite,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x14000000),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Icon(
                          isFav
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 15,
                          color: isFav ? AppColors.error : AppColors.grey400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Info section
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          listing.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.grey900,
                            letterSpacing: -0.1,
                          ),
                        ),
                        if (listing.address != null) ...[
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(
                                Icons.place_outlined,
                                size: 10,
                                color: AppColors.grey400,
                              ),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  listing.address!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 10,
                                    color: AppColors.grey400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Formatters.npr(listing.rentPerMonth),
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.grey900,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              Text(
                                '/month',
                                style: GoogleFonts.dmSans(
                                  fontSize: 9,
                                  color: AppColors.grey400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: AppColors.customerPrimary,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 13,
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
      ),
    );
  }

  Widget get _placeholder => Container(
        color: AppColors.backgroundSecondary,
        child: const Center(
          child: Icon(
            Icons.home_outlined,
            size: 28,
            color: AppColors.grey200,
          ),
        ),
      );
}
