import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/family_member_model.dart';

class FamilyMemberService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // ==================== PATIENT VERIFICATION ====================

  /// Check if patient exists - searches in both users and patients collections
  static Future<bool> checkPatientExists(String patientId) async {
    try {
      print('🔍 Checking patient existence for ID: "$patientId"');

      if (patientId.isEmpty) {
        print('❌ Patient ID is empty');
        return false;
      }

      final trimmedId = patientId.trim();

      // Method 1: Try as Document ID in users collection
      try {
        final userDoc = await _firestore.collection('users').doc(trimmedId).get();
        if (userDoc.exists) {
          print('✅ Patient found in users collection using Document ID');
          return true;
        }
      } catch (e) {
        print('⚠️ Error checking users collection: $e');
      }

      // Method 2: Try as Document ID in patients collection
      try {
        final patientDoc = await _firestore.collection('patients').doc(trimmedId).get();
        if (patientDoc.exists) {
          print('✅ Patient found in patients collection using Document ID');
          return true;
        }
      } catch (e) {
        print('⚠️ Error checking patients collection: $e');
      }

      // Method 3: Try common field names in users collection
      final fieldNames = ['patientId', 'id', 'patientID', 'uid'];
      for (final fieldName in fieldNames) {
        try {
          final query = await _firestore
              .collection('users')
              .where(fieldName, isEqualTo: trimmedId)
              .limit(1)
              .get();

          if (query.docs.isNotEmpty) {
            print('✅ Patient found in users collection using field: $fieldName');
            return true;
          }
        } catch (e) {
          print('⚠️ Error querying field $fieldName in users: $e');
        }
      }

      print('❌ Patient not found with any method');
      return false;
    } catch (e) {
      print('❌ Error checking patient existence: $e');
      return false;
    }
  }

  /// Get patient data from users collection by patientId
  static Future<QuerySnapshot> getPatientByPatientId(String patientId) async {
    try {
      print('🔍 Getting patient details for ID: "$patientId"');

      final trimmedId = patientId.trim();

      // Method 1: Try as Document ID in users collection
      try {
        final doc = await _firestore.collection('users').doc(trimmedId).get();
        if (doc.exists) {
          print('✅ Patient found in users collection using Document ID');
          final query = await _firestore
              .collection('users')
              .where(FieldPath.documentId, isEqualTo: trimmedId)
              .limit(1)
              .get();
          return query;
        }
      } catch (e) {
        print('⚠️ Error with document ID search in users: $e');
      }

      // Method 2: Try common field names in users collection
      final fieldNames = ['patientId', 'id', 'patientID', 'uid'];
      for (final fieldName in fieldNames) {
        try {
          final query = await _firestore
              .collection('users')
              .where(fieldName, isEqualTo: trimmedId)
              .limit(1)
              .get();

          if (query.docs.isNotEmpty) {
            print('✅ Patient found in users collection using field: $fieldName');
            return query;
          }
        } catch (e) {
          print('⚠️ Error querying field $fieldName in users: $e');
        }
      }

      // Fallback to patients collection
      try {
        final doc = await _firestore.collection('patients').doc(trimmedId).get();
        if (doc.exists) {
          print('✅ Patient found in patients collection using Document ID');
          final query = await _firestore
              .collection('patients')
              .where(FieldPath.documentId, isEqualTo: trimmedId)
              .limit(1)
              .get();
          return query;
        }
      } catch (e) {
        print('⚠️ Error with document ID search in patients: $e');
      }

      print('❌ No patient found with any method');
      return await _firestore
          .collection('users')
          .where('nonExistentField', isEqualTo: 'shouldReturnEmpty')
          .limit(0)
          .get();
    } catch (e) {
      print('❌ Error getting patient: $e');
      return await _firestore
          .collection('users')
          .where('nonExistentField', isEqualTo: 'shouldReturnEmpty')
          .limit(0)
          .get();
    }
  }

  /// Get patient name from users collection using patientUserId
  static Future<String> getPatientName(String patientUserId) async {
    try {
      print('🔍 Getting patient name for user ID: $patientUserId');
      
      // First try users collection
      final userDoc = await _firestore.collection('users').doc(patientUserId).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        final name = userData?['fullName'] ?? 
                    userData?['name'] ?? 
                    userData?['patientName'] ??
                    userData?['displayName'] ??
                    'Patient';
        print('✅ Patient name found in users collection: $name');
        return name;
      }

      // Fallback to patients collection
      final patientDoc = await _firestore.collection('patients').doc(patientUserId).get();
      if (patientDoc.exists) {
        final patientData = patientDoc.data();
        final name = patientData?['fullName'] ?? 
                    patientData?['name'] ?? 
                    patientData?['patientName'] ??
                    'Patient';
        print('✅ Patient name found in patients collection: $name');
        return name;
      }

      print('❌ Patient name not found');
      return 'Patient';
    } catch (e) {
      print('❌ Error getting patient name: $e');
      return 'Patient';
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
  
  /// Check if email exists in family_members collection
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
    }
  }

  // ==================== UTILITY METHODS ====================

  /// Debug method to check collections structure
  static Future<void> debugCollections() async {
    try {
      print('=== 🔍 DEBUG: Collections Structure ===');
      
      // Check users collection
      final users = await _firestore.collection('users').limit(5).get();
      print('📊 Users found: ${users.docs.length}');
      for (var i = 0; i < users.docs.length; i++) {
        final doc = users.docs[i];
        print('\n--- User ${i + 1} ---');
        print('Document ID: ${doc.id}');
        print('Fields: ${doc.data().keys.join(', ')}');
      }

      // Check patients collection
      final patients = await _firestore.collection('patients').limit(5).get();
      print('\n📊 Patients found: ${patients.docs.length}');
      for (var i = 0; i < patients.docs.length; i++) {
        final doc = patients.docs[i];
        print('\n--- Patient ${i + 1} ---');
        print('Document ID: ${doc.id}');
        print('Fields: ${doc.data().keys.join(', ')}');
      }

      // Check family_members collection
      final familyMembers = await _firestore.collection('family_members').limit(5).get();
      print('\n📊 Family Members found: ${familyMembers.docs.length}');
      for (var i = 0; i < familyMembers.docs.length; i++) {
        final doc = familyMembers.docs[i];
        print('\n--- Family Member ${i + 1} ---');
        print('Document ID: ${doc.id}');
        print('Fields: ${doc.data().keys.join(', ')}');
      }

      print('=== END DEBUG ===\n');
    } catch (e) {
      print('❌ Debug error: $e');
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