import 'package:flutter/material.dart';
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
                      BoxShadow(color: AppColors.primary.withOpacity(0.5), blurRadius: 32, spreadRadius: 4),
                    ],
                  ),
                  child: const Icon(Icons.local_fire_department_rounded, color: Colors.black, size: 50),
                ),
                const SizedBox(height: 16),
                ShaderMask(
                  shaderCallback: (b) => const LinearGradient(
                    colors: [AppColors.lime, AppColors.primary],
                  ).createShader(b),
                  child: const Text('NutriForgeX',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
                ),
                const SizedBox(height: 4),
                const Text('Version 1.0.0',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ]),
            ),
          ),
          const SizedBox(height: 32),

          // Description
          FadeInLeft(delay: const Duration(milliseconds: 200),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(18)),
              child: const Text(
                'NutriForgeX is your complete macro & calorie command center. '
                'Log meals, track proteins, monitor daily macros, and let the BMR calculator '
                'set your perfect nutrition targets — all stored privately on your device.',
                style: TextStyle(color: AppColors.textSecondary, height: 1.7, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Features
          FadeInLeft(delay: const Duration(milliseconds: 300),
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
          FadeInLeft(delay: const Duration(milliseconds: 400),
            child: _InfoCard(title: '👨‍💻 Developer', items: const [
              '🏢  A Little Taste of Texas, LLC',
              '📧  hi.androidstudio@gmail.com',
            ]),
          ),
          const SizedBox(height: 16),

          // Privacy Policy button
          FadeInUp(delay: const Duration(milliseconds: 500),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
              ),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary.withOpacity(0.15), AppColors.lime.withOpacity(0.05)],
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
                    child: const Icon(Icons.privacy_tip_outlined, color: AppColors.primary),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Privacy Policy', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
                    Text('Read how we handle your data', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ])),
                  const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.primary, size: 16),
                ]),
              ),
            ),
          ),
          const SizedBox(height: 32),

          FadeInUp(delay: const Duration(milliseconds: 600),
            child: const Center(
              child: Text('Made with 💚 by A Little Taste of Texas, LLC',
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
    decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(18)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 15)),
      const SizedBox(height: 14),
      ...items.map((item) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Text(item, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4)),
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

  static const String _privacyHtml = '''
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Privacy Policy</title>
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body {
    background-color: #0A0F0A;
    color: #F0FFF0;
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    font-size: 15px;
    line-height: 1.7;
    padding: 24px 20px 60px;
  }
  .logo {
    text-align: center;
    margin-bottom: 32px;
  }
  .logo-icon {
    width: 70px; height: 70px;
    background: linear-gradient(135deg, #B8FF57, #6FCF3A);
    border-radius: 50%;
    display: flex; align-items: center; justify-content: center;
    margin: 0 auto 12px;
    font-size: 32px;
  }
  .app-name {
    font-size: 24px;
    font-weight: 800;
    background: linear-gradient(135deg, #B8FF57, #6FCF3A);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
  }
  .subtitle { color: #8FAF8F; font-size: 13px; margin-top: 4px; }
  h1 {
    font-size: 22px; font-weight: 800; color: #F0FFF0;
    margin-bottom: 6px; margin-top: 32px;
  }
  .last-updated { color: #4A6A4A; font-size: 12px; margin-bottom: 28px; }
  h2 {
    font-size: 16px; font-weight: 700;
    color: #6FCF3A;
    margin: 28px 0 10px;
    padding-left: 12px;
    border-left: 3px solid #6FCF3A;
  }
  p { color: #8FAF8F; margin-bottom: 12px; }
  ul { color: #8FAF8F; padding-left: 20px; margin-bottom: 12px; }
  li { margin-bottom: 6px; }
  .highlight {
    background: rgba(111, 207, 58, 0.08);
    border: 1px solid rgba(111, 207, 58, 0.2);
    border-radius: 12px;
    padding: 16px 18px;
    margin: 16px 0;
  }
  .highlight p { color: #B8FF57; margin: 0; font-weight: 600; }
  a { color: #6FCF3A; }
  .footer {
    text-align: center;
    color: #4A6A4A;
    font-size: 12px;
    margin-top: 40px;
    padding-top: 20px;
    border-top: 1px solid #1F2F1F;
  }
</style>
</head>
<body>

<div class="logo">
  <div class="logo-icon">🔥</div>
  <div class="app-name">NutriForgeX</div>
  <div class="subtitle">Privacy Policy</div>
</div>

<h1>Privacy Policy</h1>
<div class="last-updated">Last updated: January 1, 2025</div>

<div class="highlight">
  <p>🛡️ NutriForgeX is 100% offline. All your data stays on your device. We never collect, transmit, or share your personal information.</p>
</div>

<h2>1. Information We Collect</h2>
<p>NutriForgeX does <strong>not</strong> collect any personal information from you. The app operates entirely offline. All data you enter — including your name, body metrics, meal logs, and nutrition targets — is stored exclusively on your device using local storage.</p>

<h2>2. How Your Data Is Used</h2>
<p>All data entered into NutriForgeX is used solely to:</p>
<ul>
  <li>Calculate your BMR (Basal Metabolic Rate) and TDEE (Total Daily Energy Expenditure)</li>
  <li>Set personalized daily calorie and macro targets</li>
  <li>Display your meal history and nutrition progress</li>
  <li>Track your daily protein streak</li>
</ul>
<p>This data never leaves your device. We have no access to it.</p>

<h2>3. Data Storage</h2>
<p>NutriForgeX uses your device's local storage (SharedPreferences) to save:</p>
<ul>
  <li>Your profile information (name, weight, height, age, gender)</li>
  <li>Your activity level and nutrition goal</li>
  <li>Your daily calorie and macro targets</li>
  <li>Your meal log entries</li>
  <li>Your protein streak count</li>
</ul>
<p>All of this data is stored locally on your device and can be cleared at any time by uninstalling the app.</p>

<h2>4. Internet Access</h2>
<p>NutriForgeX does <strong>not</strong> require an internet connection to function. The app does not make any network requests, does not contact any servers, and does not sync data anywhere. The only exception is viewing this Privacy Policy, which is rendered locally within the app.</p>

<h2>5. Third-Party Services</h2>
<p>NutriForgeX does <strong>not</strong> integrate with any third-party analytics, advertising, or tracking services. There are no ads in this app. We do not sell or share your data with any third parties.</p>

<h2>6. Children's Privacy</h2>
<p>NutriForgeX is not directed at children under the age of 13. We do not knowingly collect personal information from children under 13. The app is intended for use by adults for personal health and nutrition tracking purposes.</p>

<h2>7. Security</h2>
<p>Since all data is stored locally on your device and never transmitted over the internet, it is protected by your device's built-in security measures. We recommend keeping your device secured with a password or biometric lock.</p>

<h2>8. Your Rights</h2>
<p>Since we do not collect your data, there is nothing for us to provide, delete, or transfer. You have full control over your data at all times. You can delete all app data by clearing the app's storage in your device settings or uninstalling the app.</p>

<h2>9. Changes to This Policy</h2>
<p>We may update this Privacy Policy from time to time. Changes will be reflected within the app. Your continued use of NutriForgeX after any changes constitutes your acceptance of the updated policy.</p>

<h2>10. Contact Us</h2>
<p>If you have any questions about this Privacy Policy, please contact us:</p>
<ul>
  <li><strong>Developer:</strong> A Little Taste of Texas, LLC</li>
  <li><strong>Email:</strong> <a href="mailto:hi.androidstudio@gmail.com">hi.androidstudio@gmail.com</a></li>
</ul>

<div class="footer">
  <p>© 2025 A Little Taste of Texas, LLC</p>
  <p>NutriForgeX · All rights reserved</p>
</div>

</body>
</html>
''';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0A0F0A))
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) => setState(() => _loading = false),
      ))
      ..loadHtmlString(_privacyHtml);
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
