import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  static User? get currentUser => _auth.currentUser;

  // Get current user stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign In with Email and Password
  static Future<AuthResult> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (credential.user != null) {
        // Get user data from Firestore
        final userDoc = await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .get();

        if (userDoc.exists) {
          final userData = UserModel.fromMap(userDoc.data()!);
          return AuthResult(
            success: true,
            user: credential.user,
            userData: userData,
            message: 'Sign in successful',
          );
        } else {
          return AuthResult(
            success: false,
            message: 'User data not found',
          );
        }
      }

      return AuthResult(
        success: false,
        message: 'Authentication failed',
      );
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred';
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found for that email';
          break;
        case 'wrong-password':
          message = 'Wrong password provided';
          break;
        case 'invalid-email':
          message = 'Invalid email address';
          break;
        case 'user-disabled':
          message = 'User account has been disabled';
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Try again later';
          break;
        default:
          message = e.message ?? 'Authentication failed';
      }
      return AuthResult(success: false, message: message);
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  // Register Mother
  static Future<AuthResult> registerMother({
    required String fullName,
    required int age,
    required String username,
    required String email,
    required String password,
    required String location,
    required DateTime estimatedDueDate,
    String? emergencyContact,
    String? medicalConditions,
    String? allergies,
    String? currentMedications,
    String? previousPregnancies,
    String? familyMemberEmail,
  }) async {
    try {
      // Create Firebase Auth user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (credential.user != null) {
        // Update display name
        await credential.user!.updateDisplayName(fullName);

        // Create user data model
        final userData = UserModel(
          uid: credential.user!.uid,
          fullName: fullName,
          age: age,
          username: username,
          email: email.trim(),
          location: location,
          role: 'mother',
          estimatedDueDate: estimatedDueDate,
          emergencyContact: emergencyContact,
          medicalConditions: medicalConditions,
          allergies: allergies,
          currentMedications: currentMedications,
          previousPregnancies: previousPregnancies,
          familyMemberEmail: familyMemberEmail,
          createdAt: DateTime.now(),
          isActive: true,
        );

        // Save to Firestore
        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(userData.toMap());

        // Create separate mother profile collection for easier queries
        await _firestore
            .collection('mothers')
            .doc(credential.user!.uid)
            .set({
          'uid': credential.user!.uid,
          'fullName': fullName,
          'username': username,
          'email': email.trim(),
          'location': location,
          'estimatedDueDate': Timestamp.fromDate(estimatedDueDate),
          'emergencyContact': emergencyContact,
          'familyMemberEmail': familyMemberEmail,
          'createdAt': FieldValue.serverTimestamp(),
          'isActive': true,
        });

        return AuthResult(
          success: true,
          user: credential.user,
          userData: userData,
          message: 'Registration successful',
        );
      }

      return AuthResult(
        success: false,
        message: 'Registration failed',
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Registration failed';
      switch (e.code) {
        case 'weak-password':
          message = 'Password is too weak';
          break;
        case 'email-already-in-use':
          message = 'Email is already registered';
          break;
        case 'invalid-email':
          message = 'Invalid email address';
          break;
        default:
          message = e.message ?? 'Registration failed';
      }
      return AuthResult(success: false, message: message);
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  // Register Family Member
  static Future<AuthResult> registerFamilyMember({
    required String fullName,
    required String email,
    required String password,
    required String motherEmail,
    required String relationship,
    String? phoneNumber,
  }) async {
    try {
      // Create Firebase Auth user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (credential.user != null) {
        // Update display name
        await credential.user!.updateDisplayName(fullName);

        // Create user data model
        final userData = UserModel(
          uid: credential.user!.uid,
          fullName: fullName,
          email: email.trim(),
          role: 'family_member',
          motherEmail: motherEmail,
          relationship: relationship,
          phoneNumber: phoneNumber,
          createdAt: DateTime.now(),
          isActive: true,
        );

        // Save to Firestore
        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(userData.toMap());

        // Create separate family members collection
        await _firestore
            .collection('family_members')
            .doc(credential.user!.uid)
            .set({
          'uid': credential.user!.uid,
          'fullName': fullName,
          'email': email.trim(),
          'motherEmail': motherEmail,
          'relationship': relationship,
          'phoneNumber': phoneNumber,
          'createdAt': FieldValue.serverTimestamp(),
          'isActive': true,
        });

        return AuthResult(
          success: true,
          user: credential.user,
          userData: userData,
          message: 'Family member registration successful',
        );
      }

      return AuthResult(
        success: false,
        message: 'Registration failed',
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Registration failed';
      switch (e.code) {
        case 'weak-password':
          message = 'Password is too weak';
          break;
        case 'email-already-in-use':
          message = 'Email is already registered';
          break;
        case 'invalid-email':
          message = 'Invalid email address';
          break;
        default:
          message = e.message ?? 'Registration failed';
      }
      return AuthResult(success: false, message: message);
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  // Sign Out
  static Future<bool> signOut() async {
    try {
      await _auth.signOut();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Reset Password
  static Future<AuthResult> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return AuthResult(
        success: true,
        message: 'Password reset email sent',
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Failed to send reset email';
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found for that email';
          break;
        case 'invalid-email':
          message = 'Invalid email address';
          break;
        default:
          message = e.message ?? 'Failed to send reset email';
      }
      return AuthResult(success: false, message: message);
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  // Update user profile
  static Future<AuthResult> updateUserProfile({
    required String uid,
    Map<String, dynamic>? updates,
  }) async {
    try {
      if (updates != null && updates.isNotEmpty) {
        await _firestore
            .collection('users')
            .doc(uid)
            .update({
          ...updates,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        return AuthResult(
          success: true,
          message: 'Profile updated successfully',
        );
      }

      return AuthResult(
        success: false,
        message: 'No updates provided',
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Failed to update profile: ${e.toString()}',
      );
    }
  }

  // Get user data
  static Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get user data stream
  static Stream<UserModel?> getUserDataStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    });
  }
}

// Authentication result model
class AuthResult {
  final bool success;
  final String message;
  final User? user;
  final UserModel? userData;

  AuthResult({
    required this.success,
    required this.message,
    this.user,
    this.userData,
  });
}
