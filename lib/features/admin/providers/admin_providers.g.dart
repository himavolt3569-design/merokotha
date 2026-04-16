// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(dashboardStats)
final dashboardStatsProvider = DashboardStatsProvider._();

final class DashboardStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<AdminStats>,
          AdminStats,
          FutureOr<AdminStats>
        >
    with $FutureModifier<AdminStats>, $FutureProvider<AdminStats> {
  DashboardStatsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dashboardStatsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dashboardStatsHash();

  @$internal
  @override
  $FutureProviderElement<AdminStats> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<AdminStats> create(Ref ref) {
    return dashboardStats(ref);
  }
}

String _$dashboardStatsHash() => r'1f2a60bf1f48b60c5f4c4c2f49f1b6a858b601a5';

@ProviderFor(allUsers)
final allUsersProvider = AllUsersProvider._();

final class AllUsersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<UserModel>>,
          List<UserModel>,
          Stream<List<UserModel>>
        >
    with $FutureModifier<List<UserModel>>, $StreamProvider<List<UserModel>> {
  AllUsersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allUsersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allUsersHash();

  @$internal
  @override
  $StreamProviderElement<List<UserModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<UserModel>> create(Ref ref) {
    return allUsers(ref);
  }
}

String _$allUsersHash() => r'c629cb3d7fa58d6268c05a5c421795a76e911201';

@ProviderFor(allListings)
final allListingsProvider = AllListingsProvider._();

final class AllListingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ListingModel>>,
          List<ListingModel>,
          Stream<List<ListingModel>>
        >
    with
        $FutureModifier<List<ListingModel>>,
        $StreamProvider<List<ListingModel>> {
  AllListingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allListingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allListingsHash();

  @$internal
  @override
  $StreamProviderElement<List<ListingModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ListingModel>> create(Ref ref) {
    return allListings(ref);
  }
}

String _$allListingsHash() => r'de0162fffcf15a9cb7c9053ae1f2f1f879419f53';

@ProviderFor(allInquiries)
final allInquiriesProvider = AllInquiriesProvider._();

final class AllInquiriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<InquiryModel>>,
          List<InquiryModel>,
          Stream<List<InquiryModel>>
        >
    with
        $FutureModifier<List<InquiryModel>>,
        $StreamProvider<List<InquiryModel>> {
  AllInquiriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allInquiriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allInquiriesHash();

  @$internal
  @override
  $StreamProviderElement<List<InquiryModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<InquiryModel>> create(Ref ref) {
    return allInquiries(ref);
  }
}

String _$allInquiriesHash() => r'1335f541c069bc65cfbeb32b55323ba69a006881';

@ProviderFor(recentUsers)
final recentUsersProvider = RecentUsersProvider._();

final class RecentUsersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<UserModel>>,
          List<UserModel>,
          FutureOr<List<UserModel>>
        >
    with $FutureModifier<List<UserModel>>, $FutureProvider<List<UserModel>> {
  RecentUsersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentUsersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentUsersHash();

  @$internal
  @override
  $FutureProviderElement<List<UserModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<UserModel>> create(Ref ref) {
    return recentUsers(ref);
  }
}

String _$recentUsersHash() => r'3961f4962585780fe94f29d9e14749688af51fca';

@ProviderFor(recentListings)
final recentListingsProvider = RecentListingsProvider._();

final class RecentListingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ListingModel>>,
          List<ListingModel>,
          FutureOr<List<ListingModel>>
        >
    with
        $FutureModifier<List<ListingModel>>,
        $FutureProvider<List<ListingModel>> {
  RecentListingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentListingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentListingsHash();

  @$internal
  @override
  $FutureProviderElement<List<ListingModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ListingModel>> create(Ref ref) {
    return recentListings(ref);
  }
}

String _$recentListingsHash() => r'ad8c56b92634fca1c0aef8b641f4664106115249';

@ProviderFor(adminUserDetail)
final adminUserDetailProvider = AdminUserDetailFamily._();

final class AdminUserDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<UserModel?>,
          UserModel?,
          FutureOr<UserModel?>
        >
    with $FutureModifier<UserModel?>, $FutureProvider<UserModel?> {
  AdminUserDetailProvider._({
    required AdminUserDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'adminUserDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$adminUserDetailHash();

  @override
  String toString() {
    return r'adminUserDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<UserModel?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<UserModel?> create(Ref ref) {
    final argument = this.argument as String;
    return adminUserDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AdminUserDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$adminUserDetailHash() => r'026fa1dd4d4cdbe376d51ec6ea682ade4bd1cd67';

final class AdminUserDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<UserModel?>, String> {
  AdminUserDetailFamily._()
    : super(
        retry: null,
        name: r'adminUserDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AdminUserDetailProvider call(String uid) =>
      AdminUserDetailProvider._(argument: uid, from: this);

  @override
  String toString() => r'adminUserDetailProvider';
}

@ProviderFor(UserSearchNotifier)
final userSearchProvider = UserSearchNotifierProvider._();

final class UserSearchNotifierProvider
    extends $NotifierProvider<UserSearchNotifier, String> {
  UserSearchNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userSearchProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userSearchNotifierHash();

  @$internal
  @override
  UserSearchNotifier create() => UserSearchNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$userSearchNotifierHash() =>
    r'6180984c54dad4e7a034893227cf9a40cc7ac7b2';

abstract class _$UserSearchNotifier extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(searchedUsers)
final searchedUsersProvider = SearchedUsersProvider._();

final class SearchedUsersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<UserModel>>,
          List<UserModel>,
          FutureOr<List<UserModel>>
        >
    with $FutureModifier<List<UserModel>>, $FutureProvider<List<UserModel>> {
  SearchedUsersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchedUsersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchedUsersHash();

  @$internal
  @override
  $FutureProviderElement<List<UserModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<UserModel>> create(Ref ref) {
    return searchedUsers(ref);
  }
}

String _$searchedUsersHash() => r'08d90cf4a69e208c7e53f082c0fb2185e6862460';

@ProviderFor(AdminActionNotifier)
final adminActionProvider = AdminActionNotifierProvider._();

final class AdminActionNotifierProvider
    extends $NotifierProvider<AdminActionNotifier, AdminActionState> {
  AdminActionNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminActionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminActionNotifierHash();

  @$internal
  @override
  AdminActionNotifier create() => AdminActionNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdminActionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdminActionState>(value),
    );
  }
}

String _$adminActionNotifierHash() =>
    r'adab718de3e7eac3e0f112e63f9a91bd58a258d8';

abstract class _$AdminActionNotifier extends $Notifier<AdminActionState> {
  AdminActionState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AdminActionState, AdminActionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AdminActionState, AdminActionState>,
              AdminActionState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
