class Patient {
  final String? id;
  final String name;
  final String email;
  final String phone;
  final DateTime dateOfBirth;
  final String bloodType;
  final String emergencyContact;
  final String emergencyPhone;
  final String medicalHistory;
  final String allergies;
  final String currentMedications;
  final DateTime lastVisit;
  final String? assignedDoctorId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Patient({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.dateOfBirth,
    required this.bloodType,
    required this.emergencyContact,
    required this.emergencyPhone,
    this.medicalHistory = '',
    this.allergies = '',
    this.currentMedications = '',
    required this.lastVisit,
    this.assignedDoctorId,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'bloodType': bloodType,
      'emergencyContact': emergencyContact,
      'emergencyPhone': emergencyPhone,
      'medicalHistory': medicalHistory,
      'allergies': allergies,
      'currentMedications': currentMedications,
      'lastVisit': lastVisit.toIso8601String(),
      'assignedDoctorId': assignedDoctorId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      dateOfBirth: DateTime.parse(map['dateOfBirth']),
      bloodType: map['bloodType'],
      emergencyContact: map['emergencyContact'],
      emergencyPhone: map['emergencyPhone'],
      medicalHistory: map['medicalHistory'] ?? '',
      allergies: map['allergies'] ?? '',
      currentMedications: map['currentMedications'] ?? '',
      lastVisit: DateTime.parse(map['lastVisit']),
      assignedDoctorId: map['assignedDoctorId'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  Patient copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    DateTime? dateOfBirth,
    String? bloodType,
    String? emergencyContact,
    String? emergencyPhone,
    String? medicalHistory,
    String? allergies,
    String? currentMedications,
    DateTime? lastVisit,
    String? assignedDoctorId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      bloodType: bloodType ?? this.bloodType,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      allergies: allergies ?? this.allergies,
      currentMedications: currentMedications ?? this.currentMedications,
      lastVisit: lastVisit ?? this.lastVisit,
      assignedDoctorId: assignedDoctorId ?? this.assignedDoctorId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

