import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:merokotha/shared/models/listing_model.dart';
import 'package:merokotha/shared/providers/firebase_providers.dart';

part 'favourites_repository.g.dart';

class FavouritesRepository {
  final FirebaseFirestore _db;
  FavouritesRepository(this._db);

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _db.collection('users').doc(uid).collection('favourites');

  // Stream of favourited listing IDs
  Stream<List<String>> watchFavouriteIds(String uid) {
    return _col(uid).snapshots().map((s) => s.docs.map((d) => d.id).toList());
  }

  Future<void> addFavourite(String uid, ListingModel listing) async {
    await _col(uid).doc(listing.id).set({
      'listingId': listing.id,
      'title': listing.title,
      'rentPerMonth': listing.rentPerMonth,
      'savedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeFavourite(String uid, String listingId) async {
    await _col(uid).doc(listingId).delete();
  }

  Future<bool> isFavourite(String uid, String listingId) async {
    final doc = await _col(uid).doc(listingId).get();
    return doc.exists;
  }
}

@riverpod
FavouritesRepository favouritesRepository(Ref ref) =>
    FavouritesRepository(ref.watch(firebaseFirestoreProvider));
