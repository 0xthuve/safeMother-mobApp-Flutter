import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/pregnancy_tracking.dart';
import 'session_manager.dart';
import 'firebase_service.dart';

class DebugBackendService {
  static final DebugBackendService _instance = DebugBackendService._internal();
  factory DebugBackendService() => _instance;
  DebugBackendService._internal();

  // Debug version of updatePatientPregnancyInfo
  Future<bool> updatePatientPregnancyInfo(String userId, {
    DateTime? expectedDeliveryDate,
    DateTime? pregnancyConfirmedDate,
    double? weight,
    bool? isFirstChild,
    bool? hasPregnancyLoss,
    String? medicalHistory,
  }) async {
    try {
      print('🚀 DEBUG: Starting updatePatientPregnancyInfo for user: $userId');
      
      // Step 1: Check if user exists in users collection
      print('📋 DEBUG: Step 1 - Checking user data in users collection...');
      final userData = await FirebaseService.getUserData(userId);
      print('📋 DEBUG: User data: $userData');
      
      if (userData == null) {
        print('❌ DEBUG: User data not found in users collection!');
        return false;
      }

      // Step 2: Check current role
      final currentRole = userData['role'];
      print('📋 DEBUG: Current user role: $currentRole');

      // Step 3: Update user role to patient if needed
      if (currentRole != 'patient') {
        print('📋 DEBUG: Step 2 - Updating user role to patient...');
        final roleUpdated = await FirebaseService.updateUserRole(userId, 'patient');
        if (!roleUpdated) {
          print('❌ DEBUG: Failed to update user role!');
          return false;
        }
        print('✅ DEBUG: User role updated to patient');
      }

      // Step 4: Create patient data
      print('📋 DEBUG: Step 3 - Creating patient data...');
      final patientData = {
        'uid': userId,
        'babyName': "",
        'bloodType': "",
        'expectedDeliveryDate': expectedDeliveryDate?.toIso8601String(),
        'pregnancyConfirmedDate': pregnancyConfirmedDate?.toIso8601String(),
        'weight': weight,
        'isFirstChild': isFirstChild ?? false,
        'hasPregnancyLoss': hasPregnancyLoss ?? false,
        'medicalHistory': medicalHistory ?? '',
        'pregnancyWeek': 0,
        'height': 0,
        'allergies': [],
        'appointments': [],
        'emergencyContacts': [],
        'medications': [],
        'profilePicture': "",
        'lastCheckup': null,
        'nextCheckup': null,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      // Remove null values
      final cleanPatientData = Map<String, dynamic>.from(patientData)
        ..removeWhere((key, value) => value == null);

      print('📋 DEBUG: Patient data to save: $cleanPatientData');

      // Step 5: Save to patients collection
      print('📋 DEBUG: Step 4 - Saving to patients collection...');
      final success = await FirebaseService.createRoleData(userId, 'patient', cleanPatientData);
      
      if (success) {
        print('✅ DEBUG: Patient data saved successfully!');
        
        // Step 6: Verify the data was saved
        print('📋 DEBUG: Step 5 - Verifying patient data...');
        await Future.delayed(const Duration(milliseconds: 1000));
        final savedPatientData = await FirebaseService.getRoleData(userId, 'patient');
        print('📋 DEBUG: Saved patient data: $savedPatientData');
        
        if (savedPatientData != null) {
          print('✅ DEBUG: Patient data verified successfully!');
          return true;
        } else {
          print('❌ DEBUG: Patient data verification failed!');
          return false;
        }
      } else {
        print('❌ DEBUG: Failed to save patient data!');
        return false;
      }
    } catch (e) {
      print('❌ DEBUG: Error in updatePatientPregnancyInfo: $e');
      print('❌ DEBUG: Stack trace: ${StackTrace.current}');
      return false;
    }
  }

  // Debug version to check user status
  Future<void> debugUserStatus(String userId) async {
    print('\n=== DEBUG USER STATUS ===');
    print('User ID: $userId');
    
    // Check session
    final sessionUserId = await SessionManager.getUserId();
    print('Session User ID: $sessionUserId');
    
    // Check Firebase auth
    final currentUser = FirebaseService.currentUser;
    print('Firebase Current User: ${currentUser?.uid}');
    
    // Check users collection
    final userData = await FirebaseService.getUserData(userId);
    print('Users Collection Data: $userData');
    
    // Check patients collection
    final patientData = await FirebaseService.getRoleData(userId, 'patient');
    print('Patients Collection Data: $patientData');
    
    print('=== END DEBUG ===\n');
  }
}