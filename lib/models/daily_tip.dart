class DailyTip {
  final int id;
  final String title;
  final String description;
  final String category;
  final int pregnancyWeek;
  final String imageAsset;
  final List<String> keyPoints;
  final String fullContent;
  final DateTime createdAt;

  const DailyTip({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.pregnancyWeek,
    required this.imageAsset,
    required this.keyPoints,
    required this.fullContent,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'pregnancyWeek': pregnancyWeek,
      'imageAsset': imageAsset,
      'keyPoints': keyPoints,
      'fullContent': fullContent,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory DailyTip.fromMap(Map<String, dynamic> map) {
    return DailyTip(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      category: map['category'],
      pregnancyWeek: map['pregnancyWeek'],
      imageAsset: map['imageAsset'],
      keyPoints: List<String>.from(map['keyPoints'] ?? []),
      fullContent: map['fullContent'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  DailyTip copyWith({
    int? id,
    String? title,
    String? description,
    String? category,
    int? pregnancyWeek,
    String? imageAsset,
    List<String>? keyPoints,
    String? fullContent,
    DateTime? createdAt,
  }) {
    return DailyTip(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      pregnancyWeek: pregnancyWeek ?? this.pregnancyWeek,
      imageAsset: imageAsset ?? this.imageAsset,
      keyPoints: keyPoints ?? this.keyPoints,
      fullContent: fullContent ?? this.fullContent,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}