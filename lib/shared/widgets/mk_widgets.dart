import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

// ─────────────────────────── User Avatar ───────────────────────────

class UserAvatar extends StatelessWidget {
  final String? photoUrl;
  final String name;
  final double size;
  final Color? backgroundColor;

  const UserAvatar({
    super.key,
    this.photoUrl,
    required this.name,
    this.size = AppSizes.avatarMd,
    this.backgroundColor,
  });

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: backgroundColor ?? AppColors.primaryLight,
      child: photoUrl != null && photoUrl!.isNotEmpty
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: photoUrl!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                placeholder: (_, _) => _initialsWidget,
                errorWidget: (_, _, _) => _initialsWidget,
              ),
            )
          : _initialsWidget,
    );
  }

  Widget get _initialsWidget => Text(
    _initials,
    style: TextStyle(
      fontSize: size * 0.35,
      fontWeight: FontWeight.w600,
      color: AppColors.primary,
    ),
  );
}

// ─────────────────────────── Price Badge ───────────────────────────

class PriceBadge extends StatelessWidget {
  final double amount;
  final bool showPerMonth;
  final double fontSize;

  const PriceBadge({
    super.key,
    required this.amount,
    this.showPerMonth = true,
    this.fontSize = 15,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'NPR ${_format(amount)}',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          if (showPerMonth)
            TextSpan(
              text: '/mo',
              style: TextStyle(
                fontSize: fontSize - 3,
                fontWeight: FontWeight.w400,
                color: AppColors.grey400,
              ),
            ),
        ],
      ),
    );
  }

  String _format(double v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }
}

// ─────────────────────────── Loading ───────────────────────────

class MkLoading extends StatelessWidget {
  final bool fullScreen;

  const MkLoading({super.key, this.fullScreen = true});

  @override
  Widget build(BuildContext context) {
    final spinner = const CircularProgressIndicator(
      strokeWidth: 2.5,
      color: AppColors.primary,
    );
    if (!fullScreen) return Center(child: spinner);
    return Scaffold(body: Center(child: spinner));
  }
}

// ─────────────────────────── Error Widget ───────────────────────────

class MkErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const MkErrorWidget({
    super.key,
    this.message = 'Something went wrong',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.pagePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.grey600,
                height: 1.5,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Try again'),
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────── Empty State ───────────────────────────

class MkEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const MkEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.inbox_rounded,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.pagePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.grey50,
                borderRadius: BorderRadius.circular(AppSizes.radiusXl),
              ),
              child: Icon(icon, size: 40, color: AppColors.grey400),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.grey900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.grey400,
                height: 1.5,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────── Status Badge ───────────────────────────

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color backgroundColor;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  factory StatusBadge.active() => const StatusBadge(
    label: 'Active',
    color: AppColors.success,
    backgroundColor: AppColors.successLight,
  );

  factory StatusBadge.paused() => const StatusBadge(
    label: 'Paused',
    color: AppColors.warning,
    backgroundColor: AppColors.warningLight,
  );

  factory StatusBadge.rented() => const StatusBadge(
    label: 'Rented',
    color: AppColors.grey600,
    backgroundColor: AppColors.grey50,
  );

  factory StatusBadge.pending() => const StatusBadge(
    label: 'Pending',
    color: AppColors.warning,
    backgroundColor: AppColors.warningLight,
  );

  factory StatusBadge.accepted() => const StatusBadge(
    label: 'Accepted',
    color: AppColors.success,
    backgroundColor: AppColors.successLight,
  );

  factory StatusBadge.declined() => const StatusBadge(
    label: 'Declined',
    color: AppColors.error,
    backgroundColor: AppColors.errorLight,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
