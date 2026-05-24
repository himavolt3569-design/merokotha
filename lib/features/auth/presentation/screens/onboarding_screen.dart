import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:merokotha/core/constants/app_colors.dart';
import 'package:merokotha/core/constants/app_sizes.dart';
import 'package:merokotha/core/constants/app_strings.dart';
import 'package:merokotha/core/router/app_routes.dart';
import 'package:merokotha/core/utils/validators.dart';
import 'package:merokotha/features/auth/data/user_repository.dart';
import 'package:merokotha/features/auth/providers/auth_provider.dart';
import 'package:merokotha/shared/models/user_model.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();

  bool _isSaving = false;
  UserRole? _role;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get role passed from role_select_screen via GoRouter extra
    final extra = GoRouterState.of(context).extra;
    if (extra is UserRole) _role = extra;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() => _isSaving = true);

    try {
      final firebaseUser = ref.read(authStateProvider).value;
      if (firebaseUser == null) throw Exception('Not authenticated');

      final role = _role ?? UserRole.customer;
      final now = DateTime.now();

      final user = UserModel(
        id: firebaseUser.uid,
        name: _nameController.text.trim(),
        phone: firebaseUser.phoneNumber ?? '',
        role: role,
        location: _locationController.text.trim(),
        createdAt: now,
        updatedAt: now,
      );

      await ref.read(userRepositoryProvider).createUser(user);

      if (!mounted) return;

      // Navigate to the correct home based on role
      if (role == UserRole.owner) {
        context.go(AppRoutes.ownerHome);
      } else if (role == UserRole.superAdmin) {
        context.go(AppRoutes.adminHome);
      } else {
        context.go(AppRoutes.customerHome);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save profile: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Color get _themeColor {
    if (_role == UserRole.owner) return AppColors.ownerPrimary;
    if (_role == UserRole.superAdmin) return AppColors.error;
    return AppColors.customerPrimary;
  }

  Color get _themeLightColor {
    if (_role == UserRole.owner) return AppColors.ownerLight;
    if (_role == UserRole.superAdmin) return AppColors.errorLight;
    return AppColors.customerLight;
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = _role == UserRole.owner;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.pagePadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // Role badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _themeLightColor,
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isOwner ? Icons.house_rounded : Icons.search_rounded,
                        size: 14,
                        color: _themeColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isOwner ? AppStrings.owner : AppStrings.customer,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _themeColor,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Heading
                const Text(
                  AppStrings.setupProfile,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.grey900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tell us a bit about yourself to get started.',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.grey600,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 32),

                // ── Full name ──
                _SectionLabel(label: AppStrings.fullName),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  validator: Validators.name,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: AppStrings.fullNameHint,
                    prefixIcon: Icon(
                      Icons.person_outline_rounded,
                      size: 20,
                      color: AppColors.grey400,
                    ),
                  ),
                ),

                const SizedBox(height: AppSizes.md),

                // ── Location ──
                _SectionLabel(label: AppStrings.location),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _locationController,
                  validator: (v) =>
                      Validators.required(v, fieldName: 'Location'),
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: AppStrings.locationHint,
                    prefixIcon: Icon(
                      Icons.location_on_outlined,
                      size: 20,
                      color: AppColors.grey400,
                    ),
                  ),
                ),

                const SizedBox(height: AppSizes.xl),

                // Save button
                SizedBox(
                  width: double.infinity,
                  height: AppSizes.buttonHeight,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _themeColor,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(AppStrings.saveProfile),
                  ),
                ),

                const SizedBox(height: AppSizes.md),

                // Go back to change role
                Center(
                  child: GestureDetector(
                    onTap: () => context.go(AppRoutes.roleSelect),
                    child: const Text(
                      'Change role selection',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.grey400,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSizes.md),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.grey800,
      ),
    );
  }
}
