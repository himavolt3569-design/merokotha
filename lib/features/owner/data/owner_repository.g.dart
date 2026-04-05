// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'owner_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ownerRepository)
final ownerRepositoryProvider = OwnerRepositoryProvider._();

final class OwnerRepositoryProvider
    extends
        $FunctionalProvider<OwnerRepository, OwnerRepository, OwnerRepository>
    with $Provider<OwnerRepository> {
  OwnerRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ownerRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ownerRepositoryHash();

  @$internal
  @override
  $ProviderElement<OwnerRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OwnerRepository create(Ref ref) {
    return ownerRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OwnerRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OwnerRepository>(value),
    );
  }
}

String _$ownerRepositoryHash() => r'dac00c89915e38eb15cb8b93a2062f8b755fb54c';
