import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:merokotha/shared/models/listing_model.dart';

import 'package:merokotha/core/constants/app_colors.dart';
import 'package:merokotha/core/constants/app_sizes.dart';
import 'package:merokotha/core/router/app_routes.dart';
import 'package:merokotha/shared/widgets/mk_widgets.dart';
import 'package:merokotha/features/auth/data/auth_repository.dart';
import 'package:merokotha/features/auth/providers/auth_provider.dart';

import 'package:merokotha/features/admin/providers/admin_providers.dart';
import 'package:merokotha/features/admin/presentation/widgets/admin_widgets.dart';

class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final recentUsersAsync = ref.watch(recentUsersProvider);
    final recentListingsAsync = ref.watch(recentListingsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AdminAppBar(
        title: 'Admin Dashboard',
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            onPressed: () async {
              await ref.read(authRepositoryProvider).signOut();
              if (context.mounted) context.go(AppRoutes.login);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AdminColors.accent,
        onRefresh: () async {
          ref.invalidate(dashboardStatsProvider);
          ref.invalidate(recentUsersProvider);
          ref.invalidate(recentListingsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSizes.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: AdminColors.primary,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AdminColors.accent,
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      ),
                      child: const Icon(
                        Icons.shield_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ref
                        .watch(currentUserProvider)
                        .when(
                          data: (u) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome, ${u?.name ?? 'Admin'}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const Text(
                                'Super Administrator',
                                style: TextStyle(
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

              const SizedBox(height: 20),

              const _SectionHeader('Platform overview'),
              const SizedBox(height: 12),

              statsAsync.when(
                loading: () => const MkLoading(fullScreen: false),
                error: (e, _) => MkErrorWidget(message: e.toString()),
                data: (stats) => Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AdminStatCard(
                            label: 'Total users',
                            value: '${stats.totalUsers}',
                            icon: Icons.people_rounded,
                            color: AppColors.customerPrimary,
                            onTap: () => context.go(AppRoutes.adminUsers),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AdminStatCard(
                            label: 'House owners',
                            value: '${stats.totalOwners}',
                            icon: Icons.house_rounded,
                            color: AppColors.ownerPrimary,
                            onTap: () => context.go(AppRoutes.adminUsers),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: AdminStatCard(
                            label: 'Active listings',
                            value: '${stats.activeListings}',
                            icon: Icons.home_work_rounded,
                            color: AppColors.success,
                            onTap: () => context.go(AppRoutes.adminListings),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AdminStatCard(
                            label: 'Total listings',
                            value: '${stats.totalListings}',
                            icon: Icons.list_alt_rounded,
                            color: AppColors.info,
                            onTap: () => context.go(AppRoutes.adminListings),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: AdminStatCard(
                            label: 'Pending inquiries',
                            value: '${stats.pendingInquiries}',
                            icon: Icons.inbox_rounded,
                            color: AppColors.warning,
                            onTap: () => context.go(AppRoutes.adminInquiries),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AdminStatCard(
                            label: 'Banned users',
                            value: '${stats.bannedUsers}',
                            icon: Icons.block_rounded,
                            color: AppColors.error,
                            onTap: () => context.go(AppRoutes.adminUsers),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const _SectionHeader('Quick actions'),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.2,
                children: [
                  _QuickAction(
                    label: 'All users',
                    icon: Icons.people_rounded,
                    color: AppColors.customerPrimary,
                    onTap: () => context.push(AppRoutes.adminUsers),
                  ),
                  _QuickAction(
                    label: 'Listings',
                    icon: Icons.home_work_rounded,
                    color: AppColors.ownerPrimary,
                    onTap: () => context.push(AppRoutes.adminListings),
                  ),
                  _QuickAction(
                    label: 'Inquiries',
                    icon: Icons.inbox_rounded,
                    color: AppColors.warning,
                    onTap: () => context.push(AppRoutes.adminInquiries),
                  ),
                  _QuickAction(
                    label: 'Ads',
                    icon: Icons.campaign_rounded,
                    color: AppColors.secondary,
                    onTap: () => context.push(AppRoutes.adminAds),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              _SectionHeader(
                'Recent signups',
                onSeeAll: () => context.go(AppRoutes.adminUsers),
              ),
              const SizedBox(height: 12),
              recentUsersAsync.when(
                loading: () => const MkLoading(fullScreen: false),
                error: (_, _) => const SizedBox.shrink(),
                data: (users) => Column(
                  children: users
                      .map(
                        (u) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: AdminUserTile(
                            user: u,
                            onTap: () => context.push(
                              AppRoutes.adminUserDetail.replaceAll(
                                ':uid',
                                u.id,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),

              const SizedBox(height: 24),

              _SectionHeader(
                'Recent listings',
                onSeeAll: () => context.go(AppRoutes.adminListings),
              ),
              const SizedBox(height: 12),
              recentListingsAsync.when(
                loading: () => const MkLoading(fullScreen: false),
                error: (_, _) => const SizedBox.shrink(),
                data: (listings) => Column(
                  children: listings
                      .map(
                        (l) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: AdminListingTile(
                            listing: l,
                            onDelete: () =>
                                _confirmDelete(context, ref, l.id, l.title),
                            onToggleStatus: () => ref
                                .read(adminActionProvider.notifier)
                                .setListingStatus(
                                  l.id,
                                  l.isActive
                                      ? ListingStatus.paused
                                      : ListingStatus.active,
                                ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 0),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String id,
    String title,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete listing?'),
        content: Text('Delete "$title"? This cannot be undone.'),
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
              ref.read(adminActionProvider.notifier).deleteListing(id);
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

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  const _SectionHeader(this.title, {this.onSeeAll});

  @override
  Widget build(BuildContext context) => Row(
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
              color: AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
    ],
  );
}

class _QuickAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 8,
      ), // reduced from 16/12
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.grey50),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36, // reduced from 44
            height: 36, // reduced from 44
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Icon(icon, size: 18, color: color), // reduced from 22
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.grey700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}
