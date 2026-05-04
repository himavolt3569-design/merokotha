import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:merokotha/shared/models/listing_model.dart';
import 'package:merokotha/features/auth/providers/auth_provider.dart';
import 'package:merokotha/features/owner/data/owner_repository.dart';
import 'package:merokotha/features/owner/data/inquiry_repository.dart';

part 'owner_providers.g.dart';

@riverpod
Stream<List<ListingModel>> ownerListings(Ref ref) {
  final user = ref.watch(authStateProvider).asData?.value;
  if (user == null) return const Stream.empty();
  return ref.watch(ownerRepositoryProvider).watchMyListings(user.uid);
}

@riverpod
Stream<int> pendingInquiryCount(Ref ref) {
  final user = ref.watch(authStateProvider).asData?.value;
  if (user == null) return Stream.value(0);
  return ref.watch(inquiryRepositoryProvider).watchPendingCount(user.uid);
}

class UploadListingState {
  final bool isLoading;
  final String? error;
  final bool success;

  const UploadListingState({
    this.isLoading = false,
    this.error,
    this.success = false,
  });

  UploadListingState copyWith({
    bool? isLoading,
    String? error,
    bool? success,
    bool clearError = false,
  }) => UploadListingState(
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : (error ?? this.error),
    success: success ?? this.success,
  );
}

@riverpod
class UploadListingNotifier extends _$UploadListingNotifier {
  @override
  UploadListingState build() => const UploadListingState();

  Future<String?> uploadListing({
    required String ownerId,
    required String ownerName,
    String? ownerPhotoUrl,
    required String title,
    required String roomType,
    required double rentPerMonth,
    required double depositAmount,
    required int floor,
    required int totalFloors,
    required FurnishingType furnishing,
    required List<String> facilities,
    required String description,
    required DateTime availableFrom,
    GeoPoint? geoPoint,
    String? address,
    String? nearbyLandmarks,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final now = DateTime.now();
      final listing = ListingModel(
        id: '',
        ownerId: ownerId,
        ownerName: ownerName,
        ownerPhotoUrl: ownerPhotoUrl,
        title: title,
        rentPerMonth: rentPerMonth,
        depositAmount: depositAmount,
        floor: floor,
        totalFloors: totalFloors,
        furnishing: furnishing,
        facilities: facilities,
        description: description,
        photoUrls: const [],
        geoPoint: geoPoint,
        address: address,
        nearbyLandmarks: nearbyLandmarks,
        availableFrom: availableFrom,
        status: ListingStatus.active,
        createdAt: now,
        updatedAt: now,
        roomType: roomType,
      );

      final id = await ref.read(ownerRepositoryProvider).createListing(listing);

      state = state.copyWith(isLoading: false, success: true);
      return id;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to save listing. Please try again.',
      );
      return null;
    }
  }

  void reset() => state = const UploadListingState();
}

@riverpod
class ListingStatusNotifier extends _$ListingStatusNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> toggle(String listingId, ListingStatus newStatus) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(ownerRepositoryProvider)
          .toggleListingStatus(listingId, newStatus),
    );
  }

  Future<void> delete(String listingId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(ownerRepositoryProvider).deleteListing(listingId),
    );
  }
}
