import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:merokotha/core/constants/app_colors.dart';
import 'package:merokotha/core/constants/app_sizes.dart';
import 'package:merokotha/core/router/app_routes.dart';
import 'package:merokotha/features/customer/presentation/widgets/customer_widgets.dart';
import 'package:merokotha/features/customer/providers/customers_providers.dart';
import 'package:merokotha/shared/widgets/mk_app_bar.dart';
import 'package:merokotha/shared/widgets/mk_widgets.dart';

class FavouritesScreen extends ConsumerWidget {
  const FavouritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favListingsAsync = ref.watch(favouriteListingsProvider);
    final favIds = ref.watch(favouriteIdsProvider).asData?.value ?? [];

    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: const MkAppBar(title: 'Saved rooms'),
      body: favListingsAsync.when(
        loading: () => const MkLoading(),
        error: (e, _) => MkErrorWidget(message: e.toString()),
        data: (listings) {
          if (listings.isEmpty) {
            return MkEmptyState(
              title: 'No saved rooms',
              subtitle:
                  'Tap the heart on any listing to save it here for later',
              icon: Icons.favorite_outline_rounded,
              actionLabel: 'Browse rooms',
              onAction: () => context.go(AppRoutes.customerHome),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(AppSizes.pagePadding),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.72,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: listings.length,
            itemBuilder: (_, i) {
              final l = listings[i];
              return ListingCard(
                listing: l,
                isFavourited: favIds.contains(l.id),
                onFavourite: () =>
                    ref.read(favouriteProvider.notifier).toggle(l),
                onTap: () =>
                    context.push(AppRoutes.roomDetail.replaceAll(':id', l.id)),
              );
            },
          );
        },
      ),
      bottomNavigationBar: const CustomerBottomNav(currentIndex: 3),
    );
  }
}
