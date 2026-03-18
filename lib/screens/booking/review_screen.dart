import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:etbp_mobile/config/theme.dart';
import 'package:etbp_mobile/core/auth/auth_provider.dart';
import 'package:etbp_mobile/core/api/endpoints.dart';
import 'package:etbp_mobile/core/utils/formatters.dart';
import 'package:etbp_mobile/providers/booking_provider.dart';
import 'package:etbp_mobile/models/wallet.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key});
  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  bool _processing = false;
  Wallet? _wallet;

  @override
  void initState() {
    super.initState();
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    try {
      final api = ref.read(apiClientProvider);
      final res = await api.get(Endpoints.walletBalance);
      if (mounted) setState(() => _wallet = Wallet.fromJson(res.data));
    } catch (_) {}
  }

  Future<void> _confirm() async {
    final booking = ref.read(bookingProvider);
    final notifier = ref.read(bookingProvider.notifier);
    if (booking.trip == null || booking.passengers.isEmpty) return;

    setState(() => _processing = true);
    try {
      final api = ref.read(apiClientProvider);

      // 1. Create booking (always fresh — never reuse stale references)
      final bookingRes = await api.post(Endpoints.bookings, data: {
        'trip_id': booking.trip!.id,
        'passengers': booking.passengers.map((p) => p.toJson()).toList(),
        'contact_email': booking.contactEmail,
        'contact_phone': booking.contactPhone,
        'emergency_contact_name': booking.emergencyContactName,
        'emergency_contact_phone': booking.emergencyContactPhone,
        'payment_method': booking.paymentMethod,
      });
      final bookingRef = bookingRes.data['reference'] ?? bookingRes.data['booking_reference'] ?? '';
      notifier.setBookingReference(bookingRef);

      // 2. Process payment
      if (booking.paymentMethod == 'card') {
        final payRes = await api.post(Endpoints.initiatePayment, data: {
          'booking_reference': bookingRef,
          'method': 'card',
          'callback_url': 'https://app.enviabletransport.ng/booking/payment?booking_ref=$bookingRef',
        });
        final authUrl = payRes.data['authorization_url'] ?? '';
        if (mounted && authUrl.isNotEmpty) {
          context.push('/booking/payment?url=${Uri.encodeComponent(authUrl)}&ref=$bookingRef');
        }
      } else if (booking.paymentMethod == 'wallet') {
        await api.post(Endpoints.payWithWallet, data: {'booking_reference': bookingRef});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment successful!')));
          context.go('/booking/confirmation?ref=$bookingRef');
        }
      } else {
        // Pay at terminal
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking created. Pay at the terminal.')));
          context.go('/booking/confirmation?ref=$bookingRef');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.error));
      }
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = ref.watch(bookingProvider);
    if (booking.trip == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('No booking data')));
    }
    final trip = booking.trip!;
    final total = booking.totalAmount;

    return Scaffold(
      appBar: AppBar(title: const Text('Review & Pay')),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (booking.lockExpiresAt != null) _CountdownBanner(expiry: booking.lockExpiresAt!),
              const SizedBox(height: 12),

              // Trip details
              Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Trip Details', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                _row('Route', trip.route.name),
                _row('From', trip.route.originTerminal.city),
                _row('To', trip.route.destinationTerminal.city),
                _row('Date', formatDate(trip.departureDate)),
                _row('Time', formatTime(trip.departureTime)),
                if (trip.vehicleType != null) _row('Vehicle', trip.vehicleType!.name),
              ]))),
              const SizedBox(height: 12),

              // Passengers
              Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Passengers (${booking.passengers.length})', style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ...booking.passengers.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(children: [
                    Expanded(child: Text('${p.firstName} ${p.lastName}', style: const TextStyle(fontSize: 14))),
                    Text('Seat ${p.seatNumber}', style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                  ]),
                )),
              ]))),
              const SizedBox(height: 12),

              // Payment method
              Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Payment Method', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                _paymentOption('card', 'Pay with Card', Icons.credit_card, null),
                _paymentOption('wallet', 'Pay from Wallet', Icons.account_balance_wallet,
                    _wallet != null ? '(${formatCurrency(_wallet!.balance)})' : null),
                _paymentOption('terminal', 'Pay at Terminal', Icons.store, null),
              ]))),
              const SizedBox(height: 12),

              // Total
              Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
                const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                Text(formatCurrency(total), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primary)),
              ]))),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: _processing ? null : _confirm,
                child: _processing
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(booking.paymentMethod == 'card'
                        ? 'Pay ${formatCurrency(total)}'
                        : booking.paymentMethod == 'wallet'
                            ? 'Pay from Wallet'
                            : 'Confirm Booking'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(children: [
      SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary))),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
    ]),
  );

  Widget _paymentOption(String value, String label, IconData icon, String? subtitle) {
    final booking = ref.watch(bookingProvider);
    final selected = booking.paymentMethod == value;
    final disabled = value == 'wallet' && (_wallet == null || _wallet!.balance < booking.totalAmount);

    return InkWell(
      onTap: disabled ? null : () => ref.read(bookingProvider.notifier).setPaymentMethod(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(children: [
          Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: disabled ? Colors.grey : (selected ? AppTheme.primary : AppTheme.textSecondary), size: 20),
          const SizedBox(width: 12),
          Icon(icon, size: 20, color: disabled ? Colors.grey : AppTheme.textPrimary),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 14, color: disabled ? Colors.grey : AppTheme.textPrimary)),
          if (subtitle != null) ...[const SizedBox(width: 6), Text(subtitle, style: TextStyle(fontSize: 12, color: disabled ? Colors.grey : AppTheme.textSecondary))],
        ]),
      ),
    );
  }
}

class _CountdownBanner extends StatefulWidget {
  final DateTime expiry;
  const _CountdownBanner({required this.expiry});
  @override
  State<_CountdownBanner> createState() => __CountdownBannerState();
}

class __CountdownBannerState extends State<_CountdownBanner> {
  late int _seconds;

  @override
  void initState() {
    super.initState();
    _seconds = widget.expiry.difference(DateTime.now()).inSeconds.clamp(0, 9999);
    Stream.periodic(const Duration(seconds: 1)).listen((_) {
      if (mounted) setState(() => _seconds = widget.expiry.difference(DateTime.now()).inSeconds.clamp(0, 9999));
    });
  }

  @override
  Widget build(BuildContext context) {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    final urgent = _seconds < 60;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: urgent ? AppTheme.error.withValues(alpha: 0.1) : AppTheme.warning.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Row(children: [
        Icon(Icons.timer, size: 18, color: urgent ? AppTheme.error : AppTheme.warning),
        const SizedBox(width: 8),
        Text('Seats held for $m:$s', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: urgent ? AppTheme.error : AppTheme.warning)),
      ]),
    );
  }
}
