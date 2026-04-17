import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:merokotha/features/customer/providers/customers_providers.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
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

    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      body: CustomScrollView(
        slivers: [
          // ── Hero header ──
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              padding: EdgeInsets.fromLTRB(
                AppSizes.pagePadding,
                MediaQuery.of(context).padding.top + 20,
                AppSizes.pagePadding,
                28,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App name row + login button
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.home_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        AppStrings.appName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      // Login button
                      GestureDetector(
                        onTap: () => context.go(AppRoutes.login),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusFull,
                            ),
                          ),
                          child: const Text(
                            'Sign in',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Tagline
                  const Text(
                    'Find your perfect\nroom in Nepal',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Browse hundreds of verified rooms near you',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                    child: TextField(
                      onChanged: (v) =>
                          setState(() => _searchQuery = v.toLowerCase()),
                      decoration: const InputDecoration(
                        hintText: 'Search area, landmark...',
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: AppColors.grey400,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // ── Category filter chips ──
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.pagePadding,
              ),
              child: Row(
                children: [
                  _CategoryChip(
                    label: 'All',
                    isSelected: _selectedL1Name == null,
                    onTap: () => setState(() => _selectedL1Name = null),
                  ),
                  const SizedBox(width: 8),
                  // Build chips from listing data dynamically
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
                              padding: const EdgeInsets.only(right: 8),
                              child: _CategoryChip(
                                label: n,
                                isSelected: _selectedL1Name == n,
                                onTap: () => setState(
                                  () => _selectedL1Name = _selectedL1Name == n
                                      ? null
                                      : n,
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

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // ── Section title ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.pagePadding,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Available rooms',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.grey900,
                    ),
                  ),
                  listingsAsync.maybeWhen(
                    data: (l) => Text(
                      '${l.length} rooms',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.grey400,
                      ),
                    ),
                    orElse: () => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // ── Listings grid ──
          listingsAsync.when(
            loading: () =>
                const SliverToBoxAdapter(child: MkLoading(fullScreen: false)),
            error: (e, _) =>
                SliverToBoxAdapter(child: MkErrorWidget(message: e.toString())),
            data: (all) {
              // Apply search + category filter
              var listings = all.where((l) {
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
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.pagePadding,
                ),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _LandingListingCard(
                      listing: listings[i],
                      onTap: () => _promptLogin(context),
                    ),
                    childCount: listings.length,
                  ),
                ),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ── Sign up CTA ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.pagePadding,
                0,
                AppSizes.pagePadding,
                40,
              ),
              child: Container(
                padding: const EdgeInsets.all(AppSizes.lg),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Ready to find your room?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sign up free to save rooms, send inquiries and connect with owners.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.85),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () => context.go(AppRoutes.login),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusMd,
                            ),
                          ),
                        ),
                        child: const Text(
                          'Get started — it\'s free',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _promptLogin(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXl),
        ),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(AppSizes.pagePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Icon(
              Icons.lock_outline_rounded,
              size: 40,
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),
            const Text(
              'Sign in to continue',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.grey900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create a free account to save rooms, send inquiries and message owners.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.grey600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: AppSizes.buttonHeight,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.go(AppRoutes.login);
                },
                child: const Text('Sign in / Sign up'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Continue browsing',
                style: TextStyle(color: AppColors.grey400),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
          ],
        ),
      ),
    );
  }
}

// ── Landing listing card (no favourite button) ────────────────────

class _LandingListingCard extends StatelessWidget {
  final ListingModel listing;
  final VoidCallback onTap;

  const _LandingListingCard({required this.listing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: AppColors.grey50),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo
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
                      errorBuilder: (_, _, _) => _placeholder,
                    )
                  : _placeholder,
            ),

            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category badge
                  if (listing.categoryLabel.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusFull,
                        ),
                      ),
                      child: Text(
                        listing.categoryLabel,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  const SizedBox(height: 5),

                  // Title
                  Text(
                    listing.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Location
                  if (listing.address != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 11,
                            color: AppColors.grey400,
                          ),
                          Expanded(
                            child: Text(
                              listing.address!,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.grey400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 6),

                  // Price
                  PriceBadge(amount: listing.rentPerMonth),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget get _placeholder => Container(
    height: 140,
    color: AppColors.grey50,
    child: const Center(
      child: Icon(Icons.image_outlined, size: 36, color: AppColors.grey100),
    ),
  );
}

// ── Category chip for filter row ──────────────────────────────────

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
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
