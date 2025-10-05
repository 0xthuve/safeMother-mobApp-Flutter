import 'package:flutter/material.dart';
import 'services/firebase_service.dart';
import 'models/symptom_log.dart';

class CreateTestSymptomLog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Test Symptom Log'),
        backgroundColor: Color(0xFFE57373),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'This will create a test symptom log for the current patient',
              style: TextStyle(fontSize: 16),
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
                'Create Test Symptom Log',
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

      final userData = await FirebaseService.getUserData(currentUser.uid);
      if (userData?['role'] != 'patient') {
        _showMessage(context, 'Error: Only patients can create symptom logs');
        return;
      }

      // Create a comprehensive test symptom log
      final testLog = SymptomLog(
        patientId: currentUser.uid,
        bloodPressure: '120/80',
        weight: '65.5',
        babyKicks: '15',
        mood: 'Good',
        symptoms: 'Mild morning sickness, some back pain',
        additionalNotes: 'Feeling good overall, baby is active',
        sleepHours: '8',
        waterIntake: '2.5L',
        exerciseMinutes: '30',
        energyLevel: 'Normal',
        appetiteLevel: 'Good',
        painLevel: 'Mild',
        hadContractions: false,
        hadHeadaches: true,
        hadSwelling: false,
        tookVitamins: true,
        logDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to Firestore
      final logId = await FirebaseService.saveSymptomLog(testLog.toMap());
      
      if (logId != null) {
        _showMessage(context, 'Test symptom log created successfully!\nLog ID: $logId');
      } else {
        _showMessage(context, 'Failed to create test symptom log');
      }
    } catch (e) {
      _showMessage(context, 'Error creating test log: $e');
    }
  }

  void _showMessage(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Result'),
        content: Text(message),
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