import 'package:cloud_firestore/cloud_firestore.dart';

// --------------- Inquiry Model ---------------

enum InquiryStatus { pending, accepted, declined }

class InquiryModel {
  final String id;
  final String listingId;
  final String listingTitle;
  final String customerId;
  final String customerName;
  final String? customerPhotoUrl;
  final String ownerId;
  final String? ownerName;
  final String message;
  final DateTime moveInDate;
  final InquiryStatus status;
  final String? declineReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  const InquiryModel({
    required this.id,
    required this.listingId,
    required this.listingTitle,
    required this.customerId,
    required this.customerName,
    this.customerPhotoUrl,
    required this.ownerId,
    this.ownerName,
    required this.message,
    required this.moveInDate,
    required this.status,
    this.declineReason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InquiryModel.fromMap(Map<String, dynamic> map, String id) {
    return InquiryModel(
      id: id,
      listingId: map['listingId'] as String? ?? '',
      listingTitle: map['listingTitle'] as String? ?? '',
      customerId: map['customerId'] as String? ?? '',
      customerName: map['customerName'] as String? ?? '',
      customerPhotoUrl: map['customerPhotoUrl'] as String?,
      ownerId: map['ownerId'] as String? ?? '',
      ownerName: map['ownerName'] as String?,
      message: map['message'] as String? ?? '',
      moveInDate: (map['moveInDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: InquiryStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => InquiryStatus.pending,
      ),
      declineReason: map['declineReason'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory InquiryModel.fromSnapshot(DocumentSnapshot doc) {
    return InquiryModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'listingId': listingId,
      'listingTitle': listingTitle,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhotoUrl': customerPhotoUrl,
      'ownerId': ownerId,
      'message': message,
      'moveInDate': Timestamp.fromDate(moveInDate),
      'status': status.name,
      'declineReason': declineReason,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  bool get isPending => status == InquiryStatus.pending;
  bool get isAccepted => status == InquiryStatus.accepted;
  bool get isDeclined => status == InquiryStatus.declined;
}

// --------------- Message Model ---------------

class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String text;
  final bool isRead;
  final DateTime timestamp;

  const MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.text,
    required this.isRead,
    required this.timestamp,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    return MessageModel(
      id: id,
      chatId: map['chatId'] as String? ?? '',
      senderId: map['senderId'] as String? ?? '',
      text: map['text'] as String? ?? '',
      isRead: map['isRead'] as bool? ?? false,
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory MessageModel.fromSnapshot(DocumentSnapshot doc) {
    return MessageModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'senderId': senderId,
      'text': text,
      'isRead': isRead,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}

// --------------- Chat Model ---------------

class ChatModel {
  final String id;
  final String listingId;
  final String listingTitle;
  final String ownerId;
  final String customerId;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCountOwner;
  final int unreadCountCustomer;
  final DateTime createdAt;

  const ChatModel({
    required this.id,
    required this.listingId,
    required this.listingTitle,
    required this.ownerId,
    required this.customerId,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCountOwner = 0,
    this.unreadCountCustomer = 0,
    required this.createdAt,
  });

  factory ChatModel.fromMap(Map<String, dynamic> map, String id) {
    return ChatModel(
      id: id,
      listingId: map['listingId'] as String? ?? '',
      listingTitle: map['listingTitle'] as String? ?? '',
      ownerId: map['ownerId'] as String? ?? '',
      customerId: map['customerId'] as String? ?? '',
      lastMessage: map['lastMessage'] as String?,
      lastMessageAt: (map['lastMessageAt'] as Timestamp?)?.toDate(),
      unreadCountOwner: map['unreadCountOwner'] as int? ?? 0,
      unreadCountCustomer: map['unreadCountCustomer'] as int? ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory ChatModel.fromSnapshot(DocumentSnapshot doc) {
    return ChatModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'listingId': listingId,
      'listingTitle': listingTitle,
      'ownerId': ownerId,
      'customerId': customerId,
      'lastMessage': lastMessage,
      'lastMessageAt': lastMessageAt != null
          ? Timestamp.fromDate(lastMessageAt!)
          : null,
      'unreadCountOwner': unreadCountOwner,
      'unreadCountCustomer': unreadCountCustomer,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
