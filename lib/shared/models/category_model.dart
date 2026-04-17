import 'package:cloud_firestore/cloud_firestore.dart';

// Category level in the hierarchy
enum CategoryLevel { level1, level2, level3 }

class CategoryModel {
  final String id;
  final String name;
  final String nameNp; // Nepali name (optional)
  final CategoryLevel level;
  final String? parentId; // null for level1, set for level2 and level3
  final String? grandParentId; // only for level3
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;

  const CategoryModel({
    required this.id,
    required this.name,
    this.nameNp = '',
    required this.level,
    this.parentId,
    this.grandParentId,
    this.sortOrder = 0,
    this.isActive = true,
    required this.createdAt,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map, String id) {
    return CategoryModel(
      id: id,
      name: map['name'] as String? ?? '',
      nameNp: map['nameNp'] as String? ?? '',
      level: CategoryLevel.values.firstWhere(
        (e) => e.name == map['level'],
        orElse: () => CategoryLevel.level1,
      ),
      parentId: map['parentId'] as String?,
      grandParentId: map['grandParentId'] as String?,
      sortOrder: map['sortOrder'] as int? ?? 0,
      isActive: map['isActive'] as bool? ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory CategoryModel.fromSnapshot(DocumentSnapshot doc) {
    return CategoryModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'nameNp': nameNp,
    'level': level.name,
    'parentId': parentId,
    'grandParentId': grandParentId,
    'sortOrder': sortOrder,
    'isActive': isActive,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  CategoryModel copyWith({
    String? name,
    String? nameNp,
    bool? isActive,
    int? sortOrder,
  }) => CategoryModel(
    id: id,
    name: name ?? this.name,
    nameNp: nameNp ?? this.nameNp,
    level: level,
    parentId: parentId,
    grandParentId: grandParentId,
    sortOrder: sortOrder ?? this.sortOrder,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt,
  );

  // Display name — shows Nepali if available, else English
  String get displayName => nameNp.isNotEmpty ? nameNp : name;

  bool get isLevel1 => level == CategoryLevel.level1;
  bool get isLevel2 => level == CategoryLevel.level2;
  bool get isLevel3 => level == CategoryLevel.level3;
}

// Convenience model for a selected category path
class CategorySelection {
  final CategoryModel? level1;
  final CategoryModel? level2;
  final CategoryModel? level3;

  const CategorySelection({this.level1, this.level2, this.level3});

  bool get isComplete => level1 != null && level2 != null && level3 != null;
  bool get hasLevel1 => level1 != null;
  bool get hasLevel2 => level2 != null;

  String get displayPath {
    final parts = <String>[];
    if (level1 != null) parts.add(level1!.name);
    if (level2 != null) parts.add(level2!.name);
    if (level3 != null) parts.add(level3!.name);
    return parts.join(' › ');
  }

  CategorySelection copyWith({
    CategoryModel? level1,
    CategoryModel? level2,
    CategoryModel? level3,
    bool clearLevel2 = false,
    bool clearLevel3 = false,
  }) => CategorySelection(
    level1: level1 ?? this.level1,
    level2: clearLevel2 ? null : (level2 ?? this.level2),
    level3: clearLevel3 ? null : (level3 ?? this.level3),
  );
}
