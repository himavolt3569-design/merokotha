import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:merokotha/core/router/app_routes.dart';
import 'package:merokotha/features/customer/providers/customers_providers.dart';
import 'package:merokotha/shared/models/listing_model.dart';

// ─── ENHANCED DESIGN TOKENS ─────────────────────────────────────────────

class _T {
  static const bg = Color(0xFFF9FAFB);
  static const surface = Colors.white;
  static const primary = Color(0xFF10B981); // Vibrant Emerald
  static const primaryDark = Color(0xFF065F46); // Amber for prices/ratings
  static const textMain = Color(0xFF111827);
  static const textSub = Color(0xFF6B7280);
  static const border = Color(0xFFE5E7EB);

  static const double radius = 16.0;
  static const shadow = [BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 4))];
}

// ─── ENHANCED MAIN SCREEN ─────────────────────────────────────────────

class LandingScreen extends ConsumerStatefulWidget {
  const LandingScreen({super.key});

  @override
  ConsumerState<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends ConsumerState<LandingScreen> {
  String _search = '';
  String? _category;
  bool _isGrid = true;

  @override
  Widget build(BuildContext context) {
    final listingsAsync = ref.watch(activeListingsProvider);

    return Scaffold(
      backgroundColor: _T.bg,
      body: CustomScrollView(
        slivers: [
          // 1. Sticky Modern Navbar
          SliverAppBar(
            floating: true,
            backgroundColor: _T.bg.withOpacity(0.8),
            elevation: 0,
            title: Text(
              "MeroKotha",
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: _T.primaryDark, letterSpacing: -0.5),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: TextButton.icon(
                  onPressed: () => context.go(AppRoutes.login),
                  icon: const Icon(Icons.account_circle_outlined, size: 20),
                  label: const Text("Sign In"),
                  style: TextButton.styleFrom(foregroundColor: _T.primaryDark),
                ),
              ),
            ],
          ),

          // 2. Dynamic Hero & Search Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Find Your Next\nHome in Nepal",
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      color: _T.textMain,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _EnhancedSearchBar(onChanged: (v) => setState(() => _search = v.toLowerCase())),
                ],
              ),
            ),
          ),

          // 3. Horizontal Categories
          SliverToBoxAdapter(
            child: _FilterRow(
              listingsAsync: listingsAsync,
              selected: _category,
              onSelect: (c) => setState(() => _category = c),
            ),
          ),

          // 4. Results Header
          SliverToBoxAdapter(
            child: _Header(isGrid: _isGrid, onToggle: () => setState(() => _isGrid = !_isGrid)),
          ),

          // 5. Responsive Grid/List
          listingsAsync.when(
            loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
            error: (e, _) => SliverFillRemaining(child: Center(child: Text("Error: $e"))),
            data: (list) {
              final listings = list.where((l) {
                final matchQ = _search.isEmpty || l.title.toLowerCase().contains(_search);
                final matchC = _category == null || l.categoryL1Name == _category;
                return matchQ && matchC;
              }).toList();

              if (listings.isEmpty) {
                return const SliverFillRemaining(child: Center(child: Text("No properties found.")));
              }

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: _isGrid
                    ? SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.72,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, i) => _EnhancedGridCard(listing: listings[i], onTap: () => _showLogin(context)),
                          childCount: listings.length,
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _EnhancedListCard(listing: listings[i], onTap: () => _showLogin(context)),
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

  void _showLogin(BuildContext context) => showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => const _LoginSheet(),
  );
}

// ─── COMPONENT REFINEMENTS ─────────────────────────────────────────────

class _EnhancedSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _EnhancedSearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_T.radius),
        boxShadow: _T.shadow,
      ),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: "Search by location or name...",
          hintStyle: const TextStyle(color: _T.textSub),
          prefixIcon: const Icon(Icons.search, color: _T.primary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}

class _EnhancedGridCard extends StatelessWidget {
  final ListingModel listing;
  final VoidCallback onTap;

  const _EnhancedGridCard({required this.listing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _T.surface,
          borderRadius: BorderRadius.circular(_T.radius),
          boxShadow: _T.shadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE SECTION
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(_T.radius)),
              child: AspectRatio(
                aspectRatio: 1.1, // Adjusted for better fit
                child: listing.photoUrls.isNotEmpty
                    ? Image.network(listing.photoUrls.first, fit: BoxFit.cover)
                    : Container(color: Colors.grey[200]),
              ),
            ),

            // TEXT SECTION
            Expanded(
              // <--- This prevents the column from overflowing the bottom
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distributes space
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Rs. ${listing.rentPerMonth}",
                          style: const TextStyle(fontWeight: FontWeight.bold, color: _T.primaryDark, fontSize: 15),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          listing.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 12, color: _T.textSub),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            listing.address ?? 'Nepal',
                            style: const TextStyle(fontSize: 11, color: _T.textSub),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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

// ─── LOGIN SHEET (MODERN) ─────────────────────────────────────────────

class _LoginSheet extends StatelessWidget {
  const _LoginSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 20),
          const Icon(Icons.lock_person_outlined, size: 48, color: _T.primary),
          const SizedBox(height: 16),
          const Text("Ready to Move In?", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Text(
            "Sign in to contact the owner directly.",
            textAlign: TextAlign.center,
            style: TextStyle(color: _T.textSub),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => context.go(AppRoutes.login),
              style: ElevatedButton.styleFrom(
                backgroundColor: _T.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                "Get Started",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  final AsyncValue listingsAsync;
  final String? selected;
  final ValueChanged<String?> onSelect;

  const _FilterRow({required this.listingsAsync, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: listingsAsync.maybeWhen(
        data: (list) {
          final categories = list.map((l) => (l as ListingModel).categoryL1Name).whereType<String>().toSet().toList();

          return ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _chip("All", selected == null, () => onSelect(null)),
              ...categories.map((c) => _chip(c, selected == c, () => onSelect(c))),
            ],
          );
        },
        orElse: () => const SizedBox(),
      ),
    );
  }

  Widget _chip(String label, bool active, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: active,
        onSelected: (_) => onTap(),
        selectedColor: _T.primary,
        labelStyle: TextStyle(
          color: active ? _T.primaryDark : _T.textSub,
          fontWeight: active ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: active ? _T.primary : _T.border),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final bool isGrid;
  final VoidCallback onToggle;

  const _Header({required this.isGrid, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Row(
        children: [
          const Text(
            "Available Rooms",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _T.textMain),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _T.border),
            ),
            child: IconButton(
              visualDensity: VisualDensity.compact,
              icon: Icon(isGrid ? Icons.format_list_bulleted : Icons.grid_view_rounded, color: _T.primary),
              onPressed: onToggle,
            ),
          ),
        ],
      ),
    );
  }
}

class _EnhancedListCard extends StatelessWidget {
  final ListingModel listing;
  final VoidCallback onTap;

  const _EnhancedListCard({required this.listing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _T.surface,
          borderRadius: BorderRadius.circular(_T.radius),
          boxShadow: _T.shadow,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 100,
                height: 100,
                child: listing.photoUrls.isNotEmpty
                    ? Image.network(listing.photoUrls.first, fit: BoxFit.cover)
                    : Container(color: _T.primary),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: _T.primary),
                      const SizedBox(width: 4),
                      Text(listing.address ?? 'Kathmandu', style: const TextStyle(color: _T.textSub, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Rs. ${listing.rentPerMonth}",
                    style: const TextStyle(color: _T.primaryDark, fontWeight: FontWeight.w800, fontSize: 15),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: _T.border),
          ],
        ),
      ),
    );
  }
}
