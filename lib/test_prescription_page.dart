import 'package:flutter/material.dart';
import 'services/backend_service.dart';
import 'services/session_manager.dart';
import 'models/meal.dart';
import 'models/exercise.dart';

class TestPrescriptionPage extends StatefulWidget {
  const TestPrescriptionPage({super.key});

  @override
  State<TestPrescriptionPage> createState() => _TestPrescriptionPageState();
}

class _TestPrescriptionPageState extends State<TestPrescriptionPage> {
  final BackendService _backendService = BackendService();
  String _testResults = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Prescription System'),
        backgroundColor: const Color(0xFF7B1FA2),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _testSavePrescription,
              child: const Text('Test Save Prescription'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _testLoadPrescription,
              child: const Text('Test Load Prescription'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _clearPrescriptions,
              child: const Text('Clear Test Data'),
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _testResults.isEmpty ? 'No test results yet...' : _testResults,
                      style: const TextStyle(
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

  Future<void> _testSavePrescription() async {
    setState(() {
      _isLoading = true;
      _testResults = 'Testing save prescription...\n';
    });

    try {
      final userId = await SessionManager.getUserId();
      if (userId == null) {
        setState(() {
          _testResults += 'ERROR: No user ID found in session\n';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _testResults += 'User ID: $userId\n';
      });

      // Create test meal and exercise data
      final testMeal = Meal(
        id: 'test_meal_1',
        name: 'Test Prescribed Meal',
        description: 'This is a test meal prescribed by doctor',
        imageUrl: 'assets/chia_seed.png',
        category: 'breakfast',
        nutritionalBenefits: ['Test Nutrient'],
        calories: 300,
        isPregnancySafe: true,
        preparation: 'Test preparation',
        ingredients: ['Test ingredient'],
      );

      final testExercise = Exercise(
        id: 'test_exercise_1',
        name: 'Test Prescribed Exercise',
        description: 'This is a test exercise prescribed by doctor',
        icon: Icons.directions_walk,
        duration: '30 minutes',
        difficulty: 'easy',
        benefits: ['Test benefit'],
        isPregnancySafe: true,
        instructions: 'Test instructions',
        trimester: 'all',
      );

      final recommendations = {
        'patientId': userId,
        'doctorId': 'test_doctor_123',
        'meals': [testMeal.toJson()],
        'exercises': [testExercise.toJson()],
        'prescribedAt': DateTime.now().toIso8601String(),
      };

      setState(() {
        _testResults += 'Saving recommendations...\n';
        _testResults += 'Data: ${recommendations.toString()}\n';
      });

      final success = await _backendService.saveDoctorRecommendations(userId, recommendations);

      setState(() {
        _testResults += success 
            ? 'SUCCESS: Prescription saved successfully!\n'
            : 'ERROR: Failed to save prescription\n';
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _testResults += 'ERROR: $e\n';
        _isLoading = false;
      });
    }
  }

  Future<void> _testLoadPrescription() async {
    setState(() {
      _isLoading = true;
      _testResults += '\nTesting load prescription...\n';
    });

    try {
      final userId = await SessionManager.getUserId();
      if (userId == null) {
        setState(() {
          _testResults += 'ERROR: No user ID found in session\n';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _testResults += 'Loading recommendations for user: $userId\n';
      });

      final recommendations = await _backendService.getDoctorRecommendations(userId);

      if (recommendations != null) {
        setState(() {
          _testResults += 'SUCCESS: Found recommendations!\n';
          _testResults += 'Patient ID: ${recommendations['patientId']}\n';
          _testResults += 'Doctor ID: ${recommendations['doctorId']}\n';
          _testResults += 'Prescribed At: ${recommendations['prescribedAt']}\n';
          
          if (recommendations['meals'] != null) {
            final meals = recommendations['meals'] as List;
            _testResults += 'Meals (${meals.length}):\n';
            for (var meal in meals) {
              _testResults += '  - ${meal['name']}\n';
            }
          }
          
          if (recommendations['exercises'] != null) {
            final exercises = recommendations['exercises'] as List;
            _testResults += 'Exercises (${exercises.length}):\n';
            for (var exercise in exercises) {
              _testResults += '  - ${exercise['name']}\n';
            }
          }
        });
      } else {
        setState(() {
          _testResults += 'No recommendations found for this user\n';
        });
      }

    } catch (e) {
      setState(() {
        _testResults += 'ERROR loading prescription: $e\n';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _clearPrescriptions() async {
    setState(() {
      _testResults = 'Test data cleared.\n';
    });
  }
}