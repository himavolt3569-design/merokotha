import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:merokotha/core/constants/app_colors.dart';
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

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  bool _isSaving = false;
  UserRole? _role;

  late final AnimationController _animCtrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _headerSlide;
  late final Animation<Offset> _cardSlide;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fade = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animCtrl,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutCubic),
      ),
    );
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.07),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animCtrl,
        curve: const Interval(0.25, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _animCtrl.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final extra = GoRouterState.of(context).extra;
    if (extra is UserRole) _role = extra;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);
    try {
      final fbUser = ref.read(authStateProvider).value;
      if (fbUser == null) throw Exception('Not authenticated');
      final role = _role ?? UserRole.customer;
      final now = DateTime.now();
      final user = UserModel(
        id: fbUser.uid,
        name: _nameCtrl.text.trim(),
        phone: fbUser.phoneNumber ?? '',
        role: role,
        location: _locationCtrl.text.trim(),
        createdAt: now,
        updatedAt: now,
      );
      await ref.read(userRepositoryProvider).createUser(user);
      if (!mounted) return;
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
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  bool get _isOwner => _role == UserRole.owner;
  Color get _accent =>
      _isOwner ? AppColors.ownerPrimary : AppColors.customerPrimary;
  Color get _accentLight =>
      _isOwner ? AppColors.ownerLight : AppColors.customerLight;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F3),
      body: FadeTransition(
        opacity: _fade,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SlideTransition(
                    position: _headerSlide,
                    child: _HeaderPanel(
                      isOwner: _isOwner,
                      accent: _accent,
                      accentLight: _accentLight,
                    ),
                  ),
                  SlideTransition(
                    position: _cardSlide,
                    child: FadeTransition(
                      opacity: _fade,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _FormCard(
                              nameCtrl: _nameCtrl,
                              locationCtrl: _locationCtrl,
                              accent: _accent,
                            ),
                            const SizedBox(height: 24),
                            _CtaButton(
                              accent: _accent,
                              isSaving: _isSaving,
                              onTap: _save,
                            ),
                            const SizedBox(height: 18),
                            Center(
                              child: GestureDetector(
                                onTap: () => context.go(AppRoutes.roleSelect),
                                child: Text(
                                  'Change role selection',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 13,
                                    color: const Color(0xFF8C8880),
                                    decoration: TextDecoration.underline,
                                    decorationColor: const Color(0xFF8C8880),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Header panel ─────────────────────────────────────────────────────────────

class _HeaderPanel extends StatelessWidget {
  final bool isOwner;
  final Color accent;
  final Color accentLight;

  const _HeaderPanel({
    required this.isOwner,
    required this.accent,
    required this.accentLight,
  });

  @override
  Widget build(BuildContext context) {
    final chips = isOwner
        ? ['List for free', 'Reach tenants', 'Manage inquiries']
        : ['Browse listings', 'Save favourites', 'Contact owners'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 36, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Role badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: accentLight,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isOwner ? Icons.house_rounded : Icons.search_rounded,
                  size: 13,
                  color: accent,
                ),
                const SizedBox(width: 6),
                Text(
                  isOwner ? 'Room Owner' : 'Room Seeker',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: accent,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          Text(
            isOwner ? 'List your\nplace in minutes' : 'Find your\nperfect room',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 38,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1917),
              height: 1.1,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'Tell us a bit about yourself to personalise your experience.',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: const Color(0xFF8C8880),
              height: 1.6,
            ),
          ),

          const SizedBox(height: 24),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: chips
                .map(
                  (label) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F6F3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE8E5E0)),
                    ),
                    child: Text(
                      label,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: const Color(0xFF5F5E5A),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ── Form card ─────────────────────────────────────────────────────────────────

class _FormCard extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController locationCtrl;
  final Color accent;

  const _FormCard({
    required this.nameCtrl,
    required this.locationCtrl,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 24,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your details',
            style: GoogleFonts.dmSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1917),
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 22),
          _Field(
            ctrl: nameCtrl,
            label: 'Full name',
            hint: 'e.g. Hari Thapa',
            icon: Icons.person_outline_rounded,
            validator: Validators.name,
            accent: accent,
          ),
          const SizedBox(height: 18),
          _Field(
            ctrl: locationCtrl,
            label: 'Location',
            hint: 'e.g. Kathmandu, Baneshwor',
            icon: Icons.location_on_outlined,
            validator: (v) => Validators.required(v, fieldName: 'Location'),
            accent: accent,
          ),
        ],
      ),
    );
  }
}

// ── Input field ───────────────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final String hint;
  final IconData icon;
  final String? Function(String?)? validator;
  final Color accent;

  const _Field({
    required this.ctrl,
    required this.label,
    required this.hint,
    required this.icon,
    required this.validator,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF8C8880),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl,
          validator: validator,
          textCapitalization: TextCapitalization.words,
          style: GoogleFonts.dmSans(
            fontSize: 15,
            color: const Color(0xFF1A1917),
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.dmSans(
              fontSize: 14,
              color: const Color(0xFFB4B2A9),
            ),
            prefixIcon: Icon(icon, size: 18, color: const Color(0xFF8C8880)),
            filled: true,
            fillColor: const Color(0xFFF7F6F3),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE8E5E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE8E5E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: accent, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

// ── CTA button ────────────────────────────────────────────────────────────────

class _CtaButton extends StatelessWidget {
  final Color accent;
  final bool isSaving;
  final VoidCallback onTap;

  const _CtaButton({
    required this.accent,
    required this.isSaving,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 54,
      decoration: BoxDecoration(
        color: isSaving ? accent.withValues(alpha: 0.65) : accent,
        borderRadius: BorderRadius.circular(14),
        boxShadow: isSaving
            ? []
            : [
                BoxShadow(
                  color: accent.withValues(alpha: 0.28),
                  blurRadius: 18,
                  offset: const Offset(0, 7),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: isSaving ? null : onTap,
          child: Center(
            child: isSaving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Continue',
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
