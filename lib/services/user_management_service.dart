import 'package:flutter/material.dart';
import 'firebase_service.dart';
import 'session_manager.dart';

class UserManagementService {
  // Sign in and create session
  static Future<bool> signInUser(String email, String password, BuildContext context) async {
    try {
      final loginResult = await FirebaseService.loginWithEmailPassword(
        email: email,
        password: password,
      );

      if (loginResult != null) {
        final uid = loginResult['uid'] as String?;
        
        if (uid != null) {
          // Get user data from Firestore
          final userData = await FirebaseService.getUserData(uid);
          
          if (userData != null) {
            final userRole = userData['role'] as String?;
            final userName = userData['fullName'] as String? ?? loginResult['displayName'] as String? ?? 'User';
            
            // Save login session
            await SessionManager.saveLoginSession(
              userType: userRole == 'doctor' || userRole == 'healthcare' 
                  ? SessionManager.userTypeDoctor 
                  : SessionManager.userTypePatient,
              userId: uid,
              userName: userName,
              userEmail: loginResult['email'] as String? ?? '',
            );

            return true;
          }
        }
      }
      return false;
    } catch (e) {

      return false;
    }
  }

  // Register user and create session
  static Future<bool> registerUser({
    required String email,
    required String password,
    required String fullName,
    required String role,
    Map<String, dynamic>? additionalData,
    BuildContext? context,
  }) async {
    try {

      
      // Check if email is already registered
      final isEmailTaken = await FirebaseService.isEmailRegistered(email);
      if (isEmailTaken) {
        throw Exception('An account already exists for this email.');
      }
      
      final registrationResult = await FirebaseService.registerWithEmailPassword(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
        additionalData: additionalData,
      );

      if (registrationResult != null) {
        final uid = registrationResult['uid'] as String?;
        
        if (uid != null) {

          
          // Try to create role-specific data, but don't fail registration if this fails
          try {
            await FirebaseService.createRoleData(
              uid,
              role,
              _getDefaultRoleData(role),
            );

          } catch (roleDataError) {

            // Don't fail the registration - this can be created later
          }

          // Save login session
          try {
            await SessionManager.saveLoginSession(
              userType: role == 'doctor' || role == 'healthcare' 
                  ? SessionManager.userTypeDoctor 
                  : SessionManager.userTypePatient,
              userId: uid,
              userName: fullName,
              userEmail: registrationResult['email'] as String? ?? '',
            );

          } catch (sessionError) {

          }


          return true;
        }
      }

      return false;
    } catch (e) {

      // Check if the error is about existing account
      if (e.toString().contains('email-already-in-use') || 
          e.toString().contains('account already exists')) {
        throw Exception('An account already exists for this email.');
      }
      return false;
    }
  }

  // Sign out and clear session
  static Future<void> signOutUser() async {
    try {
      await FirebaseService.signOut();
      await SessionManager.clearSession();
    } catch (e) {

    }
  }

  // Get current user data
  static Future<Map<String, dynamic>?> getCurrentUserData() async {
    try {
      final currentUserData = FirebaseService.currentUserData;
      if (currentUserData != null) {
        final uid = currentUserData['uid'] as String?;
        if (uid != null) {
          return await FirebaseService.getUserData(uid);
        }
      }
      return null;
    } catch (e) {

      return null;
    }
  }

  // Update user profile
  static Future<bool> updateUserProfile(Map<String, dynamic> data) async {
    try {
      final currentUserData = FirebaseService.currentUserData;
      if (currentUserData != null) {
        final uid = currentUserData['uid'] as String?;
        if (uid != null) {
          await FirebaseService.updateUserData(uid, {
            ...data,
            'updatedAt': DateTime.now().toIso8601String(),
          });

          // Update session if name changed
          if (data['fullName'] != null) {
            final currentSession = await SessionManager.getUserName();
            if (currentSession != data['fullName']) {
              final userId = await SessionManager.getUserId();
              final userEmail = await SessionManager.getUserEmail();
              final userType = await SessionManager.getUserType();
              
              if (userId != null && userEmail != null && userType != null) {
                await SessionManager.saveLoginSession(
                  userType: userType,
                  userId: userId,
                  userName: data['fullName'],
                  userEmail: userEmail,
                );
              }
            }
          }

          return true;
        }
      }
      return false;
    } catch (e) {

      return false;
    }
  }

  // Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    return FirebaseService.isLoggedIn && await SessionManager.isSessionValid();
  }

  // Get user role
  static Future<String?> getUserRole() async {
    try {
      final userData = await getCurrentUserData();
      return userData?['role'] as String?;
    } catch (e) {

      return null;
    }
  }

  // Delete user account
  static Future<bool> deleteUserAccount() async {
    try {
      await FirebaseService.deleteAccount();
      await SessionManager.clearSession();
      return true;
    } catch (e) {

      return false;
    }
  }

  // Reset password
  static Future<bool> resetPassword(String email) async {
    try {
      await FirebaseService.resetPassword(email);
      return true;
    } catch (e) {

      return false;
    }
  }

  // Get email by username
  static Future<String?> getEmailByUsername(String username) async {
    try {
      return await FirebaseService.getEmailByUsername(username);
    } catch (e) {

      return null;
    }
  }

  // Google Sign In with profile completion handling
  static Future<Map<String, dynamic>?> signInWithGoogle(BuildContext context) async {
    try {
      final googleResult = await FirebaseService.signInWithGoogle();

      if (googleResult != null) {
        final uid = googleResult['uid'] as String?;
        final isNewUser = googleResult['isNewUser'] as bool? ?? false;
        final needsPregnancyInfo = googleResult['needsPregnancyInfo'] as bool? ?? false;
        
        if (uid != null) {
          final userData = await FirebaseService.getUserData(uid);
          
          if (userData != null) {
            final userRole = userData['role'] as String?;
            final userName = userData['fullName'] as String? ?? googleResult['displayName'] as String? ?? 'User';
            
            await SessionManager.saveLoginSession(
              userType: userRole == 'doctor' || userRole == 'healthcare' 
                  ? SessionManager.userTypeDoctor 
                  : SessionManager.userTypePatient,
              userId: uid,
              userName: userName,
              userEmail: googleResult['email'] as String? ?? '',
            );

            return {
              'success': true,
              'isNewUser': isNewUser,
              'needsPregnancyInfo': needsPregnancyInfo,
              'userRole': userRole,
              'userName': userName,
            };
          }
        }
      }
      return {'success': false};
    } catch (e) {

      return {'success': false, 'error': e.toString()};
    }
  }

  // Helper method to get default role data
  static Map<String, dynamic> _getDefaultRoleData(String role) {
    switch (role.toLowerCase()) {
      case 'patient':
      case 'mother':
        return {
          'pregnancyWeek': 0,
          'babyName': '',
          'emergencyContacts': [],
          'medicalHistory': [],
          'appointments': [],
          'profilePicture': '',
          'weight': 0.0,
          'height': 0.0,
          'bloodType': '',
          'allergies': [],
          'medications': [],
          'lastCheckup': null,
          'nextCheckup': null,
        };
      case 'doctor':
      case 'healthcare':
        return {
          'specialization': '',
          'licenseNumber': '',
          'hospital': '',
          'patients': [],
          'qualifications': [],
          'experience': 0,
          'consultationFee': 0.0,
          'availability': {},
          'rating': 0.0,
          'reviewCount': 0,
        };
      case 'family':
        return {
          'relationship': '',
          'linkedPatients': [],
          'emergencyContact': true,
          'permissions': [],
        };
      default:
        return {};
    }
  }

  // Sync session with Firebase auth state
  static Future<void> syncAuthState() async {
    try {
      if (FirebaseService.isLoggedIn) {
        final currentUserData = FirebaseService.currentUserData;
        if (currentUserData != null) {
          final uid = currentUserData['uid'] as String?;
          if (uid != null) {
            final userData = await FirebaseService.getUserData(uid);
            
            if (userData != null) {
              final userRole = userData['role'] as String?;
              final userName = userData['fullName'] as String? ?? currentUserData['displayName'] as String? ?? 'User';
              
              await SessionManager.saveLoginSession(
                userType: userRole == 'doctor' || userRole == 'healthcare' 
                    ? SessionManager.userTypeDoctor 
                    : SessionManager.userTypePatient,
                userId: uid,
                userName: userName,
                userEmail: currentUserData['email'] as String? ?? '',
              );
            }
          }
        }
      } else {
        await SessionManager.clearSession();
      }
    } catch (e) {

    }
  }
}
