class MedicalRecord {
  final int? id;
  final String userId;
  final String? doctorId;
  final String recordType; // 'checkup', 'lab_result', 'ultrasound', 'prescription', 'note'
  final String title;
  final String description;
  final Map<String, dynamic> data; // Flexible data storage for different record types
  final List<String> attachments; // File paths or URLs
  final DateTime recordDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  MedicalRecord({
    this.id,
    required this.userId,
    this.doctorId,
    required this.recordType,
    required this.title,
    required this.description,
    this.data = const {},
    this.attachments = const [],
    required this.recordDate,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'doctorId': doctorId,
      'recordType': recordType,
      'title': title,
      'description': description,
      'data': data,
      'attachments': attachments,
      'recordDate': recordDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory MedicalRecord.fromMap(Map<String, dynamic> map) {
    return MedicalRecord(
      id: map['id'],
      userId: map['userId'],
      doctorId: map['doctorId'],
      recordType: map['recordType'],
      title: map['title'],
      description: map['description'],
      data: Map<String, dynamic>.from(map['data'] ?? {}),
      attachments: List<String>.from(map['attachments'] ?? []),
      recordDate: DateTime.parse(map['recordDate']),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  MedicalRecord copyWith({
    int? id,
    String? userId,
    String? doctorId,
    String? recordType,
    String? title,
    String? description,
    Map<String, dynamic>? data,
    List<String>? attachments,
    DateTime? recordDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MedicalRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      doctorId: doctorId ?? this.doctorId,
      recordType: recordType ?? this.recordType,
      title: title ?? this.title,
      description: description ?? this.description,
      data: data ?? this.data,
      attachments: attachments ?? this.attachments,
      recordDate: recordDate ?? this.recordDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}