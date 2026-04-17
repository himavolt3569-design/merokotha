import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/models/inquiry_model.dart';
import '../../../shared/models/listing_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/favourites_repository.dart';
import '../data/listings_repository.dart';

part 'customers_providers.g.dart';

// ── All active listings for home feed ──
@riverpod
Stream<List<ListingModel>> activeListings(Ref ref) {
  return ref.watch(listingsRepositoryProvider).watchActiveListings();
}

// ── Single listing detail ──
@riverpod
Future<ListingModel?> listingDetail(Ref ref, String listingId) async {
  final listing = await ref
      .watch(listingsRepositoryProvider)
      .getListingById(listingId);
  if (listing != null) {
    ref.watch(listingsRepositoryProvider).incrementView(listingId);
  }
  return listing;
}

// ── Search filter state ──
@riverpod
class SearchFilterNotifier extends _$SearchFilterNotifier {
  @override
  SearchFilter build() => const SearchFilter();

  void setQuery(String q) =>
      state = state.copyWith(query: q.isEmpty ? null : q);

  // ── Replaces setRoomType — filters by deepest category level ──
  void setCategory({
    String? categoryL1Id,
    String? categoryL2Id,
    String? categoryL3Id,
  }) {
    if (categoryL1Id == null && categoryL2Id == null && categoryL3Id == null) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(
        categoryL1Id: categoryL1Id,
        categoryL2Id: categoryL2Id,
        categoryL3Id: categoryL3Id,
      );
    }
  }

  void clearCategory() => state = state.copyWith(clearCategory: true);

  void setFurnishing(FurnishingType? f) => f == null
      ? state = state.copyWith(clearFurnishing: true)
      : state = state.copyWith(furnishing: f);

  void setMinRent(double? v) => state = state.copyWith(minRent: v);
  void setMaxRent(double? v) => state = state.copyWith(maxRent: v);

  void setFacilities(List<String> f) => state = state.copyWith(facilities: f);

  void reset() => state = const SearchFilter();
}

// ── Search results (re-runs when filter changes) ──
@riverpod
Future<List<ListingModel>> searchResults(Ref ref) {
  final filter = ref.watch(searchFilterProvider);
  return ref.watch(listingsRepositoryProvider).searchListings(filter);
}

// ── Favourite IDs stream ──
@riverpod
Stream<List<String>> favouriteIds(Ref ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return const Stream.empty();
  return ref.watch(favouritesRepositoryProvider).watchFavouriteIds(user.uid);
}

// ── Check if a specific listing is favourited ──
@riverpod
bool isListingFavourited(Ref ref, String listingId) {
  final ids = ref.watch(favouriteIdsProvider).value ?? [];
  return ids.contains(listingId);
}

// ── Favourite listings (fetched from listings collection by IDs) ──
@riverpod
Future<List<ListingModel>> favouriteListings(Ref ref) async {
  final ids = ref.watch(favouriteIdsProvider).value ?? [];
  if (ids.isEmpty) return [];

  final repo = ref.watch(listingsRepositoryProvider);
  final results = await Future.wait(ids.map((id) => repo.getListingById(id)));
  return results.whereType<ListingModel>().toList();
}

// ── Toggle favourite ──
@riverpod
class FavouriteNotifier extends _$FavouriteNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> toggle(ListingModel listing) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    final isFav = ref.read(isListingFavouritedProvider(listing.id));
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => isFav
          ? ref
                .read(favouritesRepositoryProvider)
                .removeFavourite(user.uid, listing.id)
          : ref
                .read(favouritesRepositoryProvider)
                .addFavourite(user.uid, listing),
    );
  }
}

// ── Send inquiry state ──
class SendInquiryState {
  final bool isLoading;
  final String? error;
  final bool success;
  final String? inquiryId;

  const SendInquiryState({
    this.isLoading = false,
    this.error,
    this.success = false,
    this.inquiryId,
  });

  SendInquiryState copyWith({
    bool? isLoading,
    String? error,
    bool? success,
    String? inquiryId,
    bool clearError = false,
  }) => SendInquiryState(
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : (error ?? this.error),
    success: success ?? this.success,
    inquiryId: inquiryId ?? this.inquiryId,
  );
}

@riverpod
class SendInquiryNotifier extends _$SendInquiryNotifier {
  @override
  SendInquiryState build() => const SendInquiryState();

  Future<bool> send({
    required ListingModel listing,
    required String customerName,
    required String customerId,
    required String message,
    required DateTime moveInDate,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final now = DateTime.now();
      final inquiry = InquiryModel(
        id: '',
        listingId: listing.id,
        listingTitle: listing.title,
        customerId: customerId,
        customerName: customerName,
        ownerId: listing.ownerId,
        message: message,
        moveInDate: moveInDate,
        status: InquiryStatus.pending,
        createdAt: now,
        updatedAt: now,
      );
      final id = await ref
          .read(SendInquiryNotifierProvider as ProviderListenable<dynamic>)
          .sendInquiry(inquiry);
      state = state.copyWith(isLoading: false, success: true, inquiryId: id);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to send inquiry. Please try again.',
      );
      return false;
    }
  }

  void reset() => state = const SendInquiryState();
}

// ── All listings for map view ──
@riverpod
Future<List<ListingModel>> mapListings(Ref ref) {
  return ref.watch(listingsRepositoryProvider).getAllActiveForMap();
}
