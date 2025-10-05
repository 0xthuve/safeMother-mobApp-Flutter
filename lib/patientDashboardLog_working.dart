import 'package:flutter/material.dart';
import 'models/symptom_log.dart';
import 'services/backend_service.dart';
import 'services/session_manager.dart';
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

  final List<String> _moodOptions = ['Excellent', 'Good', 'Okay', 'Low', 'Anxious'];
  final List<String> _energyOptions = ['High', 'Normal', 'Low', 'Very Low'];
  final List<String> _appetiteOptions = ['Excellent', 'Normal', 'Poor', 'Nauseous'];
  final List<String> _painOptions = ['None', 'Mild', 'Moderate', 'Severe'];

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
      final userId = await SessionManager.getUserId();
      if (userId != null) {
        final logs = await _backendService.getRecentSymptomLogs(userId);
        setState(() {
          _recentLogs = logs;
        });
      }
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
      final userId = await SessionManager.getUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }
      
      final now = DateTime.now();
      final symptomLog = SymptomLog(
        patientId: userId,
        bloodPressure: _bloodPressureController.text,
        weight: _weightController.text,
        babyKicks: _babyKicks.toString(),
        mood: _mood,
        symptoms: _symptomsController.text,
        additionalNotes: _notesController.text,
        sleepHours: _sleepHoursController.text.isEmpty ? null : _sleepHoursController.text,
        waterIntake: _waterIntakeController.text.isEmpty ? null : _waterIntakeController.text,
        exerciseMinutes: _exerciseMinutesController.text.isEmpty ? null : _exerciseMinutesController.text,
        energyLevel: _energyLevel,
        appetiteLevel: _appetiteLevel,
        painLevel: _painLevel,
        hadContractions: _hadContractions,
        hadHeadaches: _hadHeadaches,
        hadSwelling: _hadSwelling,
        tookVitamins: _tookVitamins,
        nauseaDetails: _nauseaController.text.isEmpty ? null : _nauseaController.text,
        medications: _medicationsController.text.isEmpty ? null : _medicationsController.text,
        logDate: now,
        createdAt: now,
        updatedAt: now,
      );

      await _backendService.saveSymptomLog(symptomLog);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Health information saved successfully!'),
          backgroundColor: Color(0xFFE91E63),
        ),
      );
      
      _resetForm();
      _loadRecentLogs();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving health information: $e'),
          backgroundColor: Colors.red,
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
    _sleepHoursController.clear();
    _waterIntakeController.clear();
    _exerciseMinutesController.clear();
    _medicationsController.clear();
    _nauseaController.clear();
    
    setState(() {
      _babyKicks = 0;
      _mood = 'Good';
      _energyLevel = 'Normal';
      _appetiteLevel = 'Normal';
      _painLevel = 'None';
      _hadContractions = false;
      _hadHeadaches = false;
      _hadSwelling = false;
      _tookVitamins = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE91E63),
        elevation: 0,
        title: const Text(
          'Health Log',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE91E63).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.health_and_safety,
                            color: const Color(0xFFE91E63),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Daily Health Check',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D2D2D),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Log your daily health information to track your pregnancy journey',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),

              // Basic Health Metrics
              _buildSectionCard(
                title: 'Basic Metrics',
                icon: Icons.monitor_heart,
                color: const Color(0xFFE91E63),
                children: [
                  _buildTextFormField(
                    controller: _bloodPressureController,
                    label: 'Blood Pressure',
                    hint: 'e.g., 120/80',
                    icon: Icons.favorite,
                    color: const Color(0xFFE91E63),
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 16),
                  _buildTextFormField(
                    controller: _weightController,
                    label: 'Weight (kg)',
                    hint: 'e.g., 65.5',
                    icon: Icons.monitor_weight,
                    color: const Color(0xFFE91E63),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Baby Activity
              _buildSectionCard(
                title: 'Baby Activity',
                icon: Icons.child_care,
                color: const Color(0xFF9C27B0),
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF9C27B0).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.child_care,
                          color: const Color(0xFF9C27B0),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Baby Kicks Today',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D2D2D),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            if (_babyKicks > 0) _babyKicks--;
                          });
                        },
                        icon: Icon(Icons.remove_circle, color: Colors.red),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '$_babyKicks',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D2D2D),
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _babyKicks++;
                          });
                        },
                        icon: Icon(Icons.add_circle, color: Colors.green),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Daily Activities
              _buildSectionCard(
                title: 'Daily Activities',
                icon: Icons.today,
                color: const Color(0xFF2196F3),
                children: [
                  _buildTextFormField(
                    controller: _sleepHoursController,
                    label: 'Sleep Hours',
                    hint: 'e.g., 8',
                    icon: Icons.bedtime,
                    color: const Color(0xFF2196F3),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  _buildTextFormField(
                    controller: _waterIntakeController,
                    label: 'Water Intake (Liters)',
                    hint: 'e.g., 2.5',
                    icon: Icons.local_drink,
                    color: const Color(0xFF2196F3),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  _buildTextFormField(
                    controller: _exerciseMinutesController,
                    label: 'Exercise (Minutes)',
                    hint: 'e.g., 30',
                    icon: Icons.fitness_center,
                    color: const Color(0xFF2196F3),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Mood & Wellness
              _buildSectionCard(
                title: 'Mood & Wellness',
                icon: Icons.mood,
                color: const Color(0xFF4CAF50),
                children: [
                  _buildDropdownField(
                    'Mood',
                    _mood,
                    _moodOptions,
                    (value) => setState(() => _mood = value!),
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField(
                    'Energy Level',
                    _energyLevel,
                    _energyOptions,
                    (value) => setState(() => _energyLevel = value!),
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField(
                    'Appetite Level',
                    _appetiteLevel,
                    _appetiteOptions,
                    (value) => setState(() => _appetiteLevel = value!),
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField(
                    'Pain Level',
                    _painLevel,
                    _painOptions,
                    (value) => setState(() => _painLevel = value!),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Health Checklist
              _buildHealthChecklist(),

              const SizedBox(height: 20),

              // Additional Information
              _buildSectionCard(
                title: 'Additional Information',
                icon: Icons.note_add,
                color: const Color(0xFF795548),
                children: [
                  _buildTextFormField(
                    controller: _nauseaController,
                    label: 'Nausea/Vomiting Details',
                    hint: 'Describe any nausea or vomiting episodes',
                    icon: Icons.sick,
                    color: const Color(0xFF795548),
                    keyboardType: TextInputType.multiline,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  _buildTextFormField(
                    controller: _medicationsController,
                    label: 'Medications Taken',
                    hint: 'List any medications or supplements',
                    icon: Icons.medication,
                    color: const Color(0xFF795548),
                    keyboardType: TextInputType.multiline,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  _buildTextFormField(
                    controller: _symptomsController,
                    label: 'Other Symptoms',
                    hint: 'Describe any other symptoms you experienced',
                    icon: Icons.healing,
                    color: const Color(0xFF795548),
                    keyboardType: TextInputType.multiline,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  _buildTextFormField(
                    controller: _notesController,
                    label: 'Additional Notes',
                    hint: 'Any other notes about your day',
                    icon: Icons.note,
                    color: const Color(0xFF795548),
                    keyboardType: TextInputType.multiline,
                    maxLines: 3,
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE91E63),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Save Health Log',
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
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D2D2D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color color,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    String value,
    List<String> options,
    void Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      items: options.map((option) => DropdownMenuItem(
        value: option,
        child: Text(option),
      )).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildHealthChecklist() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.checklist,
                  color: const Color(0xFFFF9800),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Health Checklist',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D2D2D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCheckboxItem(
            'Had contractions today',
            _hadContractions,
            (value) => setState(() => _hadContractions = value!),
            Icons.warning,
            Colors.red,
          ),
          _buildCheckboxItem(
            'Had headaches today',
            _hadHeadaches,
            (value) => setState(() => _hadHeadaches = value!),
            Icons.warning,
            Colors.orange,
          ),
          _buildCheckboxItem(
            'Had swelling today',
            _hadSwelling,
            (value) => setState(() => _hadSwelling = value!),
            Icons.warning,
            Colors.orange,
          ),
          _buildCheckboxItem(
            'Took prenatal vitamins',
            _tookVitamins,
            (value) => setState(() => _tookVitamins = value!),
            Icons.check_circle,
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxItem(
    String title,
    bool value,
    void Function(bool?) onChanged,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF2D2D2D),
              ),
            ),
          ),
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFE91E63),
          ),
        ],
      ),
    );
  }
}