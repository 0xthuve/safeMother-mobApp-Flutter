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
      final logs = await _backendService.getRecentSymptomLogs('current_patient'); // Should come from session
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
        patientId: 'current_patient', // This should come from session
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
        SnackBar(content: Text('Health information saved successfully!')),
      );
      
      _resetForm();
      _loadRecentLogs(); // Refresh the recent logs
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving health information: $e')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Health Log'),
        backgroundColor: Color(0xFF2E8B57),
        automaticallyImplyLeading: false, // Remove back button
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 100.0), // Extra bottom padding for nav
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Health Log Form
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Log Your Health Information',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E8B57),
                        ),
                      ),
                      SizedBox(height: 20),
                      
                      // Blood Pressure
                      TextFormField(
                        controller: _bloodPressureController,
                        decoration: InputDecoration(
                          labelText: 'Blood Pressure (e.g., 120/80)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.favorite),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your blood pressure';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      
                      // Weight
                      TextFormField(
                        controller: _weightController,
                        decoration: InputDecoration(
                          labelText: 'Weight (kg)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.monitor_weight),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your weight';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      
                      // Baby Kicks Counter
                      Row(
                        children: [
                          Icon(Icons.child_friendly, color: Color(0xFF2E8B57)),
                          SizedBox(width: 8),
                          Text('Baby Kicks: $_babyKicks'),
                          Spacer(),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                if (_babyKicks > 0) _babyKicks--;
                              });
                            },
                            icon: Icon(Icons.remove_circle),
                            color: Colors.red,
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _babyKicks++;
                              });
                            },
                            icon: Icon(Icons.add_circle),
                            color: Colors.green,
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      
                      // Mood Selection
                      Row(
                        children: [
                          Icon(Icons.sentiment_satisfied, color: Color(0xFF2E8B57)),
                          SizedBox(width: 8),
                          Text('Mood: '),
                          SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _mood,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                              items: _moodOptions.map((mood) {
                                return DropdownMenuItem<String>(
                                  value: mood,
                                  child: Text(mood),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _mood = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      
                      // Symptoms
                      TextFormField(
                        controller: _symptomsController,
                        decoration: InputDecoration(
                          labelText: 'Symptoms (if any)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.health_and_safety),
                        ),
                        maxLines: 2,
                      ),
                      SizedBox(height: 16),
                      
                      // Additional Notes
                      TextFormField(
                        controller: _notesController,
                        decoration: InputDecoration(
                          labelText: 'Additional Notes',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.note_add),
                        ),
                        maxLines: 3,
                      ),
                      SizedBox(height: 20),
                      
                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF2E8B57),
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  'Save Health Log',
                                  style: TextStyle(fontSize: 16, color: Colors.white),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            SizedBox(height: 24),
            
            // Recent Logs Section
            if (_recentLogs.isNotEmpty) ...[
              Text(
                'Recent Health Logs',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E8B57),
                ),
              ),
              SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _recentLogs.length,
                itemBuilder: (context, index) {
                  final log = _recentLogs[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Color(0xFF2E8B57),
                        child: Icon(Icons.health_and_safety, color: Colors.white),
                      ),
                      title: Text('${log.logDate.day}/${log.logDate.month}/${log.logDate.year}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('BP: ${log.bloodPressure} | Weight: ${log.weight}kg'),
                          Text('Mood: ${log.mood} | Kicks: ${log.babyKicks}'),
                          if (log.symptoms.isNotEmpty)
                            Text('Symptoms: ${log.symptoms}'),
                        ],
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}