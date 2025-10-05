import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'firebase_mock_service.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Configure GoogleSignIn based on platform
  static late final GoogleSignIn _googleSignIn;
  
  // Flag to determine if we should use mock service
  static bool _useMockService = false;

  // Initialize service
  static Future<void> initialize() async {
    try {
      // Initialize GoogleSignIn based on platform
      if (kIsWeb) {
        // For web, configure with a fallback approach
        // Option 1: Use meta tag in index.html (recommended)
        // Option 2: Provide client ID directly (uncomment line below and add your web client ID)
        _googleSignIn = GoogleSignIn(
          // clientId: '1057692047745-YOUR_WEB_CLIENT_ID.apps.googleusercontent.com', // Replace with actual client ID
        );
      } else {
        // For mobile platforms, use default configuration
        _googleSignIn = GoogleSignIn();
      }
      
      // Try to use Firebase first
      _auth.currentUser;
      _useMockService = false;
      print('Using Firebase service');
    } catch (e) {
      // If Firebase is not configured, use mock service
      _useMockService = true;
      await FirebaseMockService.initialize();
      print('Using Firebase mock service');
    }
  }

  // Get current user
  static User? get currentUser {
    if (_useMockService) {
      // For mock service, we'll handle this differently in the methods that use it
      return null;
    }
    return _auth.currentUser;
  }

  // Get current user data (works for both real and mock)
  static Map<String, dynamic>? get currentUserData {
    if (_useMockService) {
      return FirebaseMockService.currentUser;
    }
    final user = _auth.currentUser;
    if (user != null) {
      return {
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
      };
    }
    return null;
  }

  // Check if user is logged in
  static bool get isLoggedIn {
    if (_useMockService) {
      return FirebaseMockService.isLoggedIn;
    }
    return _auth.currentUser != null;
  }

  // Auth state stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register with email and password
  static Future<Map<String, dynamic>?> registerWithEmailPassword({
    required String email,
    required String password,
    required String fullName,
    required String role,
    Map<String, dynamic>? additionalData,
  }) async {
    if (_useMockService) {
      return await FirebaseMockService.registerWithEmailPassword(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
        additionalData: additionalData,
      );
    }

    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update user profile
      await result.user?.updateDisplayName(fullName);

      // Create user document in Firestore
      await _firestore.collection('users').doc(result.user?.uid).set({
        'uid': result.user?.uid,
        'email': email,
        'fullName': fullName,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
        'profileComplete': false,
        ...?additionalData,
      });

      return {
        'uid': result.user?.uid,
        'email': email,
        'fullName': fullName,
        'role': role,
      };
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  // Login with email and password
  static Future<Map<String, dynamic>?> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    if (_useMockService) {
      return await FirebaseMockService.loginWithEmailPassword(
        email: email,
        password: password,
      );
    }

    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update last login time
      if (result.user != null) {
        await _firestore.collection('users').doc(result.user!.uid).update({
          'lastLoginAt': FieldValue.serverTimestamp(),
        });
      }

      return {
        'uid': result.user?.uid,
        'email': result.user?.email,
        'displayName': result.user?.displayName,
      };
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  // Sign in with Google
  static Future<Map<String, dynamic>?> signInWithGoogle() async {
    if (_useMockService) {
      return await FirebaseMockService.signInWithGoogle();
    }

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);

      bool isNewUser = result.additionalUserInfo?.isNewUser == true;
      bool profileComplete = true;

      // Check if this is a new user
      if (isNewUser) {
        // Create user document for new Google sign-in
        await _firestore.collection('users').doc(result.user?.uid).set({
          'uid': result.user?.uid,
          'email': result.user?.email,
          'fullName': result.user?.displayName ?? 'Google User',
          'role': 'patient', // Default role for Google sign-in
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
          'profileComplete': false, // New Google users need to complete profile
          'signInMethod': 'google',
          'pregnancyInfoComplete': false, // Need to ask pregnancy questions
        });
        profileComplete = false;
      } else {
        // Update last login for existing user and check profile status
        await _firestore.collection('users').doc(result.user!.uid).update({
          'lastLoginAt': FieldValue.serverTimestamp(),
        });

        // Check if profile is complete
        final userDoc = await _firestore.collection('users').doc(result.user!.uid).get();
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          profileComplete = userData['profileComplete'] == true && 
                           userData['pregnancyInfoComplete'] == true;
        }
      }

      return {
        'uid': result.user?.uid,
        'email': result.user?.email,
        'displayName': result.user?.displayName,
        'isNewUser': isNewUser,
        'profileComplete': profileComplete,
        'needsPregnancyInfo': !profileComplete,
      };
    } catch (e) {
      throw Exception('Google sign-in failed: ${e.toString()}');
    }
  }

  // Sign out
  static Future<void> signOut() async {
    if (_useMockService) {
      await FirebaseMockService.signOut();
      return;
    }

    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  // Reset password
  static Future<void> resetPassword(String email) async {
    if (_useMockService) {
      await FirebaseMockService.resetPassword(email);
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }

  // Get email by username
  static Future<String?> getEmailByUsername(String username) async {
    if (_useMockService) {
      return await FirebaseMockService.getEmailByUsername(username);
    }

    try {
      // Query Firestore to find user with matching username
      final querySnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userData = querySnapshot.docs.first.data();
        return userData['email'] as String?;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to find user by username: ${e.toString()}');
    }
  }

  // Get user data from Firestore
  static Future<Map<String, dynamic>?> getUserData(String uid) async {
    if (_useMockService) {
      return await FirebaseMockService.getUserData(uid);
    }

    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      throw Exception('Failed to get user data: ${e.toString()}');
    }
  }

  // Update user data
  static Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      throw Exception('Failed to update user data: ${e.toString()}');
    }
  }

  // Delete user account
  static Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Delete user document from Firestore
        await _firestore.collection('users').doc(user.uid).delete();
        // Delete user account
        await user.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete account: ${e.toString()}');
    }
  }

  // Check if email exists
  static Future<bool> isEmailRegistered(String email) async {
    if (_useMockService) {
      return await FirebaseMockService.isEmailRegistered(email);
    }

    try {
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Handle Firebase Auth exceptions
  static String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No user found for this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'invalid-credential':
        return 'The credentials provided are invalid.';
      default:
        return e.message ?? 'An unknown error occurred.';
    }
  }

  // Create collection for specific role data
  static Future<void> createRoleData(String uid, String role, Map<String, dynamic> roleData) async {
    try {
      String collection = '';
      switch (role.toLowerCase()) {
        case 'patient':
        case 'mother':
          collection = 'patients';
          break;
        case 'doctor':
        case 'healthcare':
          collection = 'doctors';
          break;
        case 'family':
          collection = 'family_members';
          break;
        default:
          collection = 'users_data';
      }

      await _firestore.collection(collection).doc(uid).set({
        'uid': uid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        ...roleData,
      });
    } catch (e) {
      throw Exception('Failed to create role data: ${e.toString()}');
    }
  }

  // Get role-specific data
  static Future<Map<String, dynamic>?> getRoleData(String uid, String role) async {
    try {
      String collection = '';
      switch (role.toLowerCase()) {
        case 'patient':
        case 'mother':
          collection = 'patients';
          break;
        case 'doctor':
        case 'healthcare':
          collection = 'doctors';
          break;
        case 'family':
          collection = 'family_members';
          break;
        default:
          collection = 'users_data';
      }

      DocumentSnapshot doc = await _firestore.collection(collection).doc(uid).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      throw Exception('Failed to get role data: ${e.toString()}');
    }
  }

  // ========== DOCTOR MANAGEMENT METHODS ==========

  // Get all doctors from Firebase
  static Future<List<Map<String, dynamic>>> getAllDoctors() async {
    if (_useMockService) {
      // Return empty list for mock service - no hardcoded doctors
      return [];
    }

    try {
      print('Fetching ONLY real doctors from Firebase database...');
      
      // Check if user is authenticated
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('ERROR: User not authenticated - cannot fetch doctors');
        print('Please make sure the user is logged in to view doctors');
        return [];
      }
      
      print('User authenticated: ${currentUser.email}');
      print('Querying Firebase for healthcare professionals...');
      
      final querySnapshot = await _firestore
          .collection('users')
          .where('accountType', isEqualTo: 'healthcare')
          .where('role', isEqualTo: 'doctor')
          .get();

      print('Found ${querySnapshot.docs.length} healthcare professionals in Firebase');
      
      List<Map<String, dynamic>> doctors = [];
      
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        print('Processing doctor: ${data['fullName']} - ${data['specialization']}');
        
        // Convert Firebase document to Doctor model format
        final firebaseUid = data['uid'] ?? doc.id;
        doctors.add({
          'id': firebaseUid.hashCode.abs(), // Convert string to positive int
          'firebaseUid': firebaseUid, // Store the original Firebase UID for patient-doctor links
          'name': data['fullName'] ?? 'Unknown Doctor',
          'email': data['email'] ?? '',
          'phone': data['phone'] ?? '',
          'specialization': data['specialization'] ?? 'General Practice',
          'licenseNumber': data['licenseNumber'] ?? '',
          'hospital': data['hospital'] ?? 'Unknown Hospital',
          'experience': data['yearsExperience'] != null 
              ? '${data['yearsExperience']} years' 
              : '0 years',
          'bio': 'Healthcare professional specializing in ${data['specialization'] ?? 'General Practice'}',
          'profileImage': '',
          'isAvailable': true, // Default to available
          'rating': 4.5, // Default rating
          'totalPatients': 50, // Default patient count
          'createdAt': data['createdAt'] != null 
              ? (data['createdAt'] as Timestamp).toDate().toIso8601String()
              : DateTime.now().toIso8601String(),
          'updatedAt': data['lastLoginAt'] != null 
              ? (data['lastLoginAt'] as Timestamp).toDate().toIso8601String()
              : DateTime.now().toIso8601String(),
        });
      }

      // Sort by name
      doctors.sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
      
      print('Returning ${doctors.length} doctors from Firebase');
      return doctors;
    } catch (e) {
      print('❌ ERROR fetching doctors from Firebase: $e');
      
      if (e.toString().contains('permission-denied')) {
        print('🔒 PERMISSION DENIED - Firebase security rules are blocking access');
        print('💡 SOLUTION: Check Firebase security rules or user authentication');
        print('📝 Current user: ${_auth.currentUser?.email ?? 'Not authenticated'}');
      } else if (e.toString().contains('network')) {
        print('🌐 NETWORK ERROR - Check internet connection');
      } else {
        print('🔥 FIREBASE ERROR - Check Firebase configuration');
      }
      
      print('✅ NO HARDCODED DOCTORS - Only real database doctors will be shown');
      return [];
    }
  }



  // Get doctor by ID
  static Future<Map<String, dynamic>?> getDoctorById(String doctorId) async {
    if (_useMockService) {
      return null;
    }

    try {
      final docSnapshot = await _firestore
          .collection('users')
          .doc(doctorId)
          .get();

      if (!docSnapshot.exists) {
        return null;
      }

      final data = docSnapshot.data()!;
      
      // Check if this is a doctor
      if (data['accountType'] != 'healthcare' || data['role'] != 'doctor') {
        return null;
      }

      return {
        'id': (data['uid'] ?? docSnapshot.id).hashCode, // Convert string to int for the Doctor model
        'name': data['fullName'] ?? 'Unknown Doctor',
        'specialization': data['specialization'] ?? 'General Practice',
        'hospital': data['hospital'] ?? 'Unknown Hospital',
        'email': data['email'] ?? '',
        'phone': data['phone'] ?? '',
        'licenseNumber': data['licenseNumber'] ?? '',
        'experience': data['yearsExperience'] != null 
            ? '${data['yearsExperience']} years' 
            : '0 years',
        'bio': 'Healthcare professional specializing in ${data['specialization'] ?? 'General Practice'}',
        'isAvailable': true, // Default to available
        'rating': 4.5, // Default rating
        'totalPatients': 50, // Default patient count
        'createdAt': data['createdAt'] != null 
            ? (data['createdAt'] as Timestamp).toDate().toIso8601String()
            : DateTime.now().toIso8601String(),
        'updatedAt': data['lastLoginAt'] != null 
            ? (data['lastLoginAt'] as Timestamp).toDate().toIso8601String()
            : DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('Error fetching doctor by ID from Firebase: $e');
      return null;
    }
  }

  // Get doctors by specialization
  static Future<List<Map<String, dynamic>>> getDoctorsBySpecialization(String specialization) async {
    if (_useMockService) {
      return [];
    }

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('accountType', isEqualTo: 'healthcare')
          .where('role', isEqualTo: 'doctor')
          .where('specialization', isEqualTo: specialization)
          .get();

      List<Map<String, dynamic>> doctors = [];
      
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        
        doctors.add({
          'id': (data['uid'] ?? doc.id).hashCode, // Convert string to int for the Doctor model
          'name': data['fullName'] ?? 'Unknown Doctor',
          'specialization': data['specialization'] ?? 'General Practice',
          'hospital': data['hospital'] ?? 'Unknown Hospital',
          'email': data['email'] ?? '',
          'phone': data['phone'] ?? '',
          'licenseNumber': data['licenseNumber'] ?? '',
          'experience': data['yearsExperience'] != null 
              ? '${data['yearsExperience']} years' 
              : '0 years',
          'bio': 'Healthcare professional specializing in ${data['specialization'] ?? 'General Practice'}',
          'isAvailable': true, // Default to available
          'rating': 4.5, // Default rating
          'totalPatients': 50, // Default patient count
          'createdAt': data['createdAt'] != null 
              ? (data['createdAt'] as Timestamp).toDate().toIso8601String()
              : DateTime.now().toIso8601String(),
          'updatedAt': data['lastLoginAt'] != null 
              ? (data['lastLoginAt'] as Timestamp).toDate().toIso8601String()
              : DateTime.now().toIso8601String(),
        });
      }

      doctors.sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
      return doctors;
    } catch (e) {
      print('Error fetching doctors by specialization from Firebase: $e');
      return [];
    }
  }

  // Get all available specializations
  static Future<List<String>> getAvailableSpecializations() async {
    if (_useMockService) {
      return [
        'General Practice',
        'Obstetrics and Gynecology',
        'Pediatrics',
        'Internal Medicine',
        'Family Medicine',
        'Emergency Medicine',
        'Cardiology',
        'Dermatology',
        'Psychiatry',
        'Other'
      ];
    }

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('accountType', isEqualTo: 'healthcare')
          .where('role', isEqualTo: 'doctor')
          .get();

      Set<String> specializations = {};
      
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final specialization = data['specialization'] as String?;
        if (specialization != null && specialization.isNotEmpty) {
          specializations.add(specialization);
        }
      }

      final list = specializations.toList();
      list.sort();
      return list;
    } catch (e) {
      print('Error fetching specializations from Firebase: $e');
      return [];
    }
  }

  // Get total patient count from Firebase
  static Future<int> getTotalPatientCount() async {
    if (_useMockService) {
      return 0; // No demo data
    }

    try {
      print('Fetching total patient count from Firebase database...');
      
      // Check if user is authenticated
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('ERROR: User not authenticated - cannot fetch patient count');
        return 0;
      }
      
      print('User authenticated: ${currentUser.email}');
      print('Querying Firebase for patients...');
      
      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'patient')
          .get();

      final patientCount = querySnapshot.docs.length;
      print('Found $patientCount patients in Firebase database');
      
      return patientCount;
    } catch (e) {
      print('❌ ERROR fetching patient count from Firebase: $e');
      
      if (e.toString().contains('permission-denied')) {
        print('🔒 PERMISSION DENIED - Firebase security rules are blocking access');
        print('💡 SOLUTION: Check Firebase security rules or user authentication');
        print('📝 Current user: ${_auth.currentUser?.email ?? 'Not authenticated'}');
      } else if (e.toString().contains('network')) {
        print('🌐 NETWORK ERROR - Check internet connection');
      } else {
        print('🔥 FIREBASE ERROR - Check Firebase configuration');
      }
      
      return 0;
    }
  }

  // ========== PATIENT-DOCTOR LINK MANAGEMENT ==========

  // Check if patient-doctor link already exists
  static Future<Map<String, dynamic>?> getPatientDoctorLink(String patientId, String doctorId) async {
    if (_useMockService) {
      return null;
    }

    try {
      final querySnapshot = await _firestore
          .collection('patient_doctor_links')
          .where('patientId', isEqualTo: patientId)
          .where('doctorId', isEqualTo: doctorId)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data();
        return {
          'id': doc.id,
          'patientId': data['patientId'],
          'doctorId': data['doctorId'],
          'status': data['status'],
          'isActive': data['isActive'],
          'linkedDate': data['linkedDate'] != null 
              ? (data['linkedDate'] as Timestamp).toDate()
              : DateTime.now(),
          'createdAt': data['createdAt'] != null 
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
          'updatedAt': data['updatedAt'] != null 
              ? (data['updatedAt'] as Timestamp).toDate()
              : DateTime.now(),
        };
      }
      return null;
    } catch (e) {
      print('Error checking existing patient-doctor link: $e');
      return null;
    }
  }

  // Save patient-doctor link to Firebase
  static Future<String?> createPatientDoctorLink({
    required String patientId,
    required String doctorId,
    String status = 'requested',
  }) async {
    if (_useMockService) {
      return DateTime.now().millisecondsSinceEpoch.toString();
    }

    try {
      final linkData = {
        'patientId': patientId,
        'doctorId': doctorId,
        'status': status,
        'isActive': true,
        'linkedDate': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore.collection('patient_doctor_links').add(linkData);
      print('Patient-doctor link created in Firebase: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error creating patient-doctor link in Firebase: $e');
      return null;
    }
  }

  // Get patient requests for a doctor from Firebase
  static Future<List<Map<String, dynamic>>> getPatientRequestsForDoctor(String doctorId) async {
    if (_useMockService) {
      return [];
    }

    try {
      print('Fetching patient requests for doctor: $doctorId from Firebase');
      
      // Use a simpler query to avoid composite index requirements
      final querySnapshot = await _firestore
          .collection('patient_doctor_links')
          .where('doctorId', isEqualTo: doctorId)
          .where('status', isEqualTo: 'requested')
          .get();

      List<Map<String, dynamic>> requests = [];
      
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        
        // Filter for active requests in code to avoid composite index
        if (data['isActive'] == true) {
          requests.add({
            'id': doc.id,
            'patientId': data['patientId'],
            'doctorId': data['doctorId'],
            'status': data['status'],
            'isActive': data['isActive'],
            'linkedDate': data['linkedDate'] != null 
                ? (data['linkedDate'] as Timestamp).toDate()
                : DateTime.now(),
            'createdAt': data['createdAt'] != null 
                ? (data['createdAt'] as Timestamp).toDate()
                : DateTime.now(),
            'updatedAt': data['updatedAt'] != null 
                ? (data['updatedAt'] as Timestamp).toDate()
                : DateTime.now(),
          });
        }
      }
      
      // Sort by creation date in code
      requests.sort((a, b) => (b['createdAt'] as DateTime).compareTo(a['createdAt'] as DateTime));

      print('Found ${requests.length} patient requests for doctor $doctorId');
      return requests;
    } catch (e) {
      print('Error fetching patient requests from Firebase: $e');
      return [];
    }
  }

  // Get accepted patients for a doctor from Firebase
  static Future<List<Map<String, dynamic>>> getAcceptedPatientsForDoctor(String doctorId) async {
    if (_useMockService) {
      return [];
    }

    try {
      print('Fetching accepted patients for doctor: $doctorId from Firebase');
      
      // Use a simpler query to avoid composite index requirements
      final querySnapshot = await _firestore
          .collection('patient_doctor_links')
          .where('doctorId', isEqualTo: doctorId)
          .where('status', isEqualTo: 'accepted')
          .get();

      List<Map<String, dynamic>> patients = [];
      
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        
        // Filter for active patients in code to avoid composite index
        if (data['isActive'] == true) {
          patients.add({
            'id': doc.id,
            'patientId': data['patientId'],
            'doctorId': data['doctorId'],
            'status': data['status'],
            'isActive': data['isActive'],
            'linkedDate': data['linkedDate'] != null 
                ? (data['linkedDate'] as Timestamp).toDate()
                : DateTime.now(),
            'createdAt': data['createdAt'] != null 
                ? (data['createdAt'] as Timestamp).toDate()
                : DateTime.now(),
            'updatedAt': data['updatedAt'] != null 
                ? (data['updatedAt'] as Timestamp).toDate()
                : DateTime.now(),
          });
        }
      }
      
      // Sort by linked date in code
      patients.sort((a, b) => (b['linkedDate'] as DateTime).compareTo(a['linkedDate'] as DateTime));

      print('Found ${patients.length} accepted patients for doctor $doctorId');
      return patients;
    } catch (e) {
      print('Error fetching accepted patients from Firebase: $e');
      return [];
    }
  }

  // Accept a patient request in Firebase
  static Future<bool> acceptPatientRequest(String linkId) async {
    if (_useMockService) {
      return true;
    }

    try {
      await _firestore.collection('patient_doctor_links').doc(linkId).update({
        'status': 'accepted',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('Patient request accepted in Firebase: $linkId');
      return true;
    } catch (e) {
      print('Error accepting patient request in Firebase: $e');
      return false;
    }
  }

  // Decline a patient request in Firebase
  static Future<bool> declinePatientRequest(String linkId) async {
    if (_useMockService) {
      return true;
    }

    try {
      await _firestore.collection('patient_doctor_links').doc(linkId).update({
        'status': 'declined',
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('Patient request declined in Firebase: $linkId');
      return true;
    } catch (e) {
      print('Error declining patient request in Firebase: $e');
      return false;
    }
  }

  // Remove/unlink a patient permanently in Firebase
  static Future<bool> removePatientFromDoctor(String linkId) async {
    if (_useMockService) {
      return true;
    }

    try {
      await _firestore.collection('patient_doctor_links').doc(linkId).update({
        'status': 'removed',
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('Patient removed from doctor in Firebase: $linkId');
      return true;
    } catch (e) {
      print('Error removing patient from doctor in Firebase: $e');
      return false;
    }
  }

  // Get patient details by ID
  static Future<Map<String, dynamic>?> getPatientById(String patientId) async {
    if (_useMockService) {
      return null;
    }

    try {
      final docSnapshot = await _firestore
          .collection('users')
          .doc(patientId)
          .get();

      if (!docSnapshot.exists) {
        return null;
      }

      final data = docSnapshot.data()!;
      
      // Check if this is a patient
      if (data['role'] != 'patient') {
        return null;
      }

      return {
        'id': patientId,
        'name': data['fullName'] ?? 'Unknown Patient',
        'email': data['email'] ?? '',
        'phone': data['phone'] ?? '',
        'age': data['age'] ?? 0,
        'createdAt': data['createdAt'] != null 
            ? (data['createdAt'] as Timestamp).toDate()
            : DateTime.now(),
      };
    } catch (e) {
      print('Error fetching patient by ID from Firebase: $e');
      return null;
    }
  }

  // Get all linked doctors for a patient (both pending and accepted)
  static Future<List<Map<String, dynamic>>> getLinkedDoctorsForPatient(String patientId) async {
    if (_useMockService) {
      return [];
    }

    try {
      print('Fetching linked doctors for patient: $patientId from Firebase');
      
      final querySnapshot = await _firestore
          .collection('patient_doctor_links')
          .where('patientId', isEqualTo: patientId)
          .where('isActive', isEqualTo: true)
          .get();

      List<Map<String, dynamic>> linkedDoctors = [];
      
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        
        // Get doctor details for each link
        try {
          final doctorData = await getUserData(data['doctorId']);
          if (doctorData != null) {
            linkedDoctors.add({
              'linkId': doc.id,
              'doctorId': data['doctorId'],
              'status': data['status'], // 'requested', 'accepted', 'declined'
              'linkedDate': data['linkedDate'] != null 
                  ? (data['linkedDate'] as Timestamp).toDate()
                  : DateTime.now(),
              'createdAt': data['createdAt'] != null 
                  ? (data['createdAt'] as Timestamp).toDate()
                  : DateTime.now(),
              // Doctor details
              'doctorName': doctorData['fullName'] ?? 'Unknown Doctor',
              'doctorEmail': doctorData['email'] ?? '',
              'doctorPhone': doctorData['phone'] ?? '',
              'specialization': doctorData['specialization'] ?? 'General Practice',
              'hospital': doctorData['hospital'] ?? 'Unknown Hospital',
              'yearsExperience': doctorData['yearsExperience'] ?? 0,
            });
          }
        } catch (e) {
          print('Could not load doctor data for ${data['doctorId']}: $e');
          // Add basic info even if doctor details fail
          linkedDoctors.add({
            'linkId': doc.id,
            'doctorId': data['doctorId'],
            'status': data['status'],
            'linkedDate': data['linkedDate'] != null 
                ? (data['linkedDate'] as Timestamp).toDate()
                : DateTime.now(),
            'createdAt': data['createdAt'] != null 
                ? (data['createdAt'] as Timestamp).toDate()
                : DateTime.now(),
            // Fallback doctor details
            'doctorName': 'Doctor ${data['doctorId'].substring(0, 8)}',
            'doctorEmail': 'Not available',
            'doctorPhone': 'Not available',
            'specialization': 'General Practice',
            'hospital': 'Unknown Hospital',
            'yearsExperience': 0,
          });
        }
      }
      
      // Sort by creation date (most recent first)
      linkedDoctors.sort((a, b) => (b['createdAt'] as DateTime).compareTo(a['createdAt'] as DateTime));
      
      print('Found ${linkedDoctors.length} linked doctors for patient $patientId');
      return linkedDoctors;
    } catch (e) {
      print('Error fetching linked doctors from Firebase: $e');
      return [];
    }
  }

  // ========== SYMPTOM LOGS MANAGEMENT ==========

  // Save a symptom log to Firebase
  static Future<String?> saveSymptomLog(Map<String, dynamic> logData) async {
    if (_useMockService) {
      return DateTime.now().millisecondsSinceEpoch.toString();
    }

    try {
      // Ensure required fields are present and properly formatted
      final symptomLogData = {
        ...logData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'logDate': logData['logDate'] is String 
            ? Timestamp.fromDate(DateTime.parse(logData['logDate']))
            : logData['logDate'] is DateTime
                ? Timestamp.fromDate(logData['logDate'])
                : FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore.collection('symptom_logs').add(symptomLogData);
      print('Symptom log saved to Firebase: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error saving symptom log to Firebase: $e');
      return null;
    }
  }

  // Get all symptom logs for a patient
  static Future<List<Map<String, dynamic>>> getSymptomLogsForPatient(String patientId) async {
    if (_useMockService) {
      return [];
    }

    try {
      print('Fetching symptom logs for patient: $patientId from Firebase');
      
      // Check if current user is the patient or has doctor access
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('Error: No authenticated user');
        return [];
      }

      // If the current user is not the patient, verify doctor-patient relationship
      if (currentUser.uid != patientId) {
        print('Current user (${currentUser.uid}) is not the patient ($patientId), checking doctor access...');
        
        // Get current user's role
        final currentUserData = await getUserData(currentUser.uid);
        if (currentUserData == null || 
            currentUserData['accountType'] != 'healthcare' || 
            currentUserData['role'] != 'doctor') {
          print('Error: Current user is not a doctor');
          return [];
        }

        // Verify doctor-patient relationship
        final hasAccess = await verifyDoctorPatientRelationship(currentUser.uid, patientId);
        if (!hasAccess) {
          print('Error: Doctor does not have access to patient data');
          return [];
        }
        
        print('Doctor access verified for patient $patientId');
      }
      
      final querySnapshot = await _firestore
          .collection('symptom_logs')
          .where('patientId', isEqualTo: patientId)
          .get();

      List<Map<String, dynamic>> logs = [];
      
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        
        // Convert Timestamp fields to DateTime strings for compatibility
        final logData = Map<String, dynamic>.from(data);
        logData['id'] = doc.id;
        
        // Convert Firestore Timestamps to DateTime strings
        if (data['logDate'] is Timestamp) {
          logData['logDate'] = (data['logDate'] as Timestamp).toDate().toIso8601String();
        }
        if (data['createdAt'] is Timestamp) {
          logData['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
        }
        if (data['updatedAt'] is Timestamp) {
          logData['updatedAt'] = (data['updatedAt'] as Timestamp).toDate().toIso8601String();
        }
        
        logs.add(logData);
      }
      
      // Sort by logDate in code instead of Firestore to avoid composite index requirement
      logs.sort((a, b) {
        try {
          final dateA = DateTime.parse(a['logDate']);
          final dateB = DateTime.parse(b['logDate']);
          return dateB.compareTo(dateA); // Descending order (newest first)
        } catch (e) {
          return 0; // If date parsing fails, maintain current order
        }
      });
      
      print('Found ${logs.length} symptom logs for patient $patientId');
      return logs;
    } catch (e) {
      print('Error fetching symptom logs from Firebase: $e');
      
      if (e.toString().contains('permission-denied')) {
        print('Permission denied - this might be due to Firestore security rules');
        print('Make sure the user has proper access to symptom logs');
      }
      
      return [];
    }
  }

  // Get symptom logs by date range
  static Future<List<Map<String, dynamic>>> getSymptomLogsByDateRange(
    String patientId, 
    DateTime startDate, 
    DateTime endDate
  ) async {
    if (_useMockService) {
      return [];
    }

    try {
      print('Fetching symptom logs for patient: $patientId from $startDate to $endDate');
      
      // First get all logs for the patient, then filter by date in code
      // This avoids needing composite indexes
      final querySnapshot = await _firestore
          .collection('symptom_logs')
          .where('patientId', isEqualTo: patientId)
          .get();

      List<Map<String, dynamic>> logs = [];
      
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        
        // Check if log date is within range
        DateTime logDate;
        if (data['logDate'] is Timestamp) {
          logDate = (data['logDate'] as Timestamp).toDate();
        } else if (data['logDate'] is String) {
          logDate = DateTime.parse(data['logDate']);
        } else {
          continue; // Skip if no valid date
        }
        
        // Filter by date range
        if (logDate.isBefore(startDate) || logDate.isAfter(endDate)) {
          continue;
        }
        
        // Convert Timestamp fields to DateTime strings for compatibility
        final logData = Map<String, dynamic>.from(data);
        logData['id'] = doc.id;
        
        // Convert Firestore Timestamps to DateTime strings
        if (data['logDate'] is Timestamp) {
          logData['logDate'] = (data['logDate'] as Timestamp).toDate().toIso8601String();
        }
        if (data['createdAt'] is Timestamp) {
          logData['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
        }
        if (data['updatedAt'] is Timestamp) {
          logData['updatedAt'] = (data['updatedAt'] as Timestamp).toDate().toIso8601String();
        }
        
        logs.add(logData);
      }
      
      // Sort by date in code
      logs.sort((a, b) {
        final dateA = DateTime.parse(a['logDate']);
        final dateB = DateTime.parse(b['logDate']);
        return dateB.compareTo(dateA); // Descending order
      });
      
      print('Found ${logs.length} symptom logs in date range for patient $patientId');
      return logs;
    } catch (e) {
      print('Error fetching symptom logs by date range from Firebase: $e');
      return [];
    }
  }

  // Get symptom logs for all patients of a doctor
  static Future<Map<String, List<Map<String, dynamic>>>> getSymptomLogsForDoctorPatients(String doctorId) async {
    if (_useMockService) {
      return {};
    }

    try {
      print('Fetching symptom logs for all patients of doctor: $doctorId');
      
      // First get all accepted patients for this doctor
      final acceptedPatients = await getAcceptedPatientsForDoctor(doctorId);
      
      Map<String, List<Map<String, dynamic>>> patientLogs = {};
      
      for (final patientLink in acceptedPatients) {
        final patientId = patientLink['patientId'] as String;
        
        try {
          final logs = await getSymptomLogsForPatient(patientId);
          
          if (logs.isNotEmpty) {
            patientLogs[patientId] = logs;
          }
        } catch (e) {
          print('Error fetching logs for patient $patientId: $e');
          // Continue with other patients even if one fails
          continue;
        }
      }
      
      print('Found symptom logs for ${patientLogs.length} patients of doctor $doctorId');
      return patientLogs;
    } catch (e) {
      print('Error fetching symptom logs for doctor patients: $e');
      return {};
    }
  }

  // Helper method to verify if a doctor has access to a patient's data
  static Future<bool> verifyDoctorPatientRelationship(String doctorId, String patientId) async {
    if (_useMockService) {
      return true; // Allow all access in mock mode
    }

    try {
      final querySnapshot = await _firestore
          .collection('patient_doctor_links')
          .where('doctorId', isEqualTo: doctorId)
          .where('patientId', isEqualTo: patientId)
          .where('status', isEqualTo: 'accepted')
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error verifying doctor-patient relationship: $e');
      return false;
    }
  }

  // Update a symptom log (for doctor notes or corrections)
  static Future<bool> updateSymptomLog(String logId, Map<String, dynamic> updates) async {
    if (_useMockService) {
      return true;
    }

    try {
      final updateData = {
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('symptom_logs').doc(logId).update(updateData);
      print('Symptom log updated in Firebase: $logId');
      return true;
    } catch (e) {
      print('Error updating symptom log in Firebase: $e');
      return false;
    }
  }

  // Delete a symptom log (rarely used, for data cleanup)
  static Future<bool> deleteSymptomLog(String logId) async {
    if (_useMockService) {
      return true;
    }

    try {
      await _firestore.collection('symptom_logs').doc(logId).delete();
      print('Symptom log deleted from Firebase: $logId');
      return true;
    } catch (e) {
      print('Error deleting symptom log from Firebase: $e');
      return false;
    }
  }
}