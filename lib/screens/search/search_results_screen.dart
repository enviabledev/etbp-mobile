import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:etbp_mobile/config/theme.dart';
import 'package:etbp_mobile/core/api/endpoints.dart';
import 'package:etbp_mobile/core/auth/auth_provider.dart';
import 'package:etbp_mobile/core/utils/formatters.dart';
import 'package:etbp_mobile/models/trip.dart';

class SearchResultsScreen extends ConsumerStatefulWidget {
  final String origin, destination, date, passengers;
  const SearchResultsScreen({super.key, required this.origin, required this.destination, required this.date, required this.passengers});
  @override
  ConsumerState<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends ConsumerState<SearchResultsScreen> {
  List<TripSearchResult> _trips = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _search();
  }

  Future<void> _search() async {
    setState(() { _loading = true; _error = null; });
    try {
      final api = ref.read(apiClientProvider);
      final response = await api.get(Endpoints.searchTrips, queryParameters: {
        'origin': widget.origin, 'destination': widget.destination, 'date': widget.date, 'passengers': widget.passengers,
      });
      final data = response.data is List ? response.data : (response.data?['results'] ?? []);
      setState(() { _trips = (data as List).map<TripSearchResult>((t) => TripSearchResult.fromJson(t)).toList(); _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.origin} → ${widget.destination}')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text(_error!, style: const TextStyle(color: AppTheme.error)), TextButton(onPressed: _search, child: const Text('Retry'))]))
              : _trips.isEmpty
                  ? const Center(child: Text('No trips found', style: TextStyle(color: AppTheme.textSecondary)))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _trips.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final t = _trips[i];
                        return InkWell(
                          onTap: () => context.push('/trips/${t.id}'),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.border)),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Row(children: [
                                Text(formatTime(t.departureTime), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 8),
                                if (t.estimatedDurationMinutes != null) Text(formatDuration(t.estimatedDurationMinutes), style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                                const Spacer(),
                                Text(formatCurrency(t.price), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              ]),
                              const SizedBox(height: 8),
                              Text(t.route.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                              const SizedBox(height: 4),
                              Row(children: [
                                if (t.vehicleType != null) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Text(t.vehicleType!.name, style: const TextStyle(fontSize: 12, color: AppTheme.primary))),
                                const Spacer(),
                                Text('${t.availableSeats} seats left', style: TextStyle(fontSize: 12, color: t.availableSeats < 5 ? AppTheme.warning : AppTheme.textSecondary)),
                              ]),
                            ]),
                          ),
                        );
                      },
                    ),
    );
  }
}
