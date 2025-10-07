import '../models/meal.dart';
import '../models/exercise.dart';
import 'session_manager.dart';
import 'backend_service.dart';
import 'package:flutter/material.dart';

class NutritionExerciseService {
  static final NutritionExerciseService _instance = NutritionExerciseService._internal();
  factory NutritionExerciseService() => _instance;
  NutritionExerciseService._internal();

  final BackendService _backendService = BackendService();

  // Default meals for different categories
  List<Meal> _getDefaultMeals() {
    return [
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
        name: 'Fresh Coconut',
        description: 'Natural hydration and healthy fats',
        imageUrl: 'assets/coconut.png',
        category: 'snack',
        nutritionalBenefits: ['Healthy Fats', 'Potassium', 'Electrolytes'],
        calories: 160,
        isPregnancySafe: true,
        preparation: 'Fresh coconut water and meat',
        ingredients: ['Fresh coconut'],
      ),
      Meal(
        id: 'meal_3',
        name: 'Banana Smoothie',
        description: 'High in potassium and natural energy',
        imageUrl: 'assets/banana.png',
        category: 'breakfast',
        nutritionalBenefits: ['Potassium', 'Vitamin B6', 'Natural Sugars'],
        calories: 200,
        isPregnancySafe: true,
        preparation: 'Blend banana with milk and honey',
        ingredients: ['Banana', 'Milk', 'Honey', 'Ice'],
      ),
      Meal(
        id: 'meal_4',
        name: 'Avocado Toast',
        description: 'Healthy fats and folate for baby development',
        imageUrl: 'assets/avocado.png',
        category: 'lunch',
        nutritionalBenefits: ['Folate', 'Healthy Fats', 'Fiber', 'Vitamin K'],
        calories: 320,
        isPregnancySafe: true,
        preparation: 'Mash avocado on whole grain toast',
        ingredients: ['Avocado', 'Whole grain bread', 'Salt', 'Lemon'],
      ),
      Meal(
        id: 'meal_5',
        name: 'Greek Yogurt',
        description: 'High protein and probiotics',
        imageUrl: 'assets/yogurt.png',
        category: 'snack',
        nutritionalBenefits: ['Protein', 'Probiotics', 'Calcium', 'Vitamin B12'],
        calories: 150,
        isPregnancySafe: true,
        preparation: 'Serve with fruits and nuts',
        ingredients: ['Greek yogurt', 'Berries', 'Nuts', 'Honey'],
      ),
      Meal(
        id: 'meal_6',
        name: 'Quinoa Salad',
        description: 'Complete protein and essential amino acids',
        imageUrl: 'assets/tip.png', // Using tip.png as placeholder
        category: 'lunch',
        nutritionalBenefits: ['Complete Protein', 'Iron', 'Magnesium', 'Fiber'],
        calories: 280,
        isPregnancySafe: true,
        preparation: 'Cook quinoa and mix with vegetables',
        ingredients: ['Quinoa', 'Vegetables', 'Olive oil', 'Lemon'],
      ),
      Meal(
        id: 'meal_7',
        name: 'Spinach Smoothie',
        description: 'Iron and folate for healthy pregnancy',
        imageUrl: 'assets/tip.png', // Using tip.png as placeholder
        category: 'breakfast',
        nutritionalBenefits: ['Iron', 'Folate', 'Vitamin A', 'Vitamin C'],
        calories: 180,
        isPregnancySafe: true,
        preparation: 'Blend spinach with fruits and yogurt',
        ingredients: ['Spinach', 'Banana', 'Yogurt', 'Apple juice'],
      ),
      Meal(
        id: 'meal_8',
        name: 'Sweet Potato',
        description: 'Beta-carotene and complex carbohydrates',
        imageUrl: 'assets/tip.png', // Using tip.png as placeholder
        category: 'dinner',
        nutritionalBenefits: ['Beta-carotene', 'Vitamin A', 'Fiber', 'Potassium'],
        calories: 200,
        isPregnancySafe: true,
        preparation: 'Baked or steamed sweet potato',
        ingredients: ['Sweet potato', 'Olive oil', 'Herbs'],
      ),
    ];
  }

  // Default exercises for pregnancy
  List<Exercise> _getDefaultExercises() {
    return [
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
      Exercise(
        id: 'exercise_3',
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
        id: 'exercise_4',
        name: 'Light Weights',
        description: 'Strength training with light weights',
        icon: Icons.fitness_center,
        duration: '20 minutes',
        difficulty: 'moderate',
        benefits: ['Muscle strength', 'Bone health', 'Posture improvement'],
        isPregnancySafe: true,
        instructions: 'Use light weights with proper form',
        trimester: 'first,second',
      ),
      Exercise(
        id: 'exercise_5',
        name: 'Stationary Bike',
        description: 'Safe cardio with lower back support',
        icon: Icons.directions_bike,
        duration: '25 minutes',
        difficulty: 'moderate',
        benefits: ['Cardio fitness', 'Leg strength', 'Low impact'],
        isPregnancySafe: true,
        instructions: 'Cycle at moderate intensity',
        trimester: 'first,second',
      ),
      Exercise(
        id: 'exercise_6',
        name: 'Stretching',
        description: 'Gentle stretches for flexibility',
        icon: Icons.spa,
        duration: '15 minutes',
        difficulty: 'easy',
        benefits: ['Flexibility', 'Muscle relaxation', 'Stress relief'],
        isPregnancySafe: true,
        instructions: 'Gentle stretching routine',
        trimester: 'all',
      ),
    ];
  }

  // Get recommended meals for today (ONLY doctor-prescribed meals)
  Future<List<Meal>> getTodaysMeals() async {
    try {
      final userId = await SessionManager.getUserId();
      print('NutritionService: Getting meals for user ID: $userId');
      
      if (userId != null) {
        // Try to get doctor-recommended meals
        final doctorRecommendations = await _backendService.getDoctorRecommendations(userId);
        print('NutritionService: Doctor recommendations: $doctorRecommendations');
        
        if (doctorRecommendations != null && doctorRecommendations['meals'] != null) {
          final List<dynamic> mealData = doctorRecommendations['meals'];
          print('NutritionService: Found ${mealData.length} prescribed meals');
          final meals = mealData.map((meal) => Meal.fromJson(meal)).toList();
          print('NutritionService: Parsed meals: ${meals.map((m) => m.name).toList()}');
          return meals;
        } else {
          print('NutritionService: No meals found in doctor recommendations');
        }
      } else {
        print('NutritionService: No user ID found');
      }
    } catch (e) {
      print('NutritionService: Error getting doctor recommendations: $e');
    }
    
    // Return empty list if no doctor recommendations
    print('NutritionService: Returning empty meals list');
    return [];
  }

  // Get recommended exercises for today (either from doctor or default)
  Future<List<Exercise>> getTodaysExercises() async {
    try {
      final userId = await SessionManager.getUserId();
      if (userId != null) {
        // Try to get doctor-recommended exercises
        final doctorRecommendations = await _backendService.getDoctorRecommendations(userId);
        
        if (doctorRecommendations != null && doctorRecommendations['exercises'] != null) {
          final List<dynamic> exerciseData = doctorRecommendations['exercises'];
          print('NutritionService: Found ${exerciseData.length} prescribed exercises');
          final exercises = exerciseData.map((exercise) => Exercise.fromJson(exercise)).toList();
          print('NutritionService: Parsed exercises: ${exercises.map((e) => e.name).toList()}');
          return exercises;
        } else {
          print('NutritionService: No exercises found in doctor recommendations');
        }
      }
    } catch (e) {
      print('NutritionService: Error getting doctor recommendations: $e');
    }
    
    // Return empty list if no doctor recommendations
    print('NutritionService: Returning empty exercises list');
    return [];
  }

  // Get all available meals by category
  Future<Map<String, List<Meal>>> getAllMealsByCategory() async {
    final meals = _getDefaultMeals();
    final Map<String, List<Meal>> categorizedMeals = {};
    
    for (final meal in meals) {
      if (!categorizedMeals.containsKey(meal.category)) {
        categorizedMeals[meal.category] = [];
      }
      categorizedMeals[meal.category]!.add(meal);
    }
    
    return categorizedMeals;
  }

  // Get all available exercises
  Future<List<Exercise>> getAllExercises() async {
    return _getDefaultExercises();
  }
}