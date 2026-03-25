import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../utils/app_state.dart';
import '../models/models.dart';
import 'about_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final p = state.profile;
        if (p == null) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            title: const Text('Profile'),
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline_rounded, color: AppColors.primary),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen())),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Avatar + name
              FadeInDown(
                child: Center(
                  child: Column(children: [
                    Container(
                      width: 90, height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [AppColors.lime, AppColors.primary],
                        ),
                        boxShadow: [
                          BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 24, spreadRadius: 4),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                        style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(p.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    Text(_goalLabel(p.goal), style: const TextStyle(color: AppColors.primary)),
                  ]),
                ),
              ),
              const SizedBox(height: 28),

              // Body metrics
              FadeInLeft(delay: const Duration(milliseconds: 200),
                child: _SectionCard(title: 'Body Metrics', children: [
                  _InfoRow('Weight', '${p.weightKg} kg'),
                  _InfoRow('Height', '${p.heightCm} cm'),
                  _InfoRow('Age',    '${p.age} years'),
                  _InfoRow('Gender', p.gender == 'male' ? '♂ Male' : '♀ Female'),
                  _InfoRow('Activity', _activityLabel(p.activityLevel)),
                ])),
              const SizedBox(height: 16),

              // Daily targets
              FadeInLeft(delay: const Duration(milliseconds: 300),
                child: _SectionCard(title: 'Daily Targets', children: [
                  _InfoRow('Calories', '${p.dailyCalories.round()} kcal', AppColors.calorieColor),
                  _InfoRow('Protein',  '${p.dailyProtein.round()} g',     AppColors.proteinColor),
                  _InfoRow('Carbs',    '${p.dailyCarbs.round()} g',       AppColors.carbsColor),
                  _InfoRow('Fat',      '${p.dailyFat.round()} g',         AppColors.fatColor),
                ])),
              const SizedBox(height: 16),

              // Actions
              FadeInUp(delay: const Duration(milliseconds: 400),
                child: _SectionCard(title: 'Actions', children: [
                  _ActionTile(
                    icon: Icons.calculate_outlined, label: 'Recalculate BMR & Targets',
                    color: AppColors.primary,
                    onTap: () => _showRecalcDialog(context, state, p),
                  ),
                  _ActionTile(
                    icon: Icons.info_outline_rounded, label: 'About NutriForgeX',
                    color: AppColors.textSecondary,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen())),
                  ),
                ])),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  void _showRecalcDialog(BuildContext context, AppState state, UserProfile p) {
    final result = AppState.calculateBMR(
      weightKg: p.weightKg, heightCm: p.heightCm, age: p.age,
      gender: p.gender, activityLevel: p.activityLevel, goal: p.goal,
    );
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Updated Targets', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          _DialogRow('BMR',      '${result['bmr']!.round()} kcal',      AppColors.textSecondary),
          _DialogRow('TDEE',     '${result['tdee']!.round()} kcal',     AppColors.textSecondary),
          _DialogRow('Calories', '${result['calories']!.round()} kcal', AppColors.calorieColor),
          _DialogRow('Protein',  '${result['protein']!.round()} g',     AppColors.proteinColor),
          _DialogRow('Carbs',    '${result['carbs']!.round()} g',       AppColors.carbsColor),
          _DialogRow('Fat',      '${result['fat']!.round()} g',         AppColors.fatColor),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final updated = UserProfile(
                name: p.name, weightKg: p.weightKg, heightCm: p.heightCm,
                age: p.age, gender: p.gender, activityLevel: p.activityLevel, goal: p.goal,
                dailyCalories: result['calories']!,
                dailyProtein:  result['protein']!,
                dailyCarbs:    result['carbs']!,
                dailyFat:      result['fat']!,
              );
              await state.saveProfile(updated);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  String _goalLabel(String g) {
    switch (g) {
      case 'lose':    return '🔥 Lose Weight';
      case 'gain':    return '💪 Gain Muscle';
      default:        return '⚖️ Maintain Weight';
    }
  }

  String _activityLabel(String a) {
    const m = {
      'sedentary': '🪑 Sedentary', 'light': '🚶 Light',
      'moderate': '🏃 Moderate',   'active': '💪 Active',
      'very_active': '🔥 Very Active',
    };
    return m[a] ?? a;
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(18)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.w700)),
      const SizedBox(height: 16),
      ...children,
    ]),
  );
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  final Color color;
  const _InfoRow(this.label, this.value, [this.color = AppColors.textPrimary]);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: [
      Text(label, style: const TextStyle(color: AppColors.textSecondary)),
      const Spacer(),
      Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
    ]),
  );
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionTile({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Container(
      width: 40, height: 40,
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, color: color, size: 20),
    ),
    title: Text(label, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
    trailing: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textHint, size: 14),
    onTap: onTap,
  );
}

class _DialogRow extends StatelessWidget {
  final String label, value;
  final Color color;
  const _DialogRow(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: [
      Text(label, style: const TextStyle(color: AppColors.textSecondary)),
      const Spacer(),
      Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
    ]),
  );
}
