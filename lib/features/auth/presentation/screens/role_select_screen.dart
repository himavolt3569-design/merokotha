import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/models/user_model.dart';
import '../widgets/role_card.dart';

// Temporary provider to hold selected role before saving
final _selectedRoleProvider = StateProvider<UserRole?>((ref) => null);

// Secret admin code — change this in production
const _ADMIN_SECRET_CODE = 'admin123';

class RoleSelectScreen extends ConsumerWidget {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(_selectedRoleProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Header
              const Text(
                AppStrings.chooseRole,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'This helps us personalise your experience.\nYou can switch roles later from your profile.',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.grey600,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 40),

              // Owner card
              RoleCard(
                title: AppStrings.owner,
                description: AppStrings.ownerDesc,
                icon: Icons.house_rounded,
                isSelected: selected == UserRole.owner,
                color: AppColors.ownerPrimary,
                lightColor: AppColors.ownerLight,
                onTap: () => ref.read(_selectedRoleProvider.notifier).state =
                    UserRole.owner,
              ),

              const SizedBox(height: AppSizes.md),

              // Customer card
              RoleCard(
                title: AppStrings.customer,
                description: AppStrings.customerDesc,
                icon: Icons.search_rounded,
                isSelected: selected == UserRole.customer,
                color: AppColors.customerPrimary,
                lightColor: AppColors.customerLight,
                onTap: () => ref.read(_selectedRoleProvider.notifier).state =
                    UserRole.customer,
              ),

              const Spacer(),

              // Hidden admin code button (tap icon 5 times to reveal)
              _HiddenAdminButton(
                onAdminSelected: () =>
                    ref.read(_selectedRoleProvider.notifier).state =
                        UserRole.superAdmin,
                selected: selected,
              ),

              const SizedBox(height: AppSizes.md),

              // Continue button
              SizedBox(
                width: double.infinity,
                height: AppSizes.buttonHeight,
                child: ElevatedButton(
                  onPressed: selected == null
                      ? null
                      : () => context.go(AppRoutes.onboarding, extra: selected),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selected == UserRole.owner
                        ? AppColors.ownerPrimary
                        : selected == UserRole.customer
                        ? AppColors.customerPrimary
                        : selected == UserRole.superAdmin
                        ? Colors.blueGrey
                        : null,
                  ),
                  child: const Text(AppStrings.continueText),
                ),
              ),

              const SizedBox(height: AppSizes.md),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Hidden Admin Login Button ──
class _HiddenAdminButton extends StatefulWidget {
  final VoidCallback onAdminSelected;
  final UserRole? selected;

  const _HiddenAdminButton({
    required this.onAdminSelected,
    required this.selected,
  });

  @override
  State<_HiddenAdminButton> createState() => _HiddenAdminButtonState();
}

class _HiddenAdminButtonState extends State<_HiddenAdminButton> {
  int _tapCount = 0;

  void _onTap() {
    _tapCount++;
    if (_tapCount >= 5) {
      _tapCount = 0;
      _showAdminDialog();
    }
  }

  void _showAdminDialog() {
    final codeController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Admin Access'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.admin_panel_settings_rounded,
              size: 48,
              color: Colors.blueGrey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Enter admin code to proceed',
              style: TextStyle(fontSize: 14, color: AppColors.grey600),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: codeController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Admin code',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (codeController.text.trim() == _ADMIN_SECRET_CODE) {
                Navigator.pop(context);
                widget.onAdminSelected();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✓ Admin role selected'),
                    backgroundColor: Colors.blueGrey,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✗ Invalid admin code'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: Container(
        alignment: Alignment.center,
        child: Text(
          widget.selected == UserRole.superAdmin
              ? '🔐 Admin Mode'
              : '👤 Select role above',
          style: TextStyle(
            fontSize: 12,
            color: widget.selected == UserRole.superAdmin
                ? Colors.blueGrey
                : AppColors.grey400,
          ),
        ),
      ),
    );
  }
}
