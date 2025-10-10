class PregnancyTracking {
  final int? id;
  final String userId;
  final DateTime? lastMenstrualPeriod;
  final DateTime? expectedDeliveryDate;
  final DateTime? pregnancyConfirmedDate;
  final int? currentWeek;
  final int? currentDay;
  final String trimester;
  final double? weight;
  final double? height;
  final String? babyGender;
  final String? babyName;
  final bool isFirstChild;
  final bool hasPregnancyLoss;
  final String? medicalHistory;
  final List<String> symptoms;
  final List<String> medications;
  final Map<String, dynamic> vitals; // Blood pressure, heart rate, etc.
  final DateTime createdAt;
  final DateTime updatedAt;

  PregnancyTracking({
    this.id,
    required this.userId,
    this.lastMenstrualPeriod,
    this.expectedDeliveryDate,
    this.pregnancyConfirmedDate,
    this.currentWeek,
    this.currentDay,
    this.trimester = 'First',
    this.weight,
    this.height,
    this.babyGender,
    this.babyName,
    this.isFirstChild = true,
    this.hasPregnancyLoss = false,
    this.medicalHistory,
    this.symptoms = const [],
    this.medications = const [],
    this.vitals = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'lastMenstrualPeriod': lastMenstrualPeriod?.toIso8601String(),
      'expectedDeliveryDate': expectedDeliveryDate?.toIso8601String(),
      'pregnancyConfirmedDate': pregnancyConfirmedDate?.toIso8601String(),
      'currentWeek': currentWeek,
      'currentDay': currentDay,
      'trimester': trimester,
      'weight': weight,
      'height': height,
      'babyGender': babyGender,
      'babyName': babyName,
      'isFirstChild': isFirstChild,
      'hasPregnancyLoss': hasPregnancyLoss,
      'medicalHistory': medicalHistory,
      'symptoms': symptoms,
      'medications': medications,
      'vitals': vitals,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory PregnancyTracking.fromMap(Map<String, dynamic> map) {
    return PregnancyTracking(
      id: map['id'],
      userId: map['userId'],
      lastMenstrualPeriod: map['lastMenstrualPeriod'] != null 
          ? DateTime.parse(map['lastMenstrualPeriod']) 
          : null,
      expectedDeliveryDate: map['expectedDeliveryDate'] != null 
          ? DateTime.parse(map['expectedDeliveryDate']) 
          : null,
      pregnancyConfirmedDate: map['pregnancyConfirmedDate'] != null 
          ? DateTime.parse(map['pregnancyConfirmedDate']) 
          : null,
      currentWeek: map['currentWeek'],
      currentDay: map['currentDay'],
      trimester: map['trimester'] ?? 'First',
      weight: map['weight']?.toDouble(),
      height: map['height']?.toDouble(),
      babyGender: map['babyGender'],
      babyName: map['babyName'],
      isFirstChild: map['isFirstChild'] ?? true,
      hasPregnancyLoss: map['hasPregnancyLoss'] ?? false,
      medicalHistory: map['medicalHistory'],
      symptoms: List<String>.from(map['symptoms'] ?? []),
      medications: List<String>.from(map['medications'] ?? []),
      vitals: Map<String, dynamic>.from(map['vitals'] ?? {}),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  PregnancyTracking copyWith({
    int? id,
    String? userId,
    DateTime? lastMenstrualPeriod,
    DateTime? expectedDeliveryDate,
    DateTime? pregnancyConfirmedDate,
    int? currentWeek,
    int? currentDay,
    String? trimester,
    double? weight,
    double? height,
    String? babyGender,
    String? babyName,
    bool? isFirstChild,
    bool? hasPregnancyLoss,
    String? medicalHistory,
    List<String>? symptoms,
    List<String>? medications,
    Map<String, dynamic>? vitals,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PregnancyTracking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      lastMenstrualPeriod: lastMenstrualPeriod ?? this.lastMenstrualPeriod,
      expectedDeliveryDate: expectedDeliveryDate ?? this.expectedDeliveryDate,
      pregnancyConfirmedDate: pregnancyConfirmedDate ?? this.pregnancyConfirmedDate,
      currentWeek: currentWeek ?? this.currentWeek,
      currentDay: currentDay ?? this.currentDay,
      trimester: trimester ?? this.trimester,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      babyGender: babyGender ?? this.babyGender,
      babyName: babyName ?? this.babyName,
      isFirstChild: isFirstChild ?? this.isFirstChild,
      hasPregnancyLoss: hasPregnancyLoss ?? this.hasPregnancyLoss,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      symptoms: symptoms ?? this.symptoms,
      medications: medications ?? this.medications,
      vitals: vitals ?? this.vitals,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Calculate pregnancy week based on LMP or confirmed date
  static Map<String, int> calculatePregnancyWeek(DateTime referenceDate) {
    final now = DateTime.now();
    final difference = now.difference(referenceDate);
    final totalDays = difference.inDays;
    final weeks = (totalDays / 7).floor();
    final days = totalDays % 7;
    
    return {
      'weeks': weeks > 0 ? weeks : 0,
      'days': days > 0 ? days : 0,
      'totalDays': totalDays > 0 ? totalDays : 0,
    };
  }

  // Calculate expected delivery date (280 days from LMP)
  static DateTime? calculateExpectedDeliveryDate(DateTime? lastMenstrualPeriod) {
    if (lastMenstrualPeriod == null) return null;
    return lastMenstrualPeriod.add(const Duration(days: 280));
  }

  // Determine trimester based on week
  static String getTrimester(int week) {
    if (week <= 12) return 'First';
    if (week <= 28) return 'Second';
    return 'Third';
  }

  // Get pregnancy progress percentage
  double getProgressPercentage() {
    if (currentWeek == null) return 0.0;
    return (currentWeek! / 40.0 * 100).clamp(0.0, 100.0);
  }

  // Get weeks remaining
  int getWeeksRemaining() {
    if (currentWeek == null) return 40;
    return (40 - currentWeek!).clamp(0, 40);
  }
}
