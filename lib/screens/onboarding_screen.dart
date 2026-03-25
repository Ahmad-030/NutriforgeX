import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../utils/app_state.dart';
import '../models/models.dart';
import 'main_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Form values
  final _nameCtrl   = TextEditingController();
  double _weight    = 70;
  double _height    = 170;
  int    _age       = 25;
  String _gender    = 'male';
  String _activity  = 'moderate';
  String _goal      = 'maintain';

  Map<String, double>? _bmrResult;

  void _nextPage() {
    if (_currentPage == 0 && _nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _calculate();
    }
  }

  void _calculate() {
    final result = AppState.calculateBMR(
      weightKg: _weight,
      heightCm: _height,
      age: _age,
      gender: _gender,
      activityLevel: _activity,
      goal: _goal,
    );
    setState(() { _bmrResult = result; });
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _finish() async {
    if (_bmrResult == null) return;
    final profile = UserProfile(
      name: _nameCtrl.text.trim(),
      weightKg: _weight,
      heightCm: _height,
      age: _age,
      gender: _gender,
      activityLevel: _activity,
      goal: _goal,
      dailyCalories: _bmrResult!['calories']!,
      dailyProtein:  _bmrResult!['protein']!,
      dailyCarbs:    _bmrResult!['carbs']!,
      dailyFat:      _bmrResult!['fat']!,
    );
    await context.read<AppState>().saveProfile(profile);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // FIX: resizeToAvoidBottomInset keeps layout stable when keyboard appears
      resizeToAvoidBottomInset: true,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (p) => setState(() => _currentPage = p),
        children: [
          _WelcomePage(nameCtrl: _nameCtrl, onNext: _nextPage),
          _BodyPage(
            weight: _weight, height: _height, age: _age,
            onWeight: (v) => setState(() => _weight = v),
            onHeight: (v) => setState(() => _height = v),
            onAge:    (v) => setState(() => _age = v),
            onNext: _nextPage,
          ),
          _GenderActivityPage(
            gender: _gender, activity: _activity,
            onGender:   (v) => setState(() => _gender = v),
            onActivity: (v) => setState(() => _activity = v),
            onNext: _nextPage,
          ),
          _GoalPage(goal: _goal, onGoal: (v) => setState(() => _goal = v), onNext: _nextPage),
          _ResultPage(result: _bmrResult, onFinish: _finish),
        ],
      ),
    );
  }
}

// ─── Page 1: Welcome ──────────────────────────────────────────────────────────
class _WelcomePage extends StatelessWidget {
  final TextEditingController nameCtrl;
  final VoidCallback onNext;
  const _WelcomePage({required this.nameCtrl, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        // FIX: was `scrollDirection: crollDirection.` — typo + invalid reference
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.all(28),
        child: ConstrainedBox(
          // FIX: gives the Column a finite min-height so Spacer works,
          // but the whole thing scrolls instead of overflowing when
          // the keyboard appears and shrinks available space.
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height
                - MediaQuery.of(context).padding.top
                - MediaQuery.of(context).padding.bottom,
          ),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                FadeInDown(child: const Text('👋', style: TextStyle(fontSize: 56))),
                const SizedBox(height: 20),
                FadeInDown(
                  delay: const Duration(milliseconds: 200),
                  child: ShaderMask(
                    shaderCallback: (b) => const LinearGradient(
                      colors: [AppColors.lime, AppColors.primary],
                    ).createShader(b),
                    child: const Text(
                      'Welcome to\nNutriForgeX',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FadeInLeft(
                  delay: const Duration(milliseconds: 300),
                  child: const Text(
                    'Track macros, hit protein goals, and forge the best version of yourself.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),
                ),
                // Spacer works correctly inside IntrinsicHeight + ConstrainedBox
                const Spacer(),
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: TextField(
                    controller: nameCtrl,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      labelText: "What's your name?",
                      prefixIcon: Icon(Icons.person_outline, color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FadeInUp(
                  delay: const Duration(milliseconds: 500),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onNext,
                      child: const Text("Let's Get Started →"),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Page 2: Body Metrics ─────────────────────────────────────────────────────
class _BodyPage extends StatelessWidget {
  final double weight, height;
  final int age;
  final Function(double) onWeight, onHeight;
  final Function(int) onAge;
  final VoidCallback onNext;

  const _BodyPage({
    required this.weight, required this.height, required this.age,
    required this.onWeight, required this.onHeight, required this.onAge,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _stepIndicator(2),
            const SizedBox(height: 32),
            FadeInDown(
              child: const Text(
                'Your Body Metrics',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Used to calculate your BMR & daily targets',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 40),
            _SliderCard(
              label: 'Weight', value: weight, min: 30, max: 200,
              unit: 'kg', onChanged: (v) => onWeight(v),
            ),
            const SizedBox(height: 20),
            _SliderCard(
              label: 'Height', value: height, min: 100, max: 250,
              unit: 'cm', onChanged: (v) => onHeight(v),
            ),
            const SizedBox(height: 20),
            _SliderCard(
              label: 'Age', value: age.toDouble(), min: 10, max: 90,
              unit: 'yrs', onChanged: (v) => onAge(v.round()), decimals: 0,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onNext,
                child: const Text('Continue →'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ─── Page 3: Gender & Activity ────────────────────────────────────────────────
class _GenderActivityPage extends StatelessWidget {
  final String gender, activity;
  final Function(String) onGender, onActivity;
  final VoidCallback onNext;

  const _GenderActivityPage({
    required this.gender, required this.activity,
    required this.onGender, required this.onActivity, required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _stepIndicator(3),
            const SizedBox(height: 32),
            const Text(
              'Gender & Activity',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'GENDER',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Row(children: [
              _SelectChip(
                label: '♂ Male',   value: 'male',
                selected: gender == 'male',   onTap: onGender,
              ),
              const SizedBox(width: 12),
              _SelectChip(
                label: '♀ Female', value: 'female',
                selected: gender == 'female', onTap: onGender,
              ),
            ]),
            const SizedBox(height: 32),
            const Text(
              'ACTIVITY LEVEL',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            // Flexible + SingleChildScrollView prevents overflow on small screens
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: {
                    'sedentary':   ('🪑 Sedentary',  'Little or no exercise'),
                    'light':       ('🚶 Light',       '1-3 days/week'),
                    'moderate':    ('🏃 Moderate',    '3-5 days/week'),
                    'active':      ('💪 Active',      '6-7 days/week'),
                    'very_active': ('🔥 Very Active', 'Hard daily training'),
                  }.entries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GestureDetector(
                      onTap: () => onActivity(e.key),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: activity == e.key
                              ? AppColors.primary.withOpacity(0.15)
                              : AppColors.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: activity == e.key
                                ? AppColors.primary
                                : AppColors.divider,
                            width: activity == e.key ? 2 : 1,
                          ),
                        ),
                        child: Row(children: [
                          Text(
                            e.value.$1,
                            style: TextStyle(
                              color: activity == e.key
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            e.value.$2,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ]),
                      ),
                    ),
                  )).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onNext,
                child: const Text('Continue →'),
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}

// ─── Page 4: Goal ─────────────────────────────────────────────────────────────
class _GoalPage extends StatelessWidget {
  final String goal;
  final Function(String) onGoal;
  final VoidCallback onNext;

  const _GoalPage({
    required this.goal, required this.onGoal, required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _stepIndicator(4),
            const SizedBox(height: 32),
            const Text(
              "What's Your Goal?",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "We'll set your calorie & macro targets accordingly",
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 40),
            _GoalCard(
              emoji: '🔥', title: 'Lose Weight',
              subtitle: '500 cal deficit · High protein',
              value: 'lose', selected: goal == 'lose', onTap: onGoal,
            ),
            const SizedBox(height: 16),
            _GoalCard(
              emoji: '⚖️', title: 'Maintain Weight',
              subtitle: 'TDEE calories · Balanced macros',
              value: 'maintain', selected: goal == 'maintain', onTap: onGoal,
            ),
            const SizedBox(height: 16),
            _GoalCard(
              emoji: '💪', title: 'Gain Muscle',
              subtitle: '300 cal surplus · High protein',
              value: 'gain', selected: goal == 'gain', onTap: onGoal,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onNext,
                child: const Text('Calculate My Targets →'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ─── Page 5: Result ───────────────────────────────────────────────────────────
class _ResultPage extends StatelessWidget {
  final Map<String, double>? result;
  final VoidCallback onFinish;
  const _ResultPage({required this.result, required this.onFinish});

  @override
  Widget build(BuildContext context) {
    if (result == null) return const SizedBox();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            const SizedBox(height: 20),
            FadeInDown(
              child: const Text('🎯', style: TextStyle(fontSize: 56)),
            ),
            const SizedBox(height: 16),
            FadeInDown(
              delay: const Duration(milliseconds: 200),
              child: ShaderMask(
                shaderCallback: (b) => const LinearGradient(
                  colors: [AppColors.lime, AppColors.primary],
                ).createShader(b),
                child: const Text(
                  'Your Daily Targets',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: Text(
                'BMR: ${result!['bmr']!.round()} kcal/day baseline',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 32),
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: _ResultGrid(result: result!),
            ),
            const Spacer(),
            FadeInUp(
              delay: const Duration(milliseconds: 600),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onFinish,
                  child: const Text('Start Tracking! 🚀'),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _ResultGrid extends StatelessWidget {
  final Map<String, double> result;
  const _ResultGrid({required this.result});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _MacroCell(
          label: 'Calories', value: '${result['calories']!.round()}',
          unit: 'kcal', color: AppColors.calorieColor,
        ),
        _MacroCell(
          label: 'Protein', value: '${result['protein']!.round()}',
          unit: 'g', color: AppColors.proteinColor,
        ),
        _MacroCell(
          label: 'Carbs', value: '${result['carbs']!.round()}',
          unit: 'g', color: AppColors.carbsColor,
        ),
        _MacroCell(
          label: 'Fat', value: '${result['fat']!.round()}',
          unit: 'g', color: AppColors.fatColor,
        ),
      ],
    );
  }
}

class _MacroCell extends StatelessWidget {
  final String label, value, unit;
  final Color color;
  const _MacroCell({
    required this.label, required this.value,
    required this.unit,  required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 28, fontWeight: FontWeight.w800, color: color,
            ),
          ),
          Text(unit, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary, fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────
class _SliderCard extends StatelessWidget {
  final String label, unit;
  final double value, min, max;
  final Function(double) onChanged;
  final int decimals;

  const _SliderCard({
    required this.label, required this.value, required this.min,
    required this.max,   required this.unit,  required this.onChanged,
    this.decimals = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary, fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            decimals == 0
                ? '${value.round()} $unit'
                : '${value.toStringAsFixed(1)} $unit',
            style: const TextStyle(
              color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.w700,
            ),
          ),
        ]),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor:   AppColors.primary,
            inactiveTrackColor: AppColors.divider,
            thumbColor:         AppColors.lime,
            overlayColor:       AppColors.primary.withOpacity(0.2),
          ),
          child: Slider(value: value, min: min, max: max, onChanged: onChanged),
        ),
      ]),
    );
  }
}

class _SelectChip extends StatelessWidget {
  final String label, value;
  final bool selected;
  final Function(String) onTap;
  const _SelectChip({
    required this.label, required this.value,
    required this.selected, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary.withOpacity(0.15) : AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.divider,
              width: selected ? 2 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.primary : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final String emoji, title, subtitle, value;
  final bool selected;
  final Function(String) onTap;

  const _GoalCard({
    required this.emoji,     required this.title,
    required this.subtitle,  required this.value,
    required this.selected,  required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.12) : AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                title,
                style: TextStyle(
                  color: selected ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ]),
          ),
          if (selected) const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Icon(Icons.check_circle, color: AppColors.primary),
          ),
        ]),
      ),
    );
  }
}

Widget _stepIndicator(int step) {
  return Row(
    children: List.generate(5, (i) => Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        height: 4,
        decoration: BoxDecoration(
          color: i < step ? AppColors.primary : AppColors.divider,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    )),
  );
}