import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:merokotha/features/landing/presentation/widgets/landing_theme.dart';
import 'package:merokotha/shared/models/listing_model.dart';

class LandingGridCard extends StatelessWidget {
  final ListingModel listing;
  final VoidCallback onTap;

  const LandingGridCard({super.key, required this.listing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: LandingTheme.surface,
          borderRadius: BorderRadius.circular(LandingTheme.r),
          boxShadow: LandingTheme.shadow,
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  listing.photoUrls.isNotEmpty
                      ? Image.network(
                          listing.photoUrls.first,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        )
                      : Container(
                          color: LandingTheme.hairline,
                          child: Icon(
                            Icons.home_outlined,
                            color: LandingTheme.stone,
                            size: 32,
                          ),
                        ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: LandingTheme.accent.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        listing.roomTypeLabel.toUpperCase(),
                        style: LandingTheme.labelSm.copyWith(
                          color: Colors.white,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
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
                          style: LandingTheme.titleMd,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(
                              Icons.place_outlined,
                              size: 11,
                              color: LandingTheme.stone,
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                listing.address ?? 'Nepal',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.dmSans(
                                  fontSize: 11,
                                  color: LandingTheme.stone,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rs. ${listing.rentPerMonth}',
                              style: LandingTheme.priceLg,
                            ),
                            Text(
                              '/month',
                              style: GoogleFonts.dmSans(
                                fontSize: 10,
                                color: LandingTheme.stone,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: LandingTheme.accent,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 14,
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
}

class LandingListCard extends StatelessWidget {
  final ListingModel listing;
  final VoidCallback onTap;

  const LandingListCard({super.key, required this.listing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final price = listing.rentPerMonth.toInt();
    final amenities = listing.facilities.take(3).join(' · ');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: LandingTheme.surface,
          borderRadius: BorderRadius.circular(LandingTheme.r),
          boxShadow: LandingTheme.shadow,
        ),
        clipBehavior: Clip.hardEdge,
        child: Row(
          children: [
            SizedBox(
              width: 120,
              height: 110,
              child: listing.photoUrls.isNotEmpty
                  ? Image.network(
                      listing.photoUrls.first,
                      fit: BoxFit.cover,
                    )
                  : Container(color: const Color(0xFFE8E5E0)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          listing.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: LandingTheme.titleMd,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          listing.address ?? 'Kathmandu',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: LandingTheme.stone,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              'Rs. ${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                              style: LandingTheme.priceLg,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '/month',
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                color: LandingTheme.stone,
                              ),
                            ),
                          ],
                        ),
                        if (amenities.isNotEmpty) ...[
                          const SizedBox(height: 5),
                          Text(
                            amenities,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              color: LandingTheme.stone,
                            ),
                          ),
                        ],
                      ],
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Icon(
                        Icons.favorite_border_rounded,
                        size: 18,
                        color: LandingTheme.stone,
                      ),
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
}
