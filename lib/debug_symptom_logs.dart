import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../services/session_manager.dart';

class DebugSymptomLogs extends StatefulWidget {
  @override
  _DebugSymptomLogsState createState() => _DebugSymptomLogsState();
}

class _DebugSymptomLogsState extends State<DebugSymptomLogs> {
  String _debugInfo = 'Loading...';

  @override
  void initState() {
    super.initState();
    _debugSymptomLogs();
  }

  Future<void> _debugSymptomLogs() async {
    try {
      final currentUser = FirebaseService.currentUser;
      if (currentUser == null) {
        setState(() {
          _debugInfo = 'No authenticated user found';
        });
        return;
      }

      final userData = await FirebaseService.getUserData(currentUser.uid);
      String debugOutput = 'Current User: ${currentUser.uid}\n';
      debugOutput += 'User Email: ${currentUser.email}\n';
      debugOutput += 'User Role: ${userData?['role'] ?? 'Unknown'}\n';
      debugOutput += 'Account Type: ${userData?['accountType'] ?? 'Unknown'}\n\n';

      // Check if this is a doctor
      if (userData?['role'] == 'doctor') {
        debugOutput += 'DOCTOR VIEW:\n';
        
        // Get accepted patients
        final acceptedPatients = await FirebaseService.getAcceptedPatientsForDoctor(currentUser.uid);
        debugOutput += 'Accepted Patients: ${acceptedPatients.length}\n';
        
        for (final patient in acceptedPatients) {
          final patientId = patient['patientId'] as String;
          debugOutput += '\nPatient ID: $patientId\n';
          
          // Try to get patient info
          final patientData = await FirebaseService.getUserData(patientId);
          debugOutput += 'Patient Name: ${patientData?['fullName'] ?? 'Unknown'}\n';
          
          // Try to get symptom logs for this patient
          try {
            final logs = await FirebaseService.getSymptomLogsForPatient(patientId);
            debugOutput += 'Symptom Logs Found: ${logs.length}\n';
            
            if (logs.isNotEmpty) {
              debugOutput += 'Latest Log Date: ${logs.first['logDate']}\n';
            }
          } catch (e) {
            debugOutput += 'Error getting logs for $patientId: $e\n';
          }
        }
      } else {
        debugOutput += 'PATIENT VIEW:\n';
        
        // Get symptom logs for current patient
        try {
          final logs = await FirebaseService.getSymptomLogsForPatient(currentUser.uid);
          debugOutput += 'My Symptom Logs: ${logs.length}\n';
          
          if (logs.isNotEmpty) {
            debugOutput += 'Latest Log Date: ${logs.first['logDate']}\n';
            debugOutput += 'Sample Log Data: ${logs.first.toString().substring(0, 200)}...\n';
          }
        } catch (e) {
          debugOutput += 'Error getting my logs: $e\n';
        }
      }

      setState(() {
        _debugInfo = debugOutput;
      });
    } catch (e) {
      setState(() {
        _debugInfo = 'Debug error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Debug Symptom Logs'),
        backgroundColor: Color(0xFFE57373),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _debugSymptomLogs,
              child: Text('Refresh Debug Info'),
            ),
            SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _debugInfo,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}