import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:etbp_mobile/config/theme.dart';
import 'package:etbp_mobile/core/auth/auth_provider.dart';
import 'package:etbp_mobile/core/api/endpoints.dart';
import 'package:etbp_mobile/core/utils/formatters.dart';
import 'package:etbp_mobile/models/booking.dart';

class MyTripsScreen extends ConsumerStatefulWidget {
  const MyTripsScreen({super.key});
  @override
  ConsumerState<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends ConsumerState<MyTripsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Booking> _upcoming = [];
  List<Booking> _past = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final api = ref.read(apiClientProvider);
      final upRes = await api.get(Endpoints.bookings, queryParameters: {'upcoming': 'true'});
      final pastRes = await api.get(Endpoints.bookings, queryParameters: {'upcoming': 'false'});
      final upItems = upRes.data['items'] ?? upRes.data;
      final pastItems = pastRes.data['items'] ?? pastRes.data;
      setState(() {
        _upcoming = (upItems as List).map<Booking>((b) => Booking.fromJson(b)).toList();
        _past = (pastItems as List).map<Booking>((b) => Booking.fromJson(b)).toList();
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Trips'), bottom: TabBar(controller: _tabController, tabs: const [Tab(text: 'Upcoming'), Tab(text: 'Past')])),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(controller: _tabController, children: [_buildList(_upcoming), _buildList(_past)]),
    );
  }

  Widget _buildList(List<Booking> bookings) {
    if (bookings.isEmpty) return const Center(child: Text('No trips', style: TextStyle(color: AppTheme.textSecondary)));
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(16), itemCount: bookings.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final b = bookings[i];
          return InkWell(
            onTap: () => context.push('/my-trips/${b.ref}'),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.border)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(b.trip?.route?.name ?? '${b.trip?.route?.originTerminal?.city ?? '—'} → ${b.trip?.route?.destinationTerminal?.city ?? '—'}', style: const TextStyle(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  const Spacer(),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: b.status == 'confirmed' ? AppTheme.success.withValues(alpha: 0.1) : Colors.amber.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                    child: Text(b.status, style: TextStyle(fontSize: 11, color: b.status == 'confirmed' ? AppTheme.success : AppTheme.warning)),
                  ),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Text(b.trip != null ? formatDate(b.trip!.departureDate) : '—', style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                  const SizedBox(width: 16),
                  Text(formatCurrency(b.totalAmount), style: const TextStyle(fontWeight: FontWeight.bold)),
                ]),
              ]),
            ),
          );
        },
      ),
    );
  }
}
