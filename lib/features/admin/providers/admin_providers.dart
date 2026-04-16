import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/models/inquiry_model.dart';
import '../../../shared/models/listing_model.dart';
import '../../../shared/models/user_model.dart';
import '../data/admin_repository.dart';

part 'admin_providers.g.dart';

// ── Dashboard stats ──
@riverpod
Future<AdminStats> dashboardStats(Ref ref) {
  return ref.watch(adminRepositoryProvider).getDashboardStats();
}

// ── All users stream ──
@riverpod
Stream<List<UserModel>> allUsers(Ref ref) {
  return ref.watch(adminRepositoryProvider).watchAllUsers();
}

// ── All listings stream ──
@riverpod
Stream<List<ListingModel>> allListings(Ref ref) {
  return ref.watch(adminRepositoryProvider).watchAllListings();
}

// ── All inquiries stream ──
@riverpod
Stream<List<InquiryModel>> allInquiries(Ref ref) {
  return ref.watch(adminRepositoryProvider).watchAllInquiries();
}

// ── Recent items for dashboard ──
@riverpod
Future<List<UserModel>> recentUsers(Ref ref) {
  return ref.watch(adminRepositoryProvider).getRecentUsers();
}

@riverpod
Future<List<ListingModel>> recentListings(Ref ref) {
  return ref.watch(adminRepositoryProvider).getRecentListings();
}

// ── User detail ──
@riverpod
Future<UserModel?> adminUserDetail(Ref ref, String uid) {
  return ref.watch(adminRepositoryProvider).getUserById(uid);
}

// ── User search query state ──
@riverpod
class UserSearchNotifier extends _$UserSearchNotifier {
  @override
  String build() => '';
  void setQuery(String q) => state = q;
  void clear() => state = '';
}

// ── Searched users ──
@riverpod
Future<List<UserModel>> searchedUsers(Ref ref) async {
  final query = ref.watch(userSearchProvider);
  if (query.trim().isEmpty) {
    return ref.watch(allUsersProvider).value ?? [];
  }
  return ref.watch(adminRepositoryProvider).searchUsers(query.trim());
}

// ── Admin action state ──
class AdminActionState {
  final bool isLoading;
  final String? error;
  final bool success;

  const AdminActionState({
    this.isLoading = false,
    this.error,
    this.success = false,
  });

  AdminActionState copyWith({
    bool? isLoading,
    String? error,
    bool? success,
    bool clearError = false,
  }) => AdminActionState(
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : (error ?? this.error),
    success: success ?? this.success,
  );
}

@riverpod
class AdminActionNotifier extends _$AdminActionNotifier {
  @override
  AdminActionState build() => const AdminActionState();

  Future<void> banUser(String uid, {String? reason}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(adminRepositoryProvider).banUser(uid, reason: reason);
      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to ban: $e');
    }
  }

  Future<void> unbanUser(String uid) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(adminRepositoryProvider).unbanUser(uid);
      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to unban: $e');
    }
  }

  Future<void> deleteListing(String listingId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(adminRepositoryProvider).deleteListing(listingId);
      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to delete: $e');
    }
  }

  Future<void> setListingStatus(String listingId, ListingStatus status) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref
          .read(adminRepositoryProvider)
          .setListingStatus(listingId, status);
      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> setUserRole(String uid, UserRole role) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(adminRepositoryProvider).setUserRole(uid, role);
      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void reset() => state = const AdminActionState();
}
