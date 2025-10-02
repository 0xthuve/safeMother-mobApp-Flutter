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
}