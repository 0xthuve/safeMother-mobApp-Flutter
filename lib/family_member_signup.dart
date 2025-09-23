import 'package:flutter/material.dart';
import 'package:safemothermobapp/services/auth_service.dart';
import 'package:safemothermobapp/patientDashboard.dart';

class FamilyMemberSignupScreen extends StatefulWidget {
  const FamilyMemberSignupScreen({Key? key}) : super(key: key);

  @override
  State<FamilyMemberSignupScreen> createState() => _FamilyMemberSignupScreenState();
}

class _FamilyMemberSignupScreenState extends State<FamilyMemberSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _motherEmailController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String _selectedRelationship = 'Spouse';

  final List<String> _relationships = [
    'Spouse',
    'Mother',
    'Father',
    'Sister',
    'Brother',
    'Mother-in-law',
    'Father-in-law',
    'Other Family Member',
  ];

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _motherEmailController.dispose();
    super.dispose();
  }

  Future<void> _registerFamilyMember() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final result = await AuthService.registerFamilyMember(
          fullName: _fullNameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          motherEmail: _motherEmailController.text.trim(),
          relationship: _selectedRelationship,
          phoneNumber: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
        );

        if (result.success && mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
            (route) => false,
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: const Color(0xFFE91E63),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: const Color(0xFFE91E63),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    bool obscureText = false,
    Widget? suffixIcon,
    Widget? prefixIcon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF9575CD)),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF9575CD), width: 2),
        ),
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4FF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Color(0xFF7B1FA2),
                  ),
                ),
                const SizedBox(height: 20),

                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7B1FA2).withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.family_restroom,
                        size: 48,
                        color: Color(0xFF7B1FA2),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Join as Family Member',
                        style: TextStyle(
                          color: Color(0xFF7B1FA2),
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Connect with your loved one and support them throughout their pregnancy journey.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF9575CD),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Form
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Full Name
                        _buildTextField(
                          controller: _fullNameController,
                          label: 'Full Name',
                          prefixIcon: const Icon(
                            Icons.person_outline,
                            color: Color(0xFF9575CD),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your full name';
                            }
                            if (value.trim().length < 2) {
                              return 'Name must be at least 2 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Email
                        _buildTextField(
                          controller: _emailController,
                          label: 'Email Address',
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: Color(0xFF9575CD),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(value.trim())) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password
                        _buildTextField(
                          controller: _passwordController,
                          label: 'Password',
                          obscureText: _obscurePassword,
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: Color(0xFF9575CD),
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: const Color(0xFF9575CD),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Confirm Password
                        _buildTextField(
                          controller: _confirmPasswordController,
                          label: 'Confirm Password',
                          obscureText: _obscureConfirmPassword,
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: Color(0xFF9575CD),
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: const Color(0xFF9575CD),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Phone (optional)
                        _buildTextField(
                          controller: _phoneController,
                          label: 'Phone Number (Optional)',
                          prefixIcon: const Icon(
                            Icons.phone_outlined,
                            color: Color(0xFF9575CD),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              if (value.length < 10) {
                                return 'Phone number must be at least 10 digits';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Relationship Dropdown
                        DropdownButtonFormField<String>(
                          value: _selectedRelationship,
                          decoration: InputDecoration(
                            labelText: 'Relationship to Mother',
                            labelStyle: const TextStyle(color: Color(0xFF9575CD)),
                            filled: true,
                            fillColor: const Color(0xFFF5F5F5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF9575CD), width: 2),
                            ),
                            prefixIcon: const Icon(
                              Icons.family_restroom_outlined,
                              color: Color(0xFF9575CD),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 16,
                            ),
                          ),
                          items: _relationships.map((String relationship) {
                            return DropdownMenuItem<String>(
                              value: relationship,
                              child: Text(relationship),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedRelationship = newValue;
                              });
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select your relationship';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Mother's Email
                        _buildTextField(
                          controller: _motherEmailController,
                          label: 'Mother\'s Email Address',
                          prefixIcon: const Icon(
                            Icons.pregnant_woman_outlined,
                            color: Color(0xFF9575CD),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter mother\'s email';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(value.trim())) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Register Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _registerFamilyMember,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE91E63),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  )
                                : const Text(
                                    'Register as Family Member',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
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
}