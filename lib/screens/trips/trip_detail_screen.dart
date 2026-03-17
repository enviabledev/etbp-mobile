import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:etbp_mobile/config/theme.dart';
import 'package:etbp_mobile/core/auth/auth_provider.dart';
import 'package:etbp_mobile/core/api/endpoints.dart';
import 'package:etbp_mobile/core/utils/formatters.dart';
import 'package:etbp_mobile/models/booking.dart';

class TripDetailScreen extends ConsumerStatefulWidget {
  final String ref;
  const TripDetailScreen({super.key, required this.ref});
  @override
  ConsumerState<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends ConsumerState<TripDetailScreen> {
  Booking? _booking;
  bool _loading = true;
  bool _cancelling = false;
  bool _sharing = false;
  bool _downloading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final api = ref.read(apiClientProvider);
      final res = await api.get(Endpoints.bookingDetail(widget.ref));
      setState(() {
        _booking = Booking.fromJson(res.data);
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<File> _fetchTicketPdf() async {
    final api = ref.read(apiClientProvider);
    final response = await api.download(Endpoints.eTicket(widget.ref));
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/ticket_${widget.ref}.pdf');
    await file.writeAsBytes(response.data);
    return file;
  }

  Future<void> _shareTicket() async {
    setState(() => _sharing = true);
    try {
      final file = await _fetchTicketPdf();
      await Share.shareXFiles([XFile(file.path)], text: 'My trip ticket - ${widget.ref}');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to share: $e')));
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  Future<void> _downloadTicket() async {
    setState(() => _downloading = true);
    try {
      final file = await _fetchTicketPdf();
      final dir = await getApplicationDocumentsDirectory();
      final saved = await file.copy('${dir.path}/ticket_${widget.ref}.pdf');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ticket saved to ${saved.path}')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to download: $e')));
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  Future<void> _cancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel Booking?'),
        content: const Text(
            'This action cannot be undone.\n\nRefund policy:\n• >24h before departure: 90% refund\n• 12-24h: 50% refund\n• <12h: No refund'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep Booking')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Cancel Booking', style: TextStyle(color: AppTheme.error))),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _cancelling = true);
    try {
      final api = ref.read(apiClientProvider);
      await api.put(Endpoints.cancelBooking(widget.ref), data: {'reason': 'Cancelled by passenger'});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking cancelled')));
        _load();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(appBar: AppBar(title: Text(widget.ref)), body: const Center(child: CircularProgressIndicator()));
    }
    if (_booking == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('Booking not found')));
    }

    final b = _booking!;
    final isCancellable = b.status == 'confirmed' || b.status == 'pending';
    final statusColor = b.status == 'confirmed'
        ? AppTheme.success
        : b.status == 'cancelled'
            ? AppTheme.error
            : AppTheme.warning;

    return Scaffold(
      appBar: AppBar(title: Text('Booking ${b.ref}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status badge
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(b.status.toUpperCase(),
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: statusColor)),
            ),
          ),
          const SizedBox(height: 16),

          // Trip info
          if (b.trip != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Trip', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(
                    '${b.trip!.route?.originTerminal?.city ?? '—'} → ${b.trip!.route?.destinationTerminal?.city ?? '—'}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text('${formatDate(b.trip!.departureDate)} • ${formatTime(b.trip!.departureTime)}',
                      style: const TextStyle(color: AppTheme.textSecondary)),
                ]),
              ),
            ),
          const SizedBox(height: 12),

          // Passengers
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Passengers (${b.passengerCount})', style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ...b.passengers.map((p) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(children: [
                        Expanded(child: Text(p.fullName)),
                        if (p.seatNumber != null)
                          Text('Seat ${p.seatNumber}', style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                      ]),
                    )),
              ]),
            ),
          ),
          const SizedBox(height: 12),

          // Payment
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Payment', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(children: [
                  const Text('Amount'),
                  const Spacer(),
                  Text(formatCurrency(b.totalAmount), style: const TextStyle(fontWeight: FontWeight.bold)),
                ]),
                if (b.paymentMethod != null) ...[
                  const SizedBox(height: 4),
                  Row(children: [
                    const Text('Method', style: TextStyle(color: AppTheme.textSecondary)),
                    const Spacer(),
                    Text(b.paymentMethod!, style: const TextStyle(color: AppTheme.textSecondary)),
                  ]),
                ],
              ]),
            ),
          ),
          const SizedBox(height: 16),

          // QR code
          Center(
            child: Column(children: [
              QrImageView(data: 'ETBP-${b.ref}', size: 160, backgroundColor: Colors.white),
              const SizedBox(height: 8),
              Text(b.ref, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2)),
            ]),
          ),
          const SizedBox(height: 16),

          // Share & Download buttons
          if (b.status == 'confirmed')
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _sharing ? null : _shareTicket,
                  icon: _sharing
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.share),
                  label: const Text('Share'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _downloading ? null : _downloadTicket,
                  icon: _downloading
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.download),
                  label: const Text('Download'),
                ),
              ),
            ]),
          const SizedBox(height: 16),

          // Cancel button
          if (isCancellable)
            OutlinedButton.icon(
              onPressed: _cancelling ? null : _cancel,
              icon: const Icon(Icons.cancel_outlined, color: AppTheme.error),
              label: Text(_cancelling ? 'Cancelling...' : 'Cancel Booking', style: const TextStyle(color: AppTheme.error)),
              style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.error), minimumSize: const Size(double.infinity, 48)),
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
