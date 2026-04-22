import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/providers/firebase_providers.dart';
import 'ad_model.dart';

part 'ad_repository.g.dart';

class AdRepository {
  final FirebaseFirestore _db;
  AdRepository(this._db);

  CollectionReference<Map<String, dynamic>> get _ads => _db.collection('ads');

  // ── Get live ads for a placement ──
  Stream<List<AdModel>> watchAdsForPlacement(AdPlacement placement) {
    return _ads
        .where('placement', isEqualTo: placement.name)
        .where('status', isEqualTo: AdStatus.active.name)
        .orderBy('priority', descending: true)
        .snapshots()
        .map(
          (s) => s.docs
              .map((d) => AdModel.fromSnapshot(d))
              .where((ad) => ad.isLive)
              .toList(),
        );
  }

  // ── Get all ads (for admin) ──
  Stream<List<AdModel>> watchAllAds() {
    return _ads
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => AdModel.fromSnapshot(d)).toList());
  }

  // ── Create ad (admin) ──
  Future<String> createAd(AdModel ad) async {
    final ref = await _ads.add(ad.toMap());
    return ref.id;
  }

  // ── Update ad (admin) ──
  Future<void> updateAd(String id, Map<String, dynamic> data) async {
    await _ads.doc(id).update(data);
  }

  // ── Toggle status (admin) ──
  Future<void> toggleStatus(String id, AdStatus status) async {
    await _ads.doc(id).update({'status': status.name});
  }

  // ── Delete ad (admin) ──
  Future<void> deleteAd(String id) async {
    await _ads.doc(id).delete();
  }
}

@riverpod
AdRepository adRepository(Ref ref) =>
    AdRepository(ref.watch(firebaseFirestoreProvider));
