import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String fullName;
  final int? age;
  final String? username;
  final String email;
  final String? location;
  final String role; // 'mother', 'family_member', 'healthcare'
  final DateTime? estimatedDueDate;
  final String? emergencyContact;
  final String? medicalConditions;
  final String? allergies;
  final String? currentMedications;
  final String? previousPregnancies;
  final String? familyMemberEmail;
  final String? motherEmail;
  final String? relationship;
  final String? phoneNumber;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final String? profileImageUrl;

  UserModel({
    required this.uid,
    required this.fullName,
    this.age,
    this.username,
    required this.email,
    this.location,
    required this.role,
    this.estimatedDueDate,
    this.emergencyContact,
    this.medicalConditions,
    this.allergies,
    this.currentMedications,
    this.previousPregnancies,
    this.familyMemberEmail,
    this.motherEmail,
    this.relationship,
    this.phoneNumber,
    required this.createdAt,
    this.updatedAt,
    required this.isActive,
    this.profileImageUrl,
  });

  // Convert UserModel to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'age': age,
      'username': username,
      'email': email,
      'location': location,
      'role': role,
      'estimatedDueDate': estimatedDueDate != null 
          ? Timestamp.fromDate(estimatedDueDate!) 
          : null,
      'emergencyContact': emergencyContact,
      'medicalConditions': medicalConditions,
      'allergies': allergies,
      'currentMedications': currentMedications,
      'previousPregnancies': previousPregnancies,
      'familyMemberEmail': familyMemberEmail,
      'motherEmail': motherEmail,
      'relationship': relationship,
      'phoneNumber': phoneNumber,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null 
          ? Timestamp.fromDate(updatedAt!) 
          : null,
      'isActive': isActive,
      'profileImageUrl': profileImageUrl,
    };
  }

  // Create UserModel from Map (Firebase document)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      fullName: map['fullName'] ?? '',
      age: map['age'],
      username: map['username'],
      email: map['email'] ?? '',
      location: map['location'],
      role: map['role'] ?? '',
      estimatedDueDate: map['estimatedDueDate'] != null
          ? (map['estimatedDueDate'] as Timestamp).toDate()
          : null,
      emergencyContact: map['emergencyContact'],
      medicalConditions: map['medicalConditions'],
      allergies: map['allergies'],
      currentMedications: map['currentMedications'],
      previousPregnancies: map['previousPregnancies'],
      familyMemberEmail: map['familyMemberEmail'],
      motherEmail: map['motherEmail'],
      relationship: map['relationship'],
      phoneNumber: map['phoneNumber'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
      isActive: map['isActive'] ?? true,
      profileImageUrl: map['profileImageUrl'],
    );
  }

  // Create a copy of UserModel with updated fields
  UserModel copyWith({
    String? uid,
    String? fullName,
    int? age,
    String? username,
    String? email,
    String? location,
    String? role,
    DateTime? estimatedDueDate,
    String? emergencyContact,
    String? medicalConditions,
    String? allergies,
    String? currentMedications,
    String? previousPregnancies,
    String? familyMemberEmail,
    String? motherEmail,
    String? relationship,
    String? phoneNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    String? profileImageUrl,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      age: age ?? this.age,
      username: username ?? this.username,
      email: email ?? this.email,
      location: location ?? this.location,
      role: role ?? this.role,
      estimatedDueDate: estimatedDueDate ?? this.estimatedDueDate,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      allergies: allergies ?? this.allergies,
      currentMedications: currentMedications ?? this.currentMedications,
      previousPregnancies: previousPregnancies ?? this.previousPregnancies,
      familyMemberEmail: familyMemberEmail ?? this.familyMemberEmail,
      motherEmail: motherEmail ?? this.motherEmail,
      relationship: relationship ?? this.relationship,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, fullName: $fullName, email: $email, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.uid == uid;
  }

  @override
  int get hashCode {
    return uid.hashCode;
  }

  // Helper methods
  bool get isMother => role == 'mother';
  bool get isFamilyMember => role == 'family_member';
  bool get isHealthcareProfessional => role == 'healthcare';
  
  // Calculate pregnancy week (approximate)
  int? get pregnancyWeek {
    if (estimatedDueDate == null) return null;
    final now = DateTime.now();
    final conception = estimatedDueDate!.subtract(const Duration(days: 280)); // 40 weeks
    final daysSinceConception = now.difference(conception).inDays;
    return daysSinceConception ~/ 7;
  }
  
  // Calculate days until due date
  int? get daysUntilDue {
    if (estimatedDueDate == null) return null;
    final now = DateTime.now();
    return estimatedDueDate!.difference(now).inDays;
  }
}