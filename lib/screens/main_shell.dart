import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../utils/app_theme.dart';
import 'dashboard_screen.dart';
import 'log_meal_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'about_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    LogMealScreen(),
    HistoryScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: _BottomNav(index: _index, onTap: (i) => setState(() => _index = i)),
      floatingActionButton: _index == 0
          ? FadeInUp(
              child: FloatingActionButton.extended(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Log Meal', style: TextStyle(fontWeight: FontWeight.w700)),
                onPressed: () => setState(() => _index = 1),
              ),
            )
          : null,
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int index;
  final Function(int) onTap;
  const _BottomNav({required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.home_rounded,       Icons.home_outlined,       'Home'),
      (Icons.add_circle_rounded, Icons.add_circle_outline,  'Log'),
      (Icons.bar_chart_rounded,  Icons.bar_chart_outlined,  'History'),
      (Icons.person_rounded,     Icons.person_outline,      'Profile'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final selected = i == index;
              return GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary.withOpacity(0.12) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(selected ? items[i].$1 : items[i].$2,
                      color: selected ? AppColors.primary : AppColors.textHint,
                      size: 24,
                    ),
                    const SizedBox(height: 2),
                    Text(items[i].$3,
                      style: TextStyle(
                        color: selected ? AppColors.primary : AppColors.textHint,
                        fontSize: 11,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                  ]),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
