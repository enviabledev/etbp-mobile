import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:etbp_mobile/config/constants.dart';
import 'package:etbp_mobile/config/theme.dart';
import 'package:etbp_mobile/core/api/endpoints.dart';
import 'package:etbp_mobile/core/auth/auth_provider.dart';
import 'package:etbp_mobile/core/utils/formatters.dart';
import 'package:etbp_mobile/models/route.dart';
import 'package:etbp_mobile/widgets/home/terminal_autocomplete.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _origin = '';
  String _destination = '';
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  int _passengers = 1;
  List<PopularRoute> _popularRoutes = [];

  @override
  void initState() {
    super.initState();
    _loadPopularRoutes();
  }

  Future<void> _loadPopularRoutes() async {
    try {
      final api = ref.read(apiClientProvider);
      final response = await api.get(Endpoints.popularRoutes);
      final data = response.data is List ? response.data : (response.data['results'] ?? response.data);
      if (data is List) {
        setState(() => _popularRoutes = data.map<PopularRoute>((r) => PopularRoute.fromJson(r)).toList());
      }
    } catch (_) {}
  }

  void _search() {
    if (_origin.isEmpty || _destination.isEmpty) return;
    final dateStr = '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}';
    context.push('/search?origin=$_origin&destination=$_destination&date=$dateStr&passengers=$_passengers');
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Icon(Icons.directions_bus, color: AppTheme.primary, size: 28),
                    const SizedBox(width: 8),
                    const Text(AppConstants.appName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    if (user != null) Text('Hi, ${user.firstName ?? ''}', style: const TextStyle(color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Search card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.border)),
                child: Column(
                  children: [
                    TerminalAutocomplete(
                      api: ref.read(apiClientProvider),
                      label: 'From',
                      icon: Icons.my_location,
                      onSelected: (v) => _origin = v,
                    ),
                    const SizedBox(height: 12),
                    TerminalAutocomplete(
                      api: ref.read(apiClientProvider),
                      label: 'To',
                      icon: Icons.location_on,
                      onSelected: (v) => _destination = v,
                    ),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 90)));
                            if (picked != null) setState(() => _date = picked);
                          },
                          child: InputDecorator(decoration: const InputDecoration(labelText: 'Date', prefixIcon: Icon(Icons.calendar_today, size: 20)), child: Text(formatDate(_date.toIso8601String().split('T')[0]))),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 100,
                        child: DropdownButtonFormField<int>(
                          initialValue: _passengers,
                          decoration: const InputDecoration(labelText: 'Passengers'),
                          items: List.generate(10, (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1}'))),
                          onChanged: (v) => setState(() => _passengers = v ?? 1),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: _search, child: const Text('Search Trips')),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Popular routes
              if (_popularRoutes.isNotEmpty) ...[
                const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text('Popular Routes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                const SizedBox(height: 12),
                SizedBox(
                  height: 120,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _popularRoutes.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, i) {
                      final pr = _popularRoutes[i];
                      return Container(
                        width: 200,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.border)),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('${pr.route.originTerminal.city} → ${pr.route.destinationTerminal.city}', style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text(pr.route.name, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                          Text('${pr.bookingCount} bookings', style: const TextStyle(fontSize: 12, color: AppTheme.primary)),
                        ]),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
