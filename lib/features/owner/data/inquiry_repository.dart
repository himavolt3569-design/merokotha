import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/models/inquiry_model.dart';
import '../../../shared/providers/firebase_providers.dart';

part 'inquiry_repository.g.dart';

class InquiryRepository {
  final FirebaseFirestore _db;

  InquiryRepository(this._db);

  CollectionReference<Map<String, dynamic>> get _inquiries =>
      _db.collection('inquiries');

  // ── Watch all inquiries for owner ──
  Stream<List<InquiryModel>> watchOwnerInquiries(String ownerId) {
    return _inquiries
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => InquiryModel.fromSnapshot(d)).toList());
  }

  // ── Watch inquiries by status ──
  Stream<List<InquiryModel>> watchByStatus(
    String ownerId,
    InquiryStatus status,
  ) {
    return _inquiries
        .where('ownerId', isEqualTo: ownerId)
        .where('status', isEqualTo: status.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => InquiryModel.fromSnapshot(d)).toList());
  }

  // ── Watch customer's own inquiries ──
  Stream<List<InquiryModel>> watchCustomerInquiries(String customerId) {
    return _inquiries
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => InquiryModel.fromSnapshot(d)).toList());
  }

  // ── Create inquiry (customer sends) ──
  Future<String> createInquiry(InquiryModel inquiry) async {
    final ref = await _inquiries.add(inquiry.toMap());
    return ref.id;
  }

  // ── Accept inquiry ──
  Future<void> acceptInquiry(String id) async {
    await _inquiries.doc(id).update({
      'status': InquiryStatus.accepted.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Decline inquiry ──
  Future<void> declineInquiry(String id, {String? reason}) async {
    await _inquiries.doc(id).update({
      'status': InquiryStatus.declined.name,
      'declineReason': reason,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Unread pending count for owner ──
  Stream<int> watchPendingCount(String ownerId) {
    return _inquiries
        .where('ownerId', isEqualTo: ownerId)
        .where('status', isEqualTo: InquiryStatus.pending.name)
        .snapshots()
        .map((s) => s.docs.length);
  }
}

@riverpod
InquiryRepository inquiryRepository(Ref ref) {
  return InquiryRepository(ref.watch(firebaseFirestoreProvider));
}
