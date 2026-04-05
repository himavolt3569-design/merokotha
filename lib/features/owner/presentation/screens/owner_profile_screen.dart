import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:merokotha/shared/widgets/owner_botton_nav.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/widgets/mk_app_bar.dart';
import '../../../../shared/widgets/mk_button.dart';
import '../../../../shared/widgets/mk_text_field.dart';
import '../../../../shared/widgets/mk_widgets.dart';
import '../../../auth/data/user_repository.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../../core/utils/validators.dart';

class OwnerProfileScreen extends ConsumerStatefulWidget {
  const OwnerProfileScreen({super.key});

  @override
  ConsumerState<OwnerProfileScreen> createState() => _OwnerProfileScreenState();
}

class _OwnerProfileScreenState extends ConsumerState<OwnerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  bool _isEditing = false;
  bool _isSaving = false;
  bool _isLoaded = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  void _loadUser(UserModel user) {
    if (!_isLoaded) {
      _nameCtrl.text = user.name;
      _locationCtrl.text = user.location ?? '';
      _isLoaded = true;
    }
  }

  Future<void> _save(UserModel user) async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);

    try {
      await ref.read(userRepositoryProvider).updateUser(user.id, {
        'name': _nameCtrl.text.trim(),
        'location': _locationCtrl.text.trim(),
      });
      if (mounted) {
        setState(() {
          _isEditing = false;
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _switchRole(UserModel user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Switch to Customer?'),
        content: const Text(
          'You will be switched to Customer mode. You can switch back anytime from your profile.',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Switch',
              style: TextStyle(color: AppColors.customerPrimary),
            ),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    await ref
        .read(userRepositoryProvider)
        .updateRole(user.id, UserRole.customer);
    if (mounted) context.go(AppRoutes.customerHome);
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('Are you sure you want to sign out?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Sign out',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    await ref.read(authRepositoryProvider).signOut();
    if (mounted) context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: MkAppBar(
        title: 'Profile',
        showBack: false,
        actions: [
          if (!_isEditing)
            TextButton(
              onPressed: () => setState(() => _isEditing = true),
              child: const Text(
                'Edit',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (_isEditing)
            TextButton(
              onPressed: () => setState(() {
                _isEditing = false;
                _isLoaded = false;
                userAsync.whenData((u) {
                  if (u != null) _loadUser(u);
                });
              }),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.grey400),
              ),
            ),
        ],
      ),
      body: userAsync.when(
        loading: () => const MkLoading(),
        error: (e, _) => MkErrorWidget(message: e.toString()),
        data: (user) {
          if (user == null) {
            return const MkErrorWidget(message: 'User not found');
          }
          _loadUser(user);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.pagePadding),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // ── Avatar section ──
                  _AvatarSection(user: user),
                  const SizedBox(height: 24),

                  // ── Info card ──
                  _Card(
                    title: 'Personal information',
                    children: [
                      MkTextField(
                        label: 'Full name',
                        controller: _nameCtrl,
                        validator: Validators.name,
                        enabled: _isEditing,
                        textCapitalization: TextCapitalization.words,
                        prefixIcon: const Icon(
                          Icons.person_outline_rounded,
                          size: 18,
                          color: AppColors.grey400,
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),
                      MkTextField(
                        label: 'Phone number',
                        controller: TextEditingController(text: user.phone),
                        enabled: false,
                        prefixIcon: const Icon(
                          Icons.phone_outlined,
                          size: 18,
                          color: AppColors.grey400,
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),
                      MkTextField(
                        label: 'Location',
                        controller: _locationCtrl,
                        enabled: _isEditing,
                        textCapitalization: TextCapitalization.words,
                        prefixIcon: const Icon(
                          Icons.location_on_outlined,
                          size: 18,
                          color: AppColors.grey400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Save button (edit mode) ──
                  if (_isEditing) ...[
                    MkButton(
                      label: 'Save changes',
                      onPressed: () => _save(user),
                      isLoading: _isSaving,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Account card ──
                  _Card(
                    title: 'Account',
                    children: [
                      _SettingsTile(
                        icon: Icons.verified_user_outlined,
                        label: 'Verified status',
                        trailing: user.isVerified
                            ? const StatusBadge(
                                label: 'Verified',
                                color: AppColors.success,
                                backgroundColor: AppColors.successLight,
                              )
                            : const StatusBadge(
                                label: 'Unverified',
                                color: AppColors.grey400,
                                backgroundColor: AppColors.grey50,
                              ),
                      ),
                      _Divider(),
                      _SettingsTile(
                        icon: Icons.swap_horiz_rounded,
                        label: 'Switch to Customer mode',
                        onTap: () => _switchRole(user),
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          size: 20,
                          color: AppColors.grey400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── App card ──
                  _Card(
                    title: 'App',
                    children: [
                      _SettingsTile(
                        icon: Icons.language_rounded,
                        label: 'Language',
                        trailing: const Text(
                          'English',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.grey400,
                          ),
                        ),
                        onTap: () {},
                      ),
                      _Divider(),
                      _SettingsTile(
                        icon: Icons.info_outline_rounded,
                        label: 'App version',
                        trailing: const Text(
                          '1.0.0',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.grey400,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Sign out ──
                  MkButton(
                    label: 'Sign out',
                    onPressed: _signOut,
                    variant: MkButtonVariant.danger,
                    prefixIcon: Icons.logout_rounded,
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const OwnerBottomNav(currentIndex: 4),
    );
  }
}

// ── Shared sub-widgets ─────────────────────────────────────────────

class _AvatarSection extends StatelessWidget {
  final UserModel user;
  const _AvatarSection({required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            UserAvatar(name: user.name, photoUrl: user.photoUrl, size: 88),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          user.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.grey900,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.ownerLight,
            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.house_rounded,
                size: 12,
                color: AppColors.ownerPrimary,
              ),
              SizedBox(width: 5),
              Text(
                'House Owner',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ownerPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Card({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.grey50),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.md,
              AppSizes.md,
              AppSizes.md,
              10,
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.grey600,
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.grey50),
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.grey50,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Icon(icon, size: 17, color: AppColors.grey600),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 14, color: AppColors.grey900),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, color: AppColors.grey50);
}
