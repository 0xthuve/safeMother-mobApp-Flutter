import 'package:flutter/material.dart';
import '../models/symptom_log.dart';
import '../services/backend_service.dart';
import '../services/session_manager.dart';

class DebugSymptomLogsPage extends StatefulWidget {
  const DebugSymptomLogsPage({super.key});

  @override
  State<DebugSymptomLogsPage> createState() => _DebugSymptomLogsPageState();
}

class _DebugSymptomLogsPageState extends State<DebugSymptomLogsPage> {
  final BackendService _backendService = BackendService();
  List<SymptomLog> _allLogs = [];
  String _debugInfo = '';
  bool _isLoading = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadDebugInfo();
  }

  Future<void> _loadDebugInfo() async {
    setState(() => _isLoading = true);
    
    try {
      final userId = await SessionManager.getUserId();
      setState(() => _currentUserId = userId);
      
      if (userId != null) {
        final logs = await _backendService.getSymptomLogs(userId);
        setState(() {
          _allLogs = logs;
          _debugInfo = 'Found ${logs.length} logs for user $userId';
        });
      } else {
        setState(() {
          _debugInfo = 'No user logged in';
        });
      }
    } catch (e) {
      setState(() {
        _debugInfo = 'Error: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createTestLog() async {
    if (_currentUserId == null) return;

    setState(() => _isLoading = true);
    
    try {
      final testLog = SymptomLog(
        patientId: _currentUserId!,
        logDate: DateTime.now(),
        bloodPressure: '120/80',
        weight: '65.5',
        babyKicks: '10',
        mood: 'Good',
        sleepHours: '8',
        waterIntake: '2.0',
        exerciseMinutes: '30',
        energyLevel: 'High',
        appetiteLevel: 'Good',
        painLevel: 'None',
        hadContractions: false,
        hadHeadaches: false,
        hadSwelling: false,
        tookVitamins: true,
        nauseaDetails: 'Minor morning nausea',
        medications: 'Prenatal vitamins',
        symptoms: 'Feeling good overall',
        additionalNotes: 'Test log created from debug page',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await _backendService.saveSymptomLog(testLog);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Test log created successfully!')),
        );
        await _loadDebugInfo();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create test log')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Symptom Logs'),
        backgroundColor: const Color(0xFFE91E63),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Debug Information',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text('Current User ID: $_currentUserId'),
                          const SizedBox(height: 8),
                          Text(_debugInfo),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: _loadDebugInfo,
                                child: const Text('Refresh'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: _createTestLog,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE91E63),
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Create Test Log'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Stored Logs (${_allLogs.length})',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _allLogs.isEmpty
                        ? const Center(
                            child: Text(
                              'No logs found. Try creating a test log first.',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _allLogs.length,
                            itemBuilder: (context, index) {
                              final log = _allLogs[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  title: Text(
                                    'Log ${index + 1} - ${log.logDate.day}/${log.logDate.month}/${log.logDate.year}',
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('BP: ${log.bloodPressure}'),
                                      Text('Weight: ${log.weight}kg'),
                                      Text('Mood: ${log.mood}'),
                                      Text('Baby Kicks: ${log.babyKicks}'),
                                      if (log.symptoms.isNotEmpty)
                                        Text('Symptoms: ${log.symptoms}'),
                                    ],
                                  ),
                                  isThreeLine: true,
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}