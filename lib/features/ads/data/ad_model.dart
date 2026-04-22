import 'package:cloud_firestore/cloud_firestore.dart';

enum AdPlacement {
  homeFeed, // between listing cards on customer home
  roomDetail, // bottom of room detail screen
  searchResults, // between search results
  landingPage, // below hero on landing page
}

enum AdStatus { active, paused, expired }

class AdModel {
  final String id;
  final String title; // business name e.g. "Sunrise Furniture"
  final String imageUrl; // banner image URL from Firebase Storage
  final String websiteUrl; // where to open when tapped
  final AdPlacement placement;
  final AdStatus status;
  final DateTime startsAt;
  final DateTime endsAt;
  final int priority; // higher = shown first
  final DateTime createdAt;

  const AdModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.websiteUrl,
    required this.placement,
    required this.status,
    required this.startsAt,
    required this.endsAt,
    this.priority = 0,
    required this.createdAt,
  });

  factory AdModel.fromMap(Map<String, dynamic> map, String id) {
    return AdModel(
      id: id,
      title: map['title'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      websiteUrl: map['websiteUrl'] as String? ?? '',
      placement: AdPlacement.values.firstWhere(
        (e) => e.name == map['placement'],
        orElse: () => AdPlacement.homeFeed,
      ),
      status: AdStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => AdStatus.paused,
      ),
      startsAt: (map['startsAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endsAt:
          (map['endsAt'] as Timestamp?)?.toDate() ??
          DateTime.now().add(const Duration(days: 30)),
      priority: map['priority'] as int? ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory AdModel.fromSnapshot(DocumentSnapshot doc) =>
      AdModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);

  Map<String, dynamic> toMap() => {
    'title': title,
    'imageUrl': imageUrl,
    'websiteUrl': websiteUrl,
    'placement': placement.name,
    'status': status.name,
    'startsAt': Timestamp.fromDate(startsAt),
    'endsAt': Timestamp.fromDate(endsAt),
    'priority': priority,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  bool get isLive =>
      status == AdStatus.active &&
      DateTime.now().isAfter(startsAt) &&
      DateTime.now().isBefore(endsAt);

  // Days remaining for this ad
  int get daysRemaining => endsAt.difference(DateTime.now()).inDays;

  String get placementLabel {
    switch (placement) {
      case AdPlacement.homeFeed:
        return 'Home Feed';
      case AdPlacement.roomDetail:
        return 'Room Detail';
      case AdPlacement.searchResults:
        return 'Search Results';
      case AdPlacement.landingPage:
        return 'Landing Page';
    }
  }

  String get statusLabel {
    switch (status) {
      case AdStatus.active:
        return 'Active';
      case AdStatus.paused:
        return 'Paused';
      case AdStatus.expired:
        return 'Expired';
    }
  }
}
