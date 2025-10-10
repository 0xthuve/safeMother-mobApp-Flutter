import 'package:flutter/material.dart';

class Exercise {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final String duration;
  final String difficulty; // easy, moderate, hard
  final List<String> benefits;
  final bool isPregnancySafe;
  final String instructions;
  final String trimester; // all, first, second, third

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.duration,
    required this.difficulty,
    required this.benefits,
    required this.isPregnancySafe,
    required this.instructions,
    required this.trimester,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: _getIconFromString(json['icon'] ?? 'fitness_center'),
      duration: json['duration'] ?? '',
      difficulty: json['difficulty'] ?? 'easy',
      benefits: List<String>.from(json['benefits'] ?? []),
      isPregnancySafe: json['isPregnancySafe'] ?? true,
      instructions: json['instructions'] ?? '',
      trimester: json['trimester'] ?? 'all',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': _getStringFromIcon(icon),
      'duration': duration,
      'difficulty': difficulty,
      'benefits': benefits,
      'isPregnancySafe': isPregnancySafe,
      'instructions': instructions,
      'trimester': trimester,
    };
  }

  static IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'directions_walk':
        return Icons.directions_walk;
      case 'pool':
        return Icons.pool;
      case 'self_improvement':
        return Icons.self_improvement;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'directions_bike':
        return Icons.directions_bike;
      case 'sports_gymnastics':
        return Icons.sports_gymnastics;
      case 'spa':
        return Icons.spa;
      default:
        return Icons.fitness_center;
    }
  }

  static String _getStringFromIcon(IconData icon) {
    if (icon == Icons.directions_walk) return 'directions_walk';
    if (icon == Icons.pool) return 'pool';
    if (icon == Icons.self_improvement) return 'self_improvement';
    if (icon == Icons.fitness_center) return 'fitness_center';
    if (icon == Icons.directions_bike) return 'directions_bike';
    if (icon == Icons.sports_gymnastics) return 'sports_gymnastics';
    if (icon == Icons.spa) return 'spa';
    return 'fitness_center';
  }
}