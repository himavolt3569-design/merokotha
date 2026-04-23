import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merokotha/features/ads/data/ad_model.dart';
import 'package:merokotha/features/ads/providers/ad_providers.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

// ── Main AdBanner widget ──────────────────────────────────────────
// Drop this anywhere in a screen to show an ad for that placement
//
// Usage:
//   AdBanner(placement: AdPlacement.homeFeed)
//   AdBanner(placement: AdPlacement.roomDetail)

class AdBanner extends ConsumerWidget {
  final AdPlacement placement;
  final EdgeInsetsGeometry padding;

  const AdBanner({
    super.key,
    required this.placement,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSizes.pagePadding,
      vertical: 8,
    ),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adsAsync = ref.watch(adsForPlacementProvider(placement));

    return adsAsync.when(
      // Show nothing while loading — no skeleton, no flash
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (ads) {
        if (ads.isEmpty) return const SizedBox.shrink();

        // Show the highest priority ad
        final ad = ads.first;

        return Padding(
          padding: padding,
          child: _AdCard(ad: ad),
        );
      },
    );
  }
}

// ── Ad card ───────────────────────────────────────────────────────

class _AdCard extends StatelessWidget {
  final AdModel ad;
  const _AdCard({required this.ad});

  Future<void> _openUrl(BuildContext context) async {
    final url = Uri.tryParse(ad.websiteUrl);
    if (url == null) return;
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open link')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openUrl(context),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: AppColors.grey100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Ad image ──
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSizes.radiusLg),
                topRight: Radius.circular(AppSizes.radiusLg),
              ),
              child: Stack(
                children: [
                  // Banner image
                  Image.network(
                    ad.imageUrl,
                    width: double.infinity,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      height: 100,
                      color: AppColors.grey50,
                      child: const Center(
                        child: Icon(
                          Icons.image_outlined,
                          color: AppColors.grey200,
                          size: 36,
                        ),
                      ),
                    ),
                    loadingBuilder: (_, child, progress) => progress == null
                        ? child
                        : Container(height: 100, color: AppColors.grey50),
                  ),

                  // "Ad" label top-right
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusFull,
                        ),
                      ),
                      child: const Text(
                        'Ad',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Ad footer: business name + tap to visit ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      ad.title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Visit',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.open_in_new_rounded,
                          size: 12,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
