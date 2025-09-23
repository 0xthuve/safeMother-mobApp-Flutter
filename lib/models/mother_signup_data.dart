class MotherSignupData {
  // Basic information (from page 1)
  String fullName = '';
  int age = 0;
  String username = '';
  String email = '';
  String password = '';
  String location = '';
  DateTime? estimatedDueDate;

  // Medical information (from page 2)
  DateTime? deliveryDate;
  DateTime? pregnancyConfirmedDate;
  String medicalHistory = '';
  double weight = 0.0;
  bool isFirstChild = false;
  bool hasPregnancyLoss = false;
  bool isBabyBorn = false;
  String? emergencyContact;
  String? familyMemberEmail;

  MotherSignupData();

  // Convert to map for database
  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'age': age,
      'username': username,
      'email': email,
      'location': location,
      'estimatedDueDate': estimatedDueDate,
      'deliveryDate': deliveryDate,
      'pregnancyConfirmedDate': pregnancyConfirmedDate,
      'medicalHistory': medicalHistory,
      'weight': weight,
      'isFirstChild': isFirstChild,
      'hasPregnancyLoss': hasPregnancyLoss,
      'isBabyBorn': isBabyBorn,
      'emergencyContact': emergencyContact,
      'familyMemberEmail': familyMemberEmail,
    };
  }

  // Validation
  bool isPage1Valid() {
    return fullName.isNotEmpty &&
           age > 0 &&
           username.isNotEmpty &&
           email.isNotEmpty &&
           password.length >= 6 &&
           location.isNotEmpty &&
           estimatedDueDate != null;
  }

  bool isPage2Valid() {
    return pregnancyConfirmedDate != null &&
           medicalHistory.isNotEmpty &&
           weight > 0;
  }
}