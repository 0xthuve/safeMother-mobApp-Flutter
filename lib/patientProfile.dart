import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'patientDashboard.dart';
import 'services/session_manager.dart';
import 'services/user_management_service.dart';
import 'services/backend_service.dart';
import 'models/doctor.dart';
import 'pages/edit_profile.dart';

import 'signin.dart';

void main() {
  runApp(const PatientProfile());
}

class PatientProfile extends StatelessWidget {
  const PatientProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Safe Mother',
      theme: ThemeData(
        fontFamily: 'Lexend',
        scaffoldBackgroundColor: const Color(0xFFF9F7F9),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFFE91E63), // Pink
          secondary: const Color(0xFF9C27B0), // Purple
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color(0xFF5A5A5A)),
        ),
      ),
      home: const ProfileScreen(),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = 'User';
  String _userEmail = '';
  String _userAge = '';
  String _userContact = '';
  String _userRole = 'Mother';
  bool _isLoading = true;
  List<Map<String, dynamic>> _assignedDoctors = [];


  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  // Helper method to show loading dialog
  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE91E63)),
          ),
        ),
      ),
    );
  }
  
  // Helper method to dismiss loading dialog safely
  void _dismissLoadingDialog() {
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }
  
  // Helper method to navigate to dashboard with success message
  void _navigateToDashboard(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFFE91E63),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      
      // Navigate to dashboard after a short delay
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
          );
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadAssignedDoctor();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Get user data from session and Firebase with timeout
      final userName = await SessionManager.getUserName();
      final userEmail = await SessionManager.getUserEmail();
      
      // Add timeout to prevent hanging
      final userData = await UserManagementService.getCurrentUserData()
          .timeout(const Duration(seconds: 10), onTimeout: () {
        return null;
      });

      if (mounted) {
        setState(() {
          _userName = userName ?? 'User';
          _userEmail = userEmail ?? '';
          
          // Extract additional profile data from Firebase
          if (userData != null) {
            _userAge = userData['age']?.toString() ?? '';
            _userContact = userData['phone'] ?? userData['contact'] ?? '';
            _userRole = userData['role'] ?? 'Mother';
          }
          
          _isLoading = false;
        });

        // Update text controllers
        _nameController.text = _userName;
        _ageController.text = _userAge;
        _contactController.text = _userContact;
        _emailController.text = _userEmail;
      }
    } catch (e) {

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadAssignedDoctor() async {
    try {
      final userId = await SessionManager.getUserId();
      if (userId != null) {
        // Get linked doctors and find all accepted ones
        final backendService = BackendService();
        final linkedDoctors = await backendService.getLinkedDoctorsForPatient(userId);
        
        // Find all accepted doctors (assigned doctors)
        final acceptedDoctors = linkedDoctors.where((doctor) => doctor['status'] == 'accepted').toList();
        
        if (mounted) {
          setState(() {
            _assignedDoctors = acceptedDoctors;
          });
        }
      }
    } catch (e) {

    }
  }

  Future<void> _saveUserData(String key, String value) async {
    try {
      // Update Firebase data
      Map<String, dynamic> updateData = {};
      
      switch (key) {
        case 'userName':
          updateData['fullName'] = value;
          break;
        case 'userAge':
          updateData['age'] = int.tryParse(value) ?? 0;
          break;
        case 'userContact':
          updateData['phone'] = value;
          updateData['contact'] = value;
          break;
        case 'userEmail':
          updateData['email'] = value;
          break;
      }

      final success = await UserManagementService.updateUserProfile(updateData);
      
      if (success) {
        // Also save to local preferences as backup
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(key, value);
        
        // Update the local state variables immediately instead of reloading everything
        setState(() {
          switch (key) {
            case 'userName':
              _userName = value;
              break;
            case 'userAge':
              _userAge = value;
              break;
            case 'userContact':
              _userContact = value;
              break;
            case 'userEmail':
              _userEmail = value;
              break;
          }
        });
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {

      rethrow; // Re-throw the error so it can be handled in the UI
    }
  }

  void _showEditPopup(String field, String currentValue, TextEditingController controller) {
    controller.text = currentValue;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit $field',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111611),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: 'Enter your $field',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF638763),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        if (controller.text.isNotEmpty) {
                          Navigator.of(context).pop(); // Close edit dialog first
                          
                          // Show loading indicator
                          _showLoadingDialog();

                          try {
                            String key = '';
                            if (field == 'Name') {
                              key = 'userName';
                            } else if (field == 'Age') {
                              key = 'userAge';
                            } else if (field == 'Contact') {
                              key = 'userContact';
                            } else if (field == 'Email') {
                              key = 'userEmail';
                            }

                            await _saveUserData(key, controller.text);
                            
                            // Dismiss loading dialog
                            _dismissLoadingDialog();
                            
                            // Navigate to dashboard with success message
                            _navigateToDashboard('$field updated successfully!');
                          } catch (e) {
                            // Dismiss loading dialog even on error
                            _dismissLoadingDialog();
                            
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to update $field: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE91E63),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showChangePasswordPopup() {
    _passwordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Change Password',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111611),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Current Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'New Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Confirm New Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF638763),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (_passwordController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter current password'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        
                        if (_newPasswordController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter new password'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        
                        if (_newPasswordController.text != _confirmPasswordController.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('New passwords do not match'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        
                        Navigator.of(context).pop();
                        
                        // Navigate to dashboard after password change
                        _navigateToDashboard('Password changed successfully!');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE91E63),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Change Password',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showNotificationPreferencesPopup() {
    bool emailNotifications = true;
    bool pushNotifications = true;
    bool smsNotifications = false;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Notification Preferences',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111611),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Email Notifications'),
                      value: emailNotifications,
                      onChanged: (value) {
                        setState(() {
                          emailNotifications = value;
                        });
                      },
                      activeThumbColor: const Color(0xFFE91E63),
                    ),
                    SwitchListTile(
                      title: const Text('Push Notifications'),
                      value: pushNotifications,
                      onChanged: (value) {
                        setState(() {
                          pushNotifications = value;
                        });
                      },
                      activeThumbColor: const Color(0xFFE91E63),
                    ),
                    SwitchListTile(
                      title: const Text('SMS Notifications'),
                      value: smsNotifications,
                      onChanged: (value) {
                        setState(() {
                          smsNotifications = value;
                        });
                      },
                      activeThumbColor: const Color(0xFFE91E63),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Color(0xFF638763),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            
                            // Navigate to dashboard after saving preferences
                            _navigateToDashboard('Notification preferences saved!');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE91E63),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Save',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showLinkedMembersPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Linked Family Members',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111611),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No family members linked yet.',
                  style: TextStyle(
                    color: Color(0xFF638763),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Add functionality to link family members
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E63),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Add Family Member',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        color: Color(0xFF638763),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLinkedDoctorsPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _DoctorSelectionDialog();
      },
    );
  }

void _showPrivacySettingsPopup() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Safe Mother Privacy',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111611),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Your privacy and safety are our top priority. '
                'We ensure that your personal and medical information '
                'is securely protected and never shared without your consent. '
                'Safe Mother safeguards your details to provide you with '
                'confidential and trusted care.',
                style: TextStyle(
                  color: Color(0xFF638763),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      color: Color(0xFF638763),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}


  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout,
                    color: Colors.red,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Sign Out',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111611),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Are you sure you want to sign out of your account?',
                  style: TextStyle(
                    color: Color(0xFF638763),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Color(0xFF638763)),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Color(0xFF638763),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await _performSignOut();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Sign Out',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _performSignOut() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Clear session data
      await SessionManager.clearSession();

      // Small delay for UX
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        // Remove loading indicator
        Navigator.of(context).pop();

        // Navigate to sign in screen and clear navigation stack
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const SignInScreen()),
          (route) => false,
        );

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Successfully signed out'),
            backgroundColor: const Color(0xFFE91E63),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Remove loading indicator
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign out failed: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5E8FF), Color(0xFFF9F7F9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                  top: 16,
                  left: 16,
                  right: 16,
                  bottom: 8,
                ),
                decoration: BoxDecoration(color: Colors.white),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Color(0xFF111611)),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomeScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(left: 48),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 262,
                              child: Text(
                                'Profile',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF111611),
                                  fontSize: 18,
                                  fontFamily: 'Lexend',
                                  fontWeight: FontWeight.w700,
                                  height: 1.28,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Profile Section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 128,
                              height: 128,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF4EF),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person,
                                size: 64,
                                color: Color(0xFF638763),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _isLoading
                                ? const SizedBox(
                                    width: 100,
                                    height: 20,
                                    child: LinearProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE91E63)),
                                    ),
                                  )
                                : Text(
                                    _userName,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Color(0xFF111611),
                                      fontSize: 22,
                                      fontFamily: 'Lexend',
                                      fontWeight: FontWeight.w700,
                                      height: 1.27,
                                    ),
                                  ),
                            const SizedBox(height: 4),
                            _isLoading
                                ? const SizedBox(
                                    width: 60,
                                    height: 16,
                                    child: LinearProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF638763)),
                                    ),
                                  )
                                : Text(
                                    _userRole,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Color(0xFF638763),
                                      fontSize: 16,
                                      fontFamily: 'Lexend',
                                      fontWeight: FontWeight.w400,
                                      height: 1.50,
                                    ),
                                  ),
                          ],
                        ),
                      ),
                      
                      // Personal Information Section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(
                          top: 16,
                          left: 16,
                          right: 16,
                          bottom: 8,
                        ),
                        child: const Text(
                          'Personal Information',
                          style: TextStyle(
                            color: Color(0xFF111611),
                            fontSize: 18,
                            fontFamily: 'Lexend',
                            fontWeight: FontWeight.w700,
                            height: 1.28,
                          ),
                        ),
                      ),
                      
                      _isLoading
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE91E63)),
                                ),
                              ),
                            )
                          : Column(
                              children: [
                                _buildInfoRow('Name', _userName, () {
                                  _showEditPopup('Name', _userName, _nameController);
                                }),
                                
                                _buildInfoRow('Email', _userEmail, () {
                                  _showEditPopup('Email', _userEmail, _emailController);
                                }),
                                
                                _buildInfoRow('Age', _userAge.isEmpty ? 'Not set' : _userAge, () {
                                  _showEditPopup('Age', _userAge, _ageController);
                                }),
                                
                                _buildInfoRow('Contact', _userContact.isEmpty ? 'Not set' : _userContact, () {
                                  _showEditPopup('Contact', _userContact, _contactController);
                                }),
                              ],
                            ),
                      
                      // Edit Profile Button
                      if (!_isLoading)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const EditProfilePage(),
                                ),
                              );
                              
                              // If profile was updated, navigate to dashboard
                              if (result == true) {
                                _navigateToDashboard('Profile updated successfully!');
                              }
                            },
                            icon: const Icon(Icons.edit, size: 20),
                            label: const Text(
                              'Edit Profile',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE91E63),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),
                      
                      // Account Settings Section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(
                          top: 16,
                          left: 16,
                          right: 16,
                          bottom: 8,
                        ),
                        child: const Text(
                          'Account Settings',
                          style: TextStyle(
                            color: Color(0xFF111611),
                            fontSize: 18,
                            fontFamily: 'Lexend',
                            fontWeight: FontWeight.w700,
                            height: 1.28,
                          ),
                        ),
                      ),
                      
                      _buildSettingRow('Change Password', _showChangePasswordPopup),
                      _buildSettingRow('Notification Preferences', _showNotificationPreferencesPopup),
                      
                      // Assigned Doctor Section - Always show
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(
                          top: 16,
                          left: 16,
                          right: 16,
                          bottom: 8,
                        ),
                        child: const Text(
                          'My Doctors',
                          style: TextStyle(
                            color: Color(0xFF111611),
                            fontSize: 18,
                            fontFamily: 'Lexend',
                            fontWeight: FontWeight.w700,
                            height: 1.28,
                          ),
                        ),
                      ),
                      _buildAssignedDoctorCard(),
                      
                      // Family & Doctors Section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(
                          top: 16,
                          left: 16,
                          right: 16,
                          bottom: 8,
                        ),
                        child: const Text(
                          'Family & Doctors',
                          style: TextStyle(
                            color: Color(0xFF111611),
                            fontSize: 18,
                            fontFamily: 'Lexend',
                            fontWeight: FontWeight.w700,
                            height: 1.28,
                          ),
                        ),
                      ),
                      
                      _buildSettingRow('Linked Family Members', _showLinkedMembersPopup),
                      _buildSettingRow('Linked Doctors', _showLinkedDoctorsPopup),
                      
                      // Privacy & Sharing Section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(
                          top: 16,
                          left: 16,
                          right: 16,
                          bottom: 8,
                        ),
                        child: const Text(
                          'Privacy & Sharing',
                          style: TextStyle(
                            color: Color(0xFF111611),
                            fontSize: 18,
                            fontFamily: 'Lexend',
                            fontWeight: FontWeight.w700,
                            height: 1.28,
                          ),
                        ),
                      ),
                      
                      _buildSettingRow('Privacy Settings', _showPrivacySettingsPopup),
                      
                      const SizedBox(height: 16),
                      
                      // Sign Out Section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(
                          top: 16,
                          left: 16,
                          right: 16,
                          bottom: 8,
                        ),
                        child: const Text(
                          'Account',
                          style: TextStyle(
                            color: Color(0xFF111611),
                            fontSize: 18,
                            fontFamily: 'Lexend',
                            fontWeight: FontWeight.w700,
                            height: 1.28,
                          ),
                        ),
                      ),
                      
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(color: Colors.white),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.logout,
                              color: Colors.red,
                              size: 20,
                            ),
                          ),
                          title: const Text(
                            'Sign Out',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontFamily: 'Lexend',
                              fontWeight: FontWeight.w500,
                              height: 1.50,
                            ),
                          ),
                          subtitle: const Text(
                            'Sign out of your account',
                            style: TextStyle(
                              color: Color(0xFF999999),
                              fontSize: 12,
                              fontFamily: 'Lexend',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          trailing: const Icon(Icons.chevron_right, color: Colors.red),
                          onTap: _showSignOutDialog,
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value, VoidCallback onTap) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Colors.white),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF111611),
                  fontSize: 16,
                  fontFamily: 'Lexend',
                  fontWeight: FontWeight.w500,
                  height: 1.50,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF638763),
                  fontSize: 14,
                  fontFamily: 'Lexend',
                  fontWeight: FontWeight.w400,
                  height: 1.50,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: onTap,
            icon: const Icon(Icons.edit, color: Color(0xFF638763)),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingRow(String title, VoidCallback onTap) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: Colors.white),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF111611),
            fontSize: 16,
            fontFamily: 'Lexend',
            fontWeight: FontWeight.w400,
            height: 1.50,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFF638763)),
        onTap: onTap,
      ),
    );
  }

  Widget _buildQuickActionButton(String title, IconData icon, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE91E63),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildAssignedDoctorCard() {
    // Always show the section, even when no doctors are assigned
    if (_assignedDoctors.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE91E63).withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.medical_services_outlined,
              size: 48,
              color: const Color(0xFFE91E63).withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            const Text(
              'No Doctors Assigned',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF5A5A5A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Visit "My Doctors" to connect with healthcare providers',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF5A5A5A),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    // Show all assigned doctors
    return Column(
      children: _assignedDoctors.map((doctor) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF4CAF50).withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Doctor Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Center(
                    child: Text(
                      (doctor['doctorName'] ?? 'Dr')
                          .split(' ')
                          .map((n) => n.isNotEmpty ? n[0] : '')
                          .take(2)
                          .join()
                          .toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF4CAF50),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Doctor Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dr. ${doctor['doctorName'] ?? 'Unknown Doctor'}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111611),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        doctor['specialization'] ?? 'General Practice',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                      Text(
                        doctor['hospital'] ?? 'Unknown Hospital',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF5A5A5A),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'ACTIVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Doctor Details
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  if (doctor['yearsExperience'] != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.work, size: 16, color: Color(0xFF5A5A5A)),
                        const SizedBox(width: 8),
                        Text(
                          '${doctor['yearsExperience']} years experience',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF5A5A5A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                  ],
                  Row(
                    children: [
                      const Icon(Icons.email, size: 16, color: Color(0xFF5A5A5A)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          doctor['doctorEmail'] ?? 'Contact via app',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF5A5A5A),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 16, color: Color(0xFF5A5A5A)),
                      const SizedBox(width: 8),
                      Text(
                        doctor['doctorPhone'] ?? 'Contact via app',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF5A5A5A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }
}


// Doctor Selection Dialog Widget
class _DoctorSelectionDialog extends StatefulWidget {
  @override
  State<_DoctorSelectionDialog> createState() => _DoctorSelectionDialogState();
}

class _DoctorSelectionDialogState extends State<_DoctorSelectionDialog> {
  final BackendService _backendService = BackendService();
  List<Doctor> _doctors = [];
  Doctor? _selectedDoctor;
  Doctor? _currentLinkedDoctor;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
    _loadCurrentLinkedDoctor();
  }

  Future<void> _loadDoctors() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });


      
      // Get real doctors from Firebase database who registered through doctor signup portal
      final doctors = await _backendService.getAllDoctors();
      

      
      if (doctors.isEmpty) {
        setState(() {
          _errorMessage = 'No healthcare professionals found in the database.\n\nMake sure doctors have registered through the signup portal with:\n• Account Type: Healthcare\n• Role: Doctor';
          _isLoading = false;
        });
      } else {
        setState(() {
          _doctors = doctors;
          _isLoading = false;
        });
      }
    } catch (e) {

      setState(() {
        _errorMessage = 'Failed to load healthcare professionals from database.\n\nError: ${e.toString()}\n\nThis could be due to:\n• Firebase permission issues\n• Network connectivity problems\n• No doctors registered yet\n\nPlease ensure doctors have signed up through the doctor portal.';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCurrentLinkedDoctor() async {
    try {
      final userId = await SessionManager.getUserId();
      if (userId != null) {
        final linkedDoctors = await _backendService.getLinkedDoctors(userId);
        if (linkedDoctors.isNotEmpty) {
          final activeLink = linkedDoctors.firstWhere(
            (link) => link.isActive,
            orElse: () => linkedDoctors.first,
          );
          
          // Find the doctor from our sample doctors (convert string ID to int)
          final doctorId = int.tryParse(activeLink.doctorId) ?? 0;
          final doctor = _doctors.firstWhere(
            (doc) => doc.id == doctorId,
            orElse: () => _doctors.isNotEmpty ? _doctors.first : Doctor(
              id: doctorId,
              name: 'Unknown Doctor',
              email: '',
              phone: '',
              specialization: 'Unknown',
              licenseNumber: '',
              hospital: 'Unknown',
              experience: '0 years',
              bio: 'No information available',
              profileImage: '',
              rating: 0.0,
              totalPatients: 0,
              isAvailable: true,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );
          
          setState(() {
            _currentLinkedDoctor = doctor;
            _selectedDoctor = doctor;
          });
        }
      }
    } catch (e) {

    }
  }

  Future<void> _linkWithDoctor() async {
    if (_selectedDoctor == null) return;

    try {
      final userId = await SessionManager.getUserId();
      if (userId == null) return;

      // First unlink any current doctor
      if (_currentLinkedDoctor != null) {
        await _backendService.unlinkPatientFromDoctor(userId, _currentLinkedDoctor!.id?.toString() ?? '0');
      }

      // Link with selected doctor
      final success = await _backendService.linkPatientWithDoctor(userId, _selectedDoctor!.firebaseUid ?? _selectedDoctor!.id?.toString() ?? '0');
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Request sent to ${_selectedDoctor!.name}. Waiting for approval.'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send request to doctor'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Select Your Doctor',
        style: TextStyle(
          color: Color(0xFF7B1FA2),
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_currentLinkedDoctor != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E8),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF4CAF50)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Currently Linked:',
                      style: TextStyle(
                        color: Color(0xFF4CAF50),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currentLinkedDoctor!.name,
                      style: const TextStyle(
                        color: Color(0xFF2E7D32),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _currentLinkedDoctor!.specialization,
                      style: const TextStyle(
                        color: Color(0xFF4CAF50),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Select a new doctor to change your current selection:',
                style: TextStyle(
                  color: Color(0xFF5A5A5A),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
            ] else ...[
              const Text(
                'Select a doctor to guide your pregnancy journey:',
                style: TextStyle(
                  color: Color(0xFF5A5A5A),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
            ],
            
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7B1FA2)),
                      ),
                    )
                  : _errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.red),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadDoctors,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : _doctors.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.local_hospital,
                                    color: Colors.grey,
                                    size: 48,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'No doctors available',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: _doctors.length,
                              itemBuilder: (context, index) {
                                final doctor = _doctors[index];
                                final isSelected = _selectedDoctor?.id == doctor.id;
                                
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: isSelected 
                                          ? const Color(0xFF7B1FA2)
                                          : Colors.grey.shade300,
                                      width: isSelected ? 2 : 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    color: isSelected 
                                        ? const Color(0xFF7B1FA2).withOpacity(0.1)
                                        : Colors.white,
                                  ),
                                  child: ListTile(
                                    onTap: () {
                                      setState(() {
                                        _selectedDoctor = doctor;
                                      });
                                    },
                                    leading: CircleAvatar(
                                      backgroundColor: const Color(0xFF7B1FA2),
                                      child: Text(
                                        doctor.name.split(' ').map((n) => n[0]).take(2).join(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      doctor.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: isSelected 
                                            ? const Color(0xFF7B1FA2)
                                            : Colors.black87,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          doctor.specialization,
                                          style: const TextStyle(
                                            color: Color(0xFF7B1FA2),
                                            fontSize: 13,
                                          ),
                                        ),
                                        Text(
                                          doctor.hospital,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                        if (doctor.experience.isNotEmpty)
                                          Text(
                                            doctor.experience,
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 11,
                                            ),
                                          ),
                                      ],
                                    ),
                                    trailing: isSelected
                                        ? const Icon(
                                            Icons.check_circle,
                                            color: Color(0xFF7B1FA2),
                                          )
                                        : const Icon(
                                            Icons.radio_button_unchecked,
                                            color: Colors.grey,
                                          ),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        ElevatedButton(
          onPressed: _selectedDoctor != null ? _linkWithDoctor : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7B1FA2),
            foregroundColor: Colors.white,
          ),
          child: Text(
            _currentLinkedDoctor != null ? 'Send New Request' : 'Send Request',
          ),
        ),
      ],
    );
  }
}
