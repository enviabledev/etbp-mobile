import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:etbp_mobile/config/theme.dart';
import 'package:etbp_mobile/core/auth/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppTheme.primary,
              child: Text(user?.initials ?? '',
                  style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            Text(user?.fullName ?? 'User',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(user?.email ?? '',
                style: const TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 32),
            _tile(Icons.person, 'Edit Profile', () {}),
            _tile(Icons.support, 'Help & Support',
                () => context.push('/support')),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await ref.read(authStateProvider.notifier).logout();
                  if (context.mounted) context.go('/login');
                },
                icon: const Icon(Icons.logout, color: AppTheme.error),
                label: const Text('Logout',
                    style: TextStyle(color: AppTheme.error)),
                style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.error)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(IconData icon, String label, VoidCallback onTap) => ListTile(
        leading: Icon(icon, color: AppTheme.textSecondary),
        title: Text(label),
        trailing:
            const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
        onTap: onTap,
      );
}
