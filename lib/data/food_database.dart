import '../models/models.dart';

class FoodDatabase {
  static List<FoodItem> get presets => [
    // ── Proteins ──────────────────────────────────────────────────────────────
    FoodItem(id: 'p001', name: 'Chicken Breast', calories: 165, protein: 31, carbs: 0,  fat: 3.6, servingSize: 100, unit: 'g'),
    FoodItem(id: 'p002', name: 'Egg (whole)',    calories: 155, protein: 13, carbs: 1.1,fat: 11,  servingSize: 100, unit: 'g'),
    FoodItem(id: 'p003', name: 'Tuna (canned)',  calories: 116, protein: 26, carbs: 0,  fat: 1,   servingSize: 100, unit: 'g'),
    FoodItem(id: 'p004', name: 'Salmon',         calories: 208, protein: 20, carbs: 0,  fat: 13,  servingSize: 100, unit: 'g'),
    FoodItem(id: 'p005', name: 'Greek Yogurt',   calories: 59,  protein: 10, carbs: 3.6,fat: 0.4, servingSize: 100, unit: 'g'),
    FoodItem(id: 'p006', name: 'Cottage Cheese', calories: 98,  protein: 11, carbs: 3.4,fat: 4.3, servingSize: 100, unit: 'g'),
    FoodItem(id: 'p007', name: 'Whey Protein',   calories: 400, protein: 80, carbs: 8,  fat: 5,   servingSize: 100, unit: 'g'),
    FoodItem(id: 'p008', name: 'Ground Beef (lean)', calories: 215, protein: 26, carbs: 0, fat: 11, servingSize: 100, unit: 'g'),
    FoodItem(id: 'p009', name: 'Turkey Breast',  calories: 135, protein: 30, carbs: 0,  fat: 1,   servingSize: 100, unit: 'g'),
    FoodItem(id: 'p010', name: 'Shrimp',         calories: 99,  protein: 24, carbs: 0.2,fat: 0.3, servingSize: 100, unit: 'g'),
    FoodItem(id: 'p011', name: 'Tofu (firm)',    calories: 76,  protein: 8,  carbs: 1.9,fat: 4.8, servingSize: 100, unit: 'g'),
    FoodItem(id: 'p012', name: 'Lentils (cooked)',calories: 116, protein: 9, carbs: 20, fat: 0.4, servingSize: 100, unit: 'g'),
    FoodItem(id: 'p013', name: 'Black Beans',    calories: 132, protein: 8.9,carbs: 24, fat: 0.5, servingSize: 100, unit: 'g'),
    FoodItem(id: 'p014', name: 'Milk (whole)',   calories: 61,  protein: 3.2,carbs: 4.8,fat: 3.3, servingSize: 100, unit: 'ml'),

    // ── Carbohydrates ─────────────────────────────────────────────────────────
    FoodItem(id: 'c001', name: 'White Rice (cooked)',  calories: 130, protein: 2.7, carbs: 28, fat: 0.3, servingSize: 100, unit: 'g'),
    FoodItem(id: 'c002', name: 'Brown Rice (cooked)',  calories: 112, protein: 2.3, carbs: 24, fat: 0.9, servingSize: 100, unit: 'g'),
    FoodItem(id: 'c003', name: 'Oats (dry)',           calories: 389, protein: 17,  carbs: 66, fat: 7,   servingSize: 100, unit: 'g'),
    FoodItem(id: 'c004', name: 'Whole Wheat Bread',    calories: 247, protein: 9,   carbs: 41, fat: 3.4, servingSize: 100, unit: 'g'),
    FoodItem(id: 'c005', name: 'Pasta (cooked)',       calories: 131, protein: 5,   carbs: 25, fat: 1.1, servingSize: 100, unit: 'g'),
    FoodItem(id: 'c006', name: 'Sweet Potato',         calories: 86,  protein: 1.6, carbs: 20, fat: 0.1, servingSize: 100, unit: 'g'),
    FoodItem(id: 'c007', name: 'Banana',               calories: 89,  protein: 1.1, carbs: 23, fat: 0.3, servingSize: 100, unit: 'g'),
    FoodItem(id: 'c008', name: 'Apple',                calories: 52,  protein: 0.3, carbs: 14, fat: 0.2, servingSize: 100, unit: 'g'),
    FoodItem(id: 'c009', name: 'Quinoa (cooked)',      calories: 120, protein: 4.4, carbs: 21, fat: 1.9, servingSize: 100, unit: 'g'),

    // ── Fats ──────────────────────────────────────────────────────────────────
    FoodItem(id: 'f001', name: 'Avocado',        calories: 160, protein: 2,   carbs: 9,  fat: 15,  servingSize: 100, unit: 'g'),
    FoodItem(id: 'f002', name: 'Peanut Butter',  calories: 588, protein: 25,  carbs: 20, fat: 50,  servingSize: 100, unit: 'g'),
    FoodItem(id: 'f003', name: 'Almonds',        calories: 579, protein: 21,  carbs: 22, fat: 50,  servingSize: 100, unit: 'g'),
    FoodItem(id: 'f004', name: 'Olive Oil',      calories: 884, protein: 0,   carbs: 0,  fat: 100, servingSize: 100, unit: 'ml'),
    FoodItem(id: 'f005', name: 'Cheddar Cheese', calories: 402, protein: 25,  carbs: 1.3,fat: 33,  servingSize: 100, unit: 'g'),

    // ── Vegetables ────────────────────────────────────────────────────────────
    FoodItem(id: 'v001', name: 'Broccoli',       calories: 34,  protein: 2.8, carbs: 7,  fat: 0.4, servingSize: 100, unit: 'g'),
    FoodItem(id: 'v002', name: 'Spinach',        calories: 23,  protein: 2.9, carbs: 3.6,fat: 0.4, servingSize: 100, unit: 'g'),
    FoodItem(id: 'v003', name: 'Carrot',         calories: 41,  protein: 0.9, carbs: 10, fat: 0.2, servingSize: 100, unit: 'g'),

    // ── Fast Food / Meals ─────────────────────────────────────────────────────
    FoodItem(id: 'm001', name: 'Burger (beef)',  calories: 295, protein: 17,  carbs: 24, fat: 14,  servingSize: 150, unit: 'g'),
    FoodItem(id: 'm002', name: 'Pizza slice',    calories: 266, protein: 11,  carbs: 33, fat: 10,  servingSize: 107, unit: 'g'),
    FoodItem(id: 'm003', name: 'French Fries',   calories: 312, protein: 3.4, carbs: 41, fat: 15,  servingSize: 100, unit: 'g'),
  ];
}
