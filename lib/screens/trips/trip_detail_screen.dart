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
import 'package:etbp_mobile/widgets/common/countdown_timer.dart';
import 'package:etbp_mobile/widgets/booking/add_to_calendar_button.dart';

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
  bool _transferring = false;
  bool _addingLuggage = false;
  Map<String, dynamic>? _review;
  bool _submittingReview = false;
  Map<String, dynamic>? _calendarData;

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
      // Try to load existing review
      try {
        final reviewRes = await api.get(Endpoints.getReview(widget.ref));
        _review = reviewRes.data;
      } catch (_) {
        _review = null;
      }
      final booking = Booking.fromJson(res.data);
      // Load calendar data for confirmed/checked_in bookings with future trips
      if (booking.status == 'confirmed' || booking.status == 'checked_in') {
        try {
          final calRes = await api.get(Endpoints.calendarData(widget.ref));
          _calendarData = calRes.data;
          debugPrint('Calendar data loaded: ${_calendarData?['title']}');
        } catch (e) {
          debugPrint('Calendar data load failed: $e');
          _calendarData = null;
        }
      }
      setState(() {
        _booking = booking;
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

  void _showTransferSheet() {
    final nameC = TextEditingController();
    final phoneC = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Text('Transfer Ticket', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Transfer this booking to another person. This cannot be undone.', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          const SizedBox(height: 16),
          TextField(controller: nameC, decoration: const InputDecoration(labelText: 'Recipient full name', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: phoneC, decoration: const InputDecoration(labelText: 'Recipient phone (+234...)', border: OutlineInputBorder()), keyboardType: TextInputType.phone),
          const SizedBox(height: 20),
          StatefulBuilder(builder: (ctx2, setSheetState) {
            return ElevatedButton(
              onPressed: _transferring ? null : () async {
                if (nameC.text.trim().isEmpty || phoneC.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name and phone are required')));
                  return;
                }
                setSheetState(() => _transferring = true);
                try {
                  final api = ref.read(apiClientProvider);
                  await api.post(Endpoints.transferBooking(widget.ref), data: {
                    'recipient_name': nameC.text.trim(),
                    'recipient_phone': phoneC.text.trim(),
                  });
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Booking transferred to ${nameC.text.trim()}')));
                    _load();
                  }
                } catch (e) {
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.error));
                } finally {
                  _transferring = false;
                  if (mounted) setSheetState(() {});
                }
              },
              child: _transferring ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Transfer Booking'),
            );
          }),
        ]),
      ),
    );
  }

  void _showReviewSheet() {
    int overall = 0;
    int driver = 0;
    int bus = 0;
    int punctuality = 0;
    int comfort = 0;
    String comment = '';
    bool anonymous = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(builder: (ctx2, setSheetState) {
        Widget starRow(String label, int value, Function(int) onTap, {double size = 28}) {
          return Row(children: [
            SizedBox(width: 90, child: Text(label, style: const TextStyle(fontSize: 13))),
            ...List.generate(5, (i) => GestureDetector(
              onTap: () => setSheetState(() => onTap(i + 1)),
              child: Icon(i < value ? Icons.star : Icons.star_border, color: i < value ? Colors.amber : Colors.grey[300], size: size),
            )),
          ]);
        }

        return Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Text('Rate Your Trip', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            starRow('Overall *', overall, (v) => overall = v, size: 36),
            const SizedBox(height: 12),
            starRow('Driver', driver, (v) => driver = v),
            const SizedBox(height: 8),
            starRow('Bus', bus, (v) => bus = v),
            const SizedBox(height: 8),
            starRow('Punctuality', punctuality, (v) => punctuality = v),
            const SizedBox(height: 8),
            starRow('Comfort', comfort, (v) => comfort = v),
            const SizedBox(height: 16),
            TextField(
              onChanged: (v) => comment = v,
              maxLength: 500,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'Tell us about your experience (optional)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            Row(children: [
              Checkbox(value: anonymous, onChanged: (v) => setSheetState(() => anonymous = v ?? false)),
              const Text('Submit anonymously', style: TextStyle(fontSize: 13)),
            ]),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: overall == 0 || _submittingReview ? null : () async {
                setSheetState(() => _submittingReview = true);
                try {
                  final api = ref.read(apiClientProvider);
                  await api.post(Endpoints.submitReview(widget.ref), data: {
                    'overall_rating': overall,
                    if (driver > 0) 'driver_rating': driver,
                    if (bus > 0) 'bus_condition_rating': bus,
                    if (punctuality > 0) 'punctuality_rating': punctuality,
                    if (comfort > 0) 'comfort_rating': comfort,
                    if (comment.trim().isNotEmpty) 'comment': comment.trim(),
                    'is_anonymous': anonymous,
                  });
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Review submitted!')));
                    _load();
                  }
                } catch (e) {
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.error));
                } finally {
                  _submittingReview = false;
                  if (mounted) setSheetState(() {});
                }
              },
              child: _submittingReview ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Submit Review'),
            ),
          ])),
        );
      }),
    );
  }

  void _showLuggageSheet() {
    int qty = 1;
    String method = 'wallet';
    showModalBottomSheet(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx2, setSheetState) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Text('Add Extra Luggage', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(children: [
              const Text('Bags:', style: TextStyle(fontSize: 15)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: qty > 1 ? () => setSheetState(() => qty--) : null),
              Text('$qty', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: qty < 5 ? () => setSheetState(() => qty++) : null),
            ]),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                Text('Total: ${formatCurrency(2000.0 * qty)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                const Text('@ ${2000}/bag', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ]),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: ChoiceChip(label: const Text('Wallet'), selected: method == 'wallet', onSelected: (_) => setSheetState(() => method = 'wallet'))),
              const SizedBox(width: 8),
              Expanded(child: ChoiceChip(label: const Text('Card'), selected: method == 'card', onSelected: (_) => setSheetState(() => method = 'card'))),
            ]),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addingLuggage ? null : () async {
                setSheetState(() => _addingLuggage = true);
                try {
                  final api = ref.read(apiClientProvider);
                  await api.post(Endpoints.addLuggage(widget.ref), data: {'quantity': qty, 'payment_method': method});
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$qty extra bag(s) added!')));
                    _load();
                  }
                } catch (e) {
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.error));
                } finally {
                  _addingLuggage = false;
                  if (mounted) setSheetState(() {});
                }
              },
              child: _addingLuggage ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Add Luggage'),
            ),
          ]),
        );
      }),
    );
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
    final statusColor = (b.status == 'confirmed' || b.status == 'completed' || b.status == 'checked_in')
        ? AppTheme.success
        : (b.status == 'cancelled' || b.status == 'expired')
            ? AppTheme.error
            : AppTheme.warning; // pending, no_show, etc.

    return Scaffold(
      appBar: AppBar(title: Text('Booking ${b.ref}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Payment deadline countdown
          if (b.status == 'pending' && b.paymentDeadline != null && b.paymentMethodHint == 'pay_at_terminal')
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: PaymentDeadlineBanner(
                deadline: DateTime.parse(b.paymentDeadline!),
                terminalName: b.trip?.route?.originTerminal?.name,
                onExpired: _load,
              ),
            ),

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
                    b.trip!.route?.name ?? '${b.trip!.route?.originTerminal?.city ?? '—'} → ${b.trip!.route?.destinationTerminal?.city ?? '—'}',
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
          // Add to Calendar
          if ((b.status == 'confirmed' || b.status == 'checked_in') && _calendarData != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: AddToCalendarButton(
                title: _calendarData!['title'] ?? 'Bus Trip',
                description: _calendarData!['description'] ?? '',
                location: _calendarData!['location'] ?? '',
                startTime: DateTime.tryParse(_calendarData!['start_time'] ?? '') ?? DateTime.now(),
                endTime: DateTime.tryParse(_calendarData!['end_time'] ?? '') ?? DateTime.now().add(const Duration(hours: 8)),
              ),
            ),
          const SizedBox(height: 16),

          // Review section
          if ((b.status == 'completed' || b.status == 'checked_in') && _review == null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                color: Colors.amber.withValues(alpha: 0.08),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Rate Your Trip', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF92400E))),
                    const SizedBox(height: 4),
                    const Text('Your feedback helps us improve.', style: TextStyle(fontSize: 13, color: Color(0xFFB45309))),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _showReviewSheet,
                      icon: const Icon(Icons.star, size: 18),
                      label: const Text('Write a Review'),
                    ),
                  ]),
                ),
              ),
            ),

          if (_review != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Your Review', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Row(children: List.generate(5, (i) => Icon(
                      i < (_review!['overall_rating'] ?? 0) ? Icons.star : Icons.star_border,
                      color: Colors.amber, size: 22,
                    ))),
                    if (_review!['comment'] != null) ...[
                      const SizedBox(height: 8),
                      Text(_review!['comment'], style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                    ],
                    if (_review!['admin_response'] != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8)),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('Response:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.primary)),
                          Text(_review!['admin_response'], style: const TextStyle(fontSize: 13)),
                        ]),
                      ),
                    ],
                  ]),
                ),
              ),
            ),

          // Actions: Transfer & Luggage
          if (b.status == 'confirmed' && b.trip != null) ...[
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showTransferSheet,
                  icon: const Icon(Icons.send, size: 18),
                  label: const Text('Transfer'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showLuggageSheet,
                  icon: const Icon(Icons.luggage, size: 18),
                  label: const Text('Add Luggage'),
                ),
              ),
            ]),
            const SizedBox(height: 12),
          ],

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
