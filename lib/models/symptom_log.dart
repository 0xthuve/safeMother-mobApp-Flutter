class SymptomLog {
  final String? id;
  final String patientId;
  final String bloodPressure;
  final String weight;
  final String babyKicks;
  final String mood;
  final String symptoms;
  final String? additionalNotes;
  final String? sleepHours;
  final String? waterIntake;
  final String? exerciseMinutes;
  final String energyLevel;
  final String appetiteLevel;
  final String painLevel;
  final bool hadContractions;
  final bool hadHeadaches;
  final bool hadSwelling;
  final bool tookVitamins;
  final String? nauseaDetails;
  final String? medications;
  final DateTime logDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  SymptomLog({
    this.id,
    required this.patientId,
    required this.bloodPressure,
    required this.weight,
    required this.babyKicks,
    required this.mood,
    required this.symptoms,
    this.additionalNotes,
    this.sleepHours,
    this.waterIntake,
    this.exerciseMinutes,
    required this.energyLevel,
    required this.appetiteLevel,
    required this.painLevel,
    required this.hadContractions,
    required this.hadHeadaches,
    required this.hadSwelling,
    required this.tookVitamins,
    this.nauseaDetails,
    this.medications,
    required this.logDate,
    required this.createdAt,
    required this.updatedAt,
  });

  SymptomLog copyWith({
    String? id,
    String? patientId,
    String? bloodPressure,
    String? weight,
    String? babyKicks,
    String? mood,
    String? symptoms,
    String? additionalNotes,
    String? sleepHours,
    String? waterIntake,
    String? exerciseMinutes,
    String? energyLevel,
    String? appetiteLevel,
    String? painLevel,
    bool? hadContractions,
    bool? hadHeadaches,
    bool? hadSwelling,
    bool? tookVitamins,
    String? nauseaDetails,
    String? medications,
    DateTime? logDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SymptomLog(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      bloodPressure: bloodPressure ?? this.bloodPressure,
      weight: weight ?? this.weight,
      babyKicks: babyKicks ?? this.babyKicks,
      mood: mood ?? this.mood,
      symptoms: symptoms ?? this.symptoms,
      additionalNotes: additionalNotes ?? this.additionalNotes,
      sleepHours: sleepHours ?? this.sleepHours,
      waterIntake: waterIntake ?? this.waterIntake,
      exerciseMinutes: exerciseMinutes ?? this.exerciseMinutes,
      energyLevel: energyLevel ?? this.energyLevel,
      appetiteLevel: appetiteLevel ?? this.appetiteLevel,
      painLevel: painLevel ?? this.painLevel,
      hadContractions: hadContractions ?? this.hadContractions,
      hadHeadaches: hadHeadaches ?? this.hadHeadaches,
      hadSwelling: hadSwelling ?? this.hadSwelling,
      tookVitamins: tookVitamins ?? this.tookVitamins,
      nauseaDetails: nauseaDetails ?? this.nauseaDetails,
      medications: medications ?? this.medications,
      logDate: logDate ?? this.logDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'bloodPressure': bloodPressure,
      'weight': weight,
      'babyKicks': babyKicks,
      'mood': mood,
      'symptoms': symptoms,
      'additionalNotes': additionalNotes,
      'sleepHours': sleepHours,
      'waterIntake': waterIntake,
      'exerciseMinutes': exerciseMinutes,
      'energyLevel': energyLevel,
      'appetiteLevel': appetiteLevel,
      'painLevel': painLevel,
      'hadContractions': hadContractions,
      'hadHeadaches': hadHeadaches,
      'hadSwelling': hadSwelling,
      'tookVitamins': tookVitamins,
      'nauseaDetails': nauseaDetails,
      'medications': medications,
      'logDate': logDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory SymptomLog.fromMap(Map<String, dynamic> map) {
    return SymptomLog(
      id: map['id'],
      patientId: map['patientId'] ?? '',
      bloodPressure: map['bloodPressure'] ?? '',
      weight: map['weight'] ?? '',
      babyKicks: map['babyKicks'] ?? '',
      mood: map['mood'] ?? '',
      symptoms: map['symptoms'] ?? '',
      additionalNotes: map['additionalNotes'],
      sleepHours: map['sleepHours'],
      waterIntake: map['waterIntake'],
      exerciseMinutes: map['exerciseMinutes'],
      energyLevel: map['energyLevel'] ?? 'Normal',
      appetiteLevel: map['appetiteLevel'] ?? 'Normal',
      painLevel: map['painLevel'] ?? 'None',
      hadContractions: map['hadContractions'] ?? false,
      hadHeadaches: map['hadHeadaches'] ?? false,
      hadSwelling: map['hadSwelling'] ?? false,
      tookVitamins: map['tookVitamins'] ?? false,
      nauseaDetails: map['nauseaDetails'],
      medications: map['medications'],
      logDate: DateTime.parse(map['logDate']),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  @override
  String toString() {
    return 'SymptomLog(id: $id, patientId: $patientId, bloodPressure: $bloodPressure, weight: $weight, mood: $mood, logDate: $logDate)';
  }
}