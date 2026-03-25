import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../utils/app_theme.dart';
import '../utils/app_state.dart';
import '../models/models.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final weekly = state.weeklyData;
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            title: const Text('History'),
            bottom: TabBar(
              controller: _tabCtrl,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textHint,
              tabs: const [
                Tab(text: 'Weekly Charts'),
                Tab(text: 'Meal Log'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabCtrl,
            children: [
              _ChartsTab(weekly: weekly, profile: state.profile),
              _MealLogTab(state: state),
            ],
          ),
        );
      },
    );
  }
}

// ─── Charts Tab ───────────────────────────────────────────────────────────────
class _ChartsTab extends StatelessWidget {
  final List<Map<String, dynamic>> weekly;
  final UserProfile? profile;
  const _ChartsTab({required this.weekly, required this.profile});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        FadeInDown(child: _CalorieChart(weekly: weekly, profile: profile)),
        const SizedBox(height: 20),
        FadeInUp(child: _ProteinChart(weekly: weekly, profile: profile)),
        const SizedBox(height: 20),
        FadeInUp(delay: const Duration(milliseconds: 200),
          child: _WeeklySummaryCards(weekly: weekly, profile: profile)),
      ],
    );
  }
}

class _CalorieChart extends StatelessWidget {
  final List<Map<String, dynamic>> weekly;
  final UserProfile? profile;
  const _CalorieChart({required this.weekly, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(20)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Weekly Calories', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 20),
        SizedBox(
          height: 180,
          child: BarChart(BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: (profile?.dailyCalories ?? 2000) * 1.3,
            barTouchData: BarTouchData(enabled: false),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i < 0 || i >= weekly.length) return const SizedBox();
                  return Text(DateFormat('E').format(weekly[i]['date']),
                    style: const TextStyle(color: AppColors.textHint, fontSize: 10));
                },
              )),
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(
              show: true,
              drawHorizontalLine: true,
              horizontalInterval: (profile?.dailyCalories ?? 2000) / 4,
              getDrawingHorizontalLine: (_) => const FlLine(color: AppColors.divider, strokeWidth: 1),
              drawVerticalLine: false,
            ),
            borderData: FlBorderData(show: false),
            barGroups: weekly.asMap().entries.map((e) {
              final cal = (e.value['calories'] as double);
              final goal = profile?.dailyCalories ?? 2000;
              return BarChartGroupData(x: e.key, barRods: [
                BarChartRodData(
                  toY: cal,
                  width: 22,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter, end: Alignment.topCenter,
                    colors: cal >= goal
                        ? [AppColors.primary, AppColors.lime]
                        : [AppColors.primary.withOpacity(0.4), AppColors.primary.withOpacity(0.7)],
                  ),
                ),
              ]);
            }).toList(),
          )),
        ),
      ]),
    );
  }
}

class _ProteinChart extends StatelessWidget {
  final List<Map<String, dynamic>> weekly;
  final UserProfile? profile;
  const _ProteinChart({required this.weekly, required this.profile});

  @override
  Widget build(BuildContext context) {
    final spots = weekly.asMap().entries.map((e) =>
      FlSpot(e.key.toDouble(), (e.value['protein'] as double))
    ).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(20)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Weekly Protein', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 20),
        SizedBox(
          height: 160,
          child: LineChart(LineChartData(
            gridData: FlGridData(
              drawHorizontalLine: true,
              getDrawingHorizontalLine: (_) => const FlLine(color: AppColors.divider, strokeWidth: 1),
              drawVerticalLine: false,
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i < 0 || i >= weekly.length) return const SizedBox();
                  return Text(DateFormat('E').format(weekly[i]['date']),
                    style: const TextStyle(color: AppColors.textHint, fontSize: 10));
                },
              )),
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            lineBarsData: [
              // Goal line
              if (profile != null) LineChartBarData(
                spots: List.generate(7, (i) => FlSpot(i.toDouble(), profile!.dailyProtein)),
                isCurved: false,
                color: AppColors.lime.withOpacity(0.4),
                barWidth: 1.5,
                dotData: const FlDotData(show: false),
                dashArray: [6, 4],
              ),
              // Actual
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: AppColors.proteinColor,
                barWidth: 3,
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [AppColors.proteinColor.withOpacity(0.3), Colors.transparent],
                  ),
                ),
                dotData: FlDotData(
                  getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                    radius: 4,
                    color: AppColors.lime,
                    strokeWidth: 2,
                    strokeColor: AppColors.background,
                  ),
                ),
              ),
            ],
          )),
        ),
      ]),
    );
  }
}

class _WeeklySummaryCards extends StatelessWidget {
  final List<Map<String, dynamic>> weekly;
  final UserProfile? profile;
  const _WeeklySummaryCards({required this.weekly, required this.profile});

  @override
  Widget build(BuildContext context) {
    final totalCal = weekly.fold<double>(0, (s, d) => s + (d['calories'] as double));
    final totalPro = weekly.fold<double>(0, (s, d) => s + (d['protein'] as double));
    final daysHitPro = weekly.where((d) => (d['protein'] as double) >= (profile?.dailyProtein ?? 150)).length;

    return Row(children: [
      Expanded(child: _SummaryCard(
        label: 'Avg Calories', value: '${(totalCal / 7).round()}',
        sub: 'kcal/day', color: AppColors.calorieColor,
      )),
      const SizedBox(width: 12),
      Expanded(child: _SummaryCard(
        label: 'Avg Protein', value: '${(totalPro / 7).round()}',
        sub: 'g/day', color: AppColors.proteinColor,
      )),
      const SizedBox(width: 12),
      Expanded(child: _SummaryCard(
        label: 'Protein Goals', value: '$daysHitPro/7',
        sub: 'days hit', color: AppColors.lime,
      )),
    ]);
  }
}

class _SummaryCard extends StatelessWidget {
  final String label, value, sub;
  final Color color;
  const _SummaryCard({required this.label, required this.value, required this.sub, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14)),
    child: Column(children: [
      Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w800)),
      Text(sub, style: const TextStyle(color: AppColors.textHint, fontSize: 10)),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11), textAlign: TextAlign.center),
    ]),
  );
}

// ─── Meal Log Tab ─────────────────────────────────────────────────────────────
class _MealLogTab extends StatelessWidget {
  final AppState state;
  const _MealLogTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final days = List.generate(7, (i) => DateTime.now().subtract(Duration(days: i)));
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: days.length,
      itemBuilder: (context, i) {
        final day = days[i];
        final meals = state.mealsForDate(day);
        if (meals.isEmpty && i > 0) return const SizedBox();
        final totalCal = meals.fold<double>(0, (s, m) => s + m.totalCalories);
        return FadeInLeft(
          delay: Duration(milliseconds: i * 80),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(children: [
                Text(
                  i == 0 ? 'Today' : i == 1 ? 'Yesterday' : DateFormat('EEEE, MMM d').format(day),
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 15),
                ),
                const Spacer(),
                if (meals.isNotEmpty) Text('${totalCal.round()} kcal',
                  style: const TextStyle(color: AppColors.calorieColor, fontWeight: FontWeight.w600)),
              ]),
            ),
            if (meals.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text('No meals logged', style: TextStyle(color: AppColors.textHint, fontSize: 13)),
              )
            else ...meals.map((m) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                Text(_emoji(m.mealType), style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(m.food.name, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
                  Text('${m.mealType} · ${m.quantity.round()}${m.food.unit}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('${m.totalCalories.round()} kcal',
                    style: const TextStyle(color: AppColors.calorieColor, fontWeight: FontWeight.w600, fontSize: 13)),
                  Text('P:${m.totalProtein.round()}g',
                    style: const TextStyle(color: AppColors.proteinColor, fontSize: 10)),
                ]),
              ]),
            )),
            const Divider(color: AppColors.divider),
          ]),
        );
      },
    );
  }

  String _emoji(String t) {
    switch (t) {
      case 'Breakfast': return '🌅';
      case 'Lunch':     return '☀️';
      case 'Dinner':    return '🌙';
      default:          return '🍎';
    }
  }
}
