import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../utils/app_state.dart';
import 'onboarding_screen.dart';
import 'main_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2800));
    if (!mounted) return;
    final state = context.read<AppState>();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            state.onboarded ? const MainShell() : const OnboardingScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background glow
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, __) => Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: _pulseAnim.value * 1.2,
                    colors: [
                      AppColors.primary.withOpacity(0.08),
                      AppColors.background,
                    ],
                  ),
                ),
              ),
            ),
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                FadeInDown(
                  duration: const Duration(milliseconds: 800),
                  child: AnimatedBuilder(
                    animation: _pulseAnim,
                    builder: (_, child) => Transform.scale(
                      scale: _pulseAnim.value,
                      child: child,
                    ),
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.lime, AppColors.primary],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.5),
                            blurRadius: 40,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.local_fire_department_rounded,
                        color: Colors.black,
                        size: 56,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // App name
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [AppColors.lime, AppColors.primary],
                    ).createShader(bounds),
                    child: const Text(
                      'NutriForgeX',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                FadeInUp(
                  delay: const Duration(milliseconds: 600),
                  child: const Text(
                    'Your Macro & Calorie Command Center',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 60),

                // Loading dots
                FadeIn(
                  delay: const Duration(milliseconds: 1000),
                  child: _LoadingDots(),
                ),
              ],
            ),
          ),

          // Bottom credit
          Positioned(
            bottom: 32,
            left: 0, right: 0,
            child: FadeIn(
              delay: const Duration(milliseconds: 1200),
              child: const Text(
                'A Little Taste of Texas, LLC',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textHint,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingDots extends StatefulWidget {
  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with TickerProviderStateMixin {
  final List<AnimationController> _controllers = [];
  final List<Animation<double>> _anims = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 3; i++) {
      final c = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );
      final a = Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(parent: c, curve: Curves.easeInOut),
      );
      _controllers.add(c);
      _anims.add(a);
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) c.repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) => AnimatedBuilder(
        animation: _anims[i],
        builder: (_, __) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 10, height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withOpacity(_anims[i].value),
          ),
        ),
      )),
    );
  }
}
