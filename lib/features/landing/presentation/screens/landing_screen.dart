import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:merokotha/core/router/app_routes.dart';
import 'package:merokotha/features/ads/data/ad_model.dart';
import 'package:merokotha/features/ads/presentation/widgets/ad_banner.dart';
import 'package:merokotha/features/customer/providers/customers_providers.dart';
import 'package:merokotha/shared/models/listing_model.dart';

// Design palette: "Quiet Luxury" — off-white base, deep forest green accent,
// warm stone neutrals. No gradients, no heavy shadows.
class _T {
  static const bg = Color(0xFFF7F6F3); // Warm off-white
  static const surface = Color(0xFFFFFFFF);
  static const accent = Color(0xFF1C4A3A); // Deep forest green
  static const accentMuted = Color(0xFF4A7C6A); // Sage — for tags, icons
  static const stone = Color(0xFF8C8880); // Warm grey — secondary text
  static const ink = Color(0xFF1A1917); // Near-black — primary text
  static const hairline = Color(0xFFE8E5E0); // Warm hairline

  static TextStyle get displayLg => GoogleFonts.cormorantGaramond(
    fontSize: 38,
    fontWeight: FontWeight.w600,
    height: 1.1,
    letterSpacing: -0.5,
    color: ink,
  );

  static TextStyle get labelSm => GoogleFonts.dmSans(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.4,
    color: accentMuted,
  );

  static TextStyle get bodyMd =>
      GoogleFonts.dmSans(fontSize: 13, color: stone, height: 1.5);

  static TextStyle get priceLg => GoogleFonts.cormorantGaramond(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: ink,
    letterSpacing: -0.3,
  );

  static TextStyle get titleMd => GoogleFonts.dmSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: ink,
    letterSpacing: -0.1,
  );

  static const double r = 12.0;
  static const shadow = [
    BoxShadow(color: Color(0x0A1A1917), blurRadius: 16, offset: Offset(0, 4)),
  ];
}

class LandingScreen extends ConsumerStatefulWidget {
  const LandingScreen({super.key});

  @override
  ConsumerState<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends ConsumerState<LandingScreen> {
  String _search = '';
  String? _category;
  bool _isGrid = false;

  @override
  Widget build(BuildContext context) {
    final listingsAsync = ref.watch(activeListingsProvider);

    return Scaffold(
      backgroundColor: _T.bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: _T.bg,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            titleSpacing: 20,
            title: Row(
              children: [
                Text(
                  'MeroKotha',
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                    color: _T.ink,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () => context.go(AppRoutes.login),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: _T.hairline, width: 1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Sign In',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _T.ink,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(width: 20, height: 1.5, color: _T.accentMuted),
                      const SizedBox(width: 8),
                      Text('KATHMANDU & BEYOND', style: _T.labelSm),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text('Find Your\nNext Home\nin Nepal', style: _T.displayLg),
                  const SizedBox(height: 24),
                  _SearchBar(
                    onChanged: (v) => setState(() => _search = v.toLowerCase()),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: _CategoryRow(
              selected: _category,
              onSelect: (c) => setState(() => _category = c),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          const SliverToBoxAdapter(
            child: AdBanner(placement: AdPlacement.landingPage),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 16, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('AVAILABLE ROOMS', style: _T.labelSm),
                  const Spacer(),
                  _ToggleView(
                    isGrid: _isGrid,
                    onToggle: () => setState(() => _isGrid = !_isGrid),
                  ),
                ],
              ),
            ),
          ),

          listingsAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: _T.accent,
                  ),
                ),
              ),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(child: Text('Error: $e', style: _T.bodyMd)),
            ),
            data: (list) {
              final listings = list.where((l) {
                final matchQ =
                    _search.isEmpty || l.title.toLowerCase().contains(_search);
                final matchC = _category == null || l.roomType == _category;
                return matchQ && matchC;
              }).toList();

              if (listings.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          color: _T.stone,
                          size: 40,
                        ),
                        const SizedBox(height: 12),
                        Text('No properties found', style: _T.bodyMd),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                sliver: _isGrid
                    ? SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 14,
                              crossAxisSpacing: 14,
                              childAspectRatio: 0.62,
                            ),
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) => _GridCard(
                            listing: listings[i],
                            onTap: () => context.push(
                              AppRoutes.roomDetail.replaceAll(
                                ':id',
                                listings[i].id,
                              ),
                            ),
                          ),
                          childCount: listings.length,
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _ListCard(
                              listing: listings[i],
                              onTap: () => context.push(
                                AppRoutes.roomDetail.replaceAll(
                                  ':id',
                                  listings[i].id,
                                ),
                              ),
                            ),
                          ),
                          childCount: listings.length,
                        ),
                      ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: _T.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _T.hairline, width: 1),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(Icons.search_rounded, color: _T.stone, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              style: GoogleFonts.dmSans(fontSize: 14, color: _T.ink),
              decoration: InputDecoration(
                hintText: 'Search by location or name…',
                hintStyle: GoogleFonts.dmSans(fontSize: 14, color: _T.stone),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(6),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: _T.accent,
              borderRadius: BorderRadius.circular(7),
            ),
            height: 38,
            alignment: Alignment.center,
            child: Text(
              'Search',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const _roomTypeOptions = [
  ('room', 'Room'),
  ('flat', 'Flat'),
  ('apartment', 'Apartment'),
  ('house', 'House'),
  ('office', 'Office'),
  ('shop', 'Shop'),
  ('land', 'Land'),
  ('other', 'Other'),
];

class _CategoryRow extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onSelect;

  const _CategoryRow({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _Chip(
            label: 'All',
            active: selected == null,
            onTap: () => onSelect(null),
          ),
          ..._roomTypeOptions.map(
            (c) => _Chip(
              label: c.$2,
              active: selected == c.$1,
              onTap: () => onSelect(selected == c.$1 ? null : c.$1),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _Chip({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? _T.accent : _T.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? _T.accent : _T.hairline, width: 1),
        ),
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: active ? Colors.white : _T.stone,
            letterSpacing: 0.1,
          ),
        ),
      ),
    );
  }
}

class _ToggleView extends StatelessWidget {
  final bool isGrid;
  final VoidCallback onToggle;

  const _ToggleView({required this.isGrid, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _T.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _T.hairline, width: 1),
        ),
        child: Icon(
          isGrid ? Icons.format_list_bulleted_rounded : Icons.grid_view_rounded,
          color: _T.accent,
          size: 16,
        ),
      ),
    );
  }
}

class _GridCard extends StatelessWidget {
  final ListingModel listing;
  final VoidCallback onTap;

  const _GridCard({required this.listing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _T.surface,
          borderRadius: BorderRadius.circular(_T.r),
          boxShadow: _T.shadow,
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo
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
                          color: _T.hairline,
                          child: Icon(
                            Icons.home_outlined,
                            color: _T.stone,
                            size: 32,
                          ),
                        ),
                  // Room type badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _T.accent.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        listing.roomTypeLabel.toUpperCase(),
                        style: _T.labelSm.copyWith(
                          color: Colors.white,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info
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
                          style: _T.titleMd,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(
                              Icons.place_outlined,
                              size: 11,
                              color: _T.stone,
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                listing.address ?? 'Nepal',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.dmSans(
                                  fontSize: 11,
                                  color: _T.stone,
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
                              style: _T.priceLg,
                            ),
                            Text(
                              '/month',
                              style: GoogleFonts.dmSans(
                                fontSize: 10,
                                color: _T.stone,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: _T.accent,
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

class _ListCard extends StatelessWidget {
  final ListingModel listing;
  final VoidCallback onTap;

  const _ListCard({required this.listing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _T.surface,
          borderRadius: BorderRadius.circular(_T.r),
          boxShadow: _T.shadow,
        ),
        clipBehavior: Clip.hardEdge,
        child: Row(
          children: [
            // Thumbnail
            SizedBox(
              width: 110,
              height: 110,
              child: listing.photoUrls.isNotEmpty
                  ? Image.network(listing.photoUrls.first, fit: BoxFit.cover)
                  : Container(color: const Color(0xFFE8E5E0)),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      listing.roomTypeLabel.toUpperCase(),
                      style: _T.labelSm.copyWith(fontSize: 9),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      listing.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _T.titleMd,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.place_outlined, size: 11, color: _T.stone),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            listing.address ?? 'Kathmandu',
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              color: _T.stone,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text('Rs. ${listing.rentPerMonth}', style: _T.priceLg),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(
                Icons.chevron_right_rounded,
                color: _T.hairline,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
