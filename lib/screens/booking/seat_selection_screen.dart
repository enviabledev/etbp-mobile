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
import 'package:etbp_mobile/providers/booking_provider.dart';

class SeatSelectionScreen extends ConsumerStatefulWidget {
  final String tripId;
  const SeatSelectionScreen({super.key, required this.tripId});
  @override
  ConsumerState<SeatSelectionScreen> createState() =>
      _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends ConsumerState<SeatSelectionScreen> {
  SeatMap? _seatMap;
  TripSearchResult? _trip;
  final Set<String> _selectedIds = {};
  bool _loading = true;
  bool _locking = false;

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
          id: tripRes.data['id'],
          departureDate: tripRes.data['departure_date'] ?? '',
          departureTime: tripRes.data['departure_time'] ?? '',
          price: (tripRes.data['price'] ?? 0).toDouble(),
          route: TripRoute.fromJson(routeRes.data),
          availableSeats: tripRes.data['available_seats'] ?? 0,
          totalSeats: tripRes.data['total_seats'] ?? 0,
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
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  Future<void> _continue() async {
    if (_selectedIds.isEmpty || _trip == null) return;

    // Check auth — show dialog if not logged in
    final user = ref.read(authStateProvider).value;
    if (user == null) {
      // Save trip + seats to provider so they persist across login
      final selectedSeatObjects = (_seatMap?.seats ?? [])
          .where((s) => _selectedIds.contains(s.id))
          .toList();
      final notifier = ref.read(bookingProvider.notifier);
      notifier.setTrip(_trip!);
      notifier.setSelectedSeats(selectedSeatObjects);

      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Login to continue'),
          content: const Text(
            'Please login or create an account to complete your booking. Your seat selection will be saved.',
          ),
          actions: [
            TextButton(
              onPressed: () { Navigator.pop(context); context.push('/login'); },
              child: const Text('Login'),
            ),
            TextButton(
              onPressed: () { Navigator.pop(context); context.push('/register'); },
              child: Text('Register', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
      return;
    }

    setState(() => _locking = true);
    try {
      final api = ref.read(apiClientProvider);
      final response = await api.post(Endpoints.lockSeats(widget.tripId),
          data: {'seat_ids': _selectedIds.toList()});

      final selectedSeatObjects = (_seatMap?.seats ?? [])
          .where((s) => _selectedIds.contains(s.id))
          .toList();

      final notifier = ref.read(bookingProvider.notifier);
      notifier.setTrip(_trip!);
      notifier.setSelectedSeats(selectedSeatObjects);

      final lockedUntil = response.data['locked_until'];
      if (lockedUntil != null) {
        notifier.setLockExpiry(DateTime.parse(lockedUntil));
      }

      if (mounted) context.push('/booking/passengers');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _locking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final seats = _seatMap?.seats ?? [];

    // Group seats by row
    final rowMap = <int, Map<int, Seat>>{};
    int maxCol = 0;
    for (final s in seats) {
      rowMap.putIfAbsent(s.seatRow, () => {});
      rowMap[s.seatRow]![s.seatColumn] = s;
      if (s.seatColumn > maxCol) maxCol = s.seatColumn;
    }
    final sortedRows = rowMap.keys.toList()..sort();

    // Detect aisle columns — columns that have NO seats in ANY row
    final occupiedCols = <int>{};
    for (final colMap in rowMap.values) {
      occupiedCols.addAll(colMap.keys);
    }
    final aisleCols = <int>{};
    for (int c = 1; c <= maxCol; c++) {
      if (!occupiedCols.contains(c)) aisleCols.add(c);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Select Seats')),
      body: Column(
        children: [
          // Trip summary
          if (_trip != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.white,
              child: Row(children: [
                Expanded(
                  child: Text(
                    _trip!.route.name.isNotEmpty ? _trip!.route.name : '${_trip!.route.originTerminal.city} → ${_trip!.route.destinationTerminal.city}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Text(formatCurrency(_trip!.price),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: AppTheme.primary)),
              ]),
            ),

          // Legend
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _legend(const Color(0xFFE2E8F0), 'Available'),
                const SizedBox(width: 12),
                _legend(AppTheme.primary, 'Selected'),
                const SizedBox(width: 12),
                _legend(const Color(0xFF94A3B8), 'Booked'),
                const SizedBox(width: 12),
                _legend(AppTheme.warning, 'Locked'),
              ],
            ),
          ),

          // Seat grid
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  // "Front" label
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Text('FRONT',
                        style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                            letterSpacing: 2)),
                  ),
                  // Rows
                  ...sortedRows.map((rowNum) {
                    final colMap = rowMap[rowNum]!;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(maxCol, (i) {
                          final col = i + 1;

                          // Aisle gap
                          if (aisleCols.contains(col)) {
                            return const SizedBox(width: 24);
                          }

                          final seat = colMap[col];
                          if (seat == null) {
                            // Empty cell (no seat at this position)
                            return Container(
                              width: 46,
                              height: 46,
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                            );
                          }

                          final selected = _selectedIds.contains(seat.id);
                          return _buildSeat(seat, selected);
                        }),
                      ),
                    );
                  }),
                  // "Back" label
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text('BACK',
                        style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                            letterSpacing: 2)),
                  ),
                ],
              ),
            ),
          ),

          // Seat count
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              '${_seatMap?.availableSeats ?? 0} of ${_seatMap?.totalSeats ?? 0} seats available',
              style:
                  const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _selectedIds.isEmpty || _locking ? null : _continue,
            child: _locking
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text('Continue (${_selectedIds.length} seat${_selectedIds.length == 1 ? '' : 's'})'),
          ),
        ),
      ),
    );
  }

  Widget _buildSeat(Seat seat, bool selected) {
    Color bgColor;
    Color textColor;
    Border? border;

    if (selected) {
      bgColor = AppTheme.primary;
      textColor = Colors.white;
      border = Border.all(color: AppTheme.primary, width: 2);
    } else if (seat.isBooked) {
      bgColor = const Color(0xFF94A3B8);
      textColor = Colors.white;
    } else if (seat.isLocked) {
      bgColor = AppTheme.warning.withValues(alpha: 0.3);
      textColor = AppTheme.warning;
    } else {
      // Available
      bgColor = const Color(0xFFE2E8F0);
      textColor = AppTheme.textPrimary;
    }

    return GestureDetector(
      onTap: seat.isAvailable ? () => _toggleSeat(seat.id) : null,
      child: Container(
        width: 46,
        height: 46,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: border,
        ),
        child: Center(
          child: Text(
            seat.seatNumber,
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: textColor),
          ),
        ),
      ),
    );
  }

  Widget _legend(Color color, String label) => Row(children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ]);
}
