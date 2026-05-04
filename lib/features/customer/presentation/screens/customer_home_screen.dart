import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:merokotha/features/customer/providers/customers_providers.dart';

import 'package:merokotha/core/constants/app_colors.dart';
import 'package:merokotha/core/constants/app_sizes.dart';
import 'package:merokotha/core/router/app_routes.dart';
import 'package:merokotha/shared/widgets/mk_widgets.dart';
import 'package:merokotha/features/auth/providers/auth_provider.dart';
import 'package:merokotha/features/customer/presentation/widgets/customer_widgets.dart';
import 'package:merokotha/features/ads/data/ad_model.dart';
import 'package:merokotha/features/ads/presentation/widgets/ad_banner.dart';

class CustomerHomeScreen extends ConsumerWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final listingsAsync = ref.watch(activeListingsProvider);
    final favIds = ref.watch(favouriteIdsProvider).asData?.value ?? [];

    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.customerPrimary,
          onRefresh: () async {
            ref.invalidate(activeListingsProvider);
          },
          child: CustomScrollView(
            slivers: [
              // ── App bar ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.pagePadding,
                    16,
                    AppSizes.pagePadding,
                    0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _greeting(),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.grey400,
                              ),
                            ),
                            userAsync.when(
                              data: (u) => Text(
                                u?.name.split(' ').first ?? 'MeroKotha',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.grey900,
                                ),
                              ),
                              loading: () => const Text(
                                'MeroKotha',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.grey900,
                                ),
                              ),
                              error: (_, _) => const SizedBox.shrink(),
                            ),
                            userAsync.when(
                              data: (u) => Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_rounded,
                                    size: 13,
                                    color: AppColors.customerPrimary,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    u?.location ?? 'Kathmandu',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.grey400,
                                    ),
                                  ),
                                ],
                              ),
                              loading: () => const SizedBox.shrink(),
                              error: (_, _) => const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                      userAsync.when(
                        data: (u) => GestureDetector(
                          onTap: () => context.push(AppRoutes.customerProfile),
                          child: UserAvatar(
                            name: u?.name ?? 'User',
                            photoUrl: u?.photoUrl,
                            size: 38,
                            backgroundColor: AppColors.customerLight,
                          ),
                        ),
                        loading: () => const SizedBox(width: 38, height: 38),
                        error: (_, _) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Search bar ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.pagePadding),
                  child: GestureDetector(
                    onTap: () => context.push(AppRoutes.search),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 13,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        border: Border.all(color: AppColors.grey100),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.search_rounded,
                            size: 20,
                            color: AppColors.grey400,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Search rooms, area, landmarks...',
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
              ),

              // ── Filter chips ──
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _CategoryChipRow(
                      selected: ref.watch(searchFilterProvider).categoryL1Id,
                      onSelect: (id) => ref
                          .read(searchFilterProvider.notifier)
                          .setCategory(categoryL1Id: id),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

              // ── Section header ──
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.pagePadding,
                  ),
                  child: Text(
                    'Rooms near you',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.grey900,
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // ── Listings with injected ads ──
              listingsAsync.when(
                loading: () => const SliverToBoxAdapter(
                  child: MkLoading(fullScreen: false),
                ),
                error: (e, _) => SliverToBoxAdapter(
                  child: MkErrorWidget(
                    message: e.toString(),
                    onRetry: () => ref.invalidate(activeListingsProvider),
                  ),
                ),
                data: (allListings) {
                  // Apply category chip filter client-side
                  final selectedL1 = ref
                      .watch(searchFilterProvider)
                      .categoryL1Id;
                  final listings = selectedL1 == null
                      ? allListings
                      : allListings
                            .where((l) => l.roomType == selectedL1)
                            .toList();

                  if (listings.isEmpty) {
                    return SliverToBoxAdapter(
                      child: MkEmptyState(
                        title: 'No rooms found',
                        subtitle: selectedL1 != null
                            ? 'No rooms in this category. Try a different type.'
                            : 'No listings yet. Check back soon.',
                        icon: Icons.house_outlined,
                      ),
                    );
                  }

                  // SliverList with an ad injected every 5 listings
                  return SliverList(
                    delegate: SliverChildBuilderDelegate((_, i) {
                      final showAdBefore = i > 0 && i % 5 == 0;
                      final l = listings[i];
                      return Column(
                        children: [
                          if (showAdBefore)
                            AdBanner(
                              placement: AdPlacement.homeFeed,
                              padding: const EdgeInsets.fromLTRB(
                                AppSizes.pagePadding,
                                4,
                                AppSizes.pagePadding,
                                4,
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.pagePadding,
                              vertical: 6,
                            ),
                            child: ListingCard(
                              listing: l,
                              isFavourited: favIds.contains(l.id),
                              onFavourite: () => ref
                                  .read(favouriteProvider.notifier)
                                  .toggle(l),
                              onTap: () => context.push(
                                AppRoutes.roomDetail.replaceAll(':id', l.id),
                              ),
                            ),
                          ),
                        ],
                      );
                    }, childCount: listings.length),
                  );
                },
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.customerMap),
        backgroundColor: AppColors.customerPrimary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.map_rounded),
      ),

      bottomNavigationBar: const CustomerBottomNav(currentIndex: 0),
    );
  }
}

String _greeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
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

class _CategoryChipRow extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onSelect;

  const _CategoryChipRow({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
        children: [
          _CatChip(
            label: 'All',
            active: selected == null,
            onTap: () => onSelect(null),
          ),
          ..._roomTypeOptions.map(
            (c) => _CatChip(
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

class _CatChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _CatChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.customerPrimary : Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          border: Border.all(
            color: active ? AppColors.customerPrimary : AppColors.grey100,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: active ? Colors.white : AppColors.grey600,
          ),
        ),
      ),
    );
  }
}
