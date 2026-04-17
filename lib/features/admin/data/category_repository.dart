import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/models/category_model.dart';
import '../../../shared/providers/firebase_providers.dart';

part 'category_repository.g.dart';

class CategoryRepository {
  final FirebaseFirestore _db;
  CategoryRepository(this._db);

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('categories');

  // ── Watch all active categories ──
  Stream<List<CategoryModel>> watchAll() {
    return _col
        .where('isActive', isEqualTo: true)
        .orderBy('sortOrder')
        .snapshots()
        .map((s) => s.docs.map((d) => CategoryModel.fromSnapshot(d)).toList());
  }

  // ── Watch all (including inactive) — for admin ──
  Stream<List<CategoryModel>> watchAllAdmin() {
    return _col
        .orderBy('level')
        .orderBy('sortOrder')
        .snapshots()
        .map((s) => s.docs.map((d) => CategoryModel.fromSnapshot(d)).toList());
  }

  // ── Get all once ──
  Future<List<CategoryModel>> getAll() async {
    final snap = await _col
        .where('isActive', isEqualTo: true)
        .orderBy('sortOrder')
        .get();
    return snap.docs.map((d) => CategoryModel.fromSnapshot(d)).toList();
  }

  // ── Get level 1 categories ──
  Future<List<CategoryModel>> getLevel1() async {
    final snap = await _col
        .where('level', isEqualTo: CategoryLevel.level1.name)
        .where('isActive', isEqualTo: true)
        .orderBy('sortOrder')
        .get();
    return snap.docs.map((d) => CategoryModel.fromSnapshot(d)).toList();
  }

  // ── Get level 2 under a level 1 parent ──
  Future<List<CategoryModel>> getLevel2(String parentId) async {
    final snap = await _col
        .where('level', isEqualTo: CategoryLevel.level2.name)
        .where('parentId', isEqualTo: parentId)
        .where('isActive', isEqualTo: true)
        .orderBy('sortOrder')
        .get();
    return snap.docs.map((d) => CategoryModel.fromSnapshot(d)).toList();
  }

  // ── Get level 3 under a level 2 parent ──
  Future<List<CategoryModel>> getLevel3(String parentId) async {
    final snap = await _col
        .where('level', isEqualTo: CategoryLevel.level3.name)
        .where('parentId', isEqualTo: parentId)
        .where('isActive', isEqualTo: true)
        .orderBy('sortOrder')
        .get();
    return snap.docs.map((d) => CategoryModel.fromSnapshot(d)).toList();
  }

  // ── Get category by ID ──
  Future<CategoryModel?> getById(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return null;
    return CategoryModel.fromSnapshot(doc);
  }

  // ── Create category (admin) ──
  Future<String> create(CategoryModel cat) async {
    final ref = await _col.add(cat.toMap());
    return ref.id;
  }

  // ── Update category (admin) ──
  Future<void> update(String id, Map<String, dynamic> data) async {
    await _col.doc(id).update(data);
  }

  // ── Toggle active (admin soft delete) ──
  Future<void> toggleActive(String id, bool isActive) async {
    await _col.doc(id).update({'isActive': isActive});
  }

  // ── Delete category (admin) ──
  Future<void> delete(String id) async {
    await _col.doc(id).delete();
  }

  // ── Seed default categories (call once from admin) ──
  Future<void> seedDefaults() async {
    final batch = _db.batch();
    final now = DateTime.now();
    int order = 0;

    // Level 1
    final l1Data = [
      ('Residential', 'आवासीय'),
      ('Commercial', 'व्यापारिक'),
      ('Land', 'जग्गा'),
    ];

    for (final (name, nameNp) in l1Data) {
      final ref = _col.doc();
      batch.set(
        ref,
        CategoryModel(
          id: ref.id,
          name: name,
          nameNp: nameNp,
          level: CategoryLevel.level1,
          sortOrder: order++,
          createdAt: now,
        ).toMap(),
      );
    }

    await batch.commit();
  }
}

@riverpod
CategoryRepository categoryRepository(Ref ref) =>
    CategoryRepository(ref.watch(firebaseFirestoreProvider));
