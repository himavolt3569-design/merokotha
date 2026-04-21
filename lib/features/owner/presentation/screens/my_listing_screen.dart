import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:merokotha/shared/widgets/owner_botton_nav.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/models/listing_model.dart';
import '../../../../shared/widgets/mk_app_bar.dart';
import '../../../../shared/widgets/mk_widgets.dart';
import '../../providers/owner_providers.dart';
import '../widgets/owner_widgets.dart'; // ← ADD THIS

class MyListingsScreen extends ConsumerWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsAsync = ref.watch(ownerListingsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: MkAppBar(
        title: 'My listings',
        showBack: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.primary),
            onPressed: () => context.push(AppRoutes.uploadListing),
          ),
        ],
      ),
      body: listingsAsync.when(
        loading: () => const MkLoading(),
        error: (e, _) => MkErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(ownerListingsProvider),
        ),
        data: (listings) {
          if (listings.isEmpty) {
            return MkEmptyState(
              title: 'No listings yet',
              subtitle: 'Add your first room to start receiving inquiries',
              icon: Icons.house_outlined,
              actionLabel: 'Add listing',
              onAction: () => context.push(AppRoutes.uploadListing),
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async => ref.invalidate(ownerListingsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSizes.pagePadding),
              itemCount: listings.length,
              separatorBuilder: (_, i) => const SizedBox(height: AppSizes.md),
              itemBuilder: (_, i) {
                final l = listings[i];
                return OwnerListingCard(
                  listing: l,
                  onToggle: () {
                    ref
                        .read(listingStatusProvider.notifier)
                        .toggle(
                          l.id,
                          l.isActive
                              ? ListingStatus.paused
                              : ListingStatus.active,
                        );
                  },
                  onDelete: () => _confirmDelete(context, ref, l),
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: const OwnerBottomNav(currentIndex: 1),
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
