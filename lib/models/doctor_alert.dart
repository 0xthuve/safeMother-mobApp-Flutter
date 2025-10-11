class DoctorAlert {
  final String? id;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String riskLevel;
  final String riskMessage;
  final List<String> riskFactors;
  final String bloodPressure;
  final List<String> symptoms;
  final DateTime alertDate;
  final bool isRead;
  final String? symptomLogId;

  DoctorAlert({
    this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.riskLevel,
    required this.riskMessage,
    required this.riskFactors,
    required this.bloodPressure,
    required this.symptoms,
    required this.alertDate,
    this.isRead = false,
    this.symptomLogId,
  });

  DoctorAlert copyWith({
    String? id,
    String? patientId,
    String? patientName,
    String? doctorId,
    String? riskLevel,
    String? riskMessage,
    List<String>? riskFactors,
    String? bloodPressure,
    List<String>? symptoms,
    DateTime? alertDate,
    bool? isRead,
    String? symptomLogId,
  }) {
    return DoctorAlert(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      doctorId: doctorId ?? this.doctorId,
      riskLevel: riskLevel ?? this.riskLevel,
      riskMessage: riskMessage ?? this.riskMessage,
      riskFactors: riskFactors ?? this.riskFactors,
      bloodPressure: bloodPressure ?? this.bloodPressure,
      symptoms: symptoms ?? this.symptoms,
      alertDate: alertDate ?? this.alertDate,
      isRead: isRead ?? this.isRead,
      symptomLogId: symptomLogId ?? this.symptomLogId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'patientName': patientName,
      'doctorId': doctorId,
      'riskLevel': riskLevel,
      'riskMessage': riskMessage,
      'riskFactors': riskFactors,
      'bloodPressure': bloodPressure,
      'symptoms': symptoms,
      'alertDate': alertDate.toIso8601String(),
      'isRead': isRead,
      'symptomLogId': symptomLogId,
    };
  }

  factory DoctorAlert.fromMap(Map<String, dynamic> map) {
    return DoctorAlert(
      id: map['id'],
      patientId: map['patientId'] ?? '',
      patientName: map['patientName'] ?? '',
      doctorId: map['doctorId'] ?? '',
      riskLevel: map['riskLevel'] ?? '',
      riskMessage: map['riskMessage'] ?? '',
      riskFactors: List<String>.from(map['riskFactors'] ?? []),
      bloodPressure: map['bloodPressure'] ?? '',
      symptoms: List<String>.from(map['symptoms'] ?? []),
      alertDate: DateTime.parse(map['alertDate']),
      isRead: map['isRead'] ?? false,
      symptomLogId: map['symptomLogId'],
    );
  }

  @override
  String toString() {
    return 'DoctorAlert(id: $id, patientName: $patientName, riskLevel: $riskLevel, alertDate: $alertDate)';
  }
}