import 'package:flutter/material.dart';
import 'patient_dashboard.dart';
import 'services/session_manager.dart';
import 'services/user_management_service.dart';
import 'services/backend_service.dart';
import 'models/doctor.dart';
import 'pages/edit_profile.dart';
import 'package:flutter/services.dart';

import 'signin.dart';
import 'l10n/app_localizations.dart';
import 'main.dart';

void main() {
  runApp(const PatientProfile());
}

class PatientProfile extends StatelessWidget {
  const PatientProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Safe Mother',
      debugShowCheckedModeBanner: false,
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
  String _userId = '';
  bool _isLoading = true;
  List<Map<String, dynamic>> _assignedDoctors = [];
  
  // Pregnancy information
  DateTime? _expectedDeliveryDate;
  DateTime? _pregnancyConfirmedDate;
  double? _weight;
  bool? _isFirstChild;
  bool? _hasPregnancyLoss;
  String? _medicalHistory;

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
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
      final userId = await SessionManager.getUserId();
      
      // Add timeout to prevent hanging
      final userData = await UserManagementService.getCurrentUserData()
          .timeout(const Duration(seconds: 10), onTimeout: () {
        return null;
      });

      // Load pregnancy information from Firebase patient collection
      final pregnancyData = await BackendService().getPatientPregnancyInfo(userId ?? '');

      if (mounted) {
        setState(() {
          _userName = userName ?? 'User';
          _userEmail = userEmail ?? '';
          _userId = userId ?? '';
          
          // Extract additional profile data from Firebase
          if (userData != null) {
            _userAge = userData['age']?.toString() ?? '';
            _userContact = userData['phone'] ?? userData['contact'] ?? '';
            _userRole = userData['role'] ?? 'Mother';
          }

          // Extract pregnancy data from Firebase
          if (pregnancyData != null) {
            _expectedDeliveryDate = pregnancyData['expectedDeliveryDate'] != null 
                ? DateTime.tryParse(pregnancyData['expectedDeliveryDate']) 
                : null;
            _pregnancyConfirmedDate = pregnancyData['pregnancyConfirmedDate'] != null 
                ? DateTime.tryParse(pregnancyData['pregnancyConfirmedDate']) 
                : null;
            _weight = pregnancyData['weight']?.toDouble();
            _isFirstChild = pregnancyData['isFirstChild'];
            _hasPregnancyLoss = pregnancyData['hasPregnancyLoss'];
            _medicalHistory = pregnancyData['medicalHistory'];
          }
          
          _isLoading = false;
        });


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
                Text(
                  AppLocalizations.of(context)?.changePasswordTitle ?? 'Change Password',
                  style: const TextStyle(
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
                    hintText: AppLocalizations.of(context)?.currentPassword ?? 'Current Password',
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
                    hintText: AppLocalizations.of(context)?.newPassword ?? 'New Password',
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
                    hintText: AppLocalizations.of(context)?.confirmNewPassword ?? 'Confirm New Password',
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
                      child: Text(
                        AppLocalizations.of(context)?.cancel ?? 'Cancel',
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
                            SnackBar(
                              content: Text(AppLocalizations.of(context)?.enterCurrentPassword ?? 'Please enter current password'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        
                        if (_newPasswordController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context)?.enterNewPassword ?? 'Please enter new password'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        
                        if (_newPasswordController.text != _confirmPasswordController.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context)?.passwordsNotMatch ?? 'New passwords do not match'),
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
                      child: Text(
                        AppLocalizations.of(context)?.changePassword ?? 'Change Password',
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
                Text(
                  AppLocalizations.of(context)?.linkFamilyMembers ?? 'Link Family Members',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111611),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)?.sharePatientId ?? 'Share your Patient ID with family members so they can register and link their accounts to receive updates about your pregnancy journey.',
                  style: TextStyle(
                    color: Color(0xFF638763),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  AppLocalizations.of(context)?.patientId ?? 'Your Patient ID:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111611),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE91E63).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _userId.isEmpty ? 'Loading...' : _userId,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF111611),
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (_userId.isNotEmpty) {
                            Clipboard.setData(ClipboardData(text: _userId));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AppLocalizations.of(context)?.patientIdCopied ?? 'Patient ID copied to clipboard'),
                                duration: Duration(seconds: 2),
                                backgroundColor: Color(0xFFE91E63),
                              ),
                            );
                          }
                        },
                        icon: const Icon(
                          Icons.copy,
                          color: Color(0xFFE91E63),
                          size: 20,
                        ),
                        tooltip: 'Copy Patient ID',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.green.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.green,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)?.familyMembersInfo ?? 'Family members can use this ID during registration to create linked accounts and receive pregnancy updates.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      AppLocalizations.of(context)?.close ?? 'Close',
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
              Text(
                AppLocalizations.of(context)?.safeMotherPrivacy ?? 'Safe Mother Privacy',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111611),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)?.privacyDescription ?? 'Your privacy and safety are our top priority. '
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
                  child: Text(
                    AppLocalizations.of(context)?.close ?? 'Close',
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
                Text(
                  AppLocalizations.of(context)?.signOut ?? 'Sign Out',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111611),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)?.signOutConfirm ?? 'Are you sure you want to sign out of your account?',
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
                        child: Text(
                          AppLocalizations.of(context)?.cancel ?? 'Cancel',
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
                        child: Text(
                          AppLocalizations.of(context)?.signOut ?? 'Sign Out',
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

      // Clear session data first
      await SessionManager.clearSession();

      // Small delay to ensure Firebase auth state is cleared
      await Future.delayed(const Duration(milliseconds: 800));

      if (mounted) {
        // Remove loading indicator
        Navigator.of(context).pop();

        // Navigate to sign in screen and clear navigation stack
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const SignInScreen()),
          (route) => false,
        );

        // Show success message after navigation
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)?.signOutSuccess ?? 'Successfully signed out'),
                backgroundColor: const Color(0xFFE91E63),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        // Remove loading indicator
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)?.signOutFailed ?? 'Sign out failed: $e'),
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
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE91E63), Color(0xFF9C27B0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Modern Header with gradient background
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Top navigation
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const HomeScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.arrow_back_ios,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context)?.myProfile ?? 'My Profile',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              onPressed: () => _showSignOutDialog(),
                              icon: const Icon(
                                Icons.logout,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Profile Avatar and Info
                      Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: _isLoading
                                    ? const Center(
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE91E63)),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.person,
                                        size: 60,
                                        color: Color(0xFFE91E63),
                                      ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4CAF50),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 3),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          
                          _isLoading
                              ? Container(
                                  width: 120,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                )
                              : Text(
                                  _userName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                          
                          const SizedBox(height: 8),
                          
                          _isLoading
                              ? Container(
                                  width: 80,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                )
                              : Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _userRole,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Main content with white background
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          
                          // Personal Information Section
                          _buildSectionHeader(AppLocalizations.of(context)?.personalInfo ?? 'Personal Information', Icons.person_outline),
                          const SizedBox(height: 16),
                      
                          _isLoading
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(20.0),
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE91E63)),
                                    ),
                                  ),
                                )
                              : Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8F9FA),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: const Color(0xFFE0E0E0)),
                                  ),
                                  child: Column(
                                    children: [
                                      _buildReadOnlyInfoRow(AppLocalizations.of(context)?.name ?? 'Name', _userName, Icons.person),
                                      
                                      const Divider(height: 32, color: Color(0xFFE0E0E0)),
                                      
                                      _buildReadOnlyInfoRow(AppLocalizations.of(context)?.email ?? 'Email', _userEmail, Icons.email),
                                      
                                      const Divider(height: 32, color: Color(0xFFE0E0E0)),
                                      
                                      _buildReadOnlyInfoRow(AppLocalizations.of(context)?.age ?? 'Age', _userAge.isEmpty ? 'Not set' : _userAge, Icons.cake),
                                      
                                      const Divider(height: 32, color: Color(0xFFE0E0E0)),
                                      
                                      _buildReadOnlyInfoRow(AppLocalizations.of(context)?.contact ?? 'Contact', _userContact.isEmpty ? 'Not set' : _userContact, Icons.phone),
                                      
                                      const Divider(height: 32, color: Color(0xFFE0E0E0)),
                                      
                                      _buildUidInfoRow(AppLocalizations.of(context)?.patientId ?? 'Patient ID', _userId.isEmpty ? 'Not available' : _userId, Icons.tag),
                                    ],
                                  ),
                                ),
                          
                          const SizedBox(height: 32),
                          // Pregnancy Information Section
                          _buildSectionHeader(AppLocalizations.of(context)?.pregnancyInformation ?? 'Pregnancy Information', Icons.pregnant_woman),
                          const SizedBox(height: 16),
                          
                          _isLoading
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(20.0),
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE91E63)),
                                    ),
                                  ),
                                )
                              : Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8F9FA),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: const Color(0xFFE0E0E0)),
                                  ),
                                  child: Column(
                                    children: [
                                      if (_expectedDeliveryDate != null) ...[
                                        _buildReadOnlyInfoRow(
                                          AppLocalizations.of(context)?.expectedDeliveryDate ?? 'Expected Delivery Date', 
                                          "${_expectedDeliveryDate!.day}/${_expectedDeliveryDate!.month}/${_expectedDeliveryDate!.year}", 
                                          Icons.calendar_today
                                        ),
                                        const Divider(height: 32, color: Color(0xFFE0E0E0)),
                                      ],
                                      
                                      if (_pregnancyConfirmedDate != null) ...[
                                        _buildReadOnlyInfoRow(
                                          AppLocalizations.of(context)?.pregnancyConfirmedDate ?? 'Pregnancy Confirmed Date', 
                                          "${_pregnancyConfirmedDate!.day}/${_pregnancyConfirmedDate!.month}/${_pregnancyConfirmedDate!.year}", 
                                          Icons.event_available
                                        ),
                                        const Divider(height: 32, color: Color(0xFFE0E0E0)),
                                      ],
                                      
                                      if (_weight != null) ...[
                                        _buildReadOnlyInfoRow(AppLocalizations.of(context)?.weight ?? 'Weight', '${_weight!.toStringAsFixed(1)} kg', Icons.monitor_weight),
                                        const Divider(height: 32, color: Color(0xFFE0E0E0)),
                                      ],
                                      
                                      if (_isFirstChild != null) ...[
                                        _buildReadOnlyInfoRow(AppLocalizations.of(context)?.firstChild ?? 'First Child', _isFirstChild! ? 'Yes' : 'No', Icons.child_care),
                                        const Divider(height: 32, color: Color(0xFFE0E0E0)),
                                      ],
                                      
                                      if (_hasPregnancyLoss != null) ...[
                                        _buildReadOnlyInfoRow(AppLocalizations.of(context)?.previousPregnancyLoss ?? 'Previous Pregnancy Loss', _hasPregnancyLoss! ? 'Yes' : 'No', Icons.heart_broken),
                                        const Divider(height: 32, color: Color(0xFFE0E0E0)),
                                      ],
                                      
                                      if (_medicalHistory != null && _medicalHistory!.isNotEmpty) ...[
                                        _buildReadOnlyInfoRow(AppLocalizations.of(context)?.medicalHistory ?? 'Medical History', _medicalHistory!, Icons.medical_services),
                                      ] else ...[
                                        _buildReadOnlyInfoRow(AppLocalizations.of(context)?.medicalHistory ?? 'Medical History', AppLocalizations.of(context)?.notProvided ?? 'Not provided', Icons.medical_services),
                                      ],
                                    ],
                                  ),
                                ),
                          
                          const SizedBox(height: 32),
                          _buildSectionHeader(AppLocalizations.of(context)?.quickActions ?? 'Quick Actions', Icons.flash_on),
                          const SizedBox(height: 16),
                          
                          Row(
                            children: [
                              Expanded(
                                child: _buildActionButton(
                                  AppLocalizations.of(context)?.editProfile ?? 'Edit Profile',
                                  Icons.edit,
                                  const Color(0xFFE91E63),
                                  () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const EditProfilePage(),
                                      ),
                                    );
                                    
                                    if (result == true) {
                                      _navigateToDashboard('Profile updated successfully!');
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildActionButton(
                                  AppLocalizations.of(context)?.changePassword ?? 'Change Password',
                                  Icons.lock,
                                  const Color(0xFF9C27B0),
                                  _showChangePasswordPopup,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Account Settings Section
                          _buildSectionHeader(AppLocalizations.of(context)?.accountSettings ?? 'Account Settings', Icons.settings),
                          const SizedBox(height: 16),
                          
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE0E0E0)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                _buildLanguageSettingRow(),
                                const Divider(height: 1, color: Color(0xFFE0E0E0)),
                                _buildModernSettingRow(AppLocalizations.of(context)?.privacySettings ?? 'Privacy Settings', Icons.privacy_tip, _showPrivacySettingsPopup),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // My Doctors Section
                          _buildSectionHeader(AppLocalizations.of(context)?.myDoctors ?? 'My Doctors', Icons.medical_services),
                          const SizedBox(height: 16),
                          _buildAssignedDoctorCard(),
                          
                          const SizedBox(height: 32),
                          
                          // Family & Support Section
                          _buildSectionHeader(AppLocalizations.of(context)?.familyDoctorLink ?? 'Family & Doctor Link', Icons.family_restroom),
                          const SizedBox(height: 16),
                          
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE0E0E0)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                _buildModernSettingRow(AppLocalizations.of(context)?.linkFamilyMembers ?? 'Link Family Members', Icons.family_restroom, _showLinkedMembersPopup),
                                const Divider(height: 1, color: Color(0xFFE0E0E0)),
                                _buildModernSettingRow(AppLocalizations.of(context)?.linkDoctors ?? 'Link Doctors', Icons.local_hospital, _showLinkedDoctorsPopup),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Modern widget builders

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFE91E63).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFFE91E63), size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D3748),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyInfoRow(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE91E63).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFFE91E63), size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUidInfoRow(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE91E63).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFFE91E63), size: 18),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            value,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF666666),
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            if (value.isNotEmpty && value != 'Not available') {
                              Clipboard.setData(ClipboardData(text: value));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(AppLocalizations.of(context)?.appTitle ?? 'Patient ID copied to clipboard'),
                                  duration: const Duration(seconds: 2),
                                  backgroundColor: const Color(0xFFE91E63),
                                ),
                              );
                            }
                          },
                          icon: const Icon(
                            Icons.copy,
                            color: Color(0xFFE91E63),
                            size: 18,
                          ),
                          tooltip: 'Copy Patient ID',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

void _changeLocale(BuildContext context, Locale newLocale) {
  try {
    // Find the nearest ancestor MaterialApp and update its locale
    final state = SafeMotherApp.of(context);
    if (state != null) {
      state.setLocale(newLocale);
      // Force a rebuild by calling setState on the current widget
      if (mounted) {
        setState(() {});
      }
    } else {
      print('SafeMotherApp.of(context) returned null');
    }
  } catch (e) {
    print('Error changing locale: $e');
  }
}
  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Column(
              children: [
                Icon(icon, color: Colors.white, size: 24),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernSettingRow(String title, IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE91E63).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFFE91E63), size: 18),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF9CA3AF),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

 Widget _buildLanguageSettingRow() {
  final currentLocale = Localizations.localeOf(context);
  String currentLanguage = 'English';
  
  if (currentLocale.languageCode == 'ta') {
    currentLanguage = 'Tamil';
  } else if (currentLocale.languageCode == 'si') {
    currentLanguage = 'Sinhala';
  }

  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: _showLanguageSelectionDialog,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE91E63).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.language, color: Color(0xFFE91E63), size: 18),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                AppLocalizations.of(context)?.language ?? 'Language',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2D3748),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                currentLanguage,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF5A5A5A),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF9CA3AF),
              size: 20,
            ),
          ],
        ),
      ),
    ),
  );
}
  
  void _showLanguageSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text(
            'Select Language',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111611),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Text('🇺🇸', style: TextStyle(fontSize: 24)),
                title: const Text('English'),
                onTap: () {
                  _changeLocale(context, const Locale('en'));
                  Navigator.of(dialogContext).pop();
                },
              ),
              ListTile(
                leading: const Text('🇱🇰', style: TextStyle(fontSize: 24)),
                title: const Text('தமிழ் (Tamil)'),
                onTap: () {
                  _changeLocale(context, const Locale('ta'));
                  Navigator.of(dialogContext).pop();
                },
              ),
              ListTile(
                leading: const Text('🇱🇰', style: TextStyle(fontSize: 24)),
                title: const Text('සිංහල (Sinhala)'),
                onTap: () {
                  _changeLocale(context, const Locale('si'));
                  Navigator.of(dialogContext).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAssignedDoctorCard() {
    // Always show the section, even when no doctors are assigned
    if (_assignedDoctors.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE0E0E0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE91E63).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.medical_services_outlined,
                size: 32,
                color: const Color(0xFFE91E63),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)?.noDoctorsAssigned ?? 'No Doctors Assigned',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)?.connectDoctors ?? 'Connect with healthcare providers to get personalized care and guidance throughout your pregnancy journey.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _showLinkedDoctorsPopup,
              icon: const Icon(Icons.add, size: 18),
              label: Text(AppLocalizations.of(context)?.findDoctor ?? 'Find a Doctor'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 2,
              ),
            ),
          ],
        ),
      );
    }
    
    // Show all assigned doctors with modern design
    return Column(
      children: _assignedDoctors.map((doctor) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE0E0E0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Doctor Avatar with gradient
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4CAF50).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
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
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Doctor Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Dr. ${doctor['doctorName'] ?? 'Unknown Doctor'}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              AppLocalizations.of(context)?.active ?? 'ACTIVE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
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
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Doctor Details with modern icons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  if (doctor['yearsExperience'] != null) ...[
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.work, size: 14, color: Color(0xFF4CAF50)),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${doctor['yearsExperience']} years experience',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF2D3748),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.email, size: 14, color: Color(0xFF4CAF50)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          doctor['doctorEmail'] ?? 'Contact via app',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.phone, size: 14, color: Color(0xFF4CAF50)),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        doctor['doctorPhone'] ?? 'Contact via app',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
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
              id: doctorId.toString(),
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
          SnackBar(
            content: Text(AppLocalizations.of(context)?.requestFailed ?? 'Failed to send request to doctor'),
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
      title: Text(
        AppLocalizations.of(context)?.selectDoctor ?? 'Select Your Doctor',
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
                    Text(
                      AppLocalizations.of(context)?.currentlyLinked ?? 'Currently Linked:',
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
              Text(
                AppLocalizations.of(context)?.selectNewDoctor ?? 'Select a new doctor to change your current selection:',
                style: TextStyle(
                  color: Color(0xFF5A5A5A),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
            ] else ...[
              Text(
                AppLocalizations.of(context)?.selectDoctorGuide ?? 'Select a doctor to guide your pregnancy journey:',
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
                          ? Center(
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
                                    AppLocalizations.of(context)?.noDoctorsAvailable ?? 'No doctors available',
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
          child: Text(
            AppLocalizations.of(context)?.cancel ?? 'Cancel',
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
            _currentLinkedDoctor != null ? AppLocalizations.of(context)?.sendNewRequest ?? 'Send New Request' : AppLocalizations.of(context)?.sendRequest ?? 'Send Request',
          ),
        ),
      ],
    );
  }
}
