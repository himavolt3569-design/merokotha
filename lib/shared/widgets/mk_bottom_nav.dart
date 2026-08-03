import 'package:flutter/material.dart';
import 'package:merokotha/core/constants/app_colors.dart';

/// Definition for a single destination in [MkBottomNav].
class MkBottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int badgeCount;

  const MkBottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.badgeCount = 0,
  });
}

/// Custom premium bottom navigation bar — replaces the default Material
/// [BottomNavigationBar] with a softer, hairline-topped, spring-tapped bar
/// shared between the owner and customer shells.
class MkBottomNav extends StatelessWidget {
  final int currentIndex;
  final List<MkBottomNavItem> items;
  final ValueChanged<int> onTap;
  final Color accentColor;

  const MkBottomNav({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
    this.accentColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(color: Color(0x0A1A1A18), blurRadius: 16, offset: Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _NavTapTarget(
                    item: items[i],
                    selected: i == currentIndex,
                    accentColor: accentColor,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavTapTarget extends StatelessWidget {
  final MkBottomNavItem item;
  final bool selected;
  final Color accentColor;
  final VoidCallback onTap;

  const _NavTapTarget({
    required this.item,
    required this.selected,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? accentColor : AppColors.grey400;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: accentColor.withValues(alpha: 0.08),
        highlightColor: accentColor.withValues(alpha: 0.04),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: Icon(
                    selected ? item.activeIcon : item.icon,
                    key: ValueKey(selected),
                    color: color,
                    size: 23,
                  ),
                ),
                if (item.badgeCount > 0)
                  Positioned(
                    top: -3,
                    right: -8,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        item.badgeCount > 9 ? '9+' : '${item.badgeCount}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}
