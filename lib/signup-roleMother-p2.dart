import 'package:flutter/material.dart';
import 'signin.dart';
import 'services/backend_service.dart';
import 'services/session_manager.dart';
import 'models/pregnancy_tracking.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RoleMotherP2 extends StatefulWidget {
  const RoleMotherP2({super.key});

  @override
  State<RoleMotherP2> createState() => _RoleMotherP2State();
}

class _RoleMotherP2State extends State<RoleMotherP2> {
  final _formKey = GlobalKey<FormState>();
  final _estimatedDueDateController = TextEditingController();
  final _pregnancyConfirmedController = TextEditingController();
  final _medicalHistoryController = TextEditingController();
  final _weightController = TextEditingController();
  final BackendService _backendService = BackendService();
  
  DateTime? _selectedEstimatedDueDate;
  DateTime? _selectedPregnancyDate;
  String _firstChildValue = 'No'; // Initialize with default value
  String _pregnancyLossValue = 'No'; // Initialize with default value
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        await FirebaseAuth.instance.authStateChanges().first;
        user = FirebaseAuth.instance.currentUser;
      }

      if (user != null) {
        _loadUserData(user.uid);
      } else {
        print("⚠️ No Firebase user found");
      }
    } catch (e) {
      print("Error initializing user: $e");
    }
  }

  Future<void> _loadUserData(String uid) async {
    print("Loading user data for UID: $uid");
  }

  @override
  void dispose() {
    _estimatedDueDateController.dispose();
    _pregnancyConfirmedController.dispose();
    _medicalHistoryController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isEstimatedDueDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isEstimatedDueDate 
          ? DateTime.now().add(const Duration(days: 180))
          : DateTime.now().subtract(const Duration(days: 30)),
      firstDate: isEstimatedDueDate 
          ? DateTime.now().add(const Duration(days: 90))
          : DateTime.now().subtract(const Duration(days: 280)),
      lastDate: isEstimatedDueDate 
          ? DateTime.now().add(const Duration(days: 365))
          : DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE91E63),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF5A5A5A),
            ),
            dialogTheme: DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child ?? const SizedBox(), // Never pass null
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        if (isEstimatedDueDate) {
          _selectedEstimatedDueDate = picked;
          _estimatedDueDateController.text = "${picked.day}/${picked.month}/${picked.year}";
        } else {
          _selectedPregnancyDate = picked;
          _pregnancyConfirmedController.text = "${picked.day}/${picked.month}/${picked.year}";
          
          // Automatically calculate and fill the estimated due date (40 weeks = 280 days)
          final calculatedDueDate = picked.add(const Duration(days: 280));
          _selectedEstimatedDueDate = calculatedDueDate;
          _estimatedDueDateController.text = "${calculatedDueDate.day}/${calculatedDueDate.month}/${calculatedDueDate.year}";
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Estimated due date automatically set to: ${calculatedDueDate.day}/${calculatedDueDate.month}/${calculatedDueDate.year}',
              ),
              backgroundColor: const Color(0xFF4CAF50),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      });
    }
  }

  Future<void> _handleSignUp() async {
    // First check if all required fields are filled
    if (_pregnancyConfirmedController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select pregnancy confirmation date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_estimatedDueDateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select estimated due date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_weightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your weight'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final weight = double.tryParse(_weightController.text);
    if (weight == null || weight <= 0 || weight > 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid weight between 1 and 200 kg'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = await SessionManager.getUserId();
      if (userId == null) {
        throw Exception('User not found. Please login again.');
      }

      DateTime? expectedDeliveryDate = _selectedEstimatedDueDate;
      if (expectedDeliveryDate == null && _selectedPregnancyDate != null) {
        expectedDeliveryDate = _selectedPregnancyDate!.add(const Duration(days: 280));
      }

      final now = DateTime.now();
      int currentWeek = 0;
      int currentDay = 0;
      
      if (_selectedPregnancyDate != null) {
        final daysSinceConfirmation = now.difference(_selectedPregnancyDate!).inDays;
        currentWeek = (daysSinceConfirmation / 7).floor();
        currentDay = daysSinceConfirmation % 7;
        
        if (daysSinceConfirmation < 0) {
          currentWeek = 0;
          currentDay = 0;
        }
      }

      final pregnancyTracking = PregnancyTracking(
        userId: userId,
        pregnancyConfirmedDate: _selectedPregnancyDate,
        expectedDeliveryDate: expectedDeliveryDate,
        currentWeek: currentWeek,
        currentDay: currentDay,
        trimester: PregnancyTracking.getTrimester(currentWeek),
        weight: weight,
        isFirstChild: _firstChildValue == 'Yes',
        hasPregnancyLoss: _pregnancyLossValue == 'Yes',
        medicalHistory: _medicalHistoryController.text.trim(),
        symptoms: [],
        medications: [],
        vitals: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await _backendService.savePregnancyTracking(pregnancyTracking);
      
      if (success) {
        final firebaseSuccess = await _backendService.updatePatientPregnancyInfo(
          userId,
          expectedDeliveryDate: expectedDeliveryDate,
          pregnancyConfirmedDate: _selectedPregnancyDate,
          weight: weight,
          isFirstChild: _firstChildValue == 'Yes',
          hasPregnancyLoss: _pregnancyLossValue == 'Yes',
          medicalHistory: _medicalHistoryController.text.trim(),
        );
        
        if (!firebaseSuccess) {
          print('Warning: Failed to save pregnancy details to Firebase patient collection');
        }
        
        await SessionManager.clearSession();
        
        if (mounted) {
          Fluttertoast.showToast(
            msg: "Registration successful! Please login",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: const Color(0xFF4CAF50),
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const SignInApp(),
            ),
          );
        }
      } else {
        throw Exception('Failed to save pregnancy details');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
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
            top: -80,
            left: -60,
            child: Transform.rotate(
              angle: -0.5,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(80),
                  color: const Color(0xFFF8BBD0).withOpacity(0.3), // Soft pink
                ),
              ),
            ),
          ),
          Positioned(
            right: -80,
            bottom: -120,
            child: Transform.rotate(
              angle: 0.6,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: const Color(0xFFE1BEE7).withOpacity(0.3), // Soft lavender
                ),
              ),
            ),
          ),
          
          // Additional subtle background element
          Positioned(
            top: 150,
            right: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFCCBC).withOpacity(0.4), // Soft peach
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
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                          border: Border.all(
                            color: const Color(0xFFFFCDD2).withOpacity(0.5),
                            width: 1.5,
                            ),
                          color: Colors.white,
                          image: const DecorationImage(
                            image: AssetImage('assets/logo.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Title
                      const Text(
                        'Pregnancy Details',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF7B1FA2), // Soft purple
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Subtitle
                      const Text(
                        'Please provide your pregnancy information to get personalized tracking',
                        style: TextStyle(
                          color: Color(0xFF9575CD), // Light purple
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.center,
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
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Pregnancy Confirmed Date
                            _buildDateField(
                              'Pregnancy Confirmed Date *',
                              Icons.calendar_today,
                              _pregnancyConfirmedController,
                              () => _selectDate(context, false),
                            ),
                            const SizedBox(height: 20),

                            // Estimated Due Date
                            _buildDateField(
                              'Estimated Due Date *',
                              Icons.event_available,
                              _estimatedDueDateController,
                              () => _selectDate(context, true),
                            ),
                            const SizedBox(height: 20),

                            // Weight
                            _buildInputField(
                              'Current Weight (kg) *',
                              Icons.monitor_weight,
                              controller: _weightController,
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 20),

                            // First Child - Using Radio Buttons instead of Dropdown
                            _buildRadioGroup(
                              'Is this your first child? *',
                              _firstChildValue,
                              (String? value) {
                                if (value != null) {
                                  setState(() {
                                    _firstChildValue = value;
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 20),

                            // Pregnancy Loss - Using Radio Buttons instead of Dropdown
                            _buildRadioGroup(
                              'Any previous pregnancy loss? *',
                              _pregnancyLossValue,
                              (String? value) {
                                if (value != null) {
                                  setState(() {
                                    _pregnancyLossValue = value;
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 20),

                            // Medical History (Optional)
                            _buildInputField(
                              'Medical History (Optional)',
                              Icons.medical_services,
                              controller: _medicalHistoryController,
                              maxLines: 3,
                            ),
                            const SizedBox(height: 40),

                            // Submit Button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleSignUp,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE91E63),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 2,
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
                                    : const Text(
                                        'Complete Registration',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Back to sign in prompt
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E5F5).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Remember your account?",
                              style: TextStyle(
                                color: Color(0xFF7E57C2),
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SignInApp(),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                backgroundColor: const Color(0xFFE91E63).withOpacity(0.15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Sign In',
                                style: TextStyle(
                                  color: Color(0xFFE91E63),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
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
        prefixIcon: Icon(icon, color: const Color(0xFF9575CD)),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
    );
  }

  Widget _buildDateField(
    String label,
    IconData icon,
    TextEditingController controller,
    VoidCallback onTap,
  ) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
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
        prefixIcon: Icon(icon, color: const Color(0xFF9575CD)),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFF9575CD)),
      ),
    );
  }

  Widget _buildRadioGroup(
    String title,
    String selectedValue,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF9575CD),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Radio<String>(
                      value: 'Yes',
                      groupValue: selectedValue,
                      onChanged: onChanged,
                      activeColor: const Color(0xFFE91E63),
                    ),
                    const Text('Yes', style: TextStyle(color: Color(0xFF5A5A5A))),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Radio<String>(
                      value: 'No',
                      groupValue: selectedValue,
                      onChanged: onChanged,
                      activeColor: const Color(0xFFE91E63),
                    ),
                    const Text('No', style: TextStyle(color: Color(0xFF5A5A5A))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}