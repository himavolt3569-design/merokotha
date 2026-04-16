import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/models/listing_model.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/widgets/mk_widgets.dart';

// ── Admin color constants ──────────────────────────────────────────
class AdminColors {
  static const primary = Color(0xFF2C2C2A);
  static const accent = Color(0xFFE24B4A);
  static const accentLight = Color(0xFFFCEBEB);
  static const surface = Color(0xFF3D3D3A);
  static const bg = Color(0xFF1A1A18);
}

// ─────────────────────────── Admin Bottom Nav ─────────────────────

class AdminBottomNav extends StatelessWidget {
  final int currentIndex;
  const AdminBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AdminColors.primary,
        border: Border(top: BorderSide(color: AdminColors.surface, width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AdminColors.accent,
        unselectedItemColor: AppColors.grey400,
        selectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        onTap: (i) {
          switch (i) {
            case 0:
              context.go(AppRoutes.adminHome);
              break;
            case 1:
              context.go(AppRoutes.adminUsers);
              break;
            case 2:
              context.go(AppRoutes.adminListings);
              break;
            case 3:
              context.go(AppRoutes.adminInquiries);
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline_rounded),
            activeIcon: Icon(Icons.people_rounded),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_work_outlined),
            activeIcon: Icon(Icons.home_work_rounded),
            label: 'Listings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inbox_outlined),
            activeIcon: Icon(Icons.inbox_rounded),
            label: 'Inquiries',
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── Admin App Bar ────────────────────────

class AdminAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBack;

  const AdminAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBack = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AdminColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      leading: showBack
          ? IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: Colors.white,
              ),
              onPressed: () => context.pop(),
            )
          : null,
      title: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AdminColors.accent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.shield_rounded,
              size: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AdminColors.surface),
      ),
    );
  }
}

// ─────────────────────────── Stat Card ───────────────────────────

class AdminStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const AdminStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: AppColors.grey50),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppColors.grey900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.grey400),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────── User Tile ───────────────────────────

class AdminUserTile extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onTap;
  final VoidCallback? onBan;
  final VoidCallback? onUnban;

  const AdminUserTile({
    super.key,
    required this.user,
    this.onTap,
    this.onBan,
    this.onUnban,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: user.isBanned ? AppColors.errorLight : Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(
            color: user.isBanned
                ? AppColors.error.withOpacity(0.3)
                : AppColors.grey50,
          ),
        ),
        child: Row(
          children: [
            // Avatar
            UserAvatar(
              name: user.name,
              photoUrl: user.photoUrl,
              size: 44,
              backgroundColor: user.isOwner
                  ? AppColors.ownerLight
                  : user.isAdmin
                  ? AdminColors.accentLight
                  : AppColors.customerLight,
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.grey900,
                        ),
                      ),
                      if (user.isBanned) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'BANNED',
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.phone,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.grey400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _RoleBadge(role: user.role),
                      const SizedBox(width: 6),
                      Text(
                        Formatters.timeAgo(user.createdAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.grey400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Action button
            if (user.isBanned && onUnban != null)
              _SmallAction(
                label: 'Unban',
                color: AppColors.success,
                onTap: onUnban!,
              )
            else if (!user.isBanned && !user.isAdmin && onBan != null)
              _SmallAction(label: 'Ban', color: AppColors.error, onTap: onBan!),

            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.grey400,
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final UserRole role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;
    switch (role) {
      case UserRole.owner:
        bg = AppColors.ownerLight;
        fg = AppColors.ownerPrimary;
        label = 'Owner';
        break;
      case UserRole.customer:
        bg = AppColors.customerLight;
        fg = AppColors.customerPrimary;
        label = 'Customer';
        break;
      case UserRole.superAdmin:
        bg = AdminColors.accentLight;
        fg = AdminColors.accent;
        label = 'Admin';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}

class _SmallAction extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _SmallAction({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
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
      ),
    );
  }
}

// ─────────────────────────── Admin Listing Tile ──────────────────

class AdminListingTile extends StatelessWidget {
  final ListingModel listing;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onTap;

  const AdminListingTile({
    super.key,
    required this.listing,
    this.onDelete,
    this.onToggleStatus,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: AppColors.grey50),
        ),
        child: Row(
          children: [
            // Photo
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              child: listing.photoUrls.isNotEmpty
                  ? Image.network(
                      listing.photoUrls.first,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _placeholder,
                    )
                  : _placeholder,
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    listing.ownerName,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.grey400,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      PriceBadge(amount: listing.rentPerMonth, fontSize: 12),
                      const SizedBox(width: 8),
                      _statusBadge(listing.status),
                    ],
                  ),
                ],
              ),
            ),

            // Actions
            Column(
              children: [
                if (onToggleStatus != null)
                  _SmallAction(
                    label: listing.isActive ? 'Pause' : 'Activate',
                    color: AppColors.warning,
                    onTap: onToggleStatus!,
                  ),
                if (onDelete != null) ...[
                  const SizedBox(height: 4),
                  _SmallAction(
                    label: 'Delete',
                    color: AppColors.error,
                    onTap: onDelete!,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget get _placeholder => Container(
    width: 60,
    height: 60,
    color: AppColors.grey50,
    child: const Icon(Icons.image_outlined, color: AppColors.grey100, size: 24),
  );

  Widget _statusBadge(ListingStatus status) {
    switch (status) {
      case ListingStatus.active:
        return StatusBadge.active();
      case ListingStatus.paused:
        return StatusBadge.paused();
      case ListingStatus.rented:
        return StatusBadge.rented();
    }
  }
}
