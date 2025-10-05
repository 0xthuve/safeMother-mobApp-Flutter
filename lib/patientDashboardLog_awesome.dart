import 'package:flutter/material.dart';
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
  
  // Form data
  int _babyKicks = 0;
  String _mood = 'Good';
  bool _isLoading = false;
  List<SymptomLog> _recentLogs = [];

  final List<String> _moodOptions = ['Excellent', 'Good', 'Okay', 'Low', 'Anxious'];

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
      final logs = await _backendService.getRecentSymptomLogs('current_patient');
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
      final symptomLog = SymptomLog(
        patientId: 'current_patient',
        bloodPressure: _bloodPressureController.text,
        weight: _weightController.text,
        babyKicks: _babyKicks.toString(),
        mood: _mood,
        symptoms: _symptomsController.text,
        additionalNotes: _notesController.text,
        logDate: now,
        createdAt: now,
        updatedAt: now,
      );

      await _backendService.saveSymptomLog(symptomLog);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Health information saved successfully!'),
          backgroundColor: Color(0xFFE91E63),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
        style: TextStyle(
          fontSize: 16,
          color: Color(0xFF2D1B69),
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Color(0xFF666666),
            fontSize: 14,
          ),
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
            borderSide: BorderSide(color: Color(0xFFE91E63), width: 2),
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
          colors: [Color(0xFFE91E63).withOpacity(0.1), Color(0xFF9C27B0).withOpacity(0.1)],
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
                  color: Color(0xFFE91E63).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.child_friendly, color: Color(0xFFE91E63)),
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
                      color: Color(0xFFE91E63).withOpacity(0.2),
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
                    color: Color(0xFFE91E63),
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
                    color: isSelected ? (moodColors[mood] ?? Colors.grey) : Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? (moodColors[mood] ?? Colors.grey) : Color(0xFFE0E0E0),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        moodIcons[mood],
                        color: isSelected ? Colors.white : (moodColors[mood] ?? Colors.grey),
                        size: 18,
                      ),
                      SizedBox(width: 6),
                      Text(
                        mood,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Color(0xFF2D1B69),
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFB6C1).withOpacity(0.3), // Light pink
              Color(0xFFFFF0F5), // Lavender blush
              Color(0xFFE6E6FA).withOpacity(0.5), // Lavender
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom Header
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFFE91E63).withOpacity(0.3),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.favorite,
                        color: Color(0xFFE91E63),
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
              
              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 100),
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
                              color: Color(0xFFE91E63).withOpacity(0.1),
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
                                      color: Color(0xFFE91E63).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.health_and_safety,
                                      color: Color(0xFFE91E63),
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
                                iconColor: Color(0xFFE91E63),
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
                                    colors: [Color(0xFFE91E63), Color(0xFF9C27B0)],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFFE91E63).withOpacity(0.3),
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
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.save, color: Colors.white),
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
                      
                      SizedBox(height: 24),
                      
                      // Recent Logs Section
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
                                      color: Color(0xFF9C27B0).withOpacity(0.1),
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
                                separatorBuilder: (context, index) => SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final log = _recentLogs[index];
                                  return Container(
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFF8F9FA),
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
                                                color: Color(0xFF9C27B0).withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
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
                                                Color(0xFFE91E63),
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
              ),
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

  Widget _buildLogInfoItem(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        SizedBox(width: 4),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF666666),
          ),
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