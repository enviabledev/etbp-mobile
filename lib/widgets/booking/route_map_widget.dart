import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:etbp_mobile/config/theme.dart';

class RouteMapWidget extends StatelessWidget {
  final double originLat;
  final double originLng;
  final String originName;
  final double destLat;
  final double destLng;
  final String destName;
  final List<MapStop> stops;
  final double? distanceKm;
  final int? durationMinutes;

  const RouteMapWidget({
    super.key,
    required this.originLat,
    required this.originLng,
    required this.originName,
    required this.destLat,
    required this.destLng,
    required this.destName,
    this.stops = const [],
    this.distanceKm,
    this.durationMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final points = [
      LatLng(originLat, originLng),
      ...stops.map((s) => LatLng(s.lat, s.lng)),
      LatLng(destLat, destLng),
    ];

    final bounds = LatLngBounds.fromPoints(points);

    String info = '';
    if (distanceKm != null) info += '${distanceKm!.round()} km';
    if (durationMinutes != null) {
      if (info.isNotEmpty) info += ' · ';
      final h = durationMinutes! ~/ 60;
      final m = durationMinutes! % 60;
      info += '~${h}h${m > 0 ? ' ${m}m' : ''}';
    }
    if (stops.isNotEmpty) {
      if (info.isNotEmpty) info += ' · ';
      info += '${stops.length} stop${stops.length > 1 ? 's' : ''}';
    }

    return Column(children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 220,
          child: FlutterMap(
            options: MapOptions(
              initialCameraFit: CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(40)),
              interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
            ),
            children: [
              TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.enviabletransport.etbp_mobile'),
              MarkerLayer(markers: [
                Marker(point: LatLng(originLat, originLng), width: 30, height: 30,
                  child: const Icon(Icons.location_on, color: Colors.blue, size: 30)),
                Marker(point: LatLng(destLat, destLng), width: 30, height: 30,
                  child: const Icon(Icons.location_on, color: Colors.red, size: 30)),
                ...stops.map((s) => Marker(point: LatLng(s.lat, s.lng), width: 16, height: 16,
                  child: Container(width: 12, height: 12, decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle)))),
              ]),
              PolylineLayer(polylines: [
                Polyline(points: points, strokeWidth: 3, color: AppTheme.primary),
              ]),
            ],
          ),
        ),
      ),
      if (info.isNotEmpty)
        Padding(padding: const EdgeInsets.only(top: 8), child: Text(info, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary))),
    ]);
  }
}

class MapStop {
  final double lat;
  final double lng;
  final String name;
  const MapStop({required this.lat, required this.lng, required this.name});
}
