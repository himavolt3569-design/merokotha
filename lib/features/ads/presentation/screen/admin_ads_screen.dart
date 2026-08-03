import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:merokotha/core/constants/app_colors.dart';
import 'package:merokotha/core/constants/app_sizes.dart';
import 'package:merokotha/core/utils/formatters.dart';
import 'package:merokotha/shared/widgets/mk_button.dart';
import 'package:merokotha/shared/widgets/mk_text_field.dart';
import 'package:merokotha/shared/widgets/mk_widgets.dart';
import 'package:merokotha/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:merokotha/features/ads/data/ad_model.dart';
import 'package:merokotha/features/ads/providers/ad_providers.dart';

class AdminAdsScreen extends ConsumerWidget {
  const AdminAdsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adsAsync = ref.watch(allAdsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: const AdminAppBar(title: 'Ad Management', showBack: true),
      body: adsAsync.when(
        loading: () => const MkLoading(),
        error: (e, _) => MkErrorWidget(message: e.toString()),
        data: (ads) {
          if (ads.isEmpty) {
            return const MkEmptyState(
              icon: Icons.campaign_outlined,
              title: 'No ads yet',
              subtitle: 'Tap + to create your first ad',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSizes.pagePadding),
            itemCount: ads.length,
            separatorBuilder: (_, i) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _AdTile(ad: ads[i]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context, ref),
        backgroundColor: AdminColors.accent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'New ad',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXl),
        ),
      ),
      builder: (_) => const _CreateAdSheet(),
    );
  }
}

class _AdTile extends ConsumerWidget {
  final AdModel ad;
  const _AdTile({required this.ad});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActive = ad.status == AdStatus.active;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppSizes.shadowCard,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner preview
          if (ad.imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSizes.radiusLg),
                topRight: Radius.circular(AppSizes.radiusLg),
              ),
              child: Image.network(
                ad.imageUrl,
                height: 90,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  height: 90,
                  color: AppColors.grey50,
                  child: const Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: AppColors.grey200,
                    ),
                  ),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + status
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        ad.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.grey900,
                        ),
                      ),
                    ),
                    _StatusBadge(ad: ad),
                  ],
                ),

                const SizedBox(height: 6),

                // Placement + dates
                Row(
                  children: [
                    _InfoChip(
                      icon: Icons.place_outlined,
                      label: ad.placementLabel,
                    ),
                    const SizedBox(width: 8),
                    _InfoChip(
                      icon: Icons.calendar_today_outlined,
                      label:
                          '${Formatters.dateShort(ad.startsAt)} - ${Formatters.dateShort(ad.endsAt)}',
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // URL
                Row(
                  children: [
                    const Icon(
                      Icons.link_rounded,
                      size: 13,
                      color: AppColors.grey400,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        ad.websiteUrl,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.info,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                if (ad.isLive) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${ad.daysRemaining} days remaining',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.success,
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // Action buttons
                Row(
                  children: [
                    // Toggle active/paused
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => ref
                            .read(adActionProvider.notifier)
                            .toggleStatus(
                              ad.id,
                              isActive ? AdStatus.paused : AdStatus.active,
                            ),
                        icon: Icon(
                          isActive
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          size: 16,
                        ),
                        label: Text(
                          isActive ? 'Pause' : 'Activate',
                          style: const TextStyle(fontSize: 12),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isActive
                              ? AppColors.warning
                              : AppColors.success,
                          side: BorderSide(
                            color: isActive
                                ? AppColors.warning
                                : AppColors.success,
                          ),
                          minimumSize: const Size(0, 36),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusMd,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Delete
                    OutlinedButton.icon(
                      onPressed: () => _confirmDelete(context, ref),
                      icon: const Icon(Icons.delete_outline_rounded, size: 16),
                      label: const Text(
                        'Delete',
                        style: TextStyle(fontSize: 12),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        minimumSize: const Size(0, 36),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusMd,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete ad?'),
        content: Text('Delete "${ad.title}"? This cannot be undone.'),
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
              ref.read(adActionProvider.notifier).deleteAd(ad.id);
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

class _CreateAdSheet extends ConsumerStatefulWidget {
  const _CreateAdSheet();

  @override
  ConsumerState<_CreateAdSheet> createState() => _CreateAdSheetState();
}

class _CreateAdSheetState extends ConsumerState<_CreateAdSheet> {
  final _titleCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();
  AdPlacement _placement = AdPlacement.homeFeed;
  DateTime _startsAt = DateTime.now();
  DateTime _endsAt = DateTime.now().add(const Duration(days: 30));
  int _priority = 0;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _imageCtrl.dispose();
    _urlCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startsAt : _endsAt,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AdminColors.accent),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startsAt = picked;
        } else {
          _endsAt = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (_titleCtrl.text.trim().isEmpty ||
        _imageCtrl.text.trim().isEmpty ||
        _urlCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final ad = AdModel(
      id: '',
      title: _titleCtrl.text.trim(),
      imageUrl: _imageCtrl.text.trim(),
      websiteUrl: _urlCtrl.text.trim(),
      placement: _placement,
      status: AdStatus.active,
      startsAt: _startsAt,
      endsAt: _endsAt,
      priority: _priority,
      createdAt: DateTime.now(),
    );

    await ref.read(adActionProvider.notifier).createAd(ad);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ad created successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adActionProvider);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSizes.pagePadding,
        AppSizes.pagePadding,
        AppSizes.pagePadding,
        MediaQuery.of(context).viewInsets.bottom + AppSizes.pagePadding,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Create new ad',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.grey900,
              ),
            ),
            const SizedBox(height: 20),

            MkTextField(
              label: 'Business name',
              hint: 'e.g. Sunrise Furniture Kathmandu',
              controller: _titleCtrl,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 14),

            MkTextField(
              label: 'Banner image URL',
              hint: 'https://...',
              controller: _imageCtrl,
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 4),
            const Text(
              'Upload your banner image to Firebase Storage or any image host and paste the URL here.',
              style: TextStyle(fontSize: 11, color: AppColors.grey400),
            ),
            const SizedBox(height: 14),

            MkTextField(
              label: 'Website URL',
              hint: 'https://...',
              controller: _urlCtrl,
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 14),

            // Placement selector
            const Text(
              'Placement',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.grey800,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AdPlacement.values.map((p) {
                final selected = _placement == p;
                return GestureDetector(
                  onTap: () => setState(() => _placement = p),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? AdminColors.accentLight
                          : AppColors.grey50,
                      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                      border: Border.all(
                        color: selected
                            ? AdminColors.accent
                            : AppColors.grey100,
                      ),
                    ),
                    child: Text(
                      _placementLabel(p),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: selected
                            ? AdminColors.accent
                            : AppColors.grey600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),

            // Date range
            Row(
              children: [
                Expanded(
                  child: _DateTile(
                    label: 'Starts',
                    date: _startsAt,
                    onTap: () => _pickDate(true),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DateTile(
                    label: 'Ends',
                    date: _endsAt,
                    onTap: () => _pickDate(false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Priority
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Priority (higher = shown first)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey800,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => setState(
                        () => _priority = (_priority - 1).clamp(0, 10),
                      ),
                      icon: const Icon(
                        Icons.remove_circle_outline_rounded,
                        color: AppColors.grey600,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                    Text(
                      '$_priority',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.grey900,
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(
                        () => _priority = (_priority + 1).clamp(0, 10),
                      ),
                      icon: const Icon(
                        Icons.add_circle_outline_rounded,
                        color: AppColors.grey600,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            MkButton(
              label: 'Create ad',
              onPressed: _submit,
              isLoading: state.isLoading,
              prefixIcon: Icons.campaign_rounded,
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  String _placementLabel(AdPlacement p) {
    switch (p) {
      case AdPlacement.homeFeed:
        return 'Home Feed';
      case AdPlacement.roomDetail:
        return 'Room Detail';
      case AdPlacement.searchResults:
        return 'Search';
      case AdPlacement.landingPage:
        return 'Landing Page';
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final AdModel ad;
  const _StatusBadge({required this.ad});

  @override
  Widget build(BuildContext context) {
    Color color;
    Color bg;
    String label;

    if (ad.isLive) {
      color = AppColors.success;
      bg = AppColors.successLight;
      label = 'Live';
    } else if (ad.status == AdStatus.paused) {
      color = AppColors.warning;
      bg = AppColors.warningLight;
      label = 'Paused';
    } else if (ad.status == AdStatus.expired ||
        DateTime.now().isAfter(ad.endsAt)) {
      color = AppColors.grey400;
      bg = AppColors.grey50;
      label = 'Expired';
    } else {
      color = AppColors.info;
      bg = AppColors.infoLight;
      label = 'Scheduled';
    }

    return StatusBadge(label: label, color: color, backgroundColor: bg);
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: AppColors.grey50,
      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: AppColors.grey400),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.grey600),
        ),
      ],
    ),
  );
}

class _DateTile extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;
  const _DateTile({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.grey100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.grey400),
          ),
          const SizedBox(height: 2),
          Text(
            Formatters.date(date),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.grey900,
            ),
          ),
        ],
      ),
    ),
  );
}
