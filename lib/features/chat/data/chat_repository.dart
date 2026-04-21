import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/providers/firebase_providers.dart';
import 'chat_model.dart';

part 'chat_repository.g.dart';

class ChatRepository {
  final FirebaseFirestore _db;
  ChatRepository(this._db);

  CollectionReference<Map<String, dynamic>> get _chats =>
      _db.collection('chats');

  CollectionReference<Map<String, dynamic>> _messages(String chatId) =>
      _db.collection('chats').doc(chatId).collection('messages');

  // ── Create a new chat (called when inquiry is accepted) ──
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
    // Check if chat already exists for this inquiry pair
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

  // ── Watch all chats for an owner ──
  Stream<List<ChatModel>> watchOwnerChats(String ownerId) {
    return _chats
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => ChatModel.fromSnapshot(d)).toList());
  }

  // ── Watch all chats for a customer ──
  Stream<List<ChatModel>> watchCustomerChats(String customerId) {
    return _chats
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => ChatModel.fromSnapshot(d)).toList());
  }

  // ── Watch a single chat ──
  Stream<ChatModel?> watchChat(String chatId) {
    return _chats
        .doc(chatId)
        .snapshots()
        .map((s) => s.exists ? ChatModel.fromSnapshot(s) : null);
  }

  // ── Watch messages in a chat ──
  Stream<List<MessageModel>> watchMessages(String chatId) {
    return _messages(chatId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((s) => s.docs.map((d) => MessageModel.fromSnapshot(d)).toList());
  }

  // ── Send a text message ──
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
    String? imageUrl,
    required bool senderIsOwner,
  }) async {
    final batch = _db.batch();

    // Add message
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

    // Update chat: lastMessage, lastMessageAt, increment unread for OTHER person
    final chatRef = _chats.doc(chatId);
    batch.update(chatRef, {
      'lastMessage': imageUrl != null ? '📷 Photo' : text,
      'lastMessageAt': Timestamp.fromDate(DateTime.now()),
      'lastMessageSenderId': senderId,
      // Increment unread for the recipient
      if (senderIsOwner)
        'unreadCustomer': FieldValue.increment(1)
      else
        'unreadOwner': FieldValue.increment(1),
    });

    await batch.commit();
  }

  // ── Mark all messages as read (clear unread count) ──
  Future<void> markAsRead({
    required String chatId,
    required bool readerIsOwner,
  }) async {
    await _chats.doc(chatId).update({
      if (readerIsOwner) 'unreadOwner': 0 else 'unreadCustomer': 0,
    });
  }

  // ── Get total unread count for a user ──
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
            (sum, doc) => sum + ((doc.data()[unreadField] as int?) ?? 0),
          ),
        );
  }
}

@riverpod
ChatRepository chatRepository(Ref ref) =>
    ChatRepository(ref.watch(firebaseFirestoreProvider));
