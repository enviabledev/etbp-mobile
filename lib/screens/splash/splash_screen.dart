import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:etbp_mobile/config/constants.dart';
import 'package:etbp_mobile/config/theme.dart';
import 'package:etbp_mobile/core/auth/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    final hasTokens = await ref.read(tokenStorageProvider).hasTokens();
    if (hasTokens) {
      await ref.read(authStateProvider.notifier).checkAuth();
      final user = ref.read(authStateProvider).value;
      if (user != null && mounted) {
        context.go('/home');
        return;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final firstLaunch = prefs.getBool(AppConstants.firstLaunchKey) ?? true;
    if (mounted) {
      context.go(firstLaunch ? '/onboarding' : '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.directions_bus, size: 64, color: AppTheme.primary),
            const SizedBox(height: 16),
            Text(AppConstants.appName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          ],
        ),
      ),
    );
  }
}
