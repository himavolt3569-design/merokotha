import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:merokotha/core/router/app_routes.dart';
import 'package:merokotha/features/ads/data/ad_model.dart';
import 'package:merokotha/features/ads/presentation/widgets/ad_banner.dart';
import 'package:merokotha/features/customer/providers/customers_providers.dart';
import 'package:merokotha/features/landing/presentation/widgets/landing_theme.dart';
import 'package:merokotha/features/landing/presentation/widgets/landing_search_bar.dart';
import 'package:merokotha/features/landing/presentation/widgets/landing_category_row.dart';
import 'package:merokotha/features/landing/presentation/widgets/landing_toggle_view.dart';
import 'package:merokotha/features/landing/presentation/widgets/landing_listing_cards.dart';

class LandingScreen extends ConsumerStatefulWidget {
  const LandingScreen({super.key});

  @override
  ConsumerState<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends ConsumerState<LandingScreen> {
  String _search = '';
  String? _category;
  bool _isGrid = false;

  @override
  Widget build(BuildContext context) {
    final listingsAsync = ref.watch(activeListingsProvider);

    return Scaffold(
      backgroundColor: LandingTheme.bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: LandingTheme.bg,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            titleSpacing: 20,
            title: Row(
              children: [
                Text(
                  'MeroKotha',
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                    color: LandingTheme.ink,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () => context.go(AppRoutes.login),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: LandingTheme.hairline, width: 1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Sign In',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: LandingTheme.ink,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 20,
                        height: 1.5,
                        color: LandingTheme.accentMuted,
                      ),
                      const SizedBox(width: 8),
                      Text('KATHMANDU & BEYOND', style: LandingTheme.labelSm),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Find Your\nNext Home\nin Nepal',
                    style: LandingTheme.displayLg,
                  ),
                  const SizedBox(height: 24),
                  LandingSearchBar(
                    onChanged: (v) => setState(() => _search = v.toLowerCase()),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: LandingCategoryRow(
              selected: _category,
              onSelect: (c) => setState(() => _category = c),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          const SliverToBoxAdapter(
            child: AdBanner(placement: AdPlacement.landingPage),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 16, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('AVAILABLE ROOMS', style: LandingTheme.labelSm),
                  const Spacer(),
                  LandingToggleView(
                    isGrid: _isGrid,
                    onToggle: () => setState(() => _isGrid = !_isGrid),
                  ),
                ],
              ),
            ),
          ),

          listingsAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: LandingTheme.accent,
                  ),
                ),
              ),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(
                child: Text('Error: $e', style: LandingTheme.bodyMd),
              ),
            ),
            data: (list) {
              final listings = list.where((l) {
                final matchQ =
                    _search.isEmpty || l.title.toLowerCase().contains(_search);
                final matchC = _category == null || l.roomType == _category;
                return matchQ && matchC;
              }).toList();

              if (listings.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          color: LandingTheme.stone,
                          size: 40,
                        ),
                        const SizedBox(height: 12),
                        Text('No properties found', style: LandingTheme.bodyMd),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                sliver: _isGrid
                    ? SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 14,
                              crossAxisSpacing: 14,
                              childAspectRatio: 0.62,
                            ),
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) => LandingGridCard(
                            listing: listings[i],
                            onTap: () => context.push(
                              AppRoutes.roomDetail.replaceAll(
                                ':id',
                                listings[i].id,
                              ),
                            ),
                          ),
                          childCount: listings.length,
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: LandingListCard(
                              listing: listings[i],
                              onTap: () => context.push(
                                AppRoutes.roomDetail.replaceAll(
                                  ':id',
                                  listings[i].id,
                                ),
                              ),
                            ),
                          ),
                          childCount: listings.length,
                        ),
                      ),
              );
            },
          ),
        ],
      ),
    );
  }
}
