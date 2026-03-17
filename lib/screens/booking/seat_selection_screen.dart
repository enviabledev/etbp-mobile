import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:etbp_mobile/config/theme.dart';
import 'package:etbp_mobile/core/auth/auth_provider.dart';
import 'package:etbp_mobile/core/api/endpoints.dart';
import 'package:etbp_mobile/core/utils/formatters.dart';
import 'package:etbp_mobile/models/seat.dart';
import 'package:etbp_mobile/models/trip.dart';
import 'package:etbp_mobile/models/route.dart';

class SeatSelectionScreen extends ConsumerStatefulWidget {
  final String tripId;
  const SeatSelectionScreen({super.key, required this.tripId});
  @override
  ConsumerState<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends ConsumerState<SeatSelectionScreen> {
  SeatMap? _seatMap;
  TripSearchResult? _trip;
  final Set<String> _selectedIds = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final api = ref.read(apiClientProvider);
      final tripRes = await api.get(Endpoints.tripDetail(widget.tripId));
      final routeRes = await api.get('/routes/${tripRes.data['route_id']}');
      final seatsRes = await api.get(Endpoints.tripSeats(widget.tripId));
      setState(() {
        _trip = TripSearchResult(
          id: tripRes.data['id'], departureDate: tripRes.data['departure_date'] ?? '',
          departureTime: tripRes.data['departure_time'] ?? '', price: (tripRes.data['price'] ?? 0).toDouble(),
          route: TripRoute.fromJson(routeRes.data), availableSeats: tripRes.data['available_seats'] ?? 0, totalSeats: tripRes.data['total_seats'] ?? 0,
        );
        _seatMap = SeatMap.fromJson(seatsRes.data);
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  void _toggleSeat(String id) {
    setState(() {
      if (_selectedIds.contains(id)) { _selectedIds.remove(id); } else { _selectedIds.add(id); }
    });
  }

  Future<void> _continue() async {
    if (_selectedIds.isEmpty) return;
    // Lock seats then navigate
    try {
      final api = ref.read(apiClientProvider);
      await api.post(Endpoints.lockSeats(widget.tripId), data: {'seat_ids': _selectedIds.toList()});
      if (mounted) context.push('/booking/passengers');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final seats = _seatMap?.seats ?? [];
    final rows = <int, List<Seat>>{};
    for (final s in seats) { rows.putIfAbsent(s.seatRow, () => []).add(s); }
    final sortedRows = rows.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(title: const Text('Select Seats')),
      body: Column(
        children: [
          if (_trip != null) Container(
            padding: const EdgeInsets.all(16), color: Colors.white,
            child: Row(children: [
              Text('${_trip!.route.originTerminal.city} → ${_trip!.route.destinationTerminal.city}', style: const TextStyle(fontWeight: FontWeight.w600)),
              const Spacer(),
              Text(formatCurrency(_trip!.price), style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
            ]),
          ),
          // Legend
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _legend(Colors.blue.shade100, 'Available'), const SizedBox(width: 16),
              _legend(Colors.green.shade200, 'Selected'), const SizedBox(width: 16),
              _legend(Colors.grey.shade300, 'Booked'),
            ]),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(children: sortedRows.map((row) {
                final rowSeats = rows[row]!..sort((a, b) => a.seatColumn.compareTo(b.seatColumn));
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: rowSeats.map((seat) {
                    final selected = _selectedIds.contains(seat.id);
                    final color = seat.isBooked || seat.isLocked ? Colors.grey.shade300 : selected ? Colors.green.shade200 : Colors.blue.shade100;
                    return GestureDetector(
                      onTap: seat.isAvailable ? () => _toggleSeat(seat.id) : null,
                      child: Container(
                        width: 44, height: 44, margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6), border: selected ? Border.all(color: AppTheme.primary, width: 2) : null),
                        child: Center(child: Text(seat.seatNumber, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: seat.isAvailable ? AppTheme.textPrimary : Colors.grey))),
                      ),
                    );
                  }).toList()),
                );
              }).toList()),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _selectedIds.isEmpty ? null : _continue,
            child: Text('Continue (${_selectedIds.length} seat${_selectedIds.length == 1 ? '' : 's'})'),
          ),
        ),
      ),
    );
  }

  Widget _legend(Color color, String label) => Row(children: [
    Container(width: 16, height: 16, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
    const SizedBox(width: 4),
    Text(label, style: const TextStyle(fontSize: 12)),
  ]);
}
