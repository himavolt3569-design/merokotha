import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:merokotha/core/router/app_routes.dart';
import 'package:merokotha/features/customer/providers/customers_providers.dart';

import 'package:merokotha/shared/models/listing_model.dart';
import 'package:merokotha/shared/widgets/mk_widgets.dart';

class _T {
  static const bg = Color(0xFFF5F4F0);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF15140F);
  static const inkMid = Color(0xFF6B6A62);
  static const inkFaint = Color(0xFFB8B7AF);
  static const accent = Color(0xFF1B4332);
  static const accentMid = Color(0xFF2D6A4F);
  static const accentPop = Color(0xFFD4F5E2);
  static const cardBorder = Color(0xFFECEBE6);

  static const r8 = 8.0;
  static const r12 = 12.0;
  static const r16 = 16.0;
  static const r24 = 24.0;
  static const rFull = 100.0;
}

// ─── Landing Screen ──────────────────────────────────────────────────────────

class LandingScreen extends ConsumerStatefulWidget {
  const LandingScreen({super.key});

  @override
  ConsumerState<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends ConsumerState<LandingScreen> {
  String _searchQuery = '';
  String? _selectedL1Name;
  final _scrollController = ScrollController();
  bool _isHeaderCollapsed = false;
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final collapsed = _scrollController.offset > 50;
      if (collapsed != _isHeaderCollapsed) {
        setState(() => _isHeaderCollapsed = collapsed);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listingsAsync = ref.watch(activeListingsProvider);
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _T.bg,
        body: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Spacer for sticky header
                SliverToBoxAdapter(child: SizedBox(height: topPadding + 64)),

                // Hero Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                    child: _HeroCard(listingsAsync: listingsAsync),
                  ),
                ),

                // Category Chips
                SliverToBoxAdapter(
                  child: _CategoryChips(
                    listingsAsync: listingsAsync,
                    selectedL1Name: _selectedL1Name,
                    onSelect: (name) => setState(() => _selectedL1Name = name),
                  ),
                ),

                // Section Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Available rooms',
                                style: TextStyle(
                                  fontFamily: 'Georgia',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: _T.ink,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              const SizedBox(height: 2),
                              listingsAsync.maybeWhen(
                                data: (l) => Text(
                                  '${l.length} listings available',
                                  style: const TextStyle(fontSize: 12, color: _T.inkMid),
                                ),
                                orElse: () => const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),
                        _ViewToggleButton(
                          isGrid: _isGridView,
                          onToggle: () => setState(() => _isGridView = !_isGridView),
                        ),
                      ],
                    ),
                  ),
                ),

                // Listing Grid / List
                listingsAsync.when(
                  loading: () => const SliverToBoxAdapter(child: MkLoading(fullScreen: false)),
                  error: (e, _) => SliverToBoxAdapter(child: MkErrorWidget(message: e.toString())),
                  data: (all) {
                    final listings = all.where((l) {
                      final matchSearch =
                          _searchQuery.isEmpty ||
                          l.title.toLowerCase().contains(_searchQuery) ||
                          (l.address?.toLowerCase().contains(_searchQuery) ?? false);
                      final matchCat = _selectedL1Name == null || l.categoryL1Name == _selectedL1Name;
                      return matchSearch && matchCat;
                    }).toList();

                    if (listings.isEmpty) {
                      return SliverToBoxAdapter(child: _EmptyState());
                    }

                    return SliverPadding(
                      padding: EdgeInsets.fromLTRB(18, 0, 18, bottomPadding + 24),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _isGridView ? 2 : 1,
                          childAspectRatio: _isGridView ? 0.68 : 3.0, // ← 3.2 → 3.0 for more height
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => _ListingCard(
                            listing: listings[i],
                            index: i,
                            isGridView: _isGridView,
                            onTap: () => _promptLogin(context),
                          ),
                          childCount: listings.length,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),

            // Sticky Top Bar
            _StickyTopBar(
              topPadding: topPadding,
              isCollapsed: _isHeaderCollapsed,
              onSignIn: () => context.go(AppRoutes.login),
              onSearch: (v) => setState(() => _searchQuery = v.toLowerCase()),
            ),
          ],
        ),
      ),
    );
  }

  void _promptLogin(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _LoginSheet(),
    );
  }
}

// ─── Sticky Top Bar ──────────────────────────────────────────────────────────

class _StickyTopBar extends StatelessWidget {
  final double topPadding;
  final bool isCollapsed;
  final VoidCallback onSignIn;
  final ValueChanged<String> onSearch;

  const _StickyTopBar({
    required this.topPadding,
    required this.isCollapsed,
    required this.onSignIn,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      color: isCollapsed ? _T.surface.withOpacity(0.97) : Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: topPadding),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Row(
              children: [
                // Logo
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(color: _T.accent, borderRadius: BorderRadius.circular(_T.r8)),
                  child: const Center(
                    child: Text(
                      'म',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontFamily: 'Georgia',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'MeroKotha',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Georgia',
                    fontWeight: FontWeight.w700,
                    color: _T.ink,
                    letterSpacing: -0.4,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onSignIn,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(color: _T.accent, borderRadius: BorderRadius.circular(_T.rFull)),
                    child: const Text(
                      'Sign in',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search bar — slides in when header is collapsed
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: isCollapsed ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
              child: _SearchField(onChanged: onSearch),
            ),
          ),

          if (isCollapsed) Container(height: 0.5, color: _T.cardBorder),
        ],
      ),
    );
  }
}

// ─── Hero Card ───────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  final AsyncValue listingsAsync;

  const _HeroCard({required this.listingsAsync});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: _T.accent, borderRadius: BorderRadius.circular(_T.r24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rooms across Nepal',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white54, letterSpacing: 0.3),
          ),
          const SizedBox(height: 10),
          const Text(
            'Find your\nperfect room',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.15,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Verified listings. Direct contact.\nNo middlemen.',
            style: TextStyle(fontSize: 12.5, color: Colors.white54, height: 1.55),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _StatPill(listingsAsync: listingsAsync, label: 'listings'),
              const SizedBox(width: 8),
              const _StatPillStatic(label: 'Verified'),
              const SizedBox(width: 8),
              const _StatPillStatic(label: 'Direct chat'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final AsyncValue listingsAsync;
  final String label;

  const _StatPill({required this.listingsAsync, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(_T.rFull),
        border: Border.all(color: Colors.white.withOpacity(0.12), width: 0.5),
      ),
      child: Row(
        children: [
          listingsAsync.maybeWhen(
            data: (l) => Text(
              '${(l as List).length}+',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
            ),
            orElse: () => const Text(
              '—',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11.5, color: Colors.white60)),
        ],
      ),
    );
  }
}

class _StatPillStatic extends StatelessWidget {
  final String label;

  const _StatPillStatic({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(_T.rFull),
        border: Border.all(color: Colors.white.withOpacity(0.12), width: 0.5),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11.5, color: Colors.white70, fontWeight: FontWeight.w500),
      ),
    );
  }
}

// ─── Search Field ────────────────────────────────────────────────────────────

class _SearchField extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const _SearchField({required this.onChanged});

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  final _focus = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 46,
      decoration: BoxDecoration(
        color: _T.surface,
        borderRadius: BorderRadius.circular(_T.r12),
        border: Border.all(color: _focused ? _T.accent.withOpacity(0.35) : _T.cardBorder, width: _focused ? 1.5 : 0.5),
      ),
      child: TextField(
        focusNode: _focus,
        onChanged: widget.onChanged,
        style: const TextStyle(fontSize: 13.5, color: _T.ink),
        decoration: InputDecoration(
          hintText: 'Search location or title…',
          hintStyle: const TextStyle(fontSize: 13.5, color: _T.inkFaint),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 14, right: 10),
            child: Icon(Icons.search_rounded, color: _focused ? _T.accent : _T.inkFaint, size: 18),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

// ─── Category Chips ──────────────────────────────────────────────────────────

class _CategoryChips extends StatelessWidget {
  final AsyncValue listingsAsync;
  final String? selectedL1Name;
  final ValueChanged<String?> onSelect;

  const _CategoryChips({required this.listingsAsync, required this.selectedL1Name, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        children: [
          _Chip(label: 'All', isSelected: selectedL1Name == null, onTap: () => onSelect(null)),
          const SizedBox(width: 7),
          ...listingsAsync.maybeWhen(
            data: (listings) {
              final names = (listings as List)
                  .map((l) => (l as ListingModel).categoryL1Name)
                  .whereType<String>()
                  .toSet()
                  .toList();
              return names
                  .map(
                    (n) => Padding(
                      padding: const EdgeInsets.only(right: 7),
                      child: _Chip(
                        label: n,
                        isSelected: selectedL1Name == n,
                        onTap: () => onSelect(selectedL1Name == n ? null : n),
                      ),
                    ),
                  )
                  .toList();
            },
            orElse: () => <Widget>[],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _Chip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? _T.accent : _T.surface,
          borderRadius: BorderRadius.circular(_T.rFull),
          border: Border.all(color: isSelected ? _T.accent : _T.cardBorder, width: 0.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Colors.white : _T.inkMid,
          ),
        ),
      ),
    );
  }
}

// ─── View Toggle Button ───────────────────────────────────────────────────────

class _ViewToggleButton extends StatelessWidget {
  final bool isGrid;
  final VoidCallback onToggle;

  const _ViewToggleButton({required this.isGrid, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _T.surface,
          borderRadius: BorderRadius.circular(_T.r8),
          border: Border.all(color: _T.cardBorder, width: 0.5),
        ),
        child: Icon(isGrid ? Icons.view_list_rounded : Icons.grid_view_rounded, size: 16, color: _T.inkMid),
      ),
    );
  }
}

// ─── Listing Card ────────────────────────────────────────────────────────────

class _ListingCard extends StatefulWidget {
  final ListingModel listing;
  final VoidCallback onTap;
  final int index;
  final bool isGridView;

  const _ListingCard({required this.listing, required this.onTap, required this.index, required this.isGridView});

  @override
  State<_ListingCard> createState() => _ListingCardState();
}

class _ListingCardState extends State<_ListingCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.97,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _handleTap() {
    _ctrl.reverse().then((_) => _ctrl.forward());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return widget.isGridView ? _buildGridCard() : _buildListCard();
  }

  Widget _buildGridCard() {
    final l = widget.listing;
    final isOdd = widget.index.isOdd;

    return ScaleTransition(
      scale: _ctrl,
      child: GestureDetector(
        onTap: _handleTap,
        child: Container(
          decoration: BoxDecoration(
            color: _T.surface,
            borderRadius: BorderRadius.circular(_T.r16),
            border: Border.all(color: _T.cardBorder, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 4 / 3,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(_T.r16)),
                      child: l.photoUrls.isNotEmpty
                          ? Image.network(
                              l.photoUrls.first,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (_, _, _) => _PhotoPlaceholder(isOdd: isOdd),
                            )
                          : _PhotoPlaceholder(isOdd: isOdd),
                    ),
                  ),
                  if (l.categoryLabel.isNotEmpty)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: _T.accent, borderRadius: BorderRadius.circular(_T.rFull)),
                        child: Text(
                          l.categoryLabel,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              // Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(11, 10, 11, 11),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.title,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: _T.ink,
                          letterSpacing: -0.2,
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (l.address != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded, size: 10, color: _T.inkFaint),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                l.address!,
                                style: const TextStyle(fontSize: 10.5, color: _T.inkFaint),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const Spacer(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'per month',
                                  style: TextStyle(fontSize: 9, color: _T.inkFaint, letterSpacing: 0.2),
                                ),
                                const SizedBox(height: 1),
                                PriceBadge(amount: l.rentPerMonth),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                            decoration: BoxDecoration(color: _T.accentPop, borderRadius: BorderRadius.circular(_T.r8)),
                            child: const Text(
                              'View',
                              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: _T.accent),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListCard() {
    final l = widget.listing;
    final isOdd = widget.index.isOdd;

    return ScaleTransition(
      scale: _ctrl,
      child: GestureDetector(
        onTap: _handleTap,
        child: Container(
          decoration: BoxDecoration(
            color: _T.surface,
            borderRadius: BorderRadius.circular(_T.r16),
            border: Border.all(color: _T.cardBorder, width: 0.5),
          ),
          child: Row(
            children: [
              // Photo
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(_T.r16)),
                child: SizedBox(
                  width: 110,
                  height: double.infinity,
                  child: l.photoUrls.isNotEmpty
                      ? Image.network(
                          l.photoUrls.first,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _PhotoPlaceholder(isOdd: isOdd),
                        )
                      : _PhotoPlaceholder(isOdd: isOdd),
                ),
              ),

              // Info — FIX: reduced padding + maxLines:1 + Spacer replaces spaceBetween
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10), // ← was (12,12,12,12)
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      if (l.categoryLabel.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 5),
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(color: _T.accent, borderRadius: BorderRadius.circular(_T.rFull)),
                          child: Text(
                            l.categoryLabel,
                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                        ),
                      Text(
                        l.title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _T.ink,
                          letterSpacing: -0.2,
                          height: 1.25,
                        ),
                        maxLines: 1, // ← was 2; prevents overflow in fixed-height list cards
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (l.address != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded, size: 10, color: _T.inkFaint),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                l.address!,
                                style: const TextStyle(fontSize: 10.5, color: _T.inkFaint),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const Spacer(), // ← replaces mainAxisAlignment: spaceBetween
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'per month',
                                style: TextStyle(fontSize: 9, color: _T.inkFaint, letterSpacing: 0.2),
                              ),
                              const SizedBox(height: 1),
                              PriceBadge(amount: l.rentPerMonth),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                            decoration: BoxDecoration(color: _T.accentPop, borderRadius: BorderRadius.circular(_T.r8)),
                            child: const Text(
                              'View',
                              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: _T.accent),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  final bool isOdd;

  const _PhotoPlaceholder({required this.isOdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isOdd ? const Color(0xFFE8F4ED) : const Color(0xFFF0EDE6),
      child: Center(
        child: Icon(
          Icons.home_work_outlined,
          size: 26,
          color: isOdd ? _T.accentMid.withOpacity(0.25) : _T.inkFaint.withOpacity(0.5),
        ),
      ),
    );
  }
}

// ─── Empty State ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(18),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: _T.surface,
        borderRadius: BorderRadius.circular(_T.r24),
        border: Border.all(color: _T.cardBorder, width: 0.5),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: _T.accentPop, borderRadius: BorderRadius.circular(_T.r16)),
            child: const Icon(Icons.house_outlined, size: 26, color: _T.accent),
          ),
          const SizedBox(height: 16),
          const Text(
            'No rooms found',
            style: TextStyle(fontFamily: 'Georgia', fontSize: 17, fontWeight: FontWeight.w700, color: _T.ink),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try a different search or category',
            style: TextStyle(fontSize: 13, color: _T.inkMid),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Login Bottom Sheet

class _LoginSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(22, 0, 22, MediaQuery.of(context).padding.bottom + 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              width: 34,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 24),
              decoration: BoxDecoration(color: _T.cardBorder, borderRadius: BorderRadius.circular(2)),
            ),
          ),

          // Icon
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(color: _T.accentPop, borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.lock_open_rounded, size: 24, color: _T.accent),
          ),
          const SizedBox(height: 16),

          const Text(
            'Sign in to continue',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _T.ink,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Save favourites, send inquiries,\nand message owners — for free.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: _T.inkMid, height: 1.6),
          ),
          const SizedBox(height: 28),

          // CTA
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _T.accent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_T.r16)),
                textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: -0.2),
              ),
              onPressed: () {
                Navigator.pop(context);
                context.go(AppRoutes.login);
              },
              child: const Text('Sign in / Create account'),
            ),
          ),
          const SizedBox(height: 10),

          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: _T.inkMid,
              textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            child: const Text('Continue browsing'),
          ),
        ],
      ),
    );
  }
}
