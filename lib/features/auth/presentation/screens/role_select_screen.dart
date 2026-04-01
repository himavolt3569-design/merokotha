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
