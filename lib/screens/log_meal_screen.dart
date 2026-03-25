import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../utils/app_theme.dart';
import '../utils/app_state.dart';
import '../models/models.dart';
import '../data/food_database.dart';

// ─── Category definition ──────────────────────────────────────────────────────
class _FoodCategory {
  final String key;       // prefix used in FoodDatabase ids
  final String label;
  final String emoji;
  final Color  color;

  const _FoodCategory({
    required this.key,
    required this.label,
    required this.emoji,
    required this.color,
  });
}

const _categories = [
  _FoodCategory(key: 'all',  label: 'All',      emoji: '🍽️', color: AppColors.primary),
  _FoodCategory(key: 'p',    label: 'Proteins',  emoji: '🥩', color: AppColors.proteinColor),
  _FoodCategory(key: 'c',    label: 'Carbs',     emoji: '🌾', color: AppColors.carbsColor),
  _FoodCategory(key: 'f',    label: 'Fats',      emoji: '🥑', color: AppColors.fatColor),
  _FoodCategory(key: 'v',    label: 'Veggies',   emoji: '🥦', color: Color(0xFF39D353)),
  _FoodCategory(key: 'm',    label: 'Fast Food',  emoji: '🍔', color: Color(0xFFFF8C42)),
];

// ─── Screen ───────────────────────────────────────────────────────────────────
class LogMealScreen extends StatefulWidget {
  const LogMealScreen({super.key});
  @override
  State<LogMealScreen> createState() => _LogMealScreenState();
}

class _LogMealScreenState extends State<LogMealScreen>
    with SingleTickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  String _mealType  = 'Breakfast';
  String _query     = '';
  FoodItem? _selected;
  double _quantity  = 100;

  // Category
  String _activeCategory = 'all';

  // Custom entry
  bool _showCustom  = false;
  final _cNameCtrl  = TextEditingController();
  final _cCalCtrl   = TextEditingController();
  final _cProCtrl   = TextEditingController();
  final _cCarbCtrl  = TextEditingController();
  final _cFatCtrl   = TextEditingController();

  List<FoodItem> get _filteredFoods {
    final q = _query.toLowerCase();
    var list = FoodDatabase.presets;

    // Filter by category (using id prefix)
    if (_activeCategory != 'all') {
      list = list.where((f) => f.id.startsWith(_activeCategory)).toList();
    }

    // Filter by search
    if (q.isNotEmpty) {
      list = list.where((f) => f.name.toLowerCase().contains(q)).toList();
    }

    return list;
  }

  _FoodCategory get _activeCat =>
      _categories.firstWhere((c) => c.key == _activeCategory);

  void _selectFood(FoodItem food) {
    setState(() {
      _selected = food;
      _quantity = food.servingSize;
    });
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
    setState(() {
      _selected = null;
      _searchCtrl.clear();
      _query = '';
    });
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
      _selected  = food;
      _quantity  = 100;
      _showCustom = false;
    });
    _cNameCtrl.clear();
    _cCalCtrl.clear();
    _cProCtrl.clear();
    _cCarbCtrl.clear();
    _cFatCtrl.clear();
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
            icon: Icon(
              _showCustom ? Icons.close : Icons.add,
              color: AppColors.primary,
            ),
            label: Text(
              _showCustom ? 'Cancel' : 'Custom',
              style: const TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Meal type selector ──────────────────────────────────────────────
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
                            color: _mealType == t
                                ? AppColors.primary
                                : AppColors.card,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            t,
                            style: TextStyle(
                              color: _mealType == t
                                  ? Colors.black
                                  : AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                ).toList(),
              ),
            ),
          ),

          // ── Custom food form ────────────────────────────────────────────────
          if (_showCustom)
            _CustomFoodForm(
              nameCtrl: _cNameCtrl,
              calCtrl:  _cCalCtrl,
              proCtrl:  _cProCtrl,
              carbCtrl: _cCarbCtrl,
              fatCtrl:  _cFatCtrl,
              onAdd:    _addCustomFood,
            ),

          if (!_showCustom) ...[
            // ── Search bar ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v),
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Search foods...',
                  prefixIcon: Icon(Icons.search_rounded, color: AppColors.primary),
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            // ── Category chips ────────────────────────────────────────────────
            _CategoryBar(
              categories: _categories,
              active: _activeCategory,
              onSelect: (k) => setState(() {
                _activeCategory = k;
                _selected = null;
              }),
            ),

            // ── Selected food card ────────────────────────────────────────────
            if (_selected != null)
              _SelectedFoodCard(
                food: _selected!,
                quantity: _quantity,
                onQuantityChanged: (v) => setState(() => _quantity = v),
                onLog: _logMeal,
              ),

            // ── Category header label ─────────────────────────────────────────
            if (_query.isEmpty)
              _CategoryHeaderLabel(cat: _activeCat, count: _filteredFoods.length),

            // ── Food list ─────────────────────────────────────────────────────
            Expanded(
              child: _filteredFoods.isEmpty
                  ? _EmptyState(query: _query, catLabel: _activeCat.label)
                  : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                itemCount: _filteredFoods.length,
                itemBuilder: (context, i) {
                  final food = _filteredFoods[i];
                  final isSelected = _selected?.id == food.id;
                  final cat = _categories.firstWhere(
                        (c) => food.id.startsWith(c.key) && c.key != 'all',
                    orElse: () => _categories.first,
                  );
                  return FadeInLeft(
                    delay: Duration(milliseconds: i * 35),
                    child: _FoodTile(
                      food: food,
                      isSelected: isSelected,
                      catColor: cat.color,
                      catEmoji: cat.emoji,
                      onTap: () => _selectFood(food),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Category Bar ─────────────────────────────────────────────────────────────
class _CategoryBar extends StatelessWidget {
  final List<_FoodCategory> categories;
  final String active;
  final Function(String) onSelect;

  const _CategoryBar({
    required this.categories,
    required this.active,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final cat = categories[i];
          final sel = cat.key == active;
          return GestureDetector(
            onTap: () => onSelect(cat.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: sel ? cat.color.withOpacity(0.18) : AppColors.card,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: sel ? cat.color : AppColors.divider,
                  width: sel ? 1.5 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(cat.emoji, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(
                    cat.label,
                    style: TextStyle(
                      color: sel ? cat.color : AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Category Header Label ────────────────────────────────────────────────────
class _CategoryHeaderLabel extends StatelessWidget {
  final _FoodCategory cat;
  final int count;
  const _CategoryHeaderLabel({required this.cat, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Row(
        children: [
          Text(
            cat.emoji,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 8),
          Text(
            cat.key == 'all' ? 'All Foods' : cat.label,
            style: TextStyle(
              color: cat.color,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: cat.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count items',
              style: TextStyle(
                color: cat.color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Food Tile ────────────────────────────────────────────────────────────────
class _FoodTile extends StatelessWidget {
  final FoodItem food;
  final bool isSelected;
  final Color catColor;
  final String catEmoji;
  final VoidCallback onTap;

  const _FoodTile({
    required this.food,
    required this.isSelected,
    required this.catColor,
    required this.catEmoji,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? catColor.withOpacity(0.10) : AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? catColor : AppColors.divider,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Category emoji badge
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: catColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(catEmoji, style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name,
                    style: TextStyle(
                      color: isSelected ? catColor : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Per ${food.servingSize.round()}${food.unit}',
                    style: const TextStyle(
                      color: AppColors.textHint,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${food.calories.round()} kcal',
                  style: const TextStyle(
                    color: AppColors.calorieColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'P:${food.protein.round()}  C:${food.carbs.round()}  F:${food.fat.round()}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final String query;
  final String catLabel;
  const _EmptyState({required this.query, required this.catLabel});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔍', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(
            query.isNotEmpty
                ? 'No results for "$query"'
                : 'No $catLabel foods found',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 4),
          const Text(
            'Try a different search or category',
            style: TextStyle(color: AppColors.textHint, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ─── Selected Food Card ────────────────────────────────────────────────────────
class _SelectedFoodCard extends StatelessWidget {
  final FoodItem food;
  final double quantity;
  final Function(double) onQuantityChanged;
  final VoidCallback onLog;

  const _SelectedFoodCard({
    required this.food,
    required this.quantity,
    required this.onQuantityChanged,
    required this.onLog,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = quantity / food.servingSize;
    return FadeInDown(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withOpacity(0.4)),
        ),
        child: Column(children: [
          Row(children: [
            Expanded(
              child: Text(
                food.name,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: onLog,
              child: const Text('Log It!'),
            ),
          ]),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _Stat('Cal',  '${(food.calories * ratio).round()}',    AppColors.calorieColor),
            _Stat('Pro',  '${(food.protein * ratio).round()}g',    AppColors.proteinColor),
            _Stat('Carb', '${(food.carbs * ratio).round()}g',      AppColors.carbsColor),
            _Stat('Fat',  '${(food.fat * ratio).round()}g',        AppColors.fatColor),
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
            Text(
              '${quantity.round()}${food.unit}',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
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
    Text(value,
        style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 16)),
    Text(label,
        style: const TextStyle(color: AppColors.textHint, fontSize: 10)),
  ]);
}

// ─── Custom Food Form ─────────────────────────────────────────────────────────
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
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text(
            'Add Custom Food',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: nameCtrl,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(labelText: 'Food Name'),
          ),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: TextField(
              controller: calCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(labelText: 'Calories'),
            )),
            const SizedBox(width: 10),
            Expanded(child: TextField(
              controller: proCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(labelText: 'Protein (g)'),
            )),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: TextField(
              controller: carbCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(labelText: 'Carbs (g)'),
            )),
            const SizedBox(width: 10),
            Expanded(child: TextField(
              controller: fatCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(labelText: 'Fat (g)'),
            )),
          ]),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onAdd,
              child: const Text('Add Food'),
            ),
          ),
        ]),
      ),
    );
  }
}