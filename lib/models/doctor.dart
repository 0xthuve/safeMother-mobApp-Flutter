class Doctor {
  final String? id;
  final String? firebaseUid; // Store the original Firebase UID for patient-doctor links
  final String name;
  final String email;
  final String phone;
  final String specialization;
  final String licenseNumber;
  final String hospital;
  final String experience;
  final String bio;
  final String profileImage;
  final double rating;
  final int totalPatients;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;

  Doctor({
    this.id,
    this.firebaseUid,
    required this.name,
    required this.email,
    required this.phone,
    required this.specialization,
    required this.licenseNumber,
    required this.hospital,
    required this.experience,
    required this.bio,
    this.profileImage = '',
    this.rating = 0.0,
    this.totalPatients = 0,
    this.isAvailable = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firebaseUid': firebaseUid,
      'name': name,
      'email': email,
      'phone': phone,
      'specialization': specialization,
      'licenseNumber': licenseNumber,
      'hospital': hospital,
      'experience': experience,
      'bio': bio,
      'profileImage': profileImage,
      'rating': rating,
      'totalPatients': totalPatients,
      'isAvailable': isAvailable ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Doctor.fromMap(Map<String, dynamic> map) {
    return Doctor(
      id: map['id']?.toString(),
      firebaseUid: map['firebaseUid'],
      name: map['name'] ?? 'Unknown Doctor',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      specialization: map['specialization'] ?? 'General Practice',
      licenseNumber: map['licenseNumber'] ?? '',
      hospital: map['hospital'] ?? 'Unknown Hospital',
      experience: map['experience'] ?? '0 years',
      bio: map['bio'] ?? 'Healthcare professional',
      profileImage: map['profileImage'] ?? '',
      rating: (map['rating'] is num) ? map['rating'].toDouble() : 0.0,
      totalPatients: map['totalPatients'] ?? 0,
      isAvailable: map['isAvailable'] == true || map['isAvailable'] == 1,
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
    );
  }

  static DateTime _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();
    if (dateValue is DateTime) return dateValue;
    if (dateValue is String) {
      try {
        return DateTime.parse(dateValue);
      } catch (e) {
        print('Error parsing date: $dateValue - $e');
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  Doctor copyWith({
    String? id,
    String? firebaseUid,
    String? name,
    String? email,
    String? phone,
    String? specialization,
    String? licenseNumber,
    String? hospital,
    String? experience,
    String? bio,
    String? profileImage,
    double? rating,
    int? totalPatients,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Doctor(
      id: id ?? this.id,
      firebaseUid: firebaseUid ?? this.firebaseUid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      specialization: specialization ?? this.specialization,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      hospital: hospital ?? this.hospital,
      experience: experience ?? this.experience,
      bio: bio ?? this.bio,
      profileImage: profileImage ?? this.profileImage,
      rating: rating ?? this.rating,
      totalPatients: totalPatients ?? this.totalPatients,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

