import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../utils/app_theme.dart';
import '../utils/app_state.dart';
import '../models/models.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final summary = state.todaySummary;
        final profile = state.profile;
        if (profile == null || summary == null) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              _buildAppBar(context, state, profile),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(delegate: SliverChildListDelegate([
                  _CalorieRingCard(summary: summary),
                  const SizedBox(height: 20),
                  _ProteinStreakBanner(streak: state.proteinStreak, summary: summary),
                  const SizedBox(height: 20),
                  _MacroRow(summary: summary),
                  const SizedBox(height: 20),
                  _TodayMealsList(meals: state.todayMeals, state: state),
                  const SizedBox(height: 100),
                ])),
              ),
            ],
          ),
        );
      },
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, AppState state, UserProfile profile) {
    return SliverAppBar(
      backgroundColor: AppColors.surface,
      floating: true,
      elevation: 0,
      title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Hey, ${profile.name.split(' ').first}! 👋',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        Text(DateFormat('EEEE, MMMM d').format(DateTime.now()),
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      ]),
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline_rounded, color: AppColors.primary),
          onPressed: () => Navigator.pushNamed(context, '/about'),
        ),
      ],
    );
  }
}

// ─── Calorie Ring Card ────────────────────────────────────────────────────────
class _CalorieRingCard extends StatelessWidget {
  final DailySummary summary;
  const _CalorieRingCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.card, AppColors.cardAlt],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Column(children: [
          const Text('Daily Calories', style: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          CircularPercentIndicator(
            radius: 90,
            lineWidth: 14,
            percent: summary.calorieProgress,
            center: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              ShaderMask(
                shaderCallback: (b) => const LinearGradient(
                  colors: [AppColors.lime, AppColors.primary],
                ).createShader(b),
                child: Text('${summary.totalCalories.round()}',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white)),
              ),
              const Text('kcal', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ]),
            progressColor: AppColors.primary,
            backgroundColor: AppColors.divider,
            circularStrokeCap: CircularStrokeCap.round,
            animation: true,
            animationDuration: 1200,
          ),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _CalStat(label: 'Target', value: '${summary.profile.dailyCalories.round()}', unit: 'kcal'),
            Container(width: 1, height: 36, color: AppColors.divider),
            _CalStat(label: 'Remaining', value: '${summary.remainingCalories.round()}', unit: 'kcal', color: AppColors.lime),
            Container(width: 1, height: 36, color: AppColors.divider),
            _CalStat(label: 'Eaten', value: '${summary.totalCalories.round()}', unit: 'kcal', color: AppColors.primary),
          ]),
        ]),
      ),
    );
  }
}

class _CalStat extends StatelessWidget {
  final String label, value, unit;
  final Color color;
  const _CalStat({required this.label, required this.value, required this.unit, this.color = AppColors.textPrimary});

  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w700)),
    Text(unit,  style: const TextStyle(color: AppColors.textHint, fontSize: 10)),
    Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
  ]);
}

// ─── Protein Streak Banner ────────────────────────────────────────────────────
class _ProteinStreakBanner extends StatelessWidget {
  final int streak;
  final DailySummary summary;
  const _ProteinStreakBanner({required this.streak, required this.summary});

  @override
  Widget build(BuildContext context) {
    final hit = summary.totalProtein >= summary.profile.dailyProtein;
    return FadeInLeft(
      delay: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: hit
                ? [AppColors.primary.withOpacity(0.2), AppColors.lime.withOpacity(0.1)]
                : [AppColors.card, AppColors.card],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: hit ? AppColors.primary.withOpacity(0.4) : AppColors.divider),
        ),
        child: Row(children: [
          Text(hit ? '🔥' : '💪', style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              hit ? 'Protein Goal Crushed!' : 'Protein Goal',
              style: TextStyle(
                color: hit ? AppColors.primary : AppColors.textPrimary,
                fontWeight: FontWeight.w700, fontSize: 15,
              ),
            ),
            Text(
              '${summary.totalProtein.round()}g / ${summary.profile.dailyProtein.round()}g',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('$streak', style: const TextStyle(color: AppColors.lime, fontSize: 24, fontWeight: FontWeight.w800)),
            const Text('day streak', style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
          ]),
        ]),
      ),
    );
  }
}

// ─── Macro Row ────────────────────────────────────────────────────────────────
class _MacroRow extends StatelessWidget {
  final DailySummary summary;
  const _MacroRow({required this.summary});

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      delay: const Duration(milliseconds: 300),
      child: Row(children: [
        Expanded(child: _MacroCard(
          label: 'Protein', value: summary.totalProtein, goal: summary.profile.dailyProtein,
          unit: 'g', color: AppColors.proteinColor, icon: '🥩',
        )),
        const SizedBox(width: 12),
        Expanded(child: _MacroCard(
          label: 'Carbs', value: summary.totalCarbs, goal: summary.profile.dailyCarbs,
          unit: 'g', color: AppColors.carbsColor, icon: '🌾',
        )),
        const SizedBox(width: 12),
        Expanded(child: _MacroCard(
          label: 'Fat', value: summary.totalFat, goal: summary.profile.dailyFat,
          unit: 'g', color: AppColors.fatColor, icon: '🥑',
        )),
      ]),
    );
  }
}

class _MacroCard extends StatelessWidget {
  final String label, unit, icon;
  final double value, goal;
  final Color color;
  const _MacroCard({
    required this.label, required this.value, required this.goal,
    required this.unit, required this.color, required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (value / goal).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 8),
        Text('${value.round()}$unit',
          style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w800)),
        Text('/ ${goal.round()}$unit',
          style: const TextStyle(color: AppColors.textHint, fontSize: 10)),
        const SizedBox(height: 8),
        LinearPercentIndicator(
          percent: pct,
          lineHeight: 6,
          backgroundColor: AppColors.divider,
          progressColor: color,
          barRadius: const Radius.circular(3),
          padding: EdgeInsets.zero,
          animation: true,
          animationDuration: 1000,
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
      ]),
    );
  }
}

// ─── Today's Meals List ───────────────────────────────────────────────────────
class _TodayMealsList extends StatelessWidget {
  final List<MealEntry> meals;
  final AppState state;
  const _TodayMealsList({required this.meals, required this.state});

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      delay: const Duration(milliseconds: 400),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("Today's Meals",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        if (meals.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16)),
            alignment: Alignment.center,
            child: Column(children: [
              const Text('🍽️', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 8),
              const Text('No meals logged yet', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              const Text('Tap + Log Meal to get started', style: TextStyle(color: AppColors.textHint, fontSize: 12)),
            ]),
          )
        else
          ...meals.map((m) => _MealTile(meal: m, onDelete: () => state.deleteMeal(m.id))),
      ]),
    );
  }
}

class _MealTile extends StatelessWidget {
  final MealEntry meal;
  final VoidCallback onDelete;
  const _MealTile({required this.meal, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(_mealEmoji(meal.mealType), style: const TextStyle(fontSize: 20)),
        ),
        title: Text(meal.food.name,
          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        subtitle: Text('${meal.mealType} · ${meal.quantity.round()}${meal.food.unit}',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        trailing: Column(crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('${meal.totalCalories.round()} kcal',
            style: const TextStyle(color: AppColors.calorieColor, fontWeight: FontWeight.w700)),
          Text('P: ${meal.totalProtein.round()}g',
            style: const TextStyle(color: AppColors.proteinColor, fontSize: 11)),
          GestureDetector(onTap: onDelete,
            child: const Icon(Icons.close_rounded, color: AppColors.textHint, size: 16)),
        ]),
      ),
    );
  }

  String _mealEmoji(String type) {
    switch (type) {
      case 'Breakfast': return '🌅';
      case 'Lunch':     return '☀️';
      case 'Dinner':    return '🌙';
      case 'Snack':     return '🍎';
      default:          return '🍽️';
    }
  }
}
