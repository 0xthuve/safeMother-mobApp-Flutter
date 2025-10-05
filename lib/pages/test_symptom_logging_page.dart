import 'package:flutter/material.dart';
import '../models/symptom_log.dart';
import '../services/backend_service.dart';
import '../services/session_manager.dart';

class TestSymptomLoggingPage extends StatefulWidget {
  const TestSymptomLoggingPage({super.key});

  @override
  State<TestSymptomLoggingPage> createState() => _TestSymptomLoggingPageState();
}

class _TestSymptomLoggingPageState extends State<TestSymptomLoggingPage> {
  final BackendService _backendService = BackendService();
  List<SymptomLog> _logs = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() => _isLoading = true);
    
    try {
      final userId = await SessionManager.getUserId();
      if (userId != null) {
        final logs = await _backendService.getSymptomLogs(userId);
        setState(() => _logs = logs);
      }
    } catch (e) {
      print('Error loading logs: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createTestLog() async {
    final userId = await SessionManager.getUserId();
    if (userId == null) return;

    final testLog = SymptomLog(
      patientId: userId,
      logDate: DateTime.now(),
      bloodPressure: '120/80',
      weight: '65.5',
      babyKicks: '15',
      mood: 'Happy',
      sleepHours: '8',
      waterIntake: '2.5',
      exerciseMinutes: '30',
      energyLevel: 'High',
      appetiteLevel: 'Good',
      painLevel: 'None',
      hadContractions: false,
      hadHeadaches: false,
      hadSwelling: false,
      tookVitamins: true,
      nauseaDetails: 'Mild nausea in the morning',
      medications: 'Prenatal vitamins, Iron supplements',
      symptoms: 'Feeling energetic and healthy',
      additionalNotes: 'Had a great day overall. Baby is very active.',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final success = await _backendService.saveSymptomLog(testLog);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Test log created successfully!')),
      );
      await _loadLogs();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create test log')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Symptom Logging'),
        backgroundColor: const Color(0xFFE91E63),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: _createTestLog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE91E63),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Create Test Symptom Log'),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Total Logs: ${_logs.length}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _logs.isEmpty
                      ? const Center(
                          child: Text(
                            'No symptom logs found.\nTap the button above to create a test log.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _logs.length,
                          itemBuilder: (context, index) {
                            final log = _logs[index];
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Log ${index + 1} - ${log.logDate.day}/${log.logDate.month}/${log.logDate.year}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFE91E63),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    _buildDetailRow('Blood Pressure', log.bloodPressure),
                                    _buildDetailRow('Weight', '${log.weight} kg'),
                                    _buildDetailRow('Baby Kicks', log.babyKicks),
                                    _buildDetailRow('Mood', log.mood),
                                    _buildDetailRow('Sleep Hours', log.sleepHours != null ? '${log.sleepHours}h' : 'Not recorded'),
                                    _buildDetailRow('Water Intake', log.waterIntake != null ? '${log.waterIntake}L' : 'Not recorded'),
                                    _buildDetailRow('Exercise', log.exerciseMinutes != null ? '${log.exerciseMinutes}min' : 'Not recorded'),
                                    _buildDetailRow('Energy Level', log.energyLevel),
                                    _buildDetailRow('Appetite', log.appetiteLevel),
                                    _buildDetailRow('Pain Level', log.painLevel),
                                    _buildDetailRow('Took Vitamins', log.tookVitamins ? 'Yes' : 'No'),
                                    if (log.nauseaDetails?.isNotEmpty == true)
                                      _buildDetailRow('Nausea', log.nauseaDetails!),
                                    if (log.medications?.isNotEmpty == true)
                                      _buildDetailRow('Medications', log.medications!),
                                    if (log.symptoms.isNotEmpty)
                                      _buildDetailRow('Symptoms', log.symptoms),
                                    if (log.additionalNotes?.isNotEmpty == true)
                                      _buildDetailRow('Notes', log.additionalNotes!),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF666),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Color(0xFF333)),
            ),
          ),
        ],
      ),
    );
  }
}