import 'package:flutter/material.dart';
import 'patientDashboard.dart';

class RoleMotherP2 extends StatelessWidget {
  const RoleMotherP2({super.key});

  @override
  Widget build(BuildContext context) {
    return const DeliveryDetailsForm();
  }
}

void main() {
  runApp(const DeliveryDetailsApp());
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
      home: const DeliveryDetailsForm(),
    );
  }
}

class DeliveryDetailsForm extends StatefulWidget {
  const DeliveryDetailsForm({super.key});

  @override
  State<DeliveryDetailsForm> createState() => _DeliveryDetailsFormState();
}

class _DeliveryDetailsFormState extends State<DeliveryDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  final _estimatedDueDateController = TextEditingController();
  final _pregnancyConfirmedController = TextEditingController();
  final _medicalHistoryController = TextEditingController();
  final _weightController = TextEditingController();
  
  DateTime? _selectedEstimatedDueDate;
  DateTime? _selectedPregnancyDate;
  String? _firstChildValue;
  String? _pregnancyLossValue;

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
          ? DateTime.now().add(const Duration(days: 180)) // Default to ~6 months from now for due date
          : DateTime.now().subtract(const Duration(days: 30)), // Default to ~1 month ago for confirmation date
      firstDate: isEstimatedDueDate 
          ? DateTime.now().add(const Duration(days: 90)) // Minimum 3 months from now for due date
          : DateTime.now().subtract(const Duration(days: 280)), // Up to 40 weeks ago for confirmation
      lastDate: isEstimatedDueDate 
          ? DateTime.now().add(const Duration(days: 365)) // Maximum 1 year from now for due date
          : DateTime.now(), // Today is the latest for confirmation date
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE91E63), // Soft pink
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF5A5A5A),
            ), dialogTheme: DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
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
                              // Estimated Due Date (Required)
                              TextFormField(
                                controller: _estimatedDueDateController,
                                readOnly: true,
                                style: const TextStyle(color: Color(0xFF5A5A5A)),
                                decoration: InputDecoration(
                                  labelText: 'Estimated Due Date *',
                                  labelStyle: const TextStyle(color: Color(0xFF9575CD)),
                                  filled: true,
                                  fillColor: const Color(0xFFF5F5F5),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixIcon: const Icon(Icons.calendar_month_outlined, color: Color(0xFFE91E63)),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                  helperText: 'When is your baby expected to arrive?',
                                  helperStyle: const TextStyle(color: Color(0xFF9575CD), fontSize: 12),
                                ),
                                onTap: () => _selectDate(context, true),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please select your estimated due date';
                                  }
                                  // Validate that the due date is in the future and reasonable
                                  if (_selectedEstimatedDueDate != null) {
                                    final now = DateTime.now();
                                    final daysDifference = _selectedEstimatedDueDate!.difference(now).inDays;
                                    if (daysDifference < 90) {
                                      return 'Due date should be at least 3 months from now';
                                    }
                                    if (daysDifference > 365) {
                                      return 'Due date should be within a year from now';
                                    }
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              
                              // Pregnancy Confirmed Date
                              TextFormField(
                                controller: _pregnancyConfirmedController,
                                readOnly: true,
                                style: const TextStyle(color: Color(0xFF5A5A5A)),
                                decoration: InputDecoration(
                                  labelText: 'Pregnancy Confirmed Date *',
                                  labelStyle: const TextStyle(color: Color(0xFF9575CD)),
                                  filled: true,
                                  fillColor: const Color(0xFFF5F5F5),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixIcon: const Icon(Icons.event_available_outlined, color: Color(0xFFE91E63)),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                  helperText: 'When did a doctor confirm your pregnancy?',
                                  helperStyle: const TextStyle(color: Color(0xFF9575CD), fontSize: 12),
                                ),
                                onTap: () => _selectDate(context, false),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please select pregnancy confirmation date';
                                  }
                                  // Validate that confirmation date is in the past
                                  if (_selectedPregnancyDate != null) {
                                    final now = DateTime.now();
                                    if (_selectedPregnancyDate!.isAfter(now)) {
                                      return 'Confirmation date cannot be in the future';
                                    }
                                    // Check if confirmation date is reasonable (not too far in the past)
                                    final daysDifference = now.difference(_selectedPregnancyDate!).inDays;
                                    if (daysDifference > 280) {
                                      return 'Confirmation date seems too far in the past';
                                    }
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
                                initialValue: _firstChildValue,
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
                                initialValue: _pregnancyLossValue,
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
                              const SizedBox(height: 24),
                              
                              // Continue Button
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const HomeScreen(),
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFE91E63),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  child: const Text(
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