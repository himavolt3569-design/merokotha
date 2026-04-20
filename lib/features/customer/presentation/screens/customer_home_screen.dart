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

class CustomerHomeScreen extends ConsumerWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final listingsAsync = ref.watch(activeListingsProvider);
     final favIds = ref.watch(favouriteIdsProvider).asData?.value ?? [];

    // Category chip filter — now a String? (categoryL3Id) instead of RoomType
    final selectedCategoryId = ref.watch(searchFilterProvider).categoryL3Id;

    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.customerPrimary,
          onRefresh: () async => ref.invalidate(activeListingsProvider),
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
                            const Text(
                              'MeroKotha',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppColors.grey900,
                              ),
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
                          onTap: () => context.go(AppRoutes.customerProfile),
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
                    onTap: () => context.go(AppRoutes.search),
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
              // Pass your categories from Firestore here when ready.
              // For now the chip row shows only "All" until categories are loaded.
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    FilterChipRow(
                      selectedCategoryId: selectedCategoryId,
                      categories: const [],
                      onCategoryChanged: (id) => ref
                          .read(searchFilterProvider.notifier)
                          .setCategory(categoryL3Id: id),
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

              // ── Listings grid ──
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
                  final listings = selectedCategoryId == null
                      ? allListings
                      : allListings
                            .where((l) => l.categoryL3Id == selectedCategoryId)
                            .toList();

                  if (listings.isEmpty) {
                    return SliverToBoxAdapter(
                      child: MkEmptyState(
                        title: 'No rooms found',
                        subtitle: selectedCategoryId != null
                            ? 'No rooms in this category. Try a different type.'
                            : 'No listings yet. Check back soon.',
                        icon: Icons.house_outlined,
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.pagePadding,
                    ),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.65,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      delegate: SliverChildBuilderDelegate((_, i) {
                        final l = listings[i];
                        return ListingCard(
                          listing: l,
                          isFavourited: favIds.contains(l.id),
                          onFavourite: () =>
                              ref.read(favouriteProvider.notifier).toggle(l),
                          onTap: () => context.push(
                            AppRoutes.roomDetail.replaceAll(':id', l.id),
                          ),
                        );
                      }, childCount: listings.length),
                    ),
                  );
                },
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go(AppRoutes.customerMap),
        backgroundColor: AppColors.customerPrimary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.map_rounded),
      ),

      bottomNavigationBar: const CustomerBottomNav(currentIndex: 0),
    );
  }
}
