import 'package:flutter/material.dart';
import 'models/meal.dart';
import 'models/exercise.dart';
import 'services/backend_service.dart';
import 'services/session_manager.dart';

class DoctorPrescriptionPage extends StatefulWidget {
  final String patientId;
  final String patientName;

  const DoctorPrescriptionPage({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<DoctorPrescriptionPage> createState() => _DoctorPrescriptionPageState();
}

class _DoctorPrescriptionPageState extends State<DoctorPrescriptionPage> {
  final BackendService _backendService = BackendService();
  List<Meal> _selectedMeals = [];
  List<Exercise> _selectedExercises = [];
  bool _isLoading = false;

  // Sample available meals for prescription
  List<Meal> _availableMeals = [
    Meal(
      id: 'meal_1',
      name: 'Chia Seed Pudding',
      description: 'Rich in omega-3 fatty acids and fiber',
      imageUrl: 'assets/chia_seed.png',
      category: 'breakfast',
      nutritionalBenefits: ['Omega-3', 'Fiber', 'Protein', 'Calcium'],
      calories: 250,
      isPregnancySafe: true,
      preparation: 'Mix chia seeds with milk and let sit overnight',
      ingredients: ['Chia seeds', 'Milk', 'Honey', 'Vanilla'],
    ),
    Meal(
      id: 'meal_2',
      name: 'Avocado Toast',
      description: 'Healthy fats and fiber for pregnancy',
      imageUrl: 'assets/avocado.png',
      category: 'breakfast',
      nutritionalBenefits: ['Healthy Fats', 'Folate', 'Fiber', 'Potassium'],
      calories: 320,
      isPregnancySafe: true,
      preparation: 'Toast bread and top with mashed avocado',
      ingredients: ['Whole grain bread', 'Avocado', 'Salt', 'Lemon'],
    ),
    Meal(
      id: 'meal_3',
      name: 'Greek Yogurt with Berries',
      description: 'High protein and probiotics',
      imageUrl: 'assets/yogurt.png',
      category: 'snack',
      nutritionalBenefits: ['Protein', 'Probiotics', 'Calcium', 'Antioxidants'],
      calories: 180,
      isPregnancySafe: true,
      preparation: 'Mix yogurt with fresh berries',
      ingredients: ['Greek yogurt', 'Mixed berries', 'Honey'],
    ),
  ];

  // Sample available exercises for prescription
  List<Exercise> _availableExercises = [
    Exercise(
      id: 'exercise_1',
      name: 'Walking',
      description: 'Low-impact cardio safe for all trimesters',
      icon: Icons.directions_walk,
      duration: '30 minutes',
      difficulty: 'easy',
      benefits: ['Cardiovascular health', 'Mood improvement', 'Energy boost'],
      isPregnancySafe: true,
      instructions: 'Walk at a comfortable pace for 30 minutes daily',
      trimester: 'all',
    ),
    Exercise(
      id: 'exercise_2',
      name: 'Prenatal Yoga',
      description: 'Flexibility and relaxation for pregnancy',
      icon: Icons.self_improvement,
      duration: '60 minutes',
      difficulty: 'easy',
      benefits: ['Flexibility', 'Relaxation', 'Better sleep', 'Pain relief'],
      isPregnancySafe: true,
      instructions: 'Follow prenatal yoga routines',
      trimester: 'all',
    ),
    Exercise(
      id: 'exercise_3',
      name: 'Swimming',
      description: 'Full-body workout with joint support',
      icon: Icons.pool,
      duration: '45 minutes',
      difficulty: 'moderate',
      benefits: ['Full body workout', 'Joint support', 'Reduces swelling'],
      isPregnancySafe: true,
      instructions: 'Swim laps or do water aerobics',
      trimester: 'all',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prescriptions for ${widget.patientName}'),
        backgroundColor: const Color(0xFF7B1FA2),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meal Prescriptions Section
                  const Text(
                    'Prescribe Meals',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7B1FA2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMealSelection(),
                  
                  const SizedBox(height: 32),
                  
                  // Exercise Prescriptions Section
                  const Text(
                    'Prescribe Exercises',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7B1FA2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildExerciseSelection(),
                  
                  const SizedBox(height: 32),
                  
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _savePrescriptions,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7B1FA2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save Prescriptions',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildMealSelection() {
    return Column(
      children: [
        // Selected meals
        if (_selectedMeals.isNotEmpty) ...[
          const Text(
            'Selected Meals:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedMeals.map((meal) => Chip(
              label: Text(meal.name),
              backgroundColor: const Color(0xFF4CAF50).withOpacity(0.1),
              deleteIcon: const Icon(Icons.close, size: 18),
              onDeleted: () {
                setState(() {
                  _selectedMeals.remove(meal);
                });
              },
            )).toList(),
          ),
          const SizedBox(height: 16),
        ],
        
        // Available meals
        const Text(
          'Available Meals:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ..._availableMeals.map((meal) => CheckboxListTile(
          title: Text(meal.name),
          subtitle: Text(meal.description),
          value: _selectedMeals.contains(meal),
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                _selectedMeals.add(meal);
              } else {
                _selectedMeals.remove(meal);
              }
            });
          },
        )).toList(),
      ],
    );
  }

  Widget _buildExerciseSelection() {
    return Column(
      children: [
        // Selected exercises
        if (_selectedExercises.isNotEmpty) ...[
          const Text(
            'Selected Exercises:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedExercises.map((exercise) => Chip(
              label: Text(exercise.name),
              backgroundColor: const Color(0xFF2196F3).withOpacity(0.1),
              deleteIcon: const Icon(Icons.close, size: 18),
              onDeleted: () {
                setState(() {
                  _selectedExercises.remove(exercise);
                });
              },
            )).toList(),
          ),
          const SizedBox(height: 16),
        ],
        
        // Available exercises
        const Text(
          'Available Exercises:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ..._availableExercises.map((exercise) => CheckboxListTile(
          title: Text(exercise.name),
          subtitle: Text(exercise.description),
          value: _selectedExercises.contains(exercise),
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                _selectedExercises.add(exercise);
              } else {
                _selectedExercises.remove(exercise);
              }
            });
          },
        )).toList(),
      ],
    );
  }

  Future<void> _savePrescriptions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final recommendations = {
        'patientId': widget.patientId,
        'doctorId': await SessionManager.getUserId(),
        'meals': _selectedMeals.map((meal) => meal.toJson()).toList(),
        'exercises': _selectedExercises.map((exercise) => exercise.toJson()).toList(),
        'prescribedAt': DateTime.now().toIso8601String(),
      };

      await _backendService.saveDoctorRecommendations(widget.patientId, recommendations);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Prescriptions saved successfully!'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving prescriptions: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}