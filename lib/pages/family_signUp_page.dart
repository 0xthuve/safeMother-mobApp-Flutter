import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/family_member_model.dart';
import '../services/family_member_service.dart';

class FamilySignUpScreen extends StatefulWidget {
  const FamilySignUpScreen({super.key});

  @override
  State<FamilySignUpScreen> createState() => _FamilySignUpScreenState();
}

class _FamilySignUpScreenState extends State<FamilySignUpScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _patientIdController = TextEditingController();
  
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _selectedRelationship;

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<String> _relationshipOptions = [
    'Husband',
    'Mother',
    'Father',
    'Sister',
    'Brother',
    'Daughter',
    'Son',
    'Other Family Member'
  ];

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      print('Form validation failed');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('Starting registration process...');

      // Check if patient exists
      print('Checking patient ID: ${_patientIdController.text.trim()}');
      final patientExists = await FamilyMemberService.checkPatientExists(_patientIdController.text.trim());
      
      if (!patientExists) {
        throw Exception('Patient ID not found. Please check the ID and try again.');
      }
      print('Patient ID verified');

      // Get patient details
      final patientQuery = await FamilyMemberService.getPatientByPatientId(_patientIdController.text.trim());
      if (patientQuery.docs.isEmpty) {
        throw Exception('Patient ID not found. Please check the ID and try again.');
      }

      final patientDoc = patientQuery.docs.first;
      final patientData = patientDoc.data() as Map<String, dynamic>;
      final patientUserId = patientDoc.id;

      print('Patient found: ${patientData['fullName'] ?? 'Unknown'}');

      // // Check if email already exists in family_members
      // print('Checking email: ${_emailController.text.trim()}');
      // final emailExists = await FamilyMemberService.checkEmailExists(_emailController.text.trim());
      // if (emailExists) {
      //   throw Exception('An account already exists with this email.');
      // }
      // print('Email is available');

      // Create user in Firebase Auth
      print('Creating Firebase Auth user...');
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      print('Firebase Auth user created: ${userCredential.user!.uid}');

      // Create family member object
      final familyMember = FamilyMember(
        uid: userCredential.user!.uid,
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        relationship: _selectedRelationship!,
        patientId: _patientIdController.text.trim(),
        patientUserId: patientUserId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        status: 'active',
        accountType: 'family',
        isVerified: true,
      );

      // Create family member document using FamilyMemberService
      print('Creating family member document...');
      await FamilyMemberService.createFamilyMember(familyMember);
      print('Family member document created');

      // OPTIONAL: Link family member to patient (you can skip this for now)
      try {
        print('Linking family member to patient...');
        await FamilyMemberService.linkFamilyMemberToPatient(
          patientUserId: patientUserId,
          familyMemberId: userCredential.user!.uid,
          fullName: _fullNameController.text.trim(),
          relationship: _selectedRelationship!,
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
        );
        print('Family member linked to patient');
      } catch (e) {
        print('Linking failed but continuing: $e');
        // Continue even if linking fails
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Show success dialog
        _showSuccessDialog();
      }
    } catch (e) {
      print('Registration error: $e');
      
      // Clean up: delete the Firebase Auth user if it was created but family member creation failed
      try {
        final currentUser = _auth.currentUser;
        if (currentUser != null && currentUser.uid != null) {
          await currentUser.delete();
          print('Cleaned up Firebase Auth user due to registration failure');
        }
      } catch (deleteError) {
        print('Error cleaning up user: $deleteError');
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        String errorMessage = 'Registration failed. Please try again.';
        if (e is FirebaseAuthException) {
          switch (e.code) {
            case 'email-already-in-use':
              errorMessage = 'An account already exists with this email.';
              break;
            case 'invalid-email':
              errorMessage = 'Invalid email address.';
              break;
            case 'operation-not-allowed':
              errorMessage = 'Email/password accounts are not enabled.';
              break;
            case 'weak-password':
              errorMessage = 'Password is too weak. Please use a stronger password.';
              break;
            case 'network-request-failed':
              errorMessage = 'Network error. Please check your connection.';
              break;
          }
        } else if (e is Exception) {
          errorMessage = e.toString();
        }
        
        _showErrorDialog(errorMessage);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Registration Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

void _showSuccessDialog() {
  showDialog(
    context: context,
    barrierDismissible: false,
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
              colors: [
                Color(0xFFF3E5F5),
                Color(0xFFFCE4EC),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF4CAF50),
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Registration Successful!',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2C2C2C),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your account has been created successfully.\nPlease log in to continue.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF757575),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: _buildDialogActionButton(
                  'Go to Login',
                  const Color(0xFFE91E63),
                  () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.pushReplacementNamed(context, '/'); // Navigate to Login
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

  Widget _buildDialogActionButton(String text, Color color, VoidCallback onPressed) {
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

  Widget _buildFormField({
    required String hintText,
    required IconData prefixIcon,
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    VoidCallback? onTap,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        onTap: onTap,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(prefixIcon, color: const Color(0xFFE91E63)),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.all(20),
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
              Color(0xFFFCE4EC), // Light pink
              Color(0xFFE3F2FD), // Light blue
              Colors.white,
            ],
            stops: [0.0, 0.3, 0.7],
          ),
        ),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Column(
              children: [
                // Header Section
                Container(
                  padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
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
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Back Button and Title
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                'Create Account',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 40), // For balance
                        ],
                      ),
                      const SizedBox(height: 20),
                      // App Logo
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'assets/logo.png',
                          width: 50,
                          height: 50,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.family_restroom,
                              color: Colors.white,
                              size: 30,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Safe Mother',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Family Member Registration',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Signup Form
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          'Join Safe Mother Family',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2C2C2C),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Fill in your details to create a family member account',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF757575),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),

                        // Full Name
                        _buildFormField(
                          hintText: 'Full Name',
                          prefixIcon: Icons.person,
                          controller: _fullNameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your full name';
                            }
                            if (value.length < 2) {
                              return 'Name must be at least 2 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Email
                        _buildFormField(
                          hintText: 'Email Address',
                          prefixIcon: Icons.email,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Phone Number
                        _buildFormField(
                          hintText: 'Phone Number',
                          prefixIcon: Icons.phone,
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your phone number';
                            }
                            if (!RegExp(r'^[0-9+\-\s()]{10,}$').hasMatch(value)) {
                              return 'Please enter a valid phone number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Relationship Dropdown
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: DropdownButtonFormField<String>(
                            value: _selectedRelationship,
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedRelationship = newValue;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Relationship to Patient',
                              prefixIcon: const Icon(Icons.family_restroom, color: Color(0xFFE91E63)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.transparent,
                              contentPadding: const EdgeInsets.all(20),
                            ),
                            items: _relationshipOptions.map((String relationship) {
                              return DropdownMenuItem<String>(
                                value: relationship,
                                child: Text(relationship),
                              );
                            }).toList(),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select your relationship';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Patient ID
                        _buildFormField(
                          hintText: 'Patient ID (Provided by Hospital)',
                          prefixIcon: Icons.medical_services,
                          controller: _patientIdController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the patient ID';
                            }
                            if (value.length < 3) {
                              return 'Patient ID must be at least 3 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password
                        _buildFormField(
                          hintText: 'Password',
                          prefixIcon: Icons.lock,
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility : Icons.visibility_off,
                              color: const Color(0xFF757575),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Confirm Password
                        _buildFormField(
                          hintText: 'Confirm Password',
                          prefixIcon: Icons.lock_outline,
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                              color: const Color(0xFF757575),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Sign Up Button
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFE91E63),
                                Color(0xFF2196F3),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFE91E63).withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _signUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Text(
                                    'Create Account',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Login Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: const Color(0xFF757575),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Text(
                                'Sign In',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: const Color(0xFFE91E63),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _patientIdController.dispose();
    super.dispose();
  }
}