import 'terminal.dart';

class TripRoute {
  final String? id;
  final String name;
  final String code;
  final Terminal originTerminal;
  final Terminal destinationTerminal;

  TripRoute({this.id, required this.name, required this.code, required this.originTerminal, required this.destinationTerminal});

  factory TripRoute.fromJson(Map<String, dynamic> json) => TripRoute(
    id: json['id'],
    name: json['name'] ?? '',
    code: json['code'] ?? '',
    originTerminal: Terminal.fromJson(json['origin_terminal'] ?? {}),
    destinationTerminal: Terminal.fromJson(json['destination_terminal'] ?? {}),
  );
}

class VehicleType {
  final String? id;
  final String name;
  final int seatCapacity;
  final Map<String, dynamic>? amenities;

  VehicleType({this.id, required this.name, this.seatCapacity = 0, this.amenities});

  factory VehicleType.fromJson(Map<String, dynamic> json) => VehicleType(
    id: json['id'],
    name: json['name'] ?? '',
    seatCapacity: json['seat_capacity'] ?? 0,
    amenities: json['amenities'],
  );
}

class PopularRoute {
  final TripRoute route;
  final int bookingCount;

  PopularRoute({required this.route, required this.bookingCount});

  factory PopularRoute.fromJson(Map<String, dynamic> json) => PopularRoute(
    route: TripRoute.fromJson(json['route'] ?? {}),
    bookingCount: json['booking_count'] ?? 0,
  );
}
