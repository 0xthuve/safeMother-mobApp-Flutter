import 'package:flutter/material.dart';

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
        scaffoldBackgroundColor: const Color(0xFF0F1724),
        colorScheme: ColorScheme.fromSwatch().copyWith(primary: const Color(0xFF1993E5)),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
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
  final _deliveryDateController = TextEditingController();
  final _pregnancyConfirmedController = TextEditingController();
  final _medicalHistoryController = TextEditingController();
  final _weightController = TextEditingController();
  
  DateTime? _selectedDeliveryDate;
  DateTime? _selectedPregnancyDate;
  String? _firstChildValue;
  String? _pregnancyLossValue;
  String? _babyBornValue;

  @override
  void dispose() {
    _deliveryDateController.dispose();
    _pregnancyConfirmedController.dispose();
    _medicalHistoryController.dispose();
    _weightController.dispose();
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
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF1993E5),
              onPrimary: Colors.white,
              surface: Color(0xFF0F1724),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF0F1724),
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
          // NEW BACKGROUND: Different gradient direction and colors
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0A1A30), Color(0xFF142540)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          
          // NEW BACKGROUND ELEMENTS: Different shapes and positioning
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF34D399).withOpacity(0.08),
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
                  color: const Color(0xFFFB7185).withOpacity(0.06),
                ),
              ),
            ),
          ),
          
          // Subtle pattern overlay for visual distinction
          Opacity(
            opacity: 0.03,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/subtle_pattern.png'), // Optional pattern
                  repeat: ImageRepeat.repeat,
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
                      // Logo with slightly different styling
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                          border: Border.all(
                            color: const Color(0xFF34D399).withOpacity(0.3),
                            width: 2,
                          ),
                          image: const DecorationImage(
                            image: AssetImage('assets/logo.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Title with different color accent
                      const Text(
                        'Delivery Details',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Subtitle
                      const Text(
                        'Tell us about your pregnancy journey',
                        style: TextStyle(color: Color(0xFF98A8B8)),
                      ),
                      const SizedBox(height: 32),
                      
                      // Form container with slightly different styling
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF34D399).withOpacity(0.1),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
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
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'Delivery Date (Optional)',
                                  labelStyle: const TextStyle(color: Color(0xFF9FB3C6)),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.07),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixIcon: const Icon(Icons.calendar_today_outlined, color: Color(0xFF34D399)),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                ),
                                onTap: () => _selectDate(context, true),
                              ),
                              const SizedBox(height: 16),
                              
                              // Pregnancy Confirmed Date
                              TextFormField(
                                controller: _pregnancyConfirmedController,
                                readOnly: true,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'Pregnancy Confirmed Date',
                                  labelStyle: const TextStyle(color: Color(0xFF9FB3C6)),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.07),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixIcon: const Icon(Icons.event_available_outlined, color: Color(0xFF34D399)),
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
                                  labelStyle: const TextStyle(color: Color(0xFF9FB3C6)),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.07),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixIcon: const Icon(Icons.child_care_outlined, color: Color(0xFF34D399)),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                ),
                                style: const TextStyle(color: Colors.white),
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
                                  labelStyle: const TextStyle(color: Color(0xFF9FB3C6)),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.07),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixIcon: const Icon(Icons.heart_broken_outlined, color: Color(0xFF34D399)),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                ),
                                style: const TextStyle(color: Colors.white),
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
                                  labelStyle: const TextStyle(color: Color(0xFF9FB3C6)),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.07),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixIcon: const Icon(Icons.celebration_outlined, color: Color(0xFF34D399)),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                ),
                                style: const TextStyle(color: Colors.white),
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
                              const SizedBox(height: 24),
                              
                              // Continue Button with different color accent
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const NextPage(),
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF34D399),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  child: const Text(
                                    'Continue',
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
                      
                      // Back to previous page with different styling
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.arrow_back_ios, size: 16, color: Color(0xFF34D399)),
                            SizedBox(width: 8),
                            Text(
                              'Back to previous step',
                              style: TextStyle(
                                color: Color(0xFF34D399),
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
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF9FB3C6)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.07),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF34D399)),
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
      backgroundColor: const Color(0xFF0F1724),
      body: const Center(
        child: Text(
          'Next Page',
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
      ),
    );
  }
}