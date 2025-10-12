// lib/services/familyMember_patient_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/patient.dart';
import '../models/symptom_log.dart';

class FamilyMemberPatientService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get linked patient data for the current family member
  static Future<Patient?> getLinkedPatient() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('No logged-in family member found.');
        return null;
      }

      // Fetch the family member document
      final familyMemberDoc = await _firestore
          .collection('family_members')
          .doc(currentUser.uid)
          .get();

      if (!familyMemberDoc.exists) {
        print('Family member document not found for UID: ${currentUser.uid}');
        return null;
      }

      final familyMemberData = familyMemberDoc.data()!;
      final patientUserId = familyMemberData['patientUserId'];

      if (patientUserId == null || patientUserId.toString().isEmpty) {
        print('No valid linked patientUserId found.');
        return null;
      }

      // Fetch linked patient document from USERS collection
      final patientDoc = await _firestore
          .collection('users') // Changed from 'patients' to 'users'
          .doc(patientUserId)
          .get();

      if (!patientDoc.exists) {
        print(
          'Linked patient document not found in users collection for ID: $patientUserId',
        );
        return null;
      }

      final userData = patientDoc.data()!;
      print('Successfully fetched user data: $userData');

      // Map users collection data to Patient model
      return _mapUserDataToPatient(userData, patientUserId);
    } catch (e, stack) {
      print('Error getting linked patient: $e');
      print(stack);
      return null;
    }
  }

  // Helper method to map users collection data to Patient model
  static Patient _mapUserDataToPatient(
    Map<String, dynamic> userData,
    String patientUserId,
  ) {
    // Parse dates with fallbacks
    DateTime parseDateWithFallback(dynamic date, {DateTime? fallback}) {
      if (date == null) return fallback ?? DateTime.now();
      if (date is Timestamp) return date.toDate();
      if (date is String) {
        try {
          return DateTime.parse(date);
        } catch (e) {
          return fallback ?? DateTime.now();
        }
      }
      return fallback ?? DateTime.now();
    }

    // Extract name - try different possible field names
    String getName() {
      return userData['name'] ??
          userData['fullName'] ??
          userData['displayName'] ??
          'Patient';
    }

    // Extract email
    String getEmail() {
      return userData['email'] ?? '';
    }

    // Extract phone - try different possible field names
    String getPhone() {
      return userData['phone'] ??
          userData['phoneNumber'] ??
          userData['mobile'] ??
          '';
    }

    return Patient(
      id: patientUserId,
      name: getName(),
      email: getEmail(),
      phone: getPhone(),
      dateOfBirth: parseDateWithFallback(
        userData['dateOfBirth'] ?? userData['dob'],
      ),
      bloodType: userData['bloodType'] ?? userData['bloodGroup'] ?? '',
      emergencyContact:
          userData['emergencyContact'] ?? userData['emergencyName'] ?? '',
      emergencyPhone:
          userData['emergencyPhone'] ?? userData['emergencyNumber'] ?? '',
      medicalHistory:
          userData['medicalHistory'] ?? userData['medicalInfo'] ?? '',
      allergies: userData['allergies'] ?? '',
      currentMedications:
          userData['currentMedications'] ?? userData['medications'] ?? '',
      lastVisit: parseDateWithFallback(
        userData['lastVisit'] ?? userData['lastAppointment'],
      ),
      assignedDoctorId: userData['assignedDoctorId']?.toString() ?? userData['doctorId']?.toString(),
      createdAt: parseDateWithFallback(
        userData['createdAt'] ?? userData['created'],
      ),
      updatedAt: parseDateWithFallback(
        userData['updatedAt'] ?? userData['updated'],
      ),
    );
  }

  // Get pregnancy tracking data for linked patient
  static Future<Map<String, dynamic>?> getPregnancyTrackingData(
    String patientUserId,
  ) async {
    try {
      final pregnancyQuery = await _firestore
          .collection('symptom_logs')
          .where('patientId', isEqualTo: patientUserId)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (pregnancyQuery.docs.isNotEmpty) {
        return pregnancyQuery.docs.first.data();
      }

      return null;
    } catch (e) {
      print('Error getting pregnancy tracking data: $e');
      return null;
    }
  }

  // Get latest health log for linked patient
  static Future<SymptomLog?> getLatestHealthLog(String patientUserId) async {
    try {
      final logsQuery = await _firestore
          .collection('symptom_logs')
          .where('patientId', isEqualTo: patientUserId)
          .orderBy('logDate', descending: true)
          .limit(1)
          .get();

      if (logsQuery.docs.isNotEmpty) {
        return SymptomLog.fromMap(logsQuery.docs.first.data());
      }

      return null;
    } catch (e) {
      print('Error getting latest health log: $e');
      return null;
    }
  }

  // Get latest health metrics from recent logs
  static Future<Map<String, dynamic>> getLatestHealthMetrics(
    String patientUserId,
  ) async {
    try {
      final latestLog = await getLatestHealthLog(patientUserId);

      if (latestLog != null) {
        return {
          'heartRate': _extractHeartRate(latestLog.bloodPressure),
          'bloodPressure': latestLog.bloodPressure.isNotEmpty
              ? latestLog.bloodPressure
              : 'Not recorded',
          'weight': latestLog.weight.isNotEmpty
              ? '${latestLog.weight} kg'
              : 'Not recorded',
          'babyKicks': latestLog.babyKicks.isNotEmpty
              ? latestLog.babyKicks
              : 'Not recorded',
          'mood': latestLog.mood.isNotEmpty ? latestLog.mood : 'Not recorded',
          'lastUpdated': latestLog.logDate,
        };
      }

      // Return default values when no data available
      return {
        'heartRate': 'Not recorded',
        'bloodPressure': 'Not recorded',
        'weight': 'Not recorded',
        'babyKicks': 'Not recorded',
        'mood': 'Not recorded',
        'lastUpdated': null,
      };
    } catch (e) {
      print('Error getting latest health metrics: $e');
      return {
        'heartRate': 'Not recorded',
        'bloodPressure': 'Not recorded',
        'weight': 'Not recorded',
        'babyKicks': 'Not recorded',
        'mood': 'Not recorded',
        'lastUpdated': null,
      };
    }
  }

  static String _extractHeartRate(String bloodPressure) {
    if (bloodPressure.isEmpty || bloodPressure == 'Not recorded')
      return 'Not recorded';
    try {
      final parts = bloodPressure.split('/');
      if (parts.isNotEmpty) {
        final systolic = int.tryParse(parts[0]);
        return systolic != null
            ? (systolic ~/ 1.67).toString()
            : 'Not recorded';
      }
    } catch (e) {
      return 'Not recorded';
    }
    return 'Not recorded';
  }

  // Get pregnancy progress data
  static Future<Map<String, dynamic>> getPregnancyProgress(
    String patientUserId,
  ) async {
    try {
      final pregnancyData = await getPregnancyTrackingData(patientUserId);

      if (pregnancyData != null) {
        final currentWeek = pregnancyData['currentWeek'] ?? 0;
        final dueDate = pregnancyData['dueDate'];

        return {
          'weeks': currentWeek,
          'dueDate': _formatDueDate(dueDate),
          'progressPercentage': _calculateProgressPercentage(currentWeek),
          'trimester': _getTrimester(currentWeek),
          'daysToGo': _getDaysToGo(currentWeek),
        };
      }

      // Fallback for no pregnancy data
      return {
        'weeks': 0,
        'dueDate': 'Not set',
        'progressPercentage': 0,
        'trimester': 'Not started',
        'daysToGo': 280,
      };
    } catch (e) {
      print('Error getting pregnancy progress: $e');
      return {
        'weeks': 0,
        'dueDate': 'Not set',
        'progressPercentage': 0,
        'trimester': 'Not started',
        'daysToGo': 280,
      };
    }
  }

  static String _formatDueDate(dynamic dueDate) {
    if (dueDate == null) return 'Not set';

    if (dueDate is Timestamp) {
      return DateFormat('MMM d, yyyy').format(dueDate.toDate());
    } else if (dueDate is String) {
      try {
        return DateFormat('MMM d, yyyy').format(DateTime.parse(dueDate));
      } catch (e) {
        return dueDate;
      }
    }
    return 'Not set';
  }

  static int _calculateProgressPercentage(int weeks) {
    const totalWeeks = 40;
    return ((weeks / totalWeeks) * 100).round().clamp(0, 100);
  }

  static String _getTrimester(int weeks) {
    if (weeks <= 0) return 'Not started';
    if (weeks <= 12) return 'First Trimester';
    if (weeks <= 27) return 'Second Trimester';
    return 'Third Trimester';
  }

  static int _getDaysToGo(int weeks) {
    return (40 - weeks).clamp(0, 280) * 7;
  }
}
