import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/family_member_model.dart';

class FamilyMemberService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // ==================== PATIENT VERIFICATION ====================

  /// Check if patient exists using multiple field name possibilities
  /// Check if patient exists - UPDATED for document ID search
  static Future<bool> checkPatientExists(String patientId) async {
    try {
      print('🔍 Checking patient existence for ID: "$patientId"');

      if (patientId.isEmpty) {
        print('❌ Patient ID is empty');
        return false;
      }

      final trimmedId = patientId.trim();

      // Method 1: Try as Document ID (Primary method for your case)
      try {
        final doc = await _firestore
            .collection('patients')
            .doc(trimmedId)
            .get();
        if (doc.exists) {
          print('✅ Patient found using Document ID');
          return true;
        }
      } catch (e) {
        print('⚠️ Error checking document ID: $e');
      }

      // Method 2: Try common field names (fallback)
      final fieldNames = [
        'patientId',
        'id',
        'patientID',
        'patient_code',
        'medicalRecordNumber',
        'uid',
      ];

      for (final fieldName in fieldNames) {
        try {
          final query = await _firestore
              .collection('patients')
              .where(fieldName, isEqualTo: trimmedId)
              .limit(1)
              .get();

          if (query.docs.isNotEmpty) {
            print('✅ Patient found using field: $fieldName');
            return true;
          }
        } catch (e) {
          print('⚠️ Error querying field $fieldName: $e');
        }
      }

      print('❌ Patient not found with any method');
      return false;
    } catch (e) {
      print('❌ Error checking patient existence: $e');
      return false;
    }
  }

  /// Get patient by patientId with multiple fallback methods - FIXED VERSION
  /// Get patient by patientId with multiple fallback methods - UPDATED
  static Future<QuerySnapshot> getPatientByPatientId(String patientId) async {
    try {
      print('🔍 Getting patient details for ID: "$patientId"');

      final trimmedId = patientId.trim();

      // Method 1: Try as Document ID (This is your case!)
      try {
        final doc = await _firestore
            .collection('patients')
            .doc(trimmedId)
            .get();
        if (doc.exists) {
          print('✅ Patient found using Document ID');
          // Create a query that matches this document
          final query = await _firestore
              .collection('patients')
              .where(FieldPath.documentId, isEqualTo: trimmedId)
              .limit(1)
              .get();
          return query;
        }
      } catch (e) {
        print('⚠️ Error with document ID search: $e');
      }

      // Method 2: Try common field names (fallback)
      final fieldNames = [
        'patientId',
        'id',
        'patientID',
        'patient_code',
        'medicalRecordNumber',
        'uid',
      ];

      for (final fieldName in fieldNames) {
        try {
          final query = await _firestore
              .collection('patients')
              .where(fieldName, isEqualTo: trimmedId)
              .limit(1)
              .get();

          if (query.docs.isNotEmpty) {
            print('✅ Patient found using field: $fieldName');
            return query;
          }
        } catch (e) {
          print('⚠️ Error querying field $fieldName: $e');
        }
      }

      print('❌ No patient found with any method');
      return await _firestore
          .collection('patients')
          .where('nonExistentField', isEqualTo: 'shouldReturnEmpty')
          .limit(0)
          .get();
    } catch (e) {
      print('❌ Error getting patient: $e');
      return await _firestore
          .collection('patients')
          .where('nonExistentField', isEqualTo: 'shouldReturnEmpty')
          .limit(0)
          .get();
    }
  }
  // ==================== FAMILY MEMBER OPERATIONS ====================

  /// Create a new family member
  static Future<void> createFamilyMember(FamilyMember familyMember) async {
    try {
      await _firestore
          .collection('family_members')
          .doc(familyMember.uid)
          .set(familyMember.toMap());
      print('✅ Family member created successfully: ${familyMember.uid}');
    } catch (e) {
      print('❌ Error creating family member: $e');
      throw Exception('Failed to create family member: $e');
    }
  }

  /// Get family member by UID
  static Future<FamilyMember?> getFamilyMember(String uid) async {
    try {
      final doc = await _firestore.collection('family_members').doc(uid).get();
      if (doc.exists) {
        return FamilyMember.fromDocument(doc);
      }
      return null;
    } catch (e) {
      print('❌ Error getting family member: $e');
      throw Exception('Failed to get family member: $e');
    }
  }
  
/// Check if email exists in family_members collection - MODIFIED
static Future<bool> checkEmailExists(String email) async {
  try {
    final query = await _firestore
        .collection('family_members')
        .where('email', isEqualTo: email.trim().toLowerCase())
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  } catch (e) {
    print('⚠️ Email check failed (but continuing): $e');
    // Return false and let Firebase Auth handle duplicate emails
    return false;
  }
}
  /// Link family member to patient
  static Future<void> linkFamilyMemberToPatient({
    required String patientUserId,
    required String familyMemberId,
    required String fullName,
    required String relationship,
    required String email,
    required String phone,
  }) async {
    try {
      final familyMemberData = {
        'familyMemberId': familyMemberId,
        'fullName': fullName.trim(),
        'relationship': relationship,
        'email': email.trim(),
        'phone': phone.trim(),
        'addedAt': FieldValue.serverTimestamp(),
        'isActive': true,
      };

      await _firestore.collection('patients').doc(patientUserId).update({
        'familyMembers': FieldValue.arrayUnion([familyMemberData]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Family member linked to patient successfully');
    } catch (e) {
      print('⚠️ Linking failed (optional): $e');
      // Don't throw - this is optional
    }
  }

  // ==================== UTILITY METHODS ====================

  /// Debug method to check patient collection structure
  static Future<void> debugPatientCollection() async {
    try {
      print('=== 🔍 DEBUG: Patient Collection Structure ===');
      final allPatients = await _firestore
          .collection('patients')
          .limit(10)
          .get();

      if (allPatients.docs.isEmpty) {
        print('❌ No patients found in collection!');
        return;
      }

      print('📊 Total patients found: ${allPatients.docs.length}');

      for (var i = 0; i < allPatients.docs.length; i++) {
        final doc = allPatients.docs[i];
        print('\n--- Patient ${i + 1} ---');
        print('Document ID: ${doc.id}');
        print('All Fields:');
        doc.data().forEach((key, value) {
          print('  $key: $value');
        });
      }
      print('=== END DEBUG ===\n');
    } catch (e) {
      print('❌ Debug error: $e');
    }
  }

  /// Get sample patient IDs for testing
  static Future<List<String>> getSamplePatientIds() async {
    try {
      final patients = await _firestore.collection('patients').limit(5).get();
      final ids = patients.docs
          .map((doc) {
            final data = doc.data();
            return data['patientId'] ??
                data['id'] ??
                data['patientID'] ??
                doc.id;
          })
          .where((id) => id != null)
          .cast<String>()
          .toList();

      print('📝 Sample patient IDs: $ids');
      return ids;
    } catch (e) {
      print('❌ Error getting sample IDs: $e');
      return [];
    }
  }

  // ==================== PRIVATE HELPER METHODS ====================

  /// Helper method to check field values with case-insensitive comparison
  static bool _checkFieldValue(
    Map<String, dynamic> data,
    String fieldName,
    String value,
  ) {
    try {
      final fieldValue = data[fieldName]?.toString();
      return fieldValue != null &&
          fieldValue.toLowerCase() == value.toLowerCase();
    } catch (e) {
      return false;
    }
  }

  // ==================== ADDITIONAL METHODS ====================

  /// Get family members by patientUserId
  static Future<List<FamilyMember>> getFamilyMembersByPatient(
    String patientUserId,
  ) async {
    try {
      final query = await _firestore
          .collection('family_members')
          .where('patientUserId', isEqualTo: patientUserId)
          .get();

      return query.docs.map((doc) => FamilyMember.fromDocument(doc)).toList();
    } catch (e) {
      print('❌ Error getting family members: $e');
      throw Exception('Failed to get family members: $e');
    }
  }

  /// Update family member
  static Future<void> updateFamilyMember(FamilyMember familyMember) async {
    try {
      await _firestore
          .collection('family_members')
          .doc(familyMember.uid)
          .update(familyMember.toMap());
    } catch (e) {
      print('❌ Error updating family member: $e');
      throw Exception('Failed to update family member: $e');
    }
  }

  /// Delete family member
  static Future<void> deleteFamilyMember(String uid) async {
    try {
      await _firestore.collection('family_members').doc(uid).delete();
    } catch (e) {
      print('❌ Error deleting family member: $e');
      throw Exception('Failed to delete family member: $e');
    }
  }

  /// Stream family member data
  static Stream<FamilyMember?> getFamilyMemberStream(String uid) {
    return _firestore.collection('family_members').doc(uid).snapshots().map((
      snapshot,
    ) {
      if (snapshot.exists) {
        return FamilyMember.fromDocument(snapshot);
      }
      return null;
    });
  }

  /// Get current user's family member data
  static Future<FamilyMember?> getCurrentUserFamilyMember() async {
    final user = _auth.currentUser;
    if (user != null) {
      return await getFamilyMember(user.uid);
    }
    return null;
  }
}
