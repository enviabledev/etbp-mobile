import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:etbp_mobile/config/theme.dart';
import 'package:etbp_mobile/core/auth/auth_provider.dart';
import 'package:etbp_mobile/widgets/common/phone_input.dart';
import 'package:etbp_mobile/widgets/common/otp_verification_sheet.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstC = TextEditingController();
  final _lastC = TextEditingController();
  final _phoneC = TextEditingController();
  final _dobC = TextEditingController();
  final _emergNameC = TextEditingController();
  final _emergPhoneC = TextEditingController();
  String _gender = '';
  bool _saving = false;
  bool _initialized = false;

  void _initForm() {
    if (_initialized) return;
    final user = ref.read(authStateProvider).value;
    if (user == null) return;
    _firstC.text = user.firstName ?? '';
    _lastC.text = user.lastName ?? '';
    _phoneC.text = user.phone ?? '';
    _dobC.text = user.dateOfBirth ?? '';
    _gender = user.gender ?? '';
    _emergNameC.text = user.emergencyContactName ?? '';
    _emergPhoneC.text = user.emergencyContactPhone ?? '';
    _initialized = true;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // If phone changed, require OTP verification
    final user = ref.read(authStateProvider).value;
    final newPhone = _phoneC.text.trim();
    if (newPhone.isNotEmpty && newPhone != (user?.phone ?? '')) {
      final verified = await showOTPVerification(context, ref, newPhone);
      if (!verified) return;
    }

    setState(() => _saving = true);
    try {
      final authService = ref.read(authServiceProvider);
      await authService.updateProfile({
        'first_name': _firstC.text.trim(),
        'last_name': _lastC.text.trim(),
        'phone': newPhone,
        'date_of_birth': _dobC.text.trim().isEmpty ? null : _dobC.text.trim(),
        'gender': _gender.isEmpty ? null : _gender,
        'emergency_contact_name': _emergNameC.text.trim().isEmpty ? null : _emergNameC.text.trim(),
        'emergency_contact_phone': _emergPhoneC.text.trim().isEmpty ? null : _emergPhoneC.text.trim(),
      });
      await ref.read(authStateProvider.notifier).refreshUser();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;
    _initForm();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Form(
        key: _formKey,
        child: ListView(padding: const EdgeInsets.all(20), children: [
          // Avatar
          Center(child: CircleAvatar(radius: 40, backgroundColor: AppTheme.primary,
            child: Text(user?.initials ?? '', style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)))),
          const SizedBox(height: 8),
          Center(child: Text(user?.email ?? '', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13))),
          const SizedBox(height: 24),

          // Personal info
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Personal Information', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: TextFormField(controller: _firstC, decoration: const InputDecoration(labelText: 'First name'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null)),
              const SizedBox(width: 12),
              Expanded(child: TextFormField(controller: _lastC, decoration: const InputDecoration(labelText: 'Last name'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null)),
            ]),
            const SizedBox(height: 12),
            PhoneInput(
              label: 'Phone',
              initialValue: _phoneC.text,
              onChanged: (v) => _phoneC.text = v,
            ),
            const SizedBox(height: 12),
            TextFormField(controller: _dobC, decoration: const InputDecoration(labelText: 'Date of Birth (YYYY-MM-DD)'), keyboardType: TextInputType.datetime),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _gender.isEmpty ? null : _gender,
              decoration: const InputDecoration(labelText: 'Gender'),
              items: const [
                DropdownMenuItem(value: 'male', child: Text('Male')),
                DropdownMenuItem(value: 'female', child: Text('Female')),
                DropdownMenuItem(value: 'other', child: Text('Other')),
              ],
              onChanged: (v) => _gender = v ?? '',
            ),
          ]))),
          const SizedBox(height: 12),

          // Emergency contact
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Emergency Contact', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            TextFormField(controller: _emergNameC, decoration: const InputDecoration(labelText: 'Contact name')),
            const SizedBox(height: 12),
            TextFormField(controller: _emergPhoneC, decoration: const InputDecoration(labelText: 'Contact phone'), keyboardType: TextInputType.phone),
          ]))),
          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: _saving ? null : _save,
            child: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Save Changes'),
          ),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: OutlinedButton.icon(
            onPressed: () async { await ref.read(authStateProvider.notifier).logout(); if (context.mounted) context.go('/login'); },
            icon: const Icon(Icons.logout, color: AppTheme.error),
            label: const Text('Logout', style: TextStyle(color: AppTheme.error)),
            style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.error)),
          )),
          const SizedBox(height: 32),
        ]),
      ),
    );
  }
}
