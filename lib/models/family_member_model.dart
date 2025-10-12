import 'package:cloud_firestore/cloud_firestore.dart';

class FamilyMember {
  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final String relationship;
  final String patientId;
  final String patientUserId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String status;
  final String accountType;
  final bool isVerified;

  FamilyMember({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.relationship,
    required this.patientId,
    required this.patientUserId,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.accountType,
    required this.isVerified,
  });

  factory FamilyMember.fromMap(Map<String, dynamic> data, String id) {
    // Handle timestamp conversion safely
    DateTime parseTimestamp(Timestamp? timestamp) {
      return timestamp?.toDate() ?? DateTime.now();
    }

    // Handle string fields with null safety
    String parseString(dynamic value) {
      return value?.toString() ?? '';
    }

    return FamilyMember(
      uid: id,
      fullName: parseString(data['fullName']),
      email: parseString(data['email']),
      phone: parseString(data['phone']),
      relationship: parseString(data['relationship']),
      patientId: parseString(data['patientId']),
      patientUserId: parseString(data['patientUserId']),
      createdAt: parseTimestamp(data['createdAt']),
      updatedAt: parseTimestamp(data['updatedAt']),
      status: parseString(data['status']),
      accountType: parseString(data['accountType']),
      isVerified: data['isVerified'] ?? false,
    );
  }

  factory FamilyMember.fromDocument(DocumentSnapshot doc) {
    return FamilyMember.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email.toLowerCase(),
      'phone': phone,
      'relationship': relationship,
      'patientId': patientId,
      'patientUserId': patientUserId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'status': status,
      'accountType': accountType,
      'isVerified': isVerified,
    };
  }

  FamilyMember copyWith({
    String? fullName,
    String? phone,
    String? relationship,
    DateTime? updatedAt,
    String? status,
  }) {
    return FamilyMember(
      uid: uid,
      fullName: fullName ?? this.fullName,
      email: email,
      phone: phone ?? this.phone,
      relationship: relationship ?? this.relationship,
      patientId: patientId,
      patientUserId: patientUserId,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      accountType: accountType,
      isVerified: isVerified,
    );
  }

  @override
  String toString() {
    return 'FamilyMember(uid: $uid, fullName: $fullName, email: $email, relationship: $relationship, patientId: $patientId)';
  }
}