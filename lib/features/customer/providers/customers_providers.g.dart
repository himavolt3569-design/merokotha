// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customers_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(activeListings)
final activeListingsProvider = ActiveListingsProvider._();

final class ActiveListingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ListingModel>>,
          List<ListingModel>,
          Stream<List<ListingModel>>
        >
    with
        $FutureModifier<List<ListingModel>>,
        $StreamProvider<List<ListingModel>> {
  ActiveListingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeListingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeListingsHash();

  @$internal
  @override
  $StreamProviderElement<List<ListingModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ListingModel>> create(Ref ref) {
    return activeListings(ref);
  }
}

String _$activeListingsHash() => r'4a207dbafe5b46e058f3dcda7c406152f12e1e33';

@ProviderFor(listingDetail)
final listingDetailProvider = ListingDetailFamily._();

final class ListingDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<ListingModel?>,
          ListingModel?,
          FutureOr<ListingModel?>
        >
    with $FutureModifier<ListingModel?>, $FutureProvider<ListingModel?> {
  ListingDetailProvider._({
    required ListingDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'listingDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$listingDetailHash();

  @override
  String toString() {
    return r'listingDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ListingModel?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ListingModel?> create(Ref ref) {
    final argument = this.argument as String;
    return listingDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ListingDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$listingDetailHash() => r'74984060f6b618c4dbd20bad34b488ab9d26ad21';

final class ListingDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ListingModel?>, String> {
  ListingDetailFamily._()
    : super(
        retry: null,
        name: r'listingDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ListingDetailProvider call(String listingId) =>
      ListingDetailProvider._(argument: listingId, from: this);

  @override
  String toString() => r'listingDetailProvider';
}

@ProviderFor(SearchFilterNotifier)
final searchFilterProvider = SearchFilterNotifierProvider._();

final class SearchFilterNotifierProvider
    extends $NotifierProvider<SearchFilterNotifier, SearchFilter> {
  SearchFilterNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchFilterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchFilterNotifierHash();

  @$internal
  @override
  SearchFilterNotifier create() => SearchFilterNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchFilter>(value),
    );
  }
}

String _$searchFilterNotifierHash() =>
    r'158b8c5e18d7c1e5a3413ca260b87ea8aedeff2b';

abstract class _$SearchFilterNotifier extends $Notifier<SearchFilter> {
  SearchFilter build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SearchFilter, SearchFilter>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SearchFilter, SearchFilter>,
              SearchFilter,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(searchResults)
final searchResultsProvider = SearchResultsProvider._();

final class SearchResultsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ListingModel>>,
          List<ListingModel>,
          FutureOr<List<ListingModel>>
        >
    with
        $FutureModifier<List<ListingModel>>,
        $FutureProvider<List<ListingModel>> {
  SearchResultsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchResultsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchResultsHash();

  @$internal
  @override
  $FutureProviderElement<List<ListingModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ListingModel>> create(Ref ref) {
    return searchResults(ref);
  }
}

String _$searchResultsHash() => r'f105488db8ee1283818a8471ee94bb895f3ddca3';

@ProviderFor(favouriteIds)
final favouriteIdsProvider = FavouriteIdsProvider._();

final class FavouriteIdsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          Stream<List<String>>
        >
    with $FutureModifier<List<String>>, $StreamProvider<List<String>> {
  FavouriteIdsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favouriteIdsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favouriteIdsHash();

  @$internal
  @override
  $StreamProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<String>> create(Ref ref) {
    return favouriteIds(ref);
  }
}

String _$favouriteIdsHash() => r'f3cd026d79395bea6c9b671f87c8903e7ad7d32a';

@ProviderFor(isListingFavourited)
final isListingFavouritedProvider = IsListingFavouritedFamily._();

final class IsListingFavouritedProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  IsListingFavouritedProvider._({
    required IsListingFavouritedFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'isListingFavouritedProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$isListingFavouritedHash();

  @override
  String toString() {
    return r'isListingFavouritedProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as String;
    return isListingFavourited(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is IsListingFavouritedProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isListingFavouritedHash() =>
    r'713b4053888a1f136c39cb2009412e2047621f40';

final class IsListingFavouritedFamily extends $Family
    with $FunctionalFamilyOverride<bool, String> {
  IsListingFavouritedFamily._()
    : super(
        retry: null,
        name: r'isListingFavouritedProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  IsListingFavouritedProvider call(String listingId) =>
      IsListingFavouritedProvider._(argument: listingId, from: this);

  @override
  String toString() => r'isListingFavouritedProvider';
}

@ProviderFor(favouriteListings)
final favouriteListingsProvider = FavouriteListingsProvider._();

final class FavouriteListingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ListingModel>>,
          List<ListingModel>,
          FutureOr<List<ListingModel>>
        >
    with
        $FutureModifier<List<ListingModel>>,
        $FutureProvider<List<ListingModel>> {
  FavouriteListingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favouriteListingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favouriteListingsHash();

  @$internal
  @override
  $FutureProviderElement<List<ListingModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ListingModel>> create(Ref ref) {
    return favouriteListings(ref);
  }
}

String _$favouriteListingsHash() => r'8298659a620edcea57bc415746d0e39c0ed23a68';

@ProviderFor(FavouriteNotifier)
final favouriteProvider = FavouriteNotifierProvider._();

final class FavouriteNotifierProvider
    extends $NotifierProvider<FavouriteNotifier, AsyncValue<void>> {
  FavouriteNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favouriteProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favouriteNotifierHash();

  @$internal
  @override
  FavouriteNotifier create() => FavouriteNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$favouriteNotifierHash() => r'bc33460bfed4c7e3ef0b174f388dc1646a2e5391';

abstract class _$FavouriteNotifier extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(SendInquiryNotifier)
final sendInquiryProvider = SendInquiryNotifierProvider._();

final class SendInquiryNotifierProvider
    extends $NotifierProvider<SendInquiryNotifier, SendInquiryState> {
  SendInquiryNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sendInquiryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sendInquiryNotifierHash();

  @$internal
  @override
  SendInquiryNotifier create() => SendInquiryNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SendInquiryState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SendInquiryState>(value),
    );
  }
}

String _$sendInquiryNotifierHash() =>
    r'54b39082654f17a4fbc2d3f71201e93fdc41465e';

abstract class _$SendInquiryNotifier extends $Notifier<SendInquiryState> {
  SendInquiryState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SendInquiryState, SendInquiryState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SendInquiryState, SendInquiryState>,
              SendInquiryState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(mapListings)
final mapListingsProvider = MapListingsProvider._();

final class MapListingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ListingModel>>,
          List<ListingModel>,
          FutureOr<List<ListingModel>>
        >
    with
        $FutureModifier<List<ListingModel>>,
        $FutureProvider<List<ListingModel>> {
  MapListingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mapListingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mapListingsHash();

  @$internal
  @override
  $FutureProviderElement<List<ListingModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ListingModel>> create(Ref ref) {
    return mapListings(ref);
  }
}

String _$mapListingsHash() => r'f266ba5c8e9def3ea62bffb81534ca96d64e6851';
