import 'package:flutter/material.dart';

class FirebaseMockService {
  static bool _isInitialized = false;
  static Map<String, dynamic> _mockUsers = {};
  static Map<String, dynamic> _currentUser = {};
  static bool _isLoggedIn = false;

  // Mock user data storage
  static const String _demoUserId = 'demo_user_123';
  static const String _demoEmail = 'demo@safemother.com';
  static const String _demoPassword = 'demo123';
  static const String _demoName = 'Demo User';

  // Initialize mock Firebase
  static Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _isInitialized = true;
    
    // Add demo user
    _mockUsers[_demoEmail] = {
      'uid': _demoUserId,
      'email': _demoEmail,
      'password': _demoPassword,
      'fullName': _demoName,
      'role': 'patient',
      'createdAt': DateTime.now().toIso8601String(),
      'username': 'demouser',
      'age': 28,
      'location': 'Colombo, Sri Lanka',
      'estimatedDueDate': '15/12/2024',
      'signUpStep': 2,
    };

    print('Firebase Mock Service initialized');
  }

  // Check if initialized
  static bool get isInitialized => _isInitialized;

  // Check if user is logged in
  static bool get isLoggedIn => _isLoggedIn;

  // Get current user
  static Map<String, dynamic>? get currentUser => _isLoggedIn ? _currentUser : null;

  // Mock login
  static Future<Map<String, dynamic>?> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // Check demo credentials
    if (email.toLowerCase() == _demoEmail && password == _demoPassword) {
      _currentUser = Map<String, dynamic>.from(_mockUsers[_demoEmail]!);
      _isLoggedIn = true;
      return _currentUser;
    }
    
    // Check if user exists in mock storage
    if (_mockUsers.containsKey(email.toLowerCase())) {
      final user = _mockUsers[email.toLowerCase()]!;
      if (user['password'] == password) {
        _currentUser = Map<String, dynamic>.from(user);
        _isLoggedIn = true;
        return _currentUser;
      } else {
        throw Exception('Wrong password provided');
      }
    } else {
      throw Exception('No user found for this email');
    }
  }

  // Mock registration
  static Future<Map<String, dynamic>?> registerWithEmailPassword({
    required String email,
    required String password,
    required String fullName,
    required String role,
    Map<String, dynamic>? additionalData,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    
    final emailLower = email.toLowerCase();
    
    // Check if user already exists
    if (_mockUsers.containsKey(emailLower)) {
      throw Exception('An account already exists for this email');
    }

    // Create new user
    final newUserId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    final newUser = {
      'uid': newUserId,
      'email': emailLower,
      'password': password,
      'fullName': fullName,
      'role': role,
      'createdAt': DateTime.now().toIso8601String(),
      'lastLoginAt': DateTime.now().toIso8601String(),
      'profileComplete': false,
      ...?additionalData,
    };

    _mockUsers[emailLower] = newUser;
    _currentUser = Map<String, dynamic>.from(newUser);
    _isLoggedIn = true;

    return _currentUser;
  }

  // Mock Google Sign In
  static Future<Map<String, dynamic>?> signInWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 2000));
    
    // Simulate Google sign-in
    final googleUser = {
      'uid': 'google_${DateTime.now().millisecondsSinceEpoch}',
      'email': 'google.user@gmail.com',
      'fullName': 'Google User',  
      'role': 'patient',
      'createdAt': DateTime.now().toIso8601String(),
      'lastLoginAt': DateTime.now().toIso8601String(),
      'profileComplete': false,
      'signInMethod': 'google',
    };
    
    _currentUser = googleUser;
    _isLoggedIn = true;
    _mockUsers[googleUser['email'] as String] = googleUser;
    
    return _currentUser;
  }

  // Mock sign out
  static Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = {};
    _isLoggedIn = false;
  }

  // Mock reset password
  static Future<void> resetPassword(String email) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    
    if (!_mockUsers.containsKey(email.toLowerCase())) {
      throw Exception('No user found for this email');
    }
    
    // In a real implementation, this would send an email
    print('Password reset email sent to $email');
  }

  // Get email by username
  static Future<String?> getEmailByUsername(String username) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    for (var user in _mockUsers.values) {
      if (user['username'] == username) {
        return user['email'] as String?;
      }
    }
    return null;
  }

  // Mock get user data
  static Future<Map<String, dynamic>?> getUserData(String uid) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    for (var user in _mockUsers.values) {
      if (user['uid'] == uid) {
        return Map<String, dynamic>.from(user);
      }
    }
    return null;
  }

  // Mock update user data
  static Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    for (var email in _mockUsers.keys) {
      if (_mockUsers[email]!['uid'] == uid) {
        _mockUsers[email]!.addAll(data);
        if (_currentUser['uid'] == uid) {
          _currentUser.addAll(data);
        }
        break;
      }
    }
  }

  // Mock check if email is registered
  static Future<bool> isEmailRegistered(String email) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockUsers.containsKey(email.toLowerCase());
  }

  // Mock create role data
  static Future<void> createRoleData(String uid, String role, Map<String, dynamic> roleData) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // In a real implementation, this would create a separate document
    print('Role data created for $uid with role $role');
  }

  // Mock get role data
  static Future<Map<String, dynamic>?> getRoleData(String uid, String role) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Return default role data based on role
    switch (role.toLowerCase()) {
      case 'patient':
      case 'mother':
        return {
          'pregnancyWeek': 24,
          'babyName': 'Little One',
          'emergencyContacts': [],
          'medicalHistory': [],
          'appointments': [],
          'profilePicture': '',
        };
      case 'doctor':
      case 'healthcare':
        return {
          'specialization': 'Obstetrics',
          'licenseNumber': 'MD123456',
          'hospital': 'Demo Hospital',
          'patients': [],
        };
      default:
        return {};
    }
  }

  // Mock delete account
  static Future<void> deleteAccount() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    
    if (_isLoggedIn && _currentUser.isNotEmpty) {
      final email = _currentUser['email'];
      _mockUsers.remove(email);
      _currentUser = {};
      _isLoggedIn = false;
    }
  }

  // Get all mock users (for debugging)
  static Map<String, dynamic> getAllUsers() {
    return Map<String, dynamic>.from(_mockUsers);
  }

  // Show demo instructions
  static void showDemoInstructions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Demo Mode',
            style: TextStyle(
              color: Color(0xFF7B1FA2),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'You\'re using the app in demo mode. Use these credentials:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Demo Credentials:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7B1FA2),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('Email: demo@safemother.com'),
                    Text('Password: demo123'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Or create a new account - all data will be stored locally.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF9575CD),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Got it!',
                style: TextStyle(
                  color: Color(0xFFE91E63),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}