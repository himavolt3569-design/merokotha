import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:merokotha/shared/widgets/owner_botton_nav.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/models/listing_model.dart';
import '../../../../shared/models/inquiry_model.dart';
import '../../../../shared/widgets/mk_widgets.dart';
import '../../../../shared/widgets/mk_app_bar.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/owner_providers.dart';
import '../../data/inquiry_repository.dart';
import '../widgets/owner_widgets.dart';

class OwnerHomeScreen extends ConsumerWidget {
  const OwnerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final listingsAsync = ref.watch(ownerListingsProvider);
    final pendingCount = ref.watch(pendingInquiryCountProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: MkAppBar(
        title: 'मेरो कोठा',
        showBack: false,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.grey800,
                ),
                onPressed: () => context.go(AppRoutes.ownerInquiries),
              ),
              pendingCount.when(
                data: (count) => count > 0
                    ? Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              count > 9 ? '9+' : '$count',
                              style: const TextStyle(
                                fontSize: 9,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: userAsync.when(
              data: (u) => GestureDetector(
                onTap: () => context.go(AppRoutes.ownerProfile),
                child: UserAvatar(
                  name: u?.name ?? 'Owner',
                  photoUrl: u?.photoUrl,
                  size: 34,
                ),
              ),
              loading: () => const SizedBox(
                width: 34,
                height: 34,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async => ref.invalidate(ownerListingsProvider),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSizes.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              userAsync.when(
                data: (u) => _Greeting(name: u?.name ?? 'Owner'),
                loading: () => const SizedBox(height: 48),
                error: (_, _) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 20),

              // Stats
              listingsAsync.when(
                data: (l) => _StatsRow(listings: l),
                loading: () => const SizedBox(
                  height: 90,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, _) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),

              // Quick actions
              const _SectionHeader(title: 'Quick actions'),
              const SizedBox(height: 12),
              _QuickActions(),
              const SizedBox(height: 24),

              // Recent pending inquiries
              _SectionHeader(
                title: 'Pending inquiries',
                onSeeAll: () => context.go(AppRoutes.ownerInquiries),
              ),
              const SizedBox(height: 12),
              _RecentInquiries(),
              const SizedBox(height: 24),

              // Listings preview
              _SectionHeader(
                title: 'My listings',
                onSeeAll: () => context.go(AppRoutes.myListings),
              ),
              const SizedBox(height: 12),
              listingsAsync.when(
                data: (listings) => listings.isEmpty
                    ? MkEmptyState(
                        title: 'No listings yet',
                        subtitle: 'Tap "Add listing" to post your first room',
                        icon: Icons.house_outlined,
                        actionLabel: 'Add listing',
                        onAction: () => context.go(AppRoutes.uploadListing),
                      )
                    : Column(
                        children: listings
                            .take(3)
                            .map(
                              (l) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: OwnerListingCard(
                                  listing: l,
                                  onToggle: () => ref
                                      .read(
                                        listingStatusProvider.notifier,
                                      )
                                      .toggle(
                                        l.id,
                                        l.isActive
                                            ? ListingStatus.paused
                                            : ListingStatus.active,
                                      ),
                                  onDelete: () =>
                                      _confirmDelete(context, ref, l),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                loading: () => const MkLoading(fullScreen: false),
                error: (e, _) => MkErrorWidget(
                  message: e.toString(),
                  onRetry: () => ref.invalidate(ownerListingsProvider),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(AppRoutes.uploadListing),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add listing',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      bottomNavigationBar: const OwnerBottomNav(currentIndex: 0),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, ListingModel l) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete listing?'),
        content: Text('Delete "${l.title}"? This cannot be undone.'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(listingStatusProvider.notifier).delete(l.id);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────

class _Greeting extends StatelessWidget {
  final String name;
  const _Greeting({required this.name});

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$_greeting,',
          style: const TextStyle(fontSize: 14, color: AppColors.grey400),
        ),
        Text(
          name.split(' ').first,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: AppColors.grey900,
          ),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  final List<ListingModel> listings;
  const _StatsRow({required this.listings});

  @override
  Widget build(BuildContext context) {
    final active = listings
        .where((l) => l.status == ListingStatus.active)
        .length;
    final paused = listings
        .where((l) => l.status == ListingStatus.paused)
        .length;
    final rented = listings
        .where((l) => l.status == ListingStatus.rented)
        .length;
    return Row(
      children: [
        Expanded(
          child: StatsCard(
            label: 'Active',
            value: '$active',
            icon: Icons.check_circle_outline_rounded,
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StatsCard(
            label: 'Paused',
            value: '$paused',
            icon: Icons.pause_circle_outline_rounded,
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StatsCard(
            label: 'Rented',
            value: '$rented',
            icon: Icons.home_rounded,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _QA(
          label: 'Add room',
          icon: Icons.add_home_outlined,
          color: AppColors.primary,
          onTap: () => context.go(AppRoutes.uploadListing),
        ),
        const SizedBox(width: 10),
        _QA(
          label: 'Listings',
          icon: Icons.list_alt_rounded,
          color: AppColors.info,
          onTap: () => context.go(AppRoutes.myListings),
        ),
        const SizedBox(width: 10),
        _QA(
          label: 'Inquiries',
          icon: Icons.inbox_rounded,
          color: AppColors.warning,
          onTap: () => context.go(AppRoutes.ownerInquiries),
        ),
        const SizedBox(width: 10),
        _QA(
          label: 'Map',
          icon: Icons.map_outlined,
          color: AppColors.success,
          onTap: () => context.go(AppRoutes.ownerMap),
        ),
      ],
    );
  }
}

class _QA extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _QA({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: AppColors.grey50),
          ),
          child: Column(
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentInquiries extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(currentUserProvider)
        .when(
          data: (user) {
            if (user == null) return const SizedBox.shrink();
            return StreamBuilder<List<InquiryModel>>(
              stream: ref
                  .watch(inquiryRepositoryProvider)
                  .watchByStatus(user.id, InquiryStatus.pending),
              builder: (_, snap) {
                final inquiries = snap.data ?? [];
                if (inquiries.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(AppSizes.md),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                      border: Border.all(color: AppColors.grey50),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          color: AppColors.success,
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'No pending inquiries',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return Column(
                  children: inquiries
                      .take(2)
                      .map(
                        (inq) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: InquiryCard(
                            inquiry: inq,
                            onAccept: () => ref
                                .read(inquiryRepositoryProvider)
                                .acceptInquiry(inq.id),
                            onDecline: () => ref
                                .read(inquiryRepositoryProvider)
                                .declineInquiry(inq.id),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            );
          },
          loading: () => const MkLoading(fullScreen: false),
          error: (_, _) => const SizedBox.shrink(),
        );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  const _SectionHeader({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.grey900,
          ),
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: const Text(
              'See all',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}
