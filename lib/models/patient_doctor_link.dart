class PatientDoctorLink {
  final String id;
  final String patientId;
  final String doctorId;
  final DateTime linkedDate;
  final bool isActive;
  final String status; // 'requested', 'accepted', 'declined'
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  PatientDoctorLink({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.linkedDate,
    this.isActive = true,
    this.status = 'requested',
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'linkedDate': linkedDate.toIso8601String(),
      'isActive': isActive,
      'status': status,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory PatientDoctorLink.fromMap(Map<String, dynamic> map) {
    return PatientDoctorLink(
      id: map['id'],
      patientId: map['patientId'],
      doctorId: map['doctorId'],
      linkedDate: DateTime.parse(map['linkedDate']),
      isActive: map['isActive'] ?? true,
      status: map['status'] ?? 'requested',
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  PatientDoctorLink copyWith({
    String? id,
    String? patientId,
    String? doctorId,
    DateTime? linkedDate,
    bool? isActive,
    String? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PatientDoctorLink(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      linkedDate: linkedDate ?? this.linkedDate,
      isActive: isActive ?? this.isActive,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}