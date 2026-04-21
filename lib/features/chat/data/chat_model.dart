import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String id;
  final String ownerId;
  final String ownerName;
  final String? ownerPhotoUrl;
  final String customerId;
  final String customerName;
  final String? customerPhotoUrl;
  final String listingId;
  final String listingTitle;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final String? lastMessageSenderId;
  final int unreadOwner; // unread count for owner
  final int unreadCustomer; // unread count for customer
  final DateTime createdAt;

  const ChatModel({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    this.ownerPhotoUrl,
    required this.customerId,
    required this.customerName,
    this.customerPhotoUrl,
    required this.listingId,
    required this.listingTitle,
    this.lastMessage,
    this.lastMessageAt,
    this.lastMessageSenderId,
    this.unreadOwner = 0,
    this.unreadCustomer = 0,
    required this.createdAt,
  });

  factory ChatModel.fromMap(Map<String, dynamic> map, String id) {
    return ChatModel(
      id: id,
      ownerId: map['ownerId'] as String? ?? '',
      ownerName: map['ownerName'] as String? ?? '',
      ownerPhotoUrl: map['ownerPhotoUrl'] as String?,
      customerId: map['customerId'] as String? ?? '',
      customerName: map['customerName'] as String? ?? '',
      customerPhotoUrl: map['customerPhotoUrl'] as String?,
      listingId: map['listingId'] as String? ?? '',
      listingTitle: map['listingTitle'] as String? ?? '',
      lastMessage: map['lastMessage'] as String?,
      lastMessageAt: (map['lastMessageAt'] as Timestamp?)?.toDate(),
      lastMessageSenderId: map['lastMessageSenderId'] as String?,
      unreadOwner: map['unreadOwner'] as int? ?? 0,
      unreadCustomer: map['unreadCustomer'] as int? ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory ChatModel.fromSnapshot(DocumentSnapshot doc) =>
      ChatModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);

  Map<String, dynamic> toMap() => {
    'ownerId': ownerId,
    'ownerName': ownerName,
    'ownerPhotoUrl': ownerPhotoUrl,
    'customerId': customerId,
    'customerName': customerName,
    'customerPhotoUrl': customerPhotoUrl,
    'listingId': listingId,
    'listingTitle': listingTitle,
    'lastMessage': lastMessage,
    'lastMessageAt': lastMessageAt != null
        ? Timestamp.fromDate(lastMessageAt!)
        : null,
    'lastMessageSenderId': lastMessageSenderId,
    'unreadOwner': unreadOwner,
    'unreadCustomer': unreadCustomer,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  // Get other person's name (given my uid)
  String otherName(String myUid) => myUid == ownerId ? customerName : ownerName;

  String? otherPhoto(String myUid) =>
      myUid == ownerId ? customerPhotoUrl : ownerPhotoUrl;

  int unreadFor(String myUid) =>
      myUid == ownerId ? unreadOwner : unreadCustomer;
}

// ── Message Model ─────────────────────────────────────────────────

class MessageModel {
  final String id;
  final String senderId;
  final String text;
  final String? imageUrl;
  final bool isRead;
  final DateTime createdAt;

  const MessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    this.imageUrl,
    this.isRead = false,
    required this.createdAt,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    return MessageModel(
      id: id,
      senderId: map['senderId'] as String? ?? '',
      text: map['text'] as String? ?? '',
      imageUrl: map['imageUrl'] as String?,
      isRead: map['isRead'] as bool? ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory MessageModel.fromSnapshot(DocumentSnapshot doc) =>
      MessageModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);

  Map<String, dynamic> toMap() => {
    'senderId': senderId,
    'text': text,
    'imageUrl': imageUrl,
    'isRead': isRead,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;
}
