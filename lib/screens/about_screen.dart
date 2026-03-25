import 'package:flutter/material.dart';
import 'package:flutter/services.dart';          // rootBundle
import 'package:animate_do/animate_do.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../utils/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('About'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Logo
          FadeInDown(
            child: Center(
              child: Column(children: [
                Container(
                  width: 100, height: 100,
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
                        blurRadius: 32, spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.local_fire_department_rounded,
                    color: Colors.black, size: 50,
                  ),
                ),
                const SizedBox(height: 16),
                ShaderMask(
                  shaderCallback: (b) => const LinearGradient(
                    colors: [AppColors.lime, AppColors.primary],
                  ).createShader(b),
                  child: const Text(
                    'NutriForgeX',
                    style: TextStyle(
                      fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
              ]),
            ),
          ),
          const SizedBox(height: 32),

          // Description
          FadeInLeft(
            delay: const Duration(milliseconds: 200),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card, borderRadius: BorderRadius.circular(18),
              ),
              child: const Text(
                'NutriForgeX is your complete macro & calorie command center. '
                    'Log meals, track proteins, monitor daily macros, and let the BMR calculator '
                    'set your perfect nutrition targets — all stored privately on your device.',
                style: TextStyle(
                  color: AppColors.textSecondary, height: 1.7, fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Features
          FadeInLeft(
            delay: const Duration(milliseconds: 300),
            child: _InfoCard(title: '✨ Features', items: const [
              '🔥 BMR / TDEE Calculator',
              '🥩 Per-meal macro tracking',
              '💪 Daily protein streak',
              '📊 Weekly charts & history',
              '🍽️ 30+ preset foods + custom entry',
              '🎯 Personalized calorie & macro goals',
              '📱 100% offline — no account needed',
            ]),
          ),
          const SizedBox(height: 16),

          // Developer info
          FadeInLeft(
            delay: const Duration(milliseconds: 400),
            child: _InfoCard(title: '👨‍💻 Developer', items: const [
              '🏢  A Little Taste of Texas, LLC',
              '📧  hi.androidstudio@gmail.com',
            ]),
          ),
          const SizedBox(height: 16),

          // Privacy Policy button
          FadeInUp(
            delay: const Duration(milliseconds: 500),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
              ),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.15),
                      AppColors.lime.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.privacy_tip_outlined, color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Privacy Policy',
                          style: TextStyle(
                            color: AppColors.textPrimary, fontWeight: FontWeight.w700,
                          )),
                      Text('Read how we handle your data',
                          style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 12,
                          )),
                    ]),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.primary, size: 16,
                  ),
                ]),
              ),
            ),
          ),
          const SizedBox(height: 32),

          FadeInUp(
            delay: const Duration(milliseconds: 600),
            child: const Center(
              child: Text(
                'Made with 💚 by A Little Taste of Texas, LLC',
                style: TextStyle(color: AppColors.textHint, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<String> items;
  const _InfoCard({required this.title, required this.items});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.card, borderRadius: BorderRadius.circular(18),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title,
          style: const TextStyle(
            color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 15,
          )),
      const SizedBox(height: 14),
      ...items.map((item) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Text(item,
            style: const TextStyle(
              color: AppColors.textSecondary, fontSize: 13, height: 1.4,
            )),
      )),
    ]),
  );
}

// ─── Privacy Policy WebView Screen ────────────────────────────────────────────
class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});
  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0A0F0A))
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) => setState(() => _loading = false),
      ));

    // Load HTML from assets instead of an inline Dart string
    rootBundle.loadString('assets/privacy_policy.html').then((html) {
      _controller.loadHtmlString(html);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Privacy Policy'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading) const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}