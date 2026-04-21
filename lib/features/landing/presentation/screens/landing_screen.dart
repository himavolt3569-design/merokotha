import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:merokotha/core/router/app_routes.dart';
import 'package:merokotha/features/customer/providers/customers_providers.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/models/listing_model.dart';
import '../../../../shared/widgets/mk_widgets.dart';

class LandingScreen extends ConsumerStatefulWidget {
  const LandingScreen({super.key});

  @override
  ConsumerState<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends ConsumerState<LandingScreen> {
  String _searchQuery = '';
  String? _selectedL1Name;

  @override
  Widget build(BuildContext context) {
    final listingsAsync = ref.watch(activeListingsProvider);
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F2),
      body: CustomScrollView(
        slivers: [
          // ── Hero ──
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.primary,
              padding: EdgeInsets.fromLTRB(20, topPadding + 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top bar
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.home_rounded,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'MeroKotha',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => context.go(AppRoutes.login),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: const Text(
                            'Sign in',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                              letterSpacing: -0.1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Search bar
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      onChanged: (v) =>
                          setState(() => _searchQuery = v.toLowerCase()),
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF1A1A18),
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search by location or title…',
                        hintStyle: TextStyle(
                          fontSize: 13.5,
                          color: Colors.black.withOpacity(0.3),
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: Colors.black.withOpacity(0.3),
                          size: 18,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 13,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // ── Category chips ──
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.primary,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF7F6F2),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _Chip(
                        label: 'All',
                        isSelected: _selectedL1Name == null,
                        onTap: () => setState(() => _selectedL1Name = null),
                      ),
                      const SizedBox(width: 7),
                      ...listingsAsync.maybeWhen(
                        data: (listings) {
                          final names = listings
                              .map((l) => l.categoryL1Name)
                              .whereType<String>()
                              .toSet()
                              .toList();
                          return names
                              .map(
                                (n) => Padding(
                                  padding: const EdgeInsets.only(right: 7),
                                  child: _Chip(
                                    label: n,
                                    isSelected: _selectedL1Name == n,
                                    onTap: () => setState(
                                      () => _selectedL1Name =
                                          _selectedL1Name == n ? null : n,
                                    ),
                                  ),
                                ),
                              )
                              .toList();
                        },
                        orElse: () => [],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Section header ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  const Text(
                    'Available rooms',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A18),
                      letterSpacing: -0.4,
                    ),
                  ),
                  listingsAsync.maybeWhen(
                    data: (l) => Text(
                      '${l.length} listings',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF8A8980),
                      ),
                    ),
                    orElse: () => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),

          // ── Grid ──
          listingsAsync.when(
            loading: () =>
                const SliverToBoxAdapter(child: MkLoading(fullScreen: false)),
            error: (e, _) =>
                SliverToBoxAdapter(child: MkErrorWidget(message: e.toString())),
            data: (all) {
              final listings = all.where((l) {
                final matchSearch =
                    _searchQuery.isEmpty ||
                    l.title.toLowerCase().contains(_searchQuery) ||
                    (l.address?.toLowerCase().contains(_searchQuery) ?? false);
                final matchCat =
                    _selectedL1Name == null ||
                    l.categoryL1Name == _selectedL1Name;
                return matchSearch && matchCat;
              }).toList();

              if (listings.isEmpty) {
                return const SliverToBoxAdapter(
                  child: MkEmptyState(
                    title: 'No rooms found',
                    subtitle: 'Try a different search or category',
                    icon: Icons.house_outlined,
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.70,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _ListingCard(
                      listing: listings[i],
                      onTap: () => _promptLogin(context),
                    ),
                    childCount: listings.length,
                  ),
                ),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  void _promptLogin(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.fromLTRB(
          24,
          0,
          24,
          MediaQuery.of(context).padding.bottom + 28,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 32,
                height: 3,
                margin: const EdgeInsets.only(top: 10, bottom: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0DFD9),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                size: 22,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 14),

            const Text(
              'Sign in to continue',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A18),
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Save rooms, send inquiries,\nand message owners for free.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF8A8980),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  context.go(AppRoutes.login);
                },
                child: const Text('Sign in / Create account'),
              ),
            ),
            const SizedBox(height: 8),

            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF8A8980),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              child: const Text('Continue browsing'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Listing Card ─────────────────────────────────────────────────

class _ListingCard extends StatelessWidget {
  final ListingModel listing;
  final VoidCallback onTap;

  const _ListingCard({required this.listing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withOpacity(0.06), width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo
            AspectRatio(
              aspectRatio: 4 / 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
                child: listing.photoUrls.isNotEmpty
                    ? Image.network(
                        listing.photoUrls.first,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _placeholder,
                      )
                    : _placeholder,
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 11),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Badge
                  if (listing.categoryLabel.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        listing.categoryLabel,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                  ],

                  // Title
                  Text(
                    listing.title,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A18),
                      letterSpacing: -0.2,
                      height: 1.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Location
                  if (listing.address != null) ...[
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 10,
                          color: Color(0xFFAAAAAA),
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            listing.address!,
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: Color(0xFFAAAAAA),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 9),

                  // Price row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PriceBadge(amount: listing.rentPerMonth),
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F6F2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite_border_rounded,
                          size: 12,
                          color: Color(0xFFCCCBC3),
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

  Widget get _placeholder => Container(
    color: const Color(0xFFEAE9E3),
    child: const Center(
      child: Icon(Icons.image_outlined, size: 24, color: Color(0xFFCCCBC3)),
    ),
  );
}

// ── Category Chip ─────────────────────────────────────────────────

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
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : Colors.black.withOpacity(0.08),
            width: 0.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
            color: isSelected ? Colors.white : const Color(0xFF555450),
            letterSpacing: -0.1,
          ),
        ),
      ),
    );
  }
}
