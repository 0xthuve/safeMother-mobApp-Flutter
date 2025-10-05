import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/symptom_log.dart';
import 'services/backend_service.dart';
import 'bottom_navigation.dart';
import 'navigation_handler.dart';

class PatientDashboardLog extends StatefulWidget {
  @override
  _PatientDashboardLogState createState() => _PatientDashboardLogState();
}

class _PatientDashboardLogState extends State<PatientDashboardLog> {
  final _formKey = GlobalKey<FormState>();
  final BackendService _backendService = BackendService();
  final int _currentIndex = 1; // This is the Log tab (index 1)

  // Form controllers
  final _bloodPressureController = TextEditingController();
  final _weightController = TextEditingController();
  final _symptomsController = TextEditingController();
  final _notesController = TextEditingController();
  final _sleepHoursController = TextEditingController();
  final _waterIntakeController = TextEditingController();
  final _exerciseMinutesController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _nauseaController = TextEditingController();

  // Form data
  int _babyKicks = 0;
  String _mood = 'Good';
  String _energyLevel = 'Normal';
  String _appetiteLevel = 'Normal';
  String _painLevel = 'None';
  bool _hadContractions = false;
  bool _hadHeadaches = false;
  bool _hadSwelling = false;
  bool _tookVitamins = false;
  bool _isLoading = false;
  List<SymptomLog> _recentLogs = [];

  final List<String> _moodOptions = [
    'Excellent',
    'Good',
    'Okay',
    'Low',
    'Anxious',
  ];

  final List<String> _energyLevelOptions = [
    'Very High',
    'High',
    'Normal',
    'Low',
    'Very Low',
  ];

  final List<String> _appetiteLevelOptions = [
    'Excellent',
    'Good',
    'Normal',
    'Poor',
    'None',
  ];

  final List<String> _painLevelOptions = [
    'None',
    'Mild',
    'Moderate',
    'Severe',
    'Extreme',
  ];

  @override
  void initState() {
    super.initState();
    _loadRecentLogs();
  }

  void _onItemTapped(int index) {
    if (index == _currentIndex) return;
    NavigationHandler.navigateToScreen(context, index);
  }

  Future<void> _loadRecentLogs() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final logs = await _backendService.getRecentSymptomLogs(user.uid);
      setState(() {
        _recentLogs = logs;
      });
    } catch (e) {
      print('Error loading recent logs: $e');
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final symptomLog = SymptomLog(
        patientId: user.uid,
        bloodPressure: _bloodPressureController.text,
        weight: _weightController.text,
        babyKicks: _babyKicks.toString(),
        mood: _mood,
        symptoms: _symptomsController.text,
        additionalNotes: _notesController.text,
        sleepHours: _sleepHoursController.text,
        waterIntake: _waterIntakeController.text,
        exerciseMinutes: _exerciseMinutesController.text,
        energyLevel: _energyLevel,
        appetiteLevel: _appetiteLevel,
        painLevel: _painLevel,
        hadContractions: _hadContractions,
        hadHeadaches: _hadHeadaches,
        hadSwelling: _hadSwelling,
        tookVitamins: _tookVitamins,
        nauseaDetails: _nauseaController.text,
        medications: _medicationsController.text,
        logDate: now,
        createdAt: now,
        updatedAt: now,
      );

      await _backendService.saveSymptomLog(symptomLog);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Health information saved successfully!'),
          backgroundColor: const Color(0xFF7B1FA2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      _resetForm();
      _loadRecentLogs();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving health information: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _bloodPressureController.clear();
    _weightController.clear();
    _symptomsController.clear();
    _notesController.clear();
    setState(() {
      _babyKicks = 0;
      _mood = 'Good';
    });
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color iconColor,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        style: TextStyle(fontSize: 16, color: Color(0xFF2D1B69)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Color(0xFF666666), fontSize: 14),
          prefixIcon: Container(
            margin: EdgeInsets.all(8),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          filled: true,
          fillColor: Color(0xFFF8F9FA),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Color(0xFFE0E0E0), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Color(0xFF7B1FA2), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.red, width: 1),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildKickCounter() {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF7B1FA2).withOpacity(0.1),
            Color(0xFF9C27B0).withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Color(0xFFE0E0E0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFF7B1FA2).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.child_friendly, color: Color(0xFF7B1FA2)),
              ),
              SizedBox(width: 12),
              Text(
                'Baby Kicks Counter',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D1B69),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      if (_babyKicks > 0) _babyKicks--;
                    });
                  },
                  icon: Icon(Icons.remove, color: Colors.red, size: 24),
                ),
              ),
              SizedBox(width: 20),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF7B1FA2).withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '$_babyKicks',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7B1FA2),
                  ),
                ),
              ),
              SizedBox(width: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      _babyKicks++;
                    });
                  },
                  icon: Icon(Icons.add, color: Colors.green, size: 24),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSelector() {
    final moodIcons = {
      'Excellent': Icons.sentiment_very_satisfied,
      'Good': Icons.sentiment_satisfied,
      'Okay': Icons.sentiment_neutral,
      'Low': Icons.sentiment_dissatisfied,
      'Anxious': Icons.sentiment_very_dissatisfied,
    };

    final moodColors = {
      'Excellent': Colors.green,
      'Good': Colors.lightGreen,
      'Okay': Colors.orange,
      'Low': Colors.deepOrange,
      'Anxious': Colors.red,
    };

    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: moodColors[_mood]!.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(moodIcons[_mood], color: moodColors[_mood]),
              ),
              SizedBox(width: 12),
              Text(
                'How are you feeling?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D1B69),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _moodOptions.map((mood) {
              final isSelected = _mood == mood;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _mood = mood;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (moodColors[mood] ?? Colors.grey)
                        : Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? (moodColors[mood] ?? Colors.grey)
                          : Color(0xFFE0E0E0),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        moodIcons[mood],
                        color: isSelected
                            ? Colors.white
                            : (moodColors[mood] ?? Colors.grey),
                        size: 18,
                      ),
                      SizedBox(width: 6),
                      Text(
                        mood,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Color(0xFF2D1B69),
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownSelector({
    required String title,
    required List<String> options,
    required String selectedValue,
    required Function(String) onChanged,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D1B69),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),

          DropdownButtonFormField<String>(
            value: selectedValue,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(0xFF7B1FA2), width: 2),
              ),
            ),
            items: options.map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                onChanged(newValue);
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFF5E8FF),
                  Color(0xFFF9F7F9),
                ], // Soft lavender to off-white
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Decorative shapes
          Positioned(
            top: -50,
            left: -30,
            child: Transform.rotate(
              angle: -0.3,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(60),
                  color: const Color(
                    0xFFD1C4E9,
                  ).withOpacity(0.4), // Soft lavender
                ),
              ),
            ),
          ),

          Positioned(
            top: 100,
            right: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE1BEE7).withOpacity(0.3), // Light purple
              ),
            ),
          ),

          Positioned(
            right: -60,
            bottom: -90,
            child: Transform.rotate(
              angle: 0.4,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(80),
                  color: const Color(
                    0xFFC5CAE9,
                  ).withOpacity(0.3), // Soft blue-purple
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with back button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          // Navigate back to dashboard (index 0)
                          NavigationHandler.navigateToScreen(context, 0);
                        },
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF5A5A5A),
                        ),
                      ),
                      const Text(
                        'Health Log',
                        style: TextStyle(
                          color: Color(0xFF7B1FA2),
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 48), // For balance
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Baby Kicks Counter Section
                  Container(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF7B1FA2).withOpacity(0.3),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.favorite,
                            color: Color(0xFF7B1FA2),
                            size: 28,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Health Journal',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D1B69),
                                ),
                              ),
                              Text(
                                'Track your pregnancy journey',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF666666),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Health Log Form Content
                  Container(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Beautiful Health Log Form
                        Container(
                          padding: EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF7B1FA2).withOpacity(0.1),
                                blurRadius: 15,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Color(
                                          0xFF7B1FA2,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        Icons.health_and_safety,
                                        color: Color(0xFF7B1FA2),
                                        size: 24,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Today\'s Health Check',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2D1B69),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 24),

                                // Blood Pressure
                                _buildCustomTextField(
                                  controller: _bloodPressureController,
                                  label: 'Blood Pressure (e.g., 120/80)',
                                  icon: Icons.favorite,
                                  iconColor: Color(0xFF7B1FA2),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your blood pressure';
                                    }
                                    return null;
                                  },
                                ),

                                // Weight
                                _buildCustomTextField(
                                  controller: _weightController,
                                  label: 'Weight (kg)',
                                  icon: Icons.monitor_weight,
                                  iconColor: Color(0xFF9C27B0),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your weight';
                                    }
                                    return null;
                                  },
                                ),

                                // Baby Kicks Counter
                                _buildKickCounter(),

                                // Mood Selection
                                _buildMoodSelector(),

                                // Symptoms
                                _buildCustomTextField(
                                  controller: _symptomsController,
                                  label: 'Symptoms (if any)',
                                  icon: Icons.healing,
                                  iconColor: Color(0xFFFF9800),
                                  maxLines: 2,
                                ),

                                // Sleep Hours
                                _buildCustomTextField(
                                  controller: _sleepHoursController,
                                  label: 'Sleep Hours (e.g., 8)',
                                  icon: Icons.bedtime,
                                  iconColor: Color(0xFF3F51B5),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter sleep hours';
                                    }
                                    return null;
                                  },
                                ),

                                // Water Intake
                                _buildCustomTextField(
                                  controller: _waterIntakeController,
                                  label: 'Water Intake (glasses/day)',
                                  icon: Icons.local_drink,
                                  iconColor: Color(0xFF2196F3),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter water intake';
                                    }
                                    return null;
                                  },
                                ),

                                // Exercise Minutes
                                _buildCustomTextField(
                                  controller: _exerciseMinutesController,
                                  label: 'Exercise Minutes (daily)',
                                  icon: Icons.fitness_center,
                                  iconColor: Color(0xFF4CAF50),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter exercise minutes';
                                    }
                                    return null;
                                  },
                                ),

                                // Energy Level Selector
                                _buildDropdownSelector(
                                  title: 'Energy Level',
                                  options: _energyLevelOptions,
                                  selectedValue: _energyLevel,
                                  onChanged: (value) {
                                    setState(() {
                                      _energyLevel = value;
                                    });
                                  },
                                  icon: Icons.battery_full,
                                  iconColor: Color(0xFFFF9800),
                                ),

                                // Appetite Level Selector
                                _buildDropdownSelector(
                                  title: 'Appetite Level',
                                  options: _appetiteLevelOptions,
                                  selectedValue: _appetiteLevel,
                                  onChanged: (value) {
                                    setState(() {
                                      _appetiteLevel = value;
                                    });
                                  },
                                  icon: Icons.restaurant,
                                  iconColor: Color(0xFFFF5722),
                                ),

                                // Pain Level Selector
                                _buildDropdownSelector(
                                  title: 'Pain Level',
                                  options: _painLevelOptions,
                                  selectedValue: _painLevel,
                                  onChanged: (value) {
                                    setState(() {
                                      _painLevel = value;
                                    });
                                  },
                                  icon: Icons.healing,
                                  iconColor: Color(0xFFE91E63),
                                ),

                                // Health Checkboxes Section
                                Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFF5E8FF).withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.checklist,
                                            color: Color(0xFF7B1FA2),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Health Indicators',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF2D1B69),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 12),

                                      CheckboxListTile(
                                        title: Text('Had Contractions'),
                                        value: _hadContractions,
                                        onChanged: (value) {
                                          setState(() {
                                            _hadContractions = value ?? false;
                                          });
                                        },
                                        activeColor: Color(0xFF7B1FA2),
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                      ),

                                      CheckboxListTile(
                                        title: Text('Had Headaches'),
                                        value: _hadHeadaches,
                                        onChanged: (value) {
                                          setState(() {
                                            _hadHeadaches = value ?? false;
                                          });
                                        },
                                        activeColor: Color(0xFF7B1FA2),
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                      ),

                                      CheckboxListTile(
                                        title: Text('Had Swelling'),
                                        value: _hadSwelling,
                                        onChanged: (value) {
                                          setState(() {
                                            _hadSwelling = value ?? false;
                                          });
                                        },
                                        activeColor: Color(0xFF7B1FA2),
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                      ),

                                      CheckboxListTile(
                                        title: Text('Took Vitamins'),
                                        value: _tookVitamins,
                                        onChanged: (value) {
                                          setState(() {
                                            _tookVitamins = value ?? false;
                                          });
                                        },
                                        activeColor: Color(0xFF7B1FA2),
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                      ),
                                    ],
                                  ),
                                ),

                                // Nausea Details
                                _buildCustomTextField(
                                  controller: _nauseaController,
                                  label: 'Nausea Details (if any)',
                                  icon: Icons.sick,
                                  iconColor: Color(0xFF9C27B0),
                                  maxLines: 2,
                                ),

                                // Medications
                                _buildCustomTextField(
                                  controller: _medicationsController,
                                  label: 'Current Medications',
                                  icon: Icons.medication,
                                  iconColor: Color(0xFF607D8B),
                                  maxLines: 2,
                                ),

                                // Additional Notes
                                _buildCustomTextField(
                                  controller: _notesController,
                                  label: 'Additional Notes',
                                  icon: Icons.note_add,
                                  iconColor: Color(0xFF4CAF50),
                                  maxLines: 3,
                                ),

                                // Submit Button
                                Container(
                                  width: double.infinity,
                                  height: 55,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF7B1FA2),
                                        Color(0xFF9C27B0),
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(
                                          0xFF7B1FA2,
                                        ).withOpacity(0.3),
                                        blurRadius: 10,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _submitForm,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    child: _isLoading
                                        ? CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.save,
                                                color: Colors.white,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                'Save Health Log',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
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

                        const SizedBox(height: 32),

                        // Old Recent Logs Section (keeping for reference)
                        if (_recentLogs.isNotEmpty) ...[
                          Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF9C27B0).withOpacity(0.1),
                                  blurRadius: 15,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Color(
                                          0xFF9C27B0,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        Icons.history,
                                        color: Color(0xFF9C27B0),
                                        size: 24,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Recent Health Logs',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2D1B69),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: _recentLogs.length,
                                  separatorBuilder: (context, index) =>
                                      SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final log = _recentLogs[index];
                                    return Container(
                                      padding: EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Color(0xFFF8F9FA),
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                          color: Color(0xFFE0E0E0),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: Color(
                                                    0xFF9C27B0,
                                                  ).withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Icon(
                                                  Icons.calendar_today,
                                                  color: Color(0xFF9C27B0),
                                                  size: 16,
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                '${log.logDate.day}/${log.logDate.month}/${log.logDate.year}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF2D1B69),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 12),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: _buildLogInfoItem(
                                                  Icons.favorite,
                                                  'BP',
                                                  log.bloodPressure,
                                                  Color(0xFF7B1FA2),
                                                ),
                                              ),
                                              Expanded(
                                                child: _buildLogInfoItem(
                                                  Icons.monitor_weight,
                                                  'Weight',
                                                  '${log.weight}kg',
                                                  Color(0xFF9C27B0),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: _buildLogInfoItem(
                                                  Icons.sentiment_satisfied,
                                                  'Mood',
                                                  log.mood,
                                                  Color(0xFF4CAF50),
                                                ),
                                              ),
                                              Expanded(
                                                child: _buildLogInfoItem(
                                                  Icons.child_friendly,
                                                  'Kicks',
                                                  log.babyKicks,
                                                  Color(0xFFFF9800),
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (log.symptoms.isNotEmpty) ...[
                                            SizedBox(height: 8),
                                            _buildLogInfoItem(
                                              Icons.healing,
                                              'Symptoms',
                                              log.symptoms,
                                              Color(0xFFFF5722),
                                            ),
                                          ],
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildLogInfoItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        SizedBox(width: 4),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2D1B69),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
