import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:etbp_mobile/config/theme.dart';
import 'package:etbp_mobile/core/auth/auth_provider.dart';
import 'package:etbp_mobile/core/utils/validators.dart';
import 'package:etbp_mobile/widgets/common/phone_input.dart';
import 'package:etbp_mobile/widgets/common/otp_verification_sheet.dart';
import 'package:etbp_mobile/providers/booking_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameC = TextEditingController();
  final _lastNameC = TextEditingController();
  final _emailC = TextEditingController();
  final _passwordC = TextEditingController();
  String _phone = '';
  bool _obscure = true;
  String? _error;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _error = null);

    // If phone provided, verify via OTP first
    if (_phone.isNotEmpty) {
      final verified = await showOTPVerification(context, ref, _phone);
      if (!verified) return;
    }

    await ref.read(authStateProvider.notifier).register(
      firstName: _firstNameC.text.trim(),
      lastName: _lastNameC.text.trim(),
      email: _emailC.text.trim(),
      password: _passwordC.text,
      phone: _phone.isEmpty ? null : _phone,
    );

    final state = ref.read(authStateProvider);
    if (state.hasError) {
      setState(() => _error = state.error.toString());
    } else if (state.hasValue && state.value != null && mounted) {
      final hasBooking = ref.read(bookingProvider).trip != null;
      context.go(hasBooking ? '/booking/passengers' : '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authStateProvider).isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                const Text('Create account', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Start booking trips with Enviable Transport', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textSecondary)),
                const SizedBox(height: 24),
                if (_error != null) Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: AppTheme.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(_error!, style: const TextStyle(color: AppTheme.error, fontSize: 13)),
                ),
                Row(children: [
                  Expanded(child: TextFormField(controller: _firstNameC, decoration: const InputDecoration(labelText: 'First name'), validator: (v) => validateRequired(v, 'First name'))),
                  const SizedBox(width: 12),
                  Expanded(child: TextFormField(controller: _lastNameC, decoration: const InputDecoration(labelText: 'Last name'), validator: (v) => validateRequired(v, 'Last name'))),
                ]),
                const SizedBox(height: 16),
                TextFormField(controller: _emailC, decoration: const InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress, validator: validateEmail),
                const SizedBox(height: 16),
                PhoneInput(label: 'Phone (optional)', onChanged: (v) => _phone = v),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordC,
                  decoration: InputDecoration(labelText: 'Password', suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscure = !_obscure))),
                  obscureText: _obscure,
                  validator: validatePassword,
                ),
                const SizedBox(height: 24),
                ElevatedButton(onPressed: isLoading ? null : _register, child: isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(_phone.isNotEmpty ? 'Verify & Register' : 'Create Account')),
                const SizedBox(height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('Already have an account? '),
                  GestureDetector(onTap: () => context.go('/login'), child: const Text('Sign in', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600))),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
