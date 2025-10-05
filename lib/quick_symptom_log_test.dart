import 'package:flutter/material.dart';
import 'services/firebase_service.dart';

class QuickSymptomLogTest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quick Symptom Log Test'),
        backgroundColor: Color(0xFFE57373),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Test Symptom Log Creation',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _createTestLog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFE57373),
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: Text(
                'Create Test Log for Current User',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _viewAllLogs(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: Text(
                'View All My Logs',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _debugUserInfo(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: Text(
                'Debug Current User',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createTestLog(BuildContext context) async {
    try {
      final currentUser = FirebaseService.currentUser;
      if (currentUser == null) {
        _showMessage(context, 'Error: No authenticated user');
        return;
      }

      // Create a comprehensive test symptom log
      final testLogData = {
        'patientId': currentUser.uid,
        'bloodPressure': '120/80',
        'weight': '65.5',
        'babyKicks': '15',
        'mood': 'Good',
        'symptoms': 'Test symptom log - feeling good overall',
        'additionalNotes': 'This is a test log created for debugging',
        'sleepHours': '8',
        'waterIntake': '2.5L',
        'exerciseMinutes': '30',
        'energyLevel': 'Normal',
        'appetiteLevel': 'Good',
        'painLevel': 'None',
        'hadContractions': false,
        'hadHeadaches': false,
        'hadSwelling': false,
        'tookVitamins': true,
        'logDate': DateTime.now().toIso8601String(),
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      // Save to Firestore
      final logId = await FirebaseService.saveSymptomLog(testLogData);
      
      if (logId != null) {
        _showMessage(context, 'SUCCESS!\n\nTest symptom log created:\nLog ID: $logId\nPatient ID: ${currentUser.uid}');
      } else {
        _showMessage(context, 'Failed to create test symptom log');
      }
    } catch (e) {
      _showMessage(context, 'Error creating test log: $e');
    }
  }

  Future<void> _viewAllLogs(BuildContext context) async {
    try {
      final currentUser = FirebaseService.currentUser;
      if (currentUser == null) {
        _showMessage(context, 'Error: No authenticated user');
        return;
      }

      final logs = await FirebaseService.getSymptomLogsForPatient(currentUser.uid);
      
      String message = 'Symptom Logs Found: ${logs.length}\n\n';
      
      if (logs.isNotEmpty) {
        for (int i = 0; i < logs.length && i < 3; i++) {
          final log = logs[i];
          message += 'Log ${i + 1}:\n';
          message += 'Date: ${log['logDate']}\n';
          message += 'Mood: ${log['mood']}\n';
          message += 'Blood Pressure: ${log['bloodPressure']}\n';
          message += 'Notes: ${log['additionalNotes']}\n\n';
        }
        
        if (logs.length > 3) {
          message += '... and ${logs.length - 3} more logs';
        }
      } else {
        message += 'No symptom logs found for current user.';
      }
      
      _showMessage(context, message);
    } catch (e) {
      _showMessage(context, 'Error viewing logs: $e');
    }
  }

  Future<void> _debugUserInfo(BuildContext context) async {
    try {
      final currentUser = FirebaseService.currentUser;
      if (currentUser == null) {
        _showMessage(context, 'No authenticated user');
        return;
      }

      final userData = await FirebaseService.getUserData(currentUser.uid);
      
      String message = 'Current User Debug Info:\n\n';
      message += 'User ID: ${currentUser.uid}\n';
      message += 'Email: ${currentUser.email}\n';
      message += 'Display Name: ${currentUser.displayName}\n';
      message += 'Role: ${userData?['role'] ?? 'Unknown'}\n';
      message += 'Account Type: ${userData?['accountType'] ?? 'Unknown'}\n';
      message += 'Full Name: ${userData?['fullName'] ?? 'Unknown'}\n';
      
      _showMessage(context, message);
    } catch (e) {
      _showMessage(context, 'Error getting user info: $e');
    }
  }

  void _showMessage(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Result'),
        content: SingleChildScrollView(
          child: Text(message),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}