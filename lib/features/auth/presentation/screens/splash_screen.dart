import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../data/user_repository.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final firebaseUser = await ref.read(authStateProvider.future);

    if (firebaseUser == null) {
      context.go(AppRoutes.landing);
      return;
    }

    final userExists = await ref.read(userRepositoryProvider).userExists(firebaseUser.uid);

    if (!mounted) return;

    if (!userExists) {
      context.go(AppRoutes.roleSelect);
    } else {
      final user = await ref.read(userRepositoryProvider).getUser(firebaseUser.uid);

      if (!mounted) return;

      if (user?.isAdmin == true) {
        context.go(AppRoutes.adminHome);
      } else if (user?.isOwner == true) {
        context.go(AppRoutes.ownerHome);
      } else {
        context.go(AppRoutes.customerHome);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                clipBehavior: Clip.hardEdge,
                padding: const EdgeInsets.all(12),
                child: Image.asset('assets/merokotha.png', fit: BoxFit.contain),
              ),
              const SizedBox(height: 20),
              const Text(
                AppStrings.appName,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1),
              ),
              const SizedBox(height: 8),
              Text(AppStrings.tagline, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8))),
              const SizedBox(height: 60),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
