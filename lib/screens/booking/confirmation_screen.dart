import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:etbp_mobile/config/theme.dart';

class ConfirmationScreen extends StatelessWidget {
  final String ref;
  const ConfirmationScreen({super.key, required this.ref});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 80, height: 80, decoration: BoxDecoration(color: AppTheme.success.withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(Icons.check_circle, size: 48, color: AppTheme.success)),
              const SizedBox(height: 24),
              const Text('Booking Confirmed!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Your trip has been booked successfully.', style: TextStyle(color: AppTheme.textSecondary)),
              const SizedBox(height: 24),
              Container(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                child: Text(ref, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2)),
              ),
              const SizedBox(height: 32),
              ElevatedButton(onPressed: () => context.go('/my-trips'), child: const Text('View My Trips')),
              const SizedBox(height: 12),
              OutlinedButton(onPressed: () => context.go('/home'), child: const Text('Book Another Trip')),
            ]),
          ),
        ),
      ),
    );
  }
}
