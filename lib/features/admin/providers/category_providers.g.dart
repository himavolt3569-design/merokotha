// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(allCategories)
final allCategoriesProvider = AllCategoriesProvider._();

final class AllCategoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CategoryModel>>,
          List<CategoryModel>,
          Stream<List<CategoryModel>>
        >
    with
        $FutureModifier<List<CategoryModel>>,
        $StreamProvider<List<CategoryModel>> {
  AllCategoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allCategoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allCategoriesHash();

  @$internal
  @override
  $StreamProviderElement<List<CategoryModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<CategoryModel>> create(Ref ref) {
    return allCategories(ref);
  }
}

String _$allCategoriesHash() => r'32f7aaf5e4c48cad2e6154c0396513f0955440d1';

@ProviderFor(allCategoriesAdmin)
final allCategoriesAdminProvider = AllCategoriesAdminProvider._();

final class AllCategoriesAdminProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CategoryModel>>,
          List<CategoryModel>,
          Stream<List<CategoryModel>>
        >
    with
        $FutureModifier<List<CategoryModel>>,
        $StreamProvider<List<CategoryModel>> {
  AllCategoriesAdminProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allCategoriesAdminProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allCategoriesAdminHash();

  @$internal
  @override
  $StreamProviderElement<List<CategoryModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<CategoryModel>> create(Ref ref) {
    return allCategoriesAdmin(ref);
  }
}

String _$allCategoriesAdminHash() =>
    r'f8746029415694f5a51c3c5bf7235d3a764043e2';

@ProviderFor(level1Categories)
final level1CategoriesProvider = Level1CategoriesProvider._();

final class Level1CategoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CategoryModel>>,
          List<CategoryModel>,
          FutureOr<List<CategoryModel>>
        >
    with
        $FutureModifier<List<CategoryModel>>,
        $FutureProvider<List<CategoryModel>> {
  Level1CategoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'level1CategoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$level1CategoriesHash();

  @$internal
  @override
  $FutureProviderElement<List<CategoryModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CategoryModel>> create(Ref ref) {
    return level1Categories(ref);
  }
}

String _$level1CategoriesHash() => r'd86e721cdb665f5bb4c3d94c3e167bbf5bc14b83';

@ProviderFor(level2Categories)
final level2CategoriesProvider = Level2CategoriesFamily._();

final class Level2CategoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CategoryModel>>,
          List<CategoryModel>,
          FutureOr<List<CategoryModel>>
        >
    with
        $FutureModifier<List<CategoryModel>>,
        $FutureProvider<List<CategoryModel>> {
  Level2CategoriesProvider._({
    required Level2CategoriesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'level2CategoriesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$level2CategoriesHash();

  @override
  String toString() {
    return r'level2CategoriesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<CategoryModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CategoryModel>> create(Ref ref) {
    final argument = this.argument as String;
    return level2Categories(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is Level2CategoriesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$level2CategoriesHash() => r'da71cce5718b10acda5156381e1dcf3b1473c903';

final class Level2CategoriesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<CategoryModel>>, String> {
  Level2CategoriesFamily._()
    : super(
        retry: null,
        name: r'level2CategoriesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  Level2CategoriesProvider call(String parentId) =>
      Level2CategoriesProvider._(argument: parentId, from: this);

  @override
  String toString() => r'level2CategoriesProvider';
}

@ProviderFor(level3Categories)
final level3CategoriesProvider = Level3CategoriesFamily._();

final class Level3CategoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CategoryModel>>,
          List<CategoryModel>,
          FutureOr<List<CategoryModel>>
        >
    with
        $FutureModifier<List<CategoryModel>>,
        $FutureProvider<List<CategoryModel>> {
  Level3CategoriesProvider._({
    required Level3CategoriesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'level3CategoriesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$level3CategoriesHash();

  @override
  String toString() {
    return r'level3CategoriesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<CategoryModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CategoryModel>> create(Ref ref) {
    final argument = this.argument as String;
    return level3Categories(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is Level3CategoriesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$level3CategoriesHash() => r'093a2a73f7f7240a2c23635c76eb98c6ce84d23a';

final class Level3CategoriesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<CategoryModel>>, String> {
  Level3CategoriesFamily._()
    : super(
        retry: null,
        name: r'level3CategoriesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  Level3CategoriesProvider call(String parentId) =>
      Level3CategoriesProvider._(argument: parentId, from: this);

  @override
  String toString() => r'level3CategoriesProvider';
}

@ProviderFor(categoryById)
final categoryByIdProvider = CategoryByIdFamily._();

final class CategoryByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<CategoryModel?>,
          CategoryModel?,
          FutureOr<CategoryModel?>
        >
    with $FutureModifier<CategoryModel?>, $FutureProvider<CategoryModel?> {
  CategoryByIdProvider._({
    required CategoryByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'categoryByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$categoryByIdHash();

  @override
  String toString() {
    return r'categoryByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<CategoryModel?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CategoryModel?> create(Ref ref) {
    final argument = this.argument as String;
    return categoryById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CategoryByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$categoryByIdHash() => r'f3fac5015aaa734ee2ac4ae2a709a169fd489c02';

final class CategoryByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<CategoryModel?>, String> {
  CategoryByIdFamily._()
    : super(
        retry: null,
        name: r'categoryByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CategoryByIdProvider call(String id) =>
      CategoryByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'categoryByIdProvider';
}

@ProviderFor(categoryTree)
final categoryTreeProvider = CategoryTreeProvider._();

final class CategoryTreeProvider
    extends
        $FunctionalProvider<
          Map<String, List<CategoryModel>>,
          Map<String, List<CategoryModel>>,
          Map<String, List<CategoryModel>>
        >
    with $Provider<Map<String, List<CategoryModel>>> {
  CategoryTreeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoryTreeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoryTreeHash();

  @$internal
  @override
  $ProviderElement<Map<String, List<CategoryModel>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Map<String, List<CategoryModel>> create(Ref ref) {
    return categoryTree(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, List<CategoryModel>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, List<CategoryModel>>>(
        value,
      ),
    );
  }
}

String _$categoryTreeHash() => r'a5a944997c9ee2435ec8fc74fd2d4e3a8d586e4b';

@ProviderFor(CategorySelectionNotifier)
final categorySelectionProvider = CategorySelectionNotifierProvider._();

final class CategorySelectionNotifierProvider
    extends $NotifierProvider<CategorySelectionNotifier, CategorySelection> {
  CategorySelectionNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categorySelectionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categorySelectionNotifierHash();

  @$internal
  @override
  CategorySelectionNotifier create() => CategorySelectionNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CategorySelection value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CategorySelection>(value),
    );
  }
}

String _$categorySelectionNotifierHash() =>
    r'4021bca6ef3796e09aef9a1a79a74a35ffcbafa3';

abstract class _$CategorySelectionNotifier
    extends $Notifier<CategorySelection> {
  CategorySelection build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<CategorySelection, CategorySelection>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CategorySelection, CategorySelection>,
              CategorySelection,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(CategoryActionNotifier)
final categoryActionProvider = CategoryActionNotifierProvider._();

final class CategoryActionNotifierProvider
    extends $NotifierProvider<CategoryActionNotifier, CategoryActionState> {
  CategoryActionNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoryActionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoryActionNotifierHash();

  @$internal
  @override
  CategoryActionNotifier create() => CategoryActionNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CategoryActionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CategoryActionState>(value),
    );
  }
}

String _$categoryActionNotifierHash() =>
    r'92664368d1a05a051159426a0ccffc365dd92093';

abstract class _$CategoryActionNotifier extends $Notifier<CategoryActionState> {
  CategoryActionState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<CategoryActionState, CategoryActionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CategoryActionState, CategoryActionState>,
              CategoryActionState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
