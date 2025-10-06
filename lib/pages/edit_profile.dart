import 'package:flutter/material.dart';
import '../services/user_management_service.dart';
import '../services/session_manager.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _bloodTypeController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;


  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _bloodTypeController.dispose();
    _allergiesController.dispose();
    _emergencyContactController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final userName = await SessionManager.getUserName();
      final userEmail = await SessionManager.getUserEmail();
      final userData = await UserManagementService.getCurrentUserData();

      setState(() {
        _nameController.text = userName ?? '';
        _emailController.text = userEmail ?? '';
        
        if (userData != null) {
          _phoneController.text = userData['phone'] ?? userData['contact'] ?? '';
          _ageController.text = userData['age']?.toString() ?? '';
          _bloodTypeController.text = userData['bloodType'] ?? '';
          _allergiesController.text = (userData['allergies'] as List?)?.join(', ') ?? '';
          _emergencyContactController.text = userData['emergencyContact'] ?? '';
          _emergencyPhoneController.text = userData['emergencyPhone'] ?? '';
        }
        
        _isLoading = false;
      });
    } catch (e) {

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSaving = true;
      });

      try {
        final updateData = {
          'fullName': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'contact': _phoneController.text.trim(),
          'age': int.tryParse(_ageController.text.trim()) ?? 0,
          'bloodType': _bloodTypeController.text.trim(),
          'allergies': _allergiesController.text.trim().split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
          'emergencyContact': _emergencyContactController.text.trim(),
          'emergencyPhone': _emergencyPhoneController.text.trim(),
        };

        final success = await UserManagementService.updateUserProfile(updateData);

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Profile updated successfully!'),
              backgroundColor: const Color(0xFFE91E63),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          Navigator.of(context).pop(true); // Return true to indicate success
        } else {
          throw Exception('Failed to update profile');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update profile: ${e.toString()}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F8),
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFE91E63),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _isSaving ? null : _saveProfile,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE91E63)),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Personal Information Section
                    _buildSectionTitle('Personal Information'),
                    const SizedBox(height: 16),
                    
                    _buildTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      icon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your full name';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      enabled: false, // Email should not be editable
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _ageController,
                            label: 'Age',
                            icon: Icons.cake_outlined,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                final age = int.tryParse(value);
                                if (age == null || age < 1 || age > 120) {
                                  return 'Enter valid age';
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _bloodTypeController,
                            label: 'Blood Type',
                            icon: Icons.bloodtype,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value != null && value.trim().isNotEmpty) {
                          if (value.trim().length < 10) {
                            return 'Please enter a valid phone number';
                          }
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Medical Information Section
                    _buildSectionTitle('Medical Information'),
                    const SizedBox(height: 16),
                    
                    _buildTextField(
                      controller: _allergiesController,
                      label: 'Allergies (comma separated)',
                      icon: Icons.warning_outlined,
                      maxLines: 2,
                      hintText: 'e.g., Penicillin, Peanuts, Shellfish',
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Emergency Contact Section
                    _buildSectionTitle('Emergency Contact'),
                    const SizedBox(height: 16),
                    
                    _buildTextField(
                      controller: _emergencyContactController,
                      label: 'Emergency Contact Name',
                      icon: Icons.contact_emergency_outlined,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _buildTextField(
                      controller: _emergencyPhoneController,
                      label: 'Emergency Contact Phone',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE91E63),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 2,
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF7B1FA2),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hintText,
    TextInputType? keyboardType,
    bool enabled = true,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: TextStyle(
        color: enabled ? const Color(0xFF5A5A5A) : Colors.grey,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        labelStyle: TextStyle(
          color: enabled ? const Color(0xFF9575CD) : Colors.grey,
        ),
        hintStyle: const TextStyle(
          color: Colors.grey,
          fontSize: 14,
        ),
        filled: true,
        fillColor: enabled ? const Color(0xFFF5F5F5) : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFE91E63),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1,
          ),
        ),
        prefixIcon: Icon(
          icon,
          color: enabled ? const Color(0xFF9575CD) : Colors.grey,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      ),
    );
  }
}
