import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  final String? id;
  final String doctorId;
  final String patientId;
  final DateTime appointmentDate;
  final String timeSlot;
  final String status; // 'pending', 'confirmed', 'completed', 'cancelled', 'rescheduled'
  final String reason;
  final String notes;
  final String prescription;
  final String? videoCallUrl;
  final String? videoCallId;
  final bool isVideoCallEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  Appointment({
    this.id,
    required this.doctorId,
    required this.patientId,
    required this.appointmentDate,
    required this.timeSlot,
    this.status = 'pending',
    this.reason = '',
    this.notes = '',
    this.prescription = '',
    this.videoCallUrl,
    this.videoCallId,
    this.isVideoCallEnabled = false,
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
      'videoCallUrl': videoCallUrl,
      'videoCallId': videoCallId,
      'isVideoCallEnabled': isVideoCallEnabled,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'],
      doctorId: map['doctorId'],
      patientId: map['patientId'],
      appointmentDate: _parseDateTime(map['appointmentDate']),
      timeSlot: map['timeSlot'],
      status: map['status'] ?? 'pending',
      reason: map['reason'] ?? '',
      notes: map['notes'] ?? '',
      prescription: map['prescription'] ?? '',
      videoCallUrl: map['videoCallUrl'],
      videoCallId: map['videoCallId'],
      isVideoCallEnabled: map['isVideoCallEnabled'] ?? false,
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
    );
  }

  // Helper method to parse both Timestamp and String dates
  static DateTime _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();
    
    if (dateValue is Timestamp) {
      return dateValue.toDate();
    } else if (dateValue is String) {
      return DateTime.parse(dateValue);
    } else {
      return DateTime.now();
    }
  }

  Appointment copyWith({
    String? id,
    String? doctorId,
    String? patientId,
    DateTime? appointmentDate,
    String? timeSlot,
    String? status,
    String? reason,
    String? notes,
    String? prescription,
    String? videoCallUrl,
    String? videoCallId,
    bool? isVideoCallEnabled,
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
      videoCallUrl: videoCallUrl ?? this.videoCallUrl,
      videoCallId: videoCallId ?? this.videoCallId,
      isVideoCallEnabled: isVideoCallEnabled ?? this.isVideoCallEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

