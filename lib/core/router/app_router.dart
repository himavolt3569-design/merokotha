import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:merokotha/features/customer/presentation/screens/customer_home_screen.dart';
// import 'package:merokotha/features/owner/presentation/screens/my_listing_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/otp_login_screen.dart';
import '../../features/auth/presentation/screens/role_select_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import 'app_routes.dart';

// import '../../features/owner/presentation/screens/owner_home_screen.dart';
// import '../../features/owner/presentation/screens/upload_listing_screen.dart';
// import '../../features/owner/presentation/screens/owner_inquiries_screen.dart';
// import '../../features/customer/presentation/screens/customer_home_screen.dart';
import '../../features/customer/presentation/screens/search_screen.dart';
import '../../features/customer/presentation/screens/customer_map_screen.dart';
import '../../features/customer/presentation/screens/room_detail_screen.dart';
import '../../features/customer/presentation/screens/favourites_screen.dart';
import '../../features/customer/presentation/screens/inquire_screen.dart';
import '../../shared/models/listing_model.dart';

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
      if (isLoggedIn && isOnAuthRoute) {
        // Will be handled by splash screen based on user role
        return null;
      }
      return null;
    },
    routes: [
      // Auth
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const OtpLoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.roleSelect,
        builder: (context, state) => const RoleSelectScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Owner routes
      // GoRoute(
      //   path: AppRoutes.ownerHome,
      //   builder: (context, state) => const OwnerHomeScreen(),
      // ),
      // GoRoute(
      //   path: AppRoutes.uploadListing,
      //   builder: (context, state) => const UploadListingScreen(),
      // ),
      // GoRoute(
      //   path: AppRoutes.myListings,
      //   builder: (context, state) => const MyListingsScreen(),
      // ),
      // GoRoute(
      //   path: AppRoutes.ownerInquiries,
      //   builder: (context, state) => const OwnerInquiriesScreen(),
      // ),

      // Customer routes
      GoRoute(
        path: AppRoutes.customerHome,
        builder: (context, state) => const CustomerHomeScreen(),
      ),
      GoRoute(path: AppRoutes.search, builder: (_, _) => const SearchScreen()),
      GoRoute(
        path: AppRoutes.customerMap,
        builder: (_, _) => const CustomerMapScreen(),
      ),
      GoRoute(
        path: AppRoutes.favourites,
        builder: (_, _) => const FavouritesScreen(),
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
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Page not found: ${state.error}'))),
  );
}
