import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:merokotha/features/owner/presentation/screens/my_listing_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/otp_login_screen.dart';
import '../../features/auth/presentation/screens/role_select_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../shared/models/listing_model.dart';
import 'app_routes.dart';

// Owner screens
import '../../features/owner/presentation/screens/owner_home_screen.dart';
import '../../features/owner/presentation/screens/upload_listing_screen.dart';
import '../../features/owner/presentation/screens/owner_inquiries_screen.dart';
import '../../features/owner/presentation/screens/owner_map_screen.dart';
import '../../features/owner/presentation/screens/owner_profile_screen.dart';

// Customer screens
import '../../features/customer/presentation/screens/customer_home_screen.dart';
import '../../features/customer/presentation/screens/search_screen.dart';
import '../../features/customer/presentation/screens/customer_map_screen.dart';
import '../../features/customer/presentation/screens/room_detail_screen.dart';
import '../../features/customer/presentation/screens/favourites_screen.dart';
import '../../features/customer/presentation/screens/inquire_screen.dart';
import '../../features/customer/presentation/screens/customer_profile_screen.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isOnAuthRoute =
          state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.splash;
      if (!isLoggedIn && !isOnAuthRoute) return AppRoutes.login;
      return null;
    },
    routes: [
      // ── Auth ──
      GoRoute(path: AppRoutes.splash, builder: (_, __) => const SplashScreen()),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const OtpLoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.roleSelect,
        builder: (_, __) => const RoleSelectScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),

      // ── Owner ──
      GoRoute(
        path: AppRoutes.ownerHome,
        builder: (_, __) => const OwnerHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.uploadListing,
        builder: (_, __) => const UploadListingScreen(),
      ),
      GoRoute(
        path: AppRoutes.myListings,
        builder: (_, __) => const MyListingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.ownerInquiries,
        builder: (_, __) => const OwnerInquiriesScreen(),
      ),
      GoRoute(
        path: AppRoutes.ownerMap,
        builder: (_, __) => const OwnerMapScreen(),
      ),
      GoRoute(
        path: AppRoutes.ownerProfile,
        builder: (_, __) => const OwnerProfileScreen(),
      ),

      // ── Customer ──
      GoRoute(
        path: AppRoutes.customerHome,
        builder: (_, __) => const CustomerHomeScreen(),
      ),
      GoRoute(path: AppRoutes.search, builder: (_, __) => const SearchScreen()),
      GoRoute(
        path: AppRoutes.customerMap,
        builder: (_, __) => const CustomerMapScreen(),
      ),
      GoRoute(
        path: AppRoutes.favourites,
        builder: (_, __) => const FavouritesScreen(),
      ),
      GoRoute(
        path: AppRoutes.customerProfile,
        builder: (_, __) => const CustomerProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.roomDetail,
        builder: (_, state) =>
            RoomDetailScreen(listingId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.inquire,
        builder: (_, state) =>
            InquireScreen(listing: state.extra as ListingModel),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 12),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.go(AppRoutes.splash),
              child: const Text('Go home'),
            ),
          ],
        ),
      ),
    ),
  );
}
