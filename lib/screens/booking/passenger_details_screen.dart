import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:etbp_mobile/config/theme.dart';
import 'package:etbp_mobile/core/auth/auth_provider.dart';
import 'package:etbp_mobile/providers/booking_provider.dart';

class PassengerDetailsScreen extends ConsumerStatefulWidget {
  const PassengerDetailsScreen({super.key});
  @override
  ConsumerState<PassengerDetailsScreen> createState() => _PassengerDetailsScreenState();
}

class _PassengerDetailsScreenState extends ConsumerState<PassengerDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<Map<String, TextEditingController>> _controllers = [];
  final _emailC = TextEditingController();
  final _phoneC = TextEditingController();
  final _emergNameC = TextEditingController();
  final _emergPhoneC = TextEditingController();
  final List<String> _genders = [];

  @override
  void initState() {
    super.initState();
    final booking = ref.read(bookingProvider);
    final user = ref.read(authStateProvider).value;

    for (int i = 0; i < booking.selectedSeats.length; i++) {
      final isPrimary = i == 0;
      _controllers.add({
        'first': TextEditingController(text: isPrimary ? (user?.firstName ?? '') : ''),
        'last': TextEditingController(text: isPrimary ? (user?.lastName ?? '') : ''),
        'phone': TextEditingController(text: isPrimary ? (user?.phone ?? '') : ''),
      });
      _genders.add('male');
    }

    _emailC.text = user?.email ?? '';
    _phoneC.text = user?.phone ?? '';
    _emergNameC.text = user?.emergencyContactName ?? '';
    _emergPhoneC.text = user?.emergencyContactPhone ?? '';
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.values.forEach((ctrl) => ctrl.dispose());
    }
    _emailC.dispose();
    _phoneC.dispose();
    _emergNameC.dispose();
    _emergPhoneC.dispose();
    super.dispose();
  }

  void _continue() {
    if (!_formKey.currentState!.validate()) return;

    final booking = ref.read(bookingProvider);
    final notifier = ref.read(bookingProvider.notifier);

    final passengers = <PassengerData>[];
    for (int i = 0; i < booking.selectedSeats.length; i++) {
      final seat = booking.selectedSeats[i];
      passengers.add(PassengerData(
        seatId: seat.id,
        seatNumber: seat.seatNumber,
        firstName: _controllers[i]['first']!.text.trim(),
        lastName: _controllers[i]['last']!.text.trim(),
        gender: _genders[i],
        phone: _controllers[i]['phone']!.text.trim(),
        isPrimary: i == 0,
      ));
    }

    notifier.setPassengers(passengers);
    notifier.setContactInfo(_emailC.text.trim(), _phoneC.text.trim());
    if (_emergNameC.text.trim().isNotEmpty) {
      notifier.setEmergencyContact(_emergNameC.text.trim(), _emergPhoneC.text.trim());
    }

    context.push('/booking/review');
  }

  @override
  Widget build(BuildContext context) {
    final booking = ref.watch(bookingProvider);
    if (booking.selectedSeats.isEmpty) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('No seats selected')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Passenger Details')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Lock timer
            if (booking.lockExpiresAt != null) _CountdownBanner(expiry: booking.lockExpiresAt!),
            const SizedBox(height: 8),

            // Passenger forms
            ...List.generate(booking.selectedSeats.length, (i) {
              final seat = booking.selectedSeats[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text(i == 0 ? 'Primary Passenger' : 'Passenger ${i + 1}',
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(12)),
                          child: Text('Seat ${seat.seatNumber}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                        ),
                      ]),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(child: TextFormField(
                          controller: _controllers[i]['first'],
                          decoration: const InputDecoration(labelText: 'First name'),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                        )),
                        const SizedBox(width: 12),
                        Expanded(child: TextFormField(
                          controller: _controllers[i]['last'],
                          decoration: const InputDecoration(labelText: 'Last name'),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                        )),
                      ]),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _genders[i],
                            decoration: const InputDecoration(labelText: 'Gender'),
                            items: const [
                              DropdownMenuItem(value: 'male', child: Text('Male')),
                              DropdownMenuItem(value: 'female', child: Text('Female')),
                              DropdownMenuItem(value: 'other', child: Text('Other')),
                            ],
                            onChanged: (v) => _genders[i] = v ?? 'male',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: TextFormField(
                          controller: _controllers[i]['phone'],
                          decoration: const InputDecoration(labelText: 'Phone'),
                          keyboardType: TextInputType.phone,
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                        )),
                      ]),
                    ],
                  ),
                ),
              );
            }),

            // Contact info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Contact Information', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailC,
                    decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined, size: 20)),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneC,
                    decoration: const InputDecoration(labelText: 'Phone', prefixIcon: Icon(Icons.phone_outlined, size: 20)),
                    keyboardType: TextInputType.phone,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 12),

            // Emergency contact
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Emergency Contact', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  TextFormField(controller: _emergNameC, decoration: const InputDecoration(labelText: 'Contact name')),
                  const SizedBox(height: 12),
                  TextFormField(controller: _emergPhoneC, decoration: const InputDecoration(labelText: 'Contact phone'), keyboardType: TextInputType.phone),
                ]),
              ),
            ),
            const SizedBox(height: 16),

            ElevatedButton(onPressed: _continue, child: const Text('Continue to Review')),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _CountdownBanner extends StatefulWidget {
  final DateTime expiry;
  const _CountdownBanner({required this.expiry});
  @override
  State<_CountdownBanner> createState() => _CountdownBannerState();
}

class _CountdownBannerState extends State<_CountdownBanner> {
  late int _seconds;
  late final Stream<int> _ticker;

  @override
  void initState() {
    super.initState();
    _seconds = widget.expiry.difference(DateTime.now()).inSeconds.clamp(0, 9999);
    _ticker = Stream.periodic(const Duration(seconds: 1), (_) {
      return widget.expiry.difference(DateTime.now()).inSeconds.clamp(0, 9999);
    });
    _ticker.listen((s) { if (mounted) setState(() => _seconds = s); });
  }

  @override
  Widget build(BuildContext context) {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    final urgent = _seconds < 60;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: urgent ? AppTheme.error.withValues(alpha: 0.1) : AppTheme.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(children: [
        Icon(Icons.timer, size: 18, color: urgent ? AppTheme.error : AppTheme.warning),
        const SizedBox(width: 8),
        Text('Seats held for $m:$s', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: urgent ? AppTheme.error : AppTheme.warning)),
      ]),
    );
  }
}
