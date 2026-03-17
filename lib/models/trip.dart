import 'route.dart';

class TripSearchResult {
  final String id;
  final TripRoute route;
  final VehicleType? vehicleType;
  final String departureDate;
  final String departureTime;
  final String status;
  final double price;
  final int availableSeats;
  final int totalSeats;
  final int? estimatedDurationMinutes;

  TripSearchResult({
    required this.id,
    required this.route,
    this.vehicleType,
    required this.departureDate,
    required this.departureTime,
    this.status = 'scheduled',
    required this.price,
    this.availableSeats = 0,
    this.totalSeats = 0,
    this.estimatedDurationMinutes,
  });

  factory TripSearchResult.fromJson(Map<String, dynamic> json) => TripSearchResult(
    id: json['id'] ?? '',
    route: TripRoute.fromJson(json['route'] ?? {}),
    vehicleType: json['vehicle_type'] != null ? VehicleType.fromJson(json['vehicle_type']) : null,
    departureDate: json['departure_date'] ?? '',
    departureTime: json['departure_time'] ?? '',
    status: json['status'] ?? 'scheduled',
    price: (json['price'] ?? 0).toDouble(),
    availableSeats: json['available_seats'] ?? 0,
    totalSeats: json['total_seats'] ?? 0,
    estimatedDurationMinutes: json['estimated_duration_minutes'],
  );
}
