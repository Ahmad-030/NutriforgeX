import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../utils/app_theme.dart';
import '../utils/app_state.dart';
import '../models/models.dart';
import '../data/food_database.dart';

class LogMealScreen extends StatefulWidget {
  const LogMealScreen({super.key});
  @override
  State<LogMealScreen> createState() => _LogMealScreenState();
}

class _LogMealScreenState extends State<LogMealScreen> {
  final _searchCtrl = TextEditingController();
  String _mealType  = 'Breakfast';
  String _query     = '';
  FoodItem? _selected;
  double _quantity  = 100;

  // Custom entry
  bool _showCustom  = false;
  final _cNameCtrl  = TextEditingController();
  final _cCalCtrl   = TextEditingController();
  final _cProCtrl   = TextEditingController();
  final _cCarbCtrl  = TextEditingController();
  final _cFatCtrl   = TextEditingController();

  List<FoodItem> get _filteredFoods {
    final q = _query.toLowerCase();
    if (q.isEmpty) return FoodDatabase.presets;
    return FoodDatabase.presets.where((f) => f.name.toLowerCase().contains(q)).toList();
  }

  void _selectFood(FoodItem food) {
    setState(() { _selected = food; _quantity = food.servingSize; });
  }

  Future<void> _logMeal() async {
    if (_selected == null) return;
    final entry = MealEntry(
      id: const Uuid().v4(),
      mealType: _mealType,
      food: _selected!,
      quantity: _quantity,
      dateTime: DateTime.now(),
    );
    await context.read<AppState>().addMeal(entry);
    if (!mounted) return;
    setState(() { _selected = null; _searchCtrl.clear(); _query = ''; });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${entry.food.name} logged! 💪'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _addCustomFood() {
    if (_cNameCtrl.text.trim().isEmpty) return;
    final food = FoodItem(
      id: const Uuid().v4(),
      name: _cNameCtrl.text.trim(),
      calories: double.tryParse(_cCalCtrl.text) ?? 0,
      protein:  double.tryParse(_cProCtrl.text) ?? 0,
      carbs:    double.tryParse(_cCarbCtrl.text) ?? 0,
      fat:      double.tryParse(_cFatCtrl.text) ?? 0,
      isCustom: true,
    );
    setState(() {
      _selected = food;
      _quantity = 100;
      _showCustom = false;
    });
    _cNameCtrl.clear(); _cCalCtrl.clear(); _cProCtrl.clear(); _cCarbCtrl.clear(); _cFatCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Log Meal'),
        actions: [
          TextButton.icon(
            onPressed: () => setState(() => _showCustom = !_showCustom),
            icon: Icon(_showCustom ? Icons.close : Icons.add, color: AppColors.primary),
            label: Text(_showCustom ? 'Cancel' : 'Custom',
              style: const TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Meal type selector
          FadeInDown(
            child: Container(
              color: AppColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: ['Breakfast', 'Lunch', 'Dinner', 'Snack'].map((t) =>
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _mealType = t),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _mealType == t ? AppColors.primary : AppColors.card,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(t,
                          style: TextStyle(
                            color: _mealType == t ? Colors.black : AppColors.textSecondary,
                            fontSize: 11, fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ).toList(),
              ),
            ),
          ),

          // Custom food form
          if (_showCustom) _CustomFoodForm(
            nameCtrl: _cNameCtrl, calCtrl: _cCalCtrl, proCtrl: _cProCtrl,
            carbCtrl: _cCarbCtrl, fatCtrl: _cFatCtrl, onAdd: _addCustomFood,
          ),

          // Search bar
          if (!_showCustom) Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Search foods...',
                prefixIcon: Icon(Icons.search_rounded, color: AppColors.primary),
              ),
            ),
          ),

          // Selected food preview
          if (_selected != null && !_showCustom) _SelectedFoodCard(
            food: _selected!, quantity: _quantity,
            onQuantityChanged: (v) => setState(() => _quantity = v),
            onLog: _logMeal,
          ),

          // Food list
          if (!_showCustom) Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredFoods.length,
              itemBuilder: (context, i) {
                final food = _filteredFoods[i];
                final isSelected = _selected?.id == food.id;
                return FadeInLeft(
                  delay: Duration(milliseconds: i * 40),
                  child: GestureDetector(
                    onTap: () => _selectFood(food),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary.withOpacity(0.12) : AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.divider,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(children: [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(food.name, style: TextStyle(
                            color: isSelected ? AppColors.primary : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          )),
                          Text('Per ${food.servingSize.round()}${food.unit}',
                            style: const TextStyle(color: AppColors.textHint, fontSize: 11)),
                        ])),
                        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Text('${food.calories.round()} kcal',
                            style: const TextStyle(color: AppColors.calorieColor, fontWeight: FontWeight.w700)),
                          Text('P:${food.protein.round()}g C:${food.carbs.round()}g F:${food.fat.round()}g',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                        ]),
                      ]),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedFoodCard extends StatelessWidget {
  final FoodItem food;
  final double quantity;
  final Function(double) onQuantityChanged;
  final VoidCallback onLog;

  const _SelectedFoodCard({
    required this.food, required this.quantity,
    required this.onQuantityChanged, required this.onLog,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = quantity / food.servingSize;
    return FadeInDown(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withOpacity(0.4)),
        ),
        child: Column(children: [
          Row(children: [
            Expanded(child: Text(food.name,
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 16))),
            ElevatedButton(onPressed: onLog, child: const Text('Log It!')),
          ]),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _Stat('Cal', '${(food.calories * ratio).round()}', AppColors.calorieColor),
            _Stat('Pro', '${(food.protein * ratio).round()}g',  AppColors.proteinColor),
            _Stat('Carb','${(food.carbs * ratio).round()}g',   AppColors.carbsColor),
            _Stat('Fat', '${(food.fat * ratio).round()}g',     AppColors.fatColor),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            const Text('Qty:', style: TextStyle(color: AppColors.textSecondary)),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: AppColors.divider,
                  thumbColor: AppColors.lime,
                ),
                child: Slider(
                  value: quantity,
                  min: 5,
                  max: 1000,
                  onChanged: onQuantityChanged,
                ),
              ),
            ),
            Text('${quantity.round()}${food.unit}',
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
          ]),
        ]),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _Stat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 16)),
    Text(label, style: const TextStyle(color: AppColors.textHint, fontSize: 10)),
  ]);
}

class _CustomFoodForm extends StatelessWidget {
  final TextEditingController nameCtrl, calCtrl, proCtrl, carbCtrl, fatCtrl;
  final VoidCallback onAdd;

  const _CustomFoodForm({
    required this.nameCtrl, required this.calCtrl, required this.proCtrl,
    required this.carbCtrl, required this.fatCtrl, required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Add Custom Food',
            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 12),
          TextField(controller: nameCtrl,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(labelText: 'Food Name')),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: TextField(controller: calCtrl, keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(labelText: 'Calories'))),
            const SizedBox(width: 10),
            Expanded(child: TextField(controller: proCtrl, keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(labelText: 'Protein (g)'))),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: TextField(controller: carbCtrl, keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(labelText: 'Carbs (g)'))),
            const SizedBox(width: 10),
            Expanded(child: TextField(controller: fatCtrl, keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(labelText: 'Fat (g)'))),
          ]),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity,
            child: ElevatedButton(onPressed: onAdd, child: const Text('Add Food'))),
        ]),
      ),
    );
  }
}
