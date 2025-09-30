class Appointment {
  final int? id;
  final int doctorId;
  final int patientId;
  final DateTime appointmentDate;
  final String timeSlot;
  final String status; // 'scheduled', 'completed', 'cancelled', 'rescheduled'
  final String reason;
  final String notes;
  final String prescription;
  final DateTime createdAt;
  final DateTime updatedAt;

  Appointment({
    this.id,
    required this.doctorId,
    required this.patientId,
    required this.appointmentDate,
    required this.timeSlot,
    this.status = 'scheduled',
    this.reason = '',
    this.notes = '',
    this.prescription = '',
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'doctorId': doctorId,
      'patientId': patientId,
      'appointmentDate': appointmentDate.toIso8601String(),
      'timeSlot': timeSlot,
      'status': status,
      'reason': reason,
      'notes': notes,
      'prescription': prescription,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'],
      doctorId: map['doctorId'],
      patientId: map['patientId'],
      appointmentDate: DateTime.parse(map['appointmentDate']),
      timeSlot: map['timeSlot'],
      status: map['status'] ?? 'scheduled',
      reason: map['reason'] ?? '',
      notes: map['notes'] ?? '',
      prescription: map['prescription'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  Appointment copyWith({
    int? id,
    int? doctorId,
    int? patientId,
    DateTime? appointmentDate,
    String? timeSlot,
    String? status,
    String? reason,
    String? notes,
    String? prescription,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Appointment(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      patientId: patientId ?? this.patientId,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      timeSlot: timeSlot ?? this.timeSlot,
      status: status ?? this.status,
      reason: reason ?? this.reason,
      notes: notes ?? this.notes,
      prescription: prescription ?? this.prescription,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

