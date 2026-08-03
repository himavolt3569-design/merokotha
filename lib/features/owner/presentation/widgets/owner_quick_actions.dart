import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:merokotha/core/constants/app_colors.dart';
import 'package:merokotha/core/constants/app_sizes.dart';
import 'package:merokotha/core/router/app_routes.dart';

class OwnerQuickActions extends StatelessWidget {
  const OwnerQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _QuickActionButton(
          label: 'Add room',
          icon: Icons.add_home_outlined,
          color: AppColors.primary,
          onTap: () => context.push(AppRoutes.uploadListing),
        ),
        const SizedBox(width: 10),
        _QuickActionButton(
          label: 'Listings',
          icon: Icons.list_alt_rounded,
          color: AppColors.info,
          onTap: () => context.push(AppRoutes.myListings),
        ),
        const SizedBox(width: 10),
        _QuickActionButton(
          label: 'Inquiries',
          icon: Icons.inbox_rounded,
          color: AppColors.warning,
          onTap: () => context.push(AppRoutes.ownerInquiries),
        ),
        const SizedBox(width: 10),
        _QuickActionButton(
          label: 'Map',
          icon: Icons.map_outlined,
          color: AppColors.secondary,
          onTap: () => context.push(AppRoutes.ownerMap),
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          splashColor: color.withValues(alpha: 0.08),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              boxShadow: AppSizes.shadowCard,
            ),
            child: Column(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: AppColors.grey800,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
