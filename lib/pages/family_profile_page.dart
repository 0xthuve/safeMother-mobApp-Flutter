import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/family_member_service.dart';
import '../models/family_member_model.dart';
import '../signin.dart';
import 'family_home_screen.dart';
import 'family_log_page.dart';
import 'family_appointment_page.dart';
import 'family_learn_page.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';

class FamilyProfileScreen extends StatefulWidget {
  const FamilyProfileScreen({super.key});

  @override
  State<FamilyProfileScreen> createState() => _FamilyProfileScreenState();
}

class _FamilyProfileScreenState extends State<FamilyProfileScreen> {
  String _userName = '';
  String _userEmail = '';
  String _userAge = '';
  String _userContact = '';
  String _userRole = '';
  String _linkedPatientName = '';
  String _relationship = '';
  bool _isLoading = true;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  FamilyMember? _currentFamilyMember;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Get current user
      final user = _auth.currentUser;
      if (user != null) {
        // Load family member data
        _currentFamilyMember = await FamilyMemberService.getFamilyMember(user.uid);
        
        if (_currentFamilyMember != null) {
          // Load basic user data
          _userName = _currentFamilyMember!.fullName;
          _userEmail = _currentFamilyMember!.email;
          _userContact = _currentFamilyMember!.phone;
          _relationship = _currentFamilyMember!.relationship;
          _userRole = _currentFamilyMember!.relationship;

          // Try to load patient data to get patient name from users collection
          await _loadPatientData(_currentFamilyMember!.patientUserId);
        } else {
          // Fallback to current user data if family member not found
          _userName = user.displayName ?? 'User';
          _userEmail = user.email ?? '';
          _userRole = 'Family Member';
        }

        // Update controllers
        _nameController.text = _userName;
        _emailController.text = _userEmail;
        _contactController.text = _userContact;

        // Set age if available
        _userAge = _calculateAge();
        _ageController.text = _userAge;
      }
    } catch (e) {
      print('Error loading user data: $e');
      _setDefaultValues();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadPatientData(String patientUserId) async {
    try {
      // First try to get from users collection (where patient data is stored)
      final userDoc = await _firestore.collection('users').doc(patientUserId).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        _linkedPatientName = userData?['fullName'] ?? 
                            userData?['name'] ?? 
                            userData?['patientName'] ?? 
                            'Patient';
        print('✅ Patient name found in users collection: $_linkedPatientName');
        return;
      }

      // Fallback to patients collection if not found in users
      final patientDoc = await _firestore.collection('patients').doc(patientUserId).get();
      if (patientDoc.exists) {
        final patientData = patientDoc.data();
        _linkedPatientName = patientData?['fullName'] ?? 
                            patientData?['name'] ?? 
                            patientData?['patientName'] ?? 
                            'Patient';
        print('✅ Patient name found in patients collection: $_linkedPatientName');
      } else {
        _linkedPatientName = 'Patient';
        print('⚠️ Patient not found in users or patients collection');
      }
    } catch (e) {
      print('Error loading patient data: $e');
      _linkedPatientName = 'Patient';
    }
  }

  String _calculateAge() {
    // Implement age calculation based on your data structure
    return '';
  }

  void _setDefaultValues() {
    _userName = 'User';
    _userEmail = 'user@example.com';
    _userAge = '';
    _userContact = '';
    _userRole = 'Family Member';
    _linkedPatientName = 'Patient';
    _relationship = '';
  }

  void _showEditPopup(
    String field,
    String currentValue,
    TextEditingController controller,
  ) {
    controller.text = currentValue;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF3E5F5), Color(0xFFFCE4EC)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${AppLocalizations.of(context)?.edit ?? 'Edit'} $field',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2C2C2C),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: '${AppLocalizations.of(context)?.enterYour ?? 'Enter your'} $field',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildDialogActionButton(
                      AppLocalizations.of(context)?.cancel ?? 'Cancel',
                      const Color(0xFF757575),
                      () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    _buildDialogActionButton(
                      AppLocalizations.of(context)?.edit ?? 'Save',
                      const Color(0xFFE91E63),
                      () {
                        if (controller.text.isNotEmpty) {
                          Navigator.of(context).pop();
                          _saveUserData(field, controller.text);
                        }
                      },
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

  Widget _buildDialogActionButton(
    String text,
    Color color,
    VoidCallback onPressed,
  ) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ),
    );
  }

  Future<void> _saveUserData(String field, String value) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      setState(() {
        switch (field) {
          case 'Name':
            _userName = value;
            break;
          case 'Age':
            _userAge = value;
            break;
          case 'Contact':
            _userContact = value;
            break;
          case 'Email':
            _userEmail = value;
            break;
        }
      });

      // Update in Firestore
      final updateData = <String, dynamic>{};
      switch (field) {
        case 'Name':
          updateData['fullName'] = value;
          await user.updateDisplayName(value);
          break;
        case 'Contact':
          updateData['phone'] = value;
          break;
        case 'Email':
          updateData['email'] = value;
          await user.updateEmail(value);
          break;
      }

      if (updateData.isNotEmpty) {
        updateData['updatedAt'] = FieldValue.serverTimestamp();
        await _firestore.collection('family_members').doc(user.uid).update(updateData);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)?.updatedSuccessfully ?? '$field updated successfully!'),
          backgroundColor: const Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      print('Error saving user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)?.failedUpdateField(field, e.toString()) ?? 'Failed to update $field: $e'),
          backgroundColor: const Color(0xFFF44336),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _showChangePasswordPopup() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF3E5F5), Color(0xFFFCE4EC)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)?.changePassword ?? 'Change Password',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2C2C2C),
                  ),
                ),
                const SizedBox(height: 16),
                _buildPasswordField(AppLocalizations.of(context)?.currentPassword ?? 'Current Password', currentPasswordController),
                const SizedBox(height: 12),
                _buildPasswordField(AppLocalizations.of(context)?.newPassword ?? 'New Password', newPasswordController),
                const SizedBox(height: 12),
                _buildPasswordField(AppLocalizations.of(context)?.confirmNewPassword ?? 'Confirm New Password', confirmPasswordController),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildDialogActionButton(
                      AppLocalizations.of(context)?.cancel ?? 'Cancel',
                      const Color(0xFF757575),
                      () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    _buildDialogActionButton(
                      AppLocalizations.of(context)?.update ?? 'Update',
                      const Color(0xFFE91E63),
                      () async {
                        if (newPasswordController.text != confirmPasswordController.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context)?.passwordsNotMatch ?? 'New passwords do not match!'),
                              backgroundColor: const Color(0xFFF44336),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                          return;
                        }

                        if (newPasswordController.text.length < 6) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context)?.passwordMinLength ?? 'Password must be at least 6 characters long!'),
                              backgroundColor: const Color(0xFFF44336),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                          return;
                        }

                        try {
                          final user = _auth.currentUser;
                          if (user != null) {
                            // For security, re-authenticate user before password change
                            final credential = EmailAuthProvider.credential(
                              email: user.email!,
                              password: currentPasswordController.text,
                            );
                            
                            await user.reauthenticateWithCredential(credential);
                            await user.updatePassword(newPasswordController.text);
                            
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AppLocalizations.of(context)?.passwordUpdated ?? 'Password updated successfully!'),
                                backgroundColor: const Color(0xFF4CAF50),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          }
                        } on FirebaseAuthException catch (e) {
                          String errorMessage = AppLocalizations.of(context)?.failedUpdatePassword ?? 'Failed to update password';
                          if (e.code == 'wrong-password') {
                            errorMessage = 'Current password is incorrect';
                          } else if (e.code == 'weak-password') {
                            errorMessage = 'Password is too weak';
                          } else if (e.code == 'requires-recent-login') {
                            errorMessage = 'Please log in again to change your password';
                          }
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(errorMessage),
                              backgroundColor: const Color(0xFFF44336),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${AppLocalizations.of(context)?.failedUpdatePassword ?? 'Failed to update password'}: $e'),
                              backgroundColor: const Color(0xFFF44336),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        }
                      },
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

  Widget _buildPasswordField(String hintText, TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF3E5F5), Color(0xFFFCE4EC)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)?.privacySecurity ?? 'Privacy & Security',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2C2C2C),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)?.privacyDescriptionFamily(_linkedPatientName) ?? 'Your privacy and the security of $_linkedPatientName\'s medical information are our top priority. '
                  'All data is encrypted and stored securely. Family members can only access information '
                  'that is explicitly shared with them.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF757575),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: _buildDialogActionButton(
                    AppLocalizations.of(context)?.close ?? 'Close',
                    const Color(0xFFE91E63),
                    () => Navigator.of(context).pop(),
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
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF3E5F5), Color(0xFFFCE4EC)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF44336).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout,
                    color: Color(0xFFF44336),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)?.signOut ?? 'Sign Out',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2C2C2C),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)?.signOutConfirm ?? 'Are you sure you want to sign out of your account?',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF757575),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildDialogActionButton(
                        AppLocalizations.of(context)?.cancel ?? 'Cancel',
                        const Color(0xFF757575),
                        () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF44336).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFF44336).withOpacity(0.3),
                          ),
                        ),
                        child: TextButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            try {
                              await _auth.signOut();
                              // Navigate to login screen
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SignInScreen(),
                                ),
                                (route) => false,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(AppLocalizations.of(context)?.signedOutSuccessfully ?? 'Signed out successfully'),
                                  backgroundColor: const Color(0xFF4CAF50),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(AppLocalizations.of(context)?.errorSigningOut(e.toString()) ?? 'Error signing out: $e'),
                                  backgroundColor: const Color(0xFFF44336),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            }
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context)?.signOut ?? 'Sign Out',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFF44336),
                            ),
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

  void _changeLocale(BuildContext context, Locale newLocale) {
    // Find the nearest ancestor MaterialApp and update its locale
    final state = SafeMotherApp.of(context);
    if (state != null) {
      state.setLocale(newLocale);
    }
  }

  Widget _buildLanguageSettingRow() {
    return Material(
      color: Colors.transparent,
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
            DropdownButton<Locale>(
              value: Localizations.localeOf(context),
              items: const [
                DropdownMenuItem(value: Locale('en'), child: Text('English')),
                DropdownMenuItem(value: Locale('ta'), child: Text('தமிழ் (Tamil)')),
                DropdownMenuItem(value: Locale('si'), child: Text('සිංහල (Sinhala)')),
              ],
              onChanged: (Locale? locale) {
                if (locale != null) {
                  _changeLocale(context, locale);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFCE4EC),
              Color(0xFFE3F2FD),
              Colors.white,
            ],
            stops: [0.0, 0.3, 0.7],
          ),
        ),
        child: Column(
          children: [
            // Custom App Bar
            Container(
              padding: const EdgeInsets.only(
                top: 50,
                left: 20,
                right: 20,
                bottom: 15,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFE91E63).withOpacity(0.9),
                    const Color(0xFF2196F3).withOpacity(0.9),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => FamilyHomeScreen()),
                        );
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context)?.myProfile ?? 'My Profile',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.person_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Header Section
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFF3E5F5),
                            Color(0xFFFCE4EC),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE91E63).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Color(0xFFE91E63),
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _userName.isNotEmpty ? _userName : 'Loading...',
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF2C2C2C),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${AppLocalizations.of(context)?.familyMember ?? 'Family Member'} - ${_userRole.isNotEmpty ? _userRole : 'Member'}',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: const Color(0xFF757575),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (_linkedPatientName.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.link,
                                        color: Color(0xFF4CAF50),
                                        size: 14,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${AppLocalizations.of(context)?.linkedTo ?? 'Linked to'} $_linkedPatientName',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF4CAF50),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (_isLoading) ...[
                      const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFE91E63),
                        ),
                      ),
                    ] else ...[
                      // Rest of your UI code remains the same...
                      // Personal Information Section
                      Text(
                        AppLocalizations.of(context)?.personalInformation ?? 'Personal Information',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2C2C2C),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFF3E5F5), Color(0xFFFCE4EC)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildEditableInfoRow(
                              AppLocalizations.of(context)?.name ?? 'Name',
                              _userName,
                              Icons.person,
                              () {
                                _showEditPopup(
                                  AppLocalizations.of(context)?.name ?? 'Name',
                                  _userName,
                                  _nameController,
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildEditableInfoRow(
                              AppLocalizations.of(context)?.email ?? 'Email',
                              _userEmail,
                              Icons.email,
                              () {
                                _showEditPopup(
                                  AppLocalizations.of(context)?.email ?? 'Email',
                                  _userEmail,
                                  _emailController,
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            if (_userAge.isNotEmpty)
                            _buildEditableInfoRow(
                              AppLocalizations.of(context)?.age ?? 'Age',
                              '$_userAge years',
                              Icons.cake,
                              () {
                                _showEditPopup(AppLocalizations.of(context)?.age ?? 'Age', _userAge, _ageController);
                              },
                            ),
                            if (_userAge.isNotEmpty) const SizedBox(height: 16),
                            _buildEditableInfoRow(
                              AppLocalizations.of(context)?.contact ?? 'Contact',
                              _userContact.isNotEmpty ? _userContact : 'Not set',
                              Icons.phone,
                              () {
                                _showEditPopup(
                                  AppLocalizations.of(context)?.contact ?? 'Contact',
                                  _userContact,
                                  _contactController,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Linked Patient Information
                      Text(
                        AppLocalizations.of(context)?.linkedPatient ?? 'Linked Patient',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2C2C2C),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFF3E5F5), Color(0xFFFCE4EC)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              AppLocalizations.of(context)?.patientName ?? 'Patient Name',
                              _linkedPatientName,
                              Icons.pregnant_woman,
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              AppLocalizations.of(context)?.relationship ?? 'Relationship',
                              _relationship.isNotEmpty ? _relationship : 'Not set',
                              Icons.family_restroom,
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              AppLocalizations.of(context)?.connectionStatus ?? 'Connection Status',
                              AppLocalizations.of(context)?.active ?? 'Active',
                              Icons.check_circle,
                              color: Color(0xFF4CAF50),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Account Settings
                      Text(
                        AppLocalizations.of(context)?.accountSettings ?? 'Account Settings',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2C2C2C),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFF3E5F5), Color(0xFFFCE4EC)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildLanguageSettingRow(),
                            const Divider(height: 1, color: Color(0xFFE0E0E0)),
                            _buildSettingRow(
                              AppLocalizations.of(context)?.changePassword ?? 'Change Password',
                              Icons.lock,
                              _showChangePasswordPopup,
                            ),
                            const SizedBox(height: 16),
                            _buildSettingRow(
                              AppLocalizations.of(context)?.privacySecurity ?? 'Privacy & Security',
                              Icons.security,
                              _showPrivacyPolicy,
                            ),
                            const SizedBox(height: 16),
                            _buildSettingRow(
                              AppLocalizations.of(context)?.signOut ?? 'Sign Out',
                              Icons.logout,
                              _showSignOutDialog,
                              isSignOut: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  // Rest of your widget methods remain the same...
  Widget _buildEditableInfoRow(
    String title,
    String value,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.9)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE91E63).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Color(0xFFE91E63), size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF757575),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value.isNotEmpty ? value : 'Not set',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2C2C2C),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.edit, color: Color(0xFFE91E63), size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String title,
    String value,
    IconData icon, {
    Color color = const Color(0xFF2196F3),
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.9)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF757575),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isNotEmpty ? value : 'Not set',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2C2C2C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingRow(
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isSignOut = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.9)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSignOut
                    ? const Color(0xFFF44336).withOpacity(0.1)
                    : const Color(0xFF2196F3).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSignOut ? Color(0xFFF44336) : Color(0xFF2196F3),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isSignOut ? Color(0xFFF44336) : Color(0xFF2C2C2C),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: isSignOut ? Color(0xFFF44336) : Color(0xFF757575),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFCE4EC),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FamilyHomeScreen()),
                );
              },
              child: _buildNavItem(context, Icons.home_filled, AppLocalizations.of(context)?.home ?? 'Home', 0),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FamilyViewLogScreen()),
                );
              },
              child: _buildNavItem(context, Icons.assignment_outlined, AppLocalizations.of(context)?.log ?? 'View Log', 1),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FamilyAppointmentsScreen()),
                );
              },
              child: _buildNavItem(
                context,
                Icons.calendar_today_outlined,
                AppLocalizations.of(context)?.consultationNav ?? 'Appointments',
                2,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FamilyLearnScreen()),
                );
              },
              child: _buildNavItem(context, Icons.menu_book_outlined, AppLocalizations.of(context)?.learn ?? 'Learn', 4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    int index,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: Icon(
            icon,
            color: const Color(0xFFE91E63).withOpacity(0.6),
            size: 22,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: const Color(0xFFE91E63).withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}