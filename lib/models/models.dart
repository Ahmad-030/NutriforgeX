import 'dart:convert';

// ─── User Profile Model ───────────────────────────────────────────────────────
class UserProfile {
  final String name;
  final double weightKg;
  final double heightCm;
  final int age;
  final String gender; // male / female
  final String activityLevel; // sedentary / light / moderate / active / very_active
  final String goal; // lose / maintain / gain
  final double dailyCalories;
  final double dailyProtein;
  final double dailyCarbs;
  final double dailyFat;

  UserProfile({
    required this.name,
    required this.weightKg,
    required this.heightCm,
    required this.age,
    required this.gender,
    required this.activityLevel,
    required this.goal,
    required this.dailyCalories,
    required this.dailyProtein,
    required this.dailyCarbs,
    required this.dailyFat,
  });

  Map<String, dynamic> toMap() => {
    'name': name, 'weightKg': weightKg, 'heightCm': heightCm,
    'age': age, 'gender': gender, 'activityLevel': activityLevel,
    'goal': goal, 'dailyCalories': dailyCalories, 'dailyProtein': dailyProtein,
    'dailyCarbs': dailyCarbs, 'dailyFat': dailyFat,
  };

  factory UserProfile.fromMap(Map<String, dynamic> m) => UserProfile(
    name: m['name'] ?? '', weightKg: (m['weightKg'] ?? 70).toDouble(),
    heightCm: (m['heightCm'] ?? 170).toDouble(), age: m['age'] ?? 25,
    gender: m['gender'] ?? 'male', activityLevel: m['activityLevel'] ?? 'moderate',
    goal: m['goal'] ?? 'maintain', dailyCalories: (m['dailyCalories'] ?? 2000).toDouble(),
    dailyProtein: (m['dailyProtein'] ?? 150).toDouble(),
    dailyCarbs: (m['dailyCarbs'] ?? 200).toDouble(),
    dailyFat: (m['dailyFat'] ?? 65).toDouble(),
  );

  String toJson() => jsonEncode(toMap());
  factory UserProfile.fromJson(String source) => UserProfile.fromMap(jsonDecode(source));
}

// ─── Food Item Model ──────────────────────────────────────────────────────────
class FoodItem {
  final String id;
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double servingSize; // grams
  final String unit;
  final bool isCustom;

  FoodItem({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.servingSize = 100,
    this.unit = 'g',
    this.isCustom = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'calories': calories, 'protein': protein,
    'carbs': carbs, 'fat': fat, 'servingSize': servingSize,
    'unit': unit, 'isCustom': isCustom,
  };

  factory FoodItem.fromMap(Map<String, dynamic> m) => FoodItem(
    id: m['id'] ?? '', name: m['name'] ?? '', calories: (m['calories'] ?? 0).toDouble(),
    protein: (m['protein'] ?? 0).toDouble(), carbs: (m['carbs'] ?? 0).toDouble(),
    fat: (m['fat'] ?? 0).toDouble(), servingSize: (m['servingSize'] ?? 100).toDouble(),
    unit: m['unit'] ?? 'g', isCustom: m['isCustom'] ?? false,
  );
}

// ─── Meal Entry Model ─────────────────────────────────────────────────────────
class MealEntry {
  final String id;
  final String mealType; // Breakfast / Lunch / Dinner / Snack
  final FoodItem food;
  final double quantity;
  final DateTime dateTime;

  MealEntry({
    required this.id,
    required this.mealType,
    required this.food,
    required this.quantity,
    required this.dateTime,
  });

  double get totalCalories => (food.calories / food.servingSize) * quantity;
  double get totalProtein  => (food.protein  / food.servingSize) * quantity;
  double get totalCarbs    => (food.carbs    / food.servingSize) * quantity;
  double get totalFat      => (food.fat      / food.servingSize) * quantity;

  Map<String, dynamic> toMap() => {
    'id': id, 'mealType': mealType, 'food': food.toMap(),
    'quantity': quantity, 'dateTime': dateTime.toIso8601String(),
  };

  factory MealEntry.fromMap(Map<String, dynamic> m) => MealEntry(
    id: m['id'] ?? '', mealType: m['mealType'] ?? 'Breakfast',
    food: FoodItem.fromMap(m['food']),
    quantity: (m['quantity'] ?? 100).toDouble(),
    dateTime: DateTime.parse(m['dateTime']),
  );

  String toJson() => jsonEncode(toMap());
  factory MealEntry.fromJson(String source) => MealEntry.fromMap(jsonDecode(source));
}

// ─── Daily Summary Model ──────────────────────────────────────────────────────
class DailySummary {
  final DateTime date;
  final List<MealEntry> meals;
  final UserProfile profile;

  DailySummary({required this.date, required this.meals, required this.profile});

  double get totalCalories => meals.fold(0, (s, m) => s + m.totalCalories);
  double get totalProtein  => meals.fold(0, (s, m) => s + m.totalProtein);
  double get totalCarbs    => meals.fold(0, (s, m) => s + m.totalCarbs);
  double get totalFat      => meals.fold(0, (s, m) => s + m.totalFat);

  double get calorieProgress => (totalCalories / profile.dailyCalories).clamp(0, 1);
  double get proteinProgress => (totalProtein  / profile.dailyProtein).clamp(0, 1);
  double get carbsProgress   => (totalCarbs    / profile.dailyCarbs).clamp(0, 1);
  double get fatProgress     => (totalFat      / profile.dailyFat).clamp(0, 1);

  double get remainingCalories => (profile.dailyCalories - totalCalories).clamp(0, double.infinity);
}
