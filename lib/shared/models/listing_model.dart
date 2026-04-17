import 'package:cloud_firestore/cloud_firestore.dart';

// Keep FurnishingType and ListingStatus as hardcoded enums
// — these are structural, not business categories
enum FurnishingType { furnished, semiFurnished, unfurnished }

enum ListingStatus { active, paused, rented }

class ListingModel {
  final String id;
  final String ownerId;
  final String ownerName;
  final String? ownerPhotoUrl;
  final String title;

  // ── Dynamic 3-level category (replaces hardcoded RoomType) ──
  final String? categoryL1Id;
  final String? categoryL2Id;
  final String? categoryL3Id;
  final String? categoryL1Name;
  final String? categoryL2Name;
  final String? categoryL3Name;

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
    this.categoryL1Id,
    this.categoryL2Id,
    this.categoryL3Id,
    this.categoryL1Name,
    this.categoryL2Name,
    this.categoryL3Name,
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
      categoryL1Id: map['categoryL1Id'] as String?,
      categoryL2Id: map['categoryL2Id'] as String?,
      categoryL3Id: map['categoryL3Id'] as String?,
      categoryL1Name: map['categoryL1Name'] as String?,
      categoryL2Name: map['categoryL2Name'] as String?,
      categoryL3Name: map['categoryL3Name'] as String?,
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

  Map<String, dynamic> toMap() => {
    'ownerId': ownerId,
    'ownerName': ownerName,
    'ownerPhotoUrl': ownerPhotoUrl,
    'title': title,
    'categoryL1Id': categoryL1Id,
    'categoryL2Id': categoryL2Id,
    'categoryL3Id': categoryL3Id,
    'categoryL1Name': categoryL1Name,
    'categoryL2Name': categoryL2Name,
    'categoryL3Name': categoryL3Name,
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

  ListingModel copyWith({
    String? title,
    String? categoryL1Id,
    String? categoryL2Id,
    String? categoryL3Id,
    String? categoryL1Name,
    String? categoryL2Name,
    String? categoryL3Name,
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
  }) => ListingModel(
    id: id,
    ownerId: ownerId,
    ownerName: ownerName,
    ownerPhotoUrl: ownerPhotoUrl,
    title: title ?? this.title,
    categoryL1Id: categoryL1Id ?? this.categoryL1Id,
    categoryL2Id: categoryL2Id ?? this.categoryL2Id,
    categoryL3Id: categoryL3Id ?? this.categoryL3Id,
    categoryL1Name: categoryL1Name ?? this.categoryL1Name,
    categoryL2Name: categoryL2Name ?? this.categoryL2Name,
    categoryL3Name: categoryL3Name ?? this.categoryL3Name,
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

  // ── Helpers ──
  bool get isActive => status == ListingStatus.active;

  // Category display path: "Residential › Apartment › 2BHK"
  String get categoryPath {
    final parts = <String>[];
    if (categoryL1Name != null) parts.add(categoryL1Name!);
    if (categoryL2Name != null) parts.add(categoryL2Name!);
    if (categoryL3Name != null) parts.add(categoryL3Name!);
    return parts.join(' › ');
  }

  // Shows deepest category name or fallback
  String get categoryLabel =>
      categoryL3Name ?? categoryL2Name ?? categoryL1Name ?? 'Room';

  // Alias kept for UI widgets migrating from RoomType
  String get roomTypeLabel => categoryLabel;

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
