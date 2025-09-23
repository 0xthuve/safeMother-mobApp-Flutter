import 'package:flutter/material.dart';
import 'patientDashboard.dart';
import 'models/mother_signup_data.dart';
import 'services/auth_service.dart';
import 'signin.dart';

class RoleMotherP2 extends StatelessWidget {
  final MotherSignupData signupData;
  
  const RoleMotherP2({super.key, required this.signupData});

  @override
  Widget build(BuildContext context) {
    return DeliveryDetailsForm(signupData: signupData);
  }
}

void main() {
  runApp(DeliveryDetailsApp());
}

class DeliveryDetailsApp extends StatelessWidget {
  const DeliveryDetailsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Safe Mother - Delivery Details',
      theme: ThemeData(
        fontFamily: 'Lexend',
        scaffoldBackgroundColor: const Color(0xFFF8F6F8), // Soft off-white background
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFFE91E63), // Soft pink accent
          secondary: const Color(0xFF9C27B0), // Soft purple
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color(0xFF5A5A5A)), // Dark gray text
        ),
      ),
      home: DeliveryDetailsForm(
        signupData: MotherSignupData()..fullName = 'Test User', // Dummy data for main function
      ),
    );
  }
}

class DeliveryDetailsForm extends StatefulWidget {
  final MotherSignupData signupData;
  
  const DeliveryDetailsForm({super.key, required this.signupData});

  @override
  State<DeliveryDetailsForm> createState() => _DeliveryDetailsFormState();
}

class _DeliveryDetailsFormState extends State<DeliveryDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  final _deliveryDateController = TextEditingController();
  final _pregnancyConfirmedController = TextEditingController();
  final _medicalHistoryController = TextEditingController();
  final _weightController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _familyMemberEmailController = TextEditingController();
  
  DateTime? _selectedDeliveryDate;
  DateTime? _selectedPregnancyDate;
  String? _firstChildValue;
  String? _pregnancyLossValue;
  String? _babyBornValue;
  bool _isLoading = false;

  @override
  void dispose() {
    _deliveryDateController.dispose();
    _pregnancyConfirmedController.dispose();
    _medicalHistoryController.dispose();
    _weightController.dispose();
    _emergencyContactController.dispose();
    _familyMemberEmailController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isDeliveryDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE91E63), // Soft pink
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF5A5A5A),
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        if (isDeliveryDate) {
          _selectedDeliveryDate = picked;
          _deliveryDateController.text = "${picked.day}/${picked.month}/${picked.year}";
        } else {
          _selectedPregnancyDate = picked;
          _pregnancyConfirmedController.text = "${picked.day}/${picked.month}/${picked.year}";
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Soft gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFBE9E7), Color(0xFFF8F6F8)], // Soft peach to off-white
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          
          // Decorative shapes with softer colors
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFCCBC).withOpacity(0.4), // Soft peach
              ),
            ),
          ),
          
          Positioned(
            bottom: -60,
            left: -60,
            child: Transform.rotate(
              angle: 0.8,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(60),
                  color: const Color(0xFFF8BBD0).withOpacity(0.3), // Soft pink
                ),
              ),
            ),
          ),
          
          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Logo with soft styling
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.pink[100]!, // Soft pink shadow
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                          border: Border.all(
                            color: const Color(0xFFFFCDD2).withOpacity(0.5),
                            width: 2,
                          ),
                          color: Colors.white,
                        ),
                        child: const Icon(
                          Icons.favorite,
                          size: 40,
                          color: Color(0xFFE91E63), // Soft pink
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Title
                      const Text(
                        'Delivery Details',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF7B1FA2), // Soft purple
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Subtitle
                      const Text(
                        'Tell us about your pregnancy journey',
                        style: TextStyle(
                          color: Color(0xFF9575CD), // Light purple
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Form container with soft styling
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFF3E5F5).withOpacity(0.8),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple[50]!, // Very soft purple shadow
                              blurRadius: 25,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Delivery Date (Optional)
                              TextFormField(
                                controller: _deliveryDateController,
                                readOnly: true,
                                style: const TextStyle(color: Color(0xFF5A5A5A)),
                                decoration: InputDecoration(
                                  labelText: 'Delivery Date (Optional)',
                                  labelStyle: const TextStyle(color: Color(0xFF9575CD)),
                                  filled: true,
                                  fillColor: const Color(0xFFF5F5F5),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixIcon: const Icon(Icons.calendar_today_outlined, color: Color(0xFFE91E63)),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                ),
                                onTap: () => _selectDate(context, true),
                              ),
                              const SizedBox(height: 16),
                              
                              // Pregnancy Confirmed Date
                              TextFormField(
                                controller: _pregnancyConfirmedController,
                                readOnly: true,
                                style: const TextStyle(color: Color(0xFF5A5A5A)),
                                decoration: InputDecoration(
                                  labelText: 'Pregnancy Confirmed Date',
                                  labelStyle: const TextStyle(color: Color(0xFF9575CD)),
                                  filled: true,
                                  fillColor: const Color(0xFFF5F5F5),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixIcon: const Icon(Icons.event_available_outlined, color: Color(0xFFE91E63)),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                ),
                                onTap: () => _selectDate(context, false),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please select pregnancy confirmation date';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              
                              // Medical History
                              _buildInputField(
                                'Medical History',
                                Icons.medical_services_outlined,
                                controller: _medicalHistoryController,
                                maxLines: 3,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please provide your medical history';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              
                              // Weight
                              _buildInputField(
                                'Weight (kg)',
                                Icons.monitor_weight_outlined,
                                controller: _weightController,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your weight';
                                  }
                                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                                    return 'Please enter a valid weight';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              
                              // First Child?
                              DropdownButtonFormField<String>(
                                value: _firstChildValue,
                                decoration: InputDecoration(
                                  labelText: 'First Child?',
                                  labelStyle: const TextStyle(color: Color(0xFF9575CD)),
                                  filled: true,
                                  fillColor: const Color(0xFFF5F5F5),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixIcon: const Icon(Icons.child_care_outlined, color: Color(0xFFE91E63)),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                ),
                                style: const TextStyle(color: Color(0xFF5A5A5A)),
                                items: const [
                                  DropdownMenuItem(value: 'Yes', child: Text('Yes')),
                                  DropdownMenuItem(value: 'No', child: Text('No')),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _firstChildValue = value;
                                  });
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select an option';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              
                              // Pregnancy loss?
                              DropdownButtonFormField<String>(
                                value: _pregnancyLossValue,
                                decoration: InputDecoration(
                                  labelText: 'Pregnancy Loss?',
                                  labelStyle: const TextStyle(color: Color(0xFF9575CD)),
                                  filled: true,
                                  fillColor: const Color(0xFFF5F5F5),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixIcon: const Icon(Icons.heart_broken_outlined, color: Color(0xFFE91E63)),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                ),
                                style: const TextStyle(color: Color(0xFF5A5A5A)),
                                items: const [
                                  DropdownMenuItem(value: 'Yes', child: Text('Yes')),
                                  DropdownMenuItem(value: 'No', child: Text('No')),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _pregnancyLossValue = value;
                                  });
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select an option';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              
                              // Baby already born?
                              DropdownButtonFormField<String>(
                                value: _babyBornValue,
                                decoration: InputDecoration(
                                  labelText: 'Baby Already Born?',
                                  labelStyle: const TextStyle(color: Color(0xFF9575CD)),
                                  filled: true,
                                  fillColor: const Color(0xFFF5F5F5),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixIcon: const Icon(Icons.celebration_outlined, color: Color(0xFFE91E63)),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                ),
                                style: const TextStyle(color: Color(0xFF5A5A5A)),
                                items: const [
                                  DropdownMenuItem(value: 'Yes', child: Text('Yes')),
                                  DropdownMenuItem(value: 'No', child: Text('No')),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _babyBornValue = value;
                                  });
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select an option';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              
                              // Emergency Contact (Optional)
                              _buildInputField(
                                'Emergency Contact (Optional)',
                                Icons.emergency_outlined,
                                controller: _emergencyContactController,
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 16),
                              
                              // Family Member Email (Optional)
                              _buildInputField(
                                'Family Member Email (Optional)',
                                Icons.family_restroom_outlined,
                                controller: _familyMemberEmailController,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 24),
                              
                              // Complete Sign Up Button
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : () async {
                                    if (_formKey.currentState!.validate()) {
                                      setState(() {
                                        _isLoading = true;
                                      });

                                      try {
                                        // Update signup data with page 2 info
                                        final completeData = widget.signupData
                                          ..deliveryDate = _selectedDeliveryDate
                                          ..pregnancyConfirmedDate = _selectedPregnancyDate
                                          ..medicalHistory = _medicalHistoryController.text.trim()
                                          ..weight = double.parse(_weightController.text.trim())
                                          ..isFirstChild = _firstChildValue == 'Yes'
                                          ..hasPregnancyLoss = _pregnancyLossValue == 'Yes'
                                          ..isBabyBorn = _babyBornValue == 'Yes'
                                          ..emergencyContact = _emergencyContactController.text.trim().isEmpty 
                                              ? null : _emergencyContactController.text.trim()
                                          ..familyMemberEmail = _familyMemberEmailController.text.trim().isEmpty 
                                              ? null : _familyMemberEmailController.text.trim();

                                        // Register the mother with complete data
                                        final result = await AuthService.registerMother(
                                          fullName: completeData.fullName,
                                          age: completeData.age,
                                          username: completeData.username,
                                          email: completeData.email,
                                          password: completeData.password,
                                          location: completeData.location,
                                          estimatedDueDate: completeData.estimatedDueDate!,
                                          emergencyContact: completeData.emergencyContact,
                                          medicalConditions: completeData.medicalHistory,
                                          currentMedications: null,
                                          allergies: null,
                                          previousPregnancies: completeData.isFirstChild ? '0' : 'Yes',
                                          familyMemberEmail: completeData.familyMemberEmail,
                                        );

                                        if (result.success) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Welcome to Safe Mother, ${completeData.fullName}!'),
                                                backgroundColor: const Color(0xFF4CAF50),
                                                behavior: SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                              ),
                                            );

                                            // Navigate to dashboard
                                            Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => const HomeScreen(),
                                              ),
                                              (route) => false, // Remove all previous routes
                                            );
                                          }
                                        } else {
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(result.message),
                                                backgroundColor: const Color(0xFFE91E63),
                                                behavior: SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Registration failed: ${e.toString()}'),
                                              backgroundColor: const Color(0xFFE91E63),
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
                                            _isLoading = false;
                                          });
                                        }
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFE91E63),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : const Text(
                                          'Complete Sign Up',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Back to previous page
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.arrow_back_ios, size: 16, color: Color(0xFFE91E63)),
                            SizedBox(width: 8),
                            Text(
                              'Back to previous step',
                              style: TextStyle(
                                color: Color(0xFFE91E63),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
    String label,
    IconData icon, {
    TextEditingController? controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Color(0xFF5A5A5A)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF9575CD)),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFFE91E63)),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      validator: validator,
    );
  }
}

// Dummy Next Page
class NextPage extends StatelessWidget {
  const NextPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F8),
      body: const Center(
        child: Text(
          'Next Page',
          style: TextStyle(color: Color(0xFF5A5A5A), fontSize: 22),
        ),
      ),
    );
  }
}