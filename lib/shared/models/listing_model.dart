import 'package:cloud_firestore/cloud_firestore.dart';

enum RoomType { single, shared, flat, apartment }

enum FurnishingType { furnished, semiFurnished, unfurnished }

enum ListingStatus { active, paused, rented }

class ListingModel {
  final String id;
  final String ownerId;
  final String ownerName;
  final String? ownerPhotoUrl;
  final String title;
  final RoomType roomType;
  final double rentPerMonth;
  final double depositAmount;
  final int floor;
  final int totalFloors;
  final FurnishingType furnishing;
  final List<String> facilities;
  final String description;
  final List<String> photoUrls;
  final GeoPoint? geoPoint;
  final String? address;
  final String? nearbyLandmarks;
  final DateTime availableFrom;
  final ListingStatus status;
  final int viewCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ListingModel({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    this.ownerPhotoUrl,
    required this.title,
    required this.roomType,
    required this.rentPerMonth,
    required this.depositAmount,
    required this.floor,
    required this.totalFloors,
    required this.furnishing,
    required this.facilities,
    required this.description,
    required this.photoUrls,
    this.geoPoint,
    this.address,
    this.nearbyLandmarks,
    required this.availableFrom,
    required this.status,
    this.viewCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ListingModel.fromMap(Map<String, dynamic> map, String id) {
    return ListingModel(
      id: id,
      ownerId: map['ownerId'] as String? ?? '',
      ownerName: map['ownerName'] as String? ?? '',
      ownerPhotoUrl: map['ownerPhotoUrl'] as String?,
      title: map['title'] as String? ?? '',
      roomType: RoomType.values.firstWhere(
        (e) => e.name == map['roomType'],
        orElse: () => RoomType.single,
      ),
      rentPerMonth: (map['rentPerMonth'] as num?)?.toDouble() ?? 0,
      depositAmount: (map['depositAmount'] as num?)?.toDouble() ?? 0,
      floor: map['floor'] as int? ?? 0,
      totalFloors: map['totalFloors'] as int? ?? 1,
      furnishing: FurnishingType.values.firstWhere(
        (e) => e.name == map['furnishing'],
        orElse: () => FurnishingType.unfurnished,
      ),
      facilities: List<String>.from(map['facilities'] ?? []),
      description: map['description'] as String? ?? '',
      photoUrls: List<String>.from(map['photoUrls'] ?? []),
      geoPoint: map['geoPoint'] as GeoPoint?,
      address: map['address'] as String?,
      nearbyLandmarks: map['nearbyLandmarks'] as String?,
      availableFrom:
          (map['availableFrom'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: ListingStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ListingStatus.active,
      ),
      viewCount: map['viewCount'] as int? ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory ListingModel.fromSnapshot(DocumentSnapshot doc) {
    return ListingModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'ownerName': ownerName,
      'ownerPhotoUrl': ownerPhotoUrl,
      'title': title,
      'roomType': roomType.name,
      'rentPerMonth': rentPerMonth,
      'depositAmount': depositAmount,
      'floor': floor,
      'totalFloors': totalFloors,
      'furnishing': furnishing.name,
      'facilities': facilities,
      'description': description,
      'photoUrls': photoUrls,
      'geoPoint': geoPoint,
      'address': address,
      'nearbyLandmarks': nearbyLandmarks,
      'availableFrom': Timestamp.fromDate(availableFrom),
      'status': status.name,
      'viewCount': viewCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  ListingModel copyWith({
    String? title,
    RoomType? roomType,
    double? rentPerMonth,
    double? depositAmount,
    int? floor,
    int? totalFloors,
    FurnishingType? furnishing,
    List<String>? facilities,
    String? description,
    List<String>? photoUrls,
    GeoPoint? geoPoint,
    String? address,
    String? nearbyLandmarks,
    DateTime? availableFrom,
    ListingStatus? status,
    int? viewCount,
  }) {
    return ListingModel(
      id: id,
      ownerId: ownerId,
      ownerName: ownerName,
      ownerPhotoUrl: ownerPhotoUrl,
      title: title ?? this.title,
      roomType: roomType ?? this.roomType,
      rentPerMonth: rentPerMonth ?? this.rentPerMonth,
      depositAmount: depositAmount ?? this.depositAmount,
      floor: floor ?? this.floor,
      totalFloors: totalFloors ?? this.totalFloors,
      furnishing: furnishing ?? this.furnishing,
      facilities: facilities ?? this.facilities,
      description: description ?? this.description,
      photoUrls: photoUrls ?? this.photoUrls,
      geoPoint: geoPoint ?? this.geoPoint,
      address: address ?? this.address,
      nearbyLandmarks: nearbyLandmarks ?? this.nearbyLandmarks,
      availableFrom: availableFrom ?? this.availableFrom,
      status: status ?? this.status,
      viewCount: viewCount ?? this.viewCount,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  bool get isActive => status == ListingStatus.active;
  String get roomTypeLabel =>
      roomType.name[0].toUpperCase() + roomType.name.substring(1);
  String get furnishingLabel {
    switch (furnishing) {
      case FurnishingType.furnished:
        return 'Furnished';
      case FurnishingType.semiFurnished:
        return 'Semi-furnished';
      case FurnishingType.unfurnished:
        return 'Unfurnished';
    }
  }
}
