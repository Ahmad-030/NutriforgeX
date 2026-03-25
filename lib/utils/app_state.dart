import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class AppState extends ChangeNotifier {
  static const _keyProfile   = 'user_profile';
  static const _keyMeals     = 'meal_entries';
  static const _keyStreak    = 'protein_streak';
  static const _keyLastDate  = 'last_streak_date';
  static const _keyOnboarded = 'onboarded';

  UserProfile? _profile;
  List<MealEntry> _allMeals = [];
  int _proteinStreak = 0;
  bool _onboarded = false;
  DateTime _selectedDate = DateTime.now();

  UserProfile? get profile => _profile;
  int get proteinStreak => _proteinStreak;
  bool get onboarded => _onboarded;
  DateTime get selectedDate => _selectedDate;

  List<MealEntry> get todayMeals {
    final now = _selectedDate;
    return _allMeals.where((m) =>
      m.dateTime.year == now.year &&
      m.dateTime.month == now.month &&
      m.dateTime.day == now.day
    ).toList()..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  List<MealEntry> mealsForDate(DateTime date) {
    return _allMeals.where((m) =>
      m.dateTime.year == date.year &&
      m.dateTime.month == date.month &&
      m.dateTime.day == date.day
    ).toList();
  }

  DailySummary? get todaySummary {
    if (_profile == null) return null;
    return DailySummary(date: _selectedDate, meals: todayMeals, profile: _profile!);
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _onboarded = prefs.getBool(_keyOnboarded) ?? false;
    _proteinStreak = prefs.getInt(_keyStreak) ?? 0;

    final profileJson = prefs.getString(_keyProfile);
    if (profileJson != null) {
      _profile = UserProfile.fromJson(profileJson);
    }

    final mealsJson = prefs.getStringList(_keyMeals) ?? [];
    _allMeals = mealsJson
        .map((j) => MealEntry.fromJson(j))
        .toList();

    _checkStreak(prefs);
    notifyListeners();
  }

  void _checkStreak(SharedPreferences prefs) {
    final lastDateStr = prefs.getString(_keyLastDate);
    if (lastDateStr == null) return;
    final lastDate = DateTime.parse(lastDateStr);
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    if (lastDate.year == yesterday.year &&
        lastDate.month == yesterday.month &&
        lastDate.day == yesterday.day) {
      // streak still valid
    } else if (lastDate.year != DateTime.now().year ||
               lastDate.month != DateTime.now().month ||
               lastDate.day != DateTime.now().day) {
      _proteinStreak = 0;
      prefs.setInt(_keyStreak, 0);
    }
  }

  Future<void> saveProfile(UserProfile profile) async {
    _profile = profile;
    _onboarded = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyProfile, profile.toJson());
    await prefs.setBool(_keyOnboarded, true);
    notifyListeners();
  }

  Future<void> addMeal(MealEntry meal) async {
    _allMeals.add(meal);
    await _saveMeals();
    await _updateStreak();
    notifyListeners();
  }

  Future<void> deleteMeal(String id) async {
    _allMeals.removeWhere((m) => m.id == id);
    await _saveMeals();
    notifyListeners();
  }

  Future<void> _saveMeals() async {
    // Keep max 500 entries
    if (_allMeals.length > 500) {
      _allMeals = _allMeals.sublist(_allMeals.length - 500);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyMeals, _allMeals.map((m) => m.toJson()).toList());
  }

  Future<void> _updateStreak() async {
    if (_profile == null) return;
    final today = todaySummary;
    if (today == null) return;
    if (today.totalProtein >= _profile!.dailyProtein) {
      final prefs = await SharedPreferences.getInstance();
      final lastDateStr = prefs.getString(_keyLastDate);
      final now = DateTime.now();
      if (lastDateStr != null) {
        final last = DateTime.parse(lastDateStr);
        if (last.year == now.year && last.month == now.month && last.day == now.day) {
          return; // already counted today
        }
      }
      _proteinStreak++;
      await prefs.setInt(_keyStreak, _proteinStreak);
      await prefs.setString(_keyLastDate, now.toIso8601String());
    }
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  // Weekly data for charts
  List<Map<String, dynamic>> get weeklyData {
    final result = <Map<String, dynamic>>[];
    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final meals = mealsForDate(date);
      final calories = meals.fold<double>(0, (s, m) => s + m.totalCalories);
      final protein  = meals.fold<double>(0, (s, m) => s + m.totalProtein);
      result.add({'date': date, 'calories': calories, 'protein': protein});
    }
    return result;
  }

  // BMR / TDEE Calculator
  static Map<String, double> calculateBMR({
    required double weightKg,
    required double heightCm,
    required int age,
    required String gender,
    required String activityLevel,
    required String goal,
  }) {
    // Mifflin-St Jeor Equation
    double bmr;
    if (gender == 'male') {
      bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5;
    } else {
      bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 161;
    }

    const multipliers = {
      'sedentary': 1.2,
      'light': 1.375,
      'moderate': 1.55,
      'active': 1.725,
      'very_active': 1.9,
    };

    double tdee = bmr * (multipliers[activityLevel] ?? 1.55);

    double targetCalories;
    switch (goal) {
      case 'lose':   targetCalories = tdee - 500; break;
      case 'gain':   targetCalories = tdee + 300; break;
      default:       targetCalories = tdee;
    }
    targetCalories = targetCalories.clamp(1200, 4000);

    // Macro split
    double protein, carbs, fat;
    switch (goal) {
      case 'lose':
        protein = weightKg * 2.2;   // high protein for muscle retention
        fat     = targetCalories * 0.25 / 9;
        carbs   = (targetCalories - (protein * 4) - (fat * 9)) / 4;
        break;
      case 'gain':
        protein = weightKg * 2.0;
        fat     = targetCalories * 0.25 / 9;
        carbs   = (targetCalories - (protein * 4) - (fat * 9)) / 4;
        break;
      default:
        protein = weightKg * 1.8;
        fat     = targetCalories * 0.30 / 9;
        carbs   = (targetCalories - (protein * 4) - (fat * 9)) / 4;
    }

    return {
      'bmr': bmr,
      'tdee': tdee,
      'calories': targetCalories,
      'protein': protein.clamp(0, 300),
      'carbs': carbs.clamp(0, 500),
      'fat': fat.clamp(0, 150),
    };
  }
}
