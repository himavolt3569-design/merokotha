import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:merokotha/core/router/app_routes.dart';
import 'package:merokotha/features/landing/presentation/widgets/landing_search_bar.dart';
import 'package:merokotha/features/landing/presentation/widgets/landing_theme.dart';

/// Full-bleed photo hero with a dark overlay, brand mark and a search bar
/// that floats half-over the photo, half-over the content below it.
class LandingHero extends StatelessWidget {
  final String? photoUrl;
  final ValueChanged<String> onSearchChanged;

  static const double overlap = 30;

  const LandingHero({
    super.key,
    required this.photoUrl,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final heroHeight = MediaQuery.sizeOf(context).height * 0.46;

    return SizedBox(
      height: heroHeight + overlap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
            child: SizedBox(
              height: heroHeight,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: photoUrl != null
                        ? CachedNetworkImage(
                            key: ValueKey(photoUrl),
                            imageUrl: photoUrl!,
                            fit: BoxFit.cover,
                            fadeInDuration: const Duration(milliseconds: 300),
                            errorWidget: (_, _, _) => const _HeroFallback(),
                          )
                        : const _HeroFallback(key: ValueKey('fallback')),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x66000000),
                          Color(0x11000000),
                          Color(0x22000000),
                          Color(0xB3000000),
                        ],
                        stops: [0.0, 0.35, 0.6, 1.0],
                      ),
                    ),
                  ),
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 16, 0),
                      child: Row(
                        children: [
                          const Text('🏠', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 6),
                          Text(
                            'Mero Kotha',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.2,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          _SignInChip(
                            onTap: () => context.go(AppRoutes.login),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: overlap + 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'मेरो कोठा · Nepal',
                          style: LandingTheme.labelSm.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Find Your Next\nHome in Nepal',
                          style: LandingTheme.displayLg,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 0,
            child: LandingSearchBar(onChanged: onSearchChanged),
          ),
        ],
      ),
    );
  }
}

class _HeroFallback extends StatelessWidget {
  const _HeroFallback({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [LandingTheme.accentDark, LandingTheme.accent],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.home_work_outlined,
          size: 72,
          color: Colors.white.withValues(alpha: 0.25),
        ),
      ),
    );
  }
}

class _SignInChip extends StatelessWidget {
  final VoidCallback onTap;
  const _SignInChip({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
          ),
          child: const Text(
            'Sign In',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
