import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:merokotha/shared/models/category_model.dart';
import 'package:merokotha/features/admin/data/category_repository.dart';

part 'category_providers.g.dart';

// ── All active categories stream ──
@riverpod
Stream<List<CategoryModel>> allCategories(Ref ref) {
  return ref.watch(categoryRepositoryProvider).watchAll();
}

// ── All categories for admin (includes inactive) ──
@riverpod
Stream<List<CategoryModel>> allCategoriesAdmin(Ref ref) {
  return ref.watch(categoryRepositoryProvider).watchAllAdmin();
}

// ── Level 1 categories only ──
@riverpod
Stream<List<CategoryModel>> level1Categories(Ref ref) =>
    ref.read(categoryRepositoryProvider).watchLevel1();

@riverpod
Stream<List<CategoryModel>> level2Categories(Ref ref, String parentId) =>
    ref.read(categoryRepositoryProvider).watchLevel2(parentId);

@riverpod
Stream<List<CategoryModel>> level3Categories(Ref ref, String parentId) =>
    ref.read(categoryRepositoryProvider).watchLevel3(parentId);

// ── Category by ID ──
@riverpod
Future<CategoryModel?> categoryById(Ref ref, String id) {
  return ref.watch(categoryRepositoryProvider).getById(id);
}

// ── Build category tree from flat list ──
@riverpod
Map<String, List<CategoryModel>> categoryTree(Ref ref) {
  final all = ref.watch(allCategoriesProvider).value ?? [];
  final Map<String, List<CategoryModel>> tree = {};

  // Group by parentId (null key = level1 roots)
  for (final cat in all) {
    final key = cat.parentId ?? 'root';
    tree.putIfAbsent(key, () => []).add(cat);
  }
  return tree;
}

// ── Category selection notifier (for upload listing / search) ──
@riverpod
class CategorySelectionNotifier extends _$CategorySelectionNotifier {
  @override
  CategorySelection build() => const CategorySelection();

  void selectLevel1(CategoryModel cat) {
    state = CategorySelection(level1: cat);
  }

  void selectLevel2(CategoryModel cat) {
    state = state.copyWith(level2: cat, clearLevel3: true);
  }

  void selectLevel3(CategoryModel cat) {
    state = state.copyWith(level3: cat);
  }

  void reset() => state = const CategorySelection();
}

// ── Admin category action notifier ──
class CategoryActionState {
  final bool isLoading;
  final String? error;
  final bool success;

  const CategoryActionState({
    this.isLoading = false,
    this.error,
    this.success = false,
  });

  CategoryActionState copyWith({
    bool? isLoading,
    String? error,
    bool? success,
    bool clearError = false,
  }) => CategoryActionState(
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : (error ?? this.error),
    success: success ?? this.success,
  );
}

@riverpod
class CategoryActionNotifier extends _$CategoryActionNotifier {
  @override
  CategoryActionState build() => const CategoryActionState();

  Future<void> create({
    required String name,
    String nameNp = '',
    required CategoryLevel level,
    String? parentId,
    String? grandParentId,
    int sortOrder = 0,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final cat = CategoryModel(
        id: '',
        name: name,
        nameNp: nameNp,
        level: level,
        parentId: parentId,
        grandParentId: grandParentId,
        sortOrder: sortOrder,
        createdAt: DateTime.now(),
      );
      await ref.read(categoryRepositoryProvider).create(cat);
      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to create: $e');
    }
  }

  Future<void> update(String id, String name, String nameNp) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(categoryRepositoryProvider).update(id, {
        'name': name,
        'nameNp': nameNp,
      });
      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to update: $e');
    }
  }

  Future<void> toggleActive(String id, bool isActive) async {
    await ref.read(categoryRepositoryProvider).toggleActive(id, isActive);
  }

  Future<void> delete(String id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(categoryRepositoryProvider).delete(id);
      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to delete: $e');
    }
  }

  Future<void> seedDefaults() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(categoryRepositoryProvider).seedDefaults();
      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void reset() => state = const CategoryActionState();
}
