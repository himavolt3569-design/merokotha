import 'package:merokotha/features/ads/data/ad_model.dart';
import 'package:merokotha/features/ads/data/ad_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ad_providers.g.dart';

// ── Live ads per placement ──
@riverpod
Stream<List<AdModel>> adsForPlacement(Ref ref, AdPlacement placement) {
  return ref.watch(adRepositoryProvider).watchAdsForPlacement(placement);
}

// Convenience providers for each placement
@riverpod
Stream<List<AdModel>> homeFeedAds(Ref ref) {
  return ref
      .watch(adRepositoryProvider)
      .watchAdsForPlacement(AdPlacement.homeFeed);
}

@riverpod
Stream<List<AdModel>> roomDetailAds(Ref ref) {
  return ref
      .watch(adRepositoryProvider)
      .watchAdsForPlacement(AdPlacement.roomDetail);
}

@riverpod
Stream<List<AdModel>> searchAds(Ref ref) {
  return ref
      .watch(adRepositoryProvider)
      .watchAdsForPlacement(AdPlacement.searchResults);
}

@riverpod
Stream<List<AdModel>> landingAds(Ref ref) {
  return ref
      .watch(adRepositoryProvider)
      .watchAdsForPlacement(AdPlacement.landingPage);
}

// ── All ads for admin ──
@riverpod
Stream<List<AdModel>> allAds(Ref ref) {
  return ref.watch(adRepositoryProvider).watchAllAds();
}

// ── Admin action notifier ──
class AdActionState {
  final bool isLoading;
  final String? error;
  final bool success;
  const AdActionState({
    this.isLoading = false,
    this.error,
    this.success = false,
  });

  AdActionState copyWith({
    bool? isLoading,
    String? error,
    bool? success,
    bool clearError = false,
  }) => AdActionState(
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : (error ?? this.error),
    success: success ?? this.success,
  );
}

@riverpod
class AdActionNotifier extends _$AdActionNotifier {
  @override
  AdActionState build() => const AdActionState();

  Future<void> createAd(AdModel ad) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(adRepositoryProvider).createAd(ad);
      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> toggleStatus(String id, AdStatus status) async {
    try {
      await ref.read(adRepositoryProvider).toggleStatus(id, status);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteAd(String id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(adRepositoryProvider).deleteAd(id);
      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void reset() => state = const AdActionState();
}
