import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:etbp_mobile/config/constants.dart';
import 'package:etbp_mobile/config/theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  final _pages = const [
    _OnboardingPage(icon: Icons.search, title: 'Book Your Trip', subtitle: 'Search routes and book tickets instantly'),
    _OnboardingPage(icon: Icons.event_seat, title: 'Select Your Seat', subtitle: 'Choose your preferred seat with real-time availability'),
    _OnboardingPage(icon: Icons.shield, title: 'Travel With Confidence', subtitle: 'Secure payments, live tracking, and 24/7 support'),
  ];

  void _complete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.firstLaunchKey, false);
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(onPressed: _complete, child: const Text('Skip')),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: _pages,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) => Container(
                width: _page == i ? 24 : 8, height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: _page == i ? AppTheme.primary : AppTheme.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              )),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton(
                onPressed: _page == 2 ? _complete : () => _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
                child: Text(_page == 2 ? 'Get Started' : 'Next'),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _OnboardingPage({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120, height: 120,
            decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, size: 56, color: AppTheme.primary),
          ),
          const SizedBox(height: 40),
          Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          const SizedBox(height: 12),
          Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}
