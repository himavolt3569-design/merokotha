import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/models/listing_model.dart';
import '../../../shared/providers/firebase_providers.dart';

part 'owner_repository.g.dart';

class OwnerRepository {
  final FirebaseFirestore _db;

  OwnerRepository(this._db);

  CollectionReference<Map<String, dynamic>> get _listings =>
      _db.collection('listings');

  // ── Watch all listings for this owner in real time ──
  Stream<List<ListingModel>> watchMyListings(String ownerId) {
    return _listings
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => ListingModel.fromSnapshot(d)).toList(),
        );
  }

  // ── Get listings once ──
  Future<List<ListingModel>> getMyListings(String ownerId) async {
    final snap = await _listings
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) => ListingModel.fromSnapshot(d)).toList();
  }

  // ── Create new listing ──
  Future<String> createListing(ListingModel listing) async {
    final ref = await _listings.add(listing.toMap());
    return ref.id;
  }

  // ── Update existing listing ──
  Future<void> updateListing(String id, Map<String, dynamic> data) async {
    await _listings.doc(id).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Delete listing ──
  Future<void> deleteListing(String id) async {
    await _listings.doc(id).delete();
  }

  // ── Toggle pause / active ──
  Future<void> toggleListingStatus(String id, ListingStatus status) async {
    await _listings.doc(id).update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Increment view count ──
  Future<void> incrementViewCount(String id) async {
    await _listings.doc(id).update({'viewCount': FieldValue.increment(1)});
  }
}

@riverpod
OwnerRepository ownerRepository(Ref ref) {
  return OwnerRepository(ref.watch(firebaseFirestoreProvider));
}
