import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:merokotha/shared/providers/firebase_providers.dart';
import 'package:merokotha/features/chat/data/chat_model.dart';

part 'chat_repository.g.dart';

class ChatRepository {
  final FirebaseFirestore _db;
  ChatRepository(this._db);

  CollectionReference<Map<String, dynamic>> get _chats =>
      _db.collection('chats');

  CollectionReference<Map<String, dynamic>> _messages(String chatId) =>
      _db.collection('chats').doc(chatId).collection('messages');

  Future<String> createChat({
    required String ownerId,
    required String ownerName,
    String? ownerPhotoUrl,
    required String customerId,
    required String customerName,
    String? customerPhotoUrl,
    required String listingId,
    required String listingTitle,
  }) async {
    // Return existing chat if one already exists for this owner+customer+listing
    final existing = await _chats
        .where('ownerId', isEqualTo: ownerId)
        .where('customerId', isEqualTo: customerId)
        .where('listingId', isEqualTo: listingId)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      return existing.docs.first.id;
    }

    final chat = ChatModel(
      id: '',
      ownerId: ownerId,
      ownerName: ownerName,
      ownerPhotoUrl: ownerPhotoUrl,
      customerId: customerId,
      customerName: customerName,
      customerPhotoUrl: customerPhotoUrl,
      listingId: listingId,
      listingTitle: listingTitle,
      createdAt: DateTime.now(),
    );

    final ref = await _chats.add(chat.toMap());
    return ref.id;
  }

  Stream<List<ChatModel>> watchOwnerChats(String ownerId) {
    return _chats
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => ChatModel.fromSnapshot(d)).toList());
  }

  Stream<List<ChatModel>> watchCustomerChats(String customerId) {
    return _chats
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => ChatModel.fromSnapshot(d)).toList());
  }

  Stream<ChatModel?> watchChat(String chatId) {
    return _chats
        .doc(chatId)
        .snapshots()
        .map((s) => s.exists ? ChatModel.fromSnapshot(s) : null);
  }

  Stream<List<MessageModel>> watchMessages(String chatId) {
    return _messages(chatId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((s) => s.docs.map((d) => MessageModel.fromSnapshot(d)).toList());
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
    String? imageUrl,
    required bool senderIsOwner,
  }) async {
    final batch = _db.batch();

    final msgRef = _messages(chatId).doc();
    batch.set(
      msgRef,
      MessageModel(
        id: msgRef.id,
        senderId: senderId,
        text: text,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
      ).toMap(),
    );

    final chatRef = _chats.doc(chatId);
    batch.update(chatRef, {
      'lastMessage': imageUrl != null ? '📷 Photo' : text,
      'lastMessageAt': Timestamp.fromDate(DateTime.now()),
      'lastMessageSenderId': senderId,
      if (senderIsOwner)
        'unreadCustomer': FieldValue.increment(1)
      else
        'unreadOwner': FieldValue.increment(1),
    });

    await batch.commit();
  }

  Future<void> markAsRead({
    required String chatId,
    required bool readerIsOwner,
  }) async {
    await _chats.doc(chatId).update({
      if (readerIsOwner) 'unreadOwner': 0 else 'unreadCustomer': 0,
    });
  }

  Stream<int> watchTotalUnread({
    required String userId,
    required bool isOwner,
  }) {
    final field = isOwner ? 'ownerId' : 'customerId';
    final unreadField = isOwner ? 'unreadOwner' : 'unreadCustomer';

    return _chats
        .where(field, isEqualTo: userId)
        .snapshots()
        .map(
          (s) => s.docs.fold<int>(
            0,
            (total, doc) => total + ((doc.data()[unreadField] as int?) ?? 0),
          ),
        );
  }
}

@riverpod
ChatRepository chatRepository(Ref ref) =>
    ChatRepository(ref.watch(firebaseFirestoreProvider));
