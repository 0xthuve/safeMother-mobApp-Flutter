class Meal {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String category; // breakfast, lunch, dinner, snack
  final List<String> nutritionalBenefits;
  final int calories;
  final bool isPregnancySafe;
  final String preparation;
  final List<String> ingredients;

  Meal({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.nutritionalBenefits,
    required this.calories,
    required this.isPregnancySafe,
    required this.preparation,
    required this.ingredients,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      category: json['category'] ?? '',
      nutritionalBenefits: List<String>.from(json['nutritionalBenefits'] ?? []),
      calories: json['calories'] ?? 0,
      isPregnancySafe: json['isPregnancySafe'] ?? true,
      preparation: json['preparation'] ?? '',
      ingredients: List<String>.from(json['ingredients'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'nutritionalBenefits': nutritionalBenefits,
      'calories': calories,
      'isPregnancySafe': isPregnancySafe,
      'preparation': preparation,
      'ingredients': ingredients,
    };
  }
}