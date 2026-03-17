class Seat {
  final String id;
  final String seatNumber;
  final int seatRow;
  final int seatColumn;
  final String seatType;
  final double priceModifier;
  final String status;

  Seat({
    required this.id,
    required this.seatNumber,
    required this.seatRow,
    required this.seatColumn,
    this.seatType = 'standard',
    this.priceModifier = 0,
    this.status = 'available',
  });

  bool get isAvailable => status == 'available';
  bool get isBooked => status == 'booked';
  bool get isLocked => status == 'locked';

  factory Seat.fromJson(Map<String, dynamic> json) => Seat(
    id: json['id'] ?? '',
    seatNumber: json['seat_number'] ?? '',
    seatRow: json['seat_row'] ?? 0,
    seatColumn: json['seat_column'] ?? 0,
    seatType: json['seat_type'] ?? 'standard',
    priceModifier: (json['price_modifier'] ?? 0).toDouble(),
    status: json['status'] ?? 'available',
  );
}

class SeatMap {
  final String tripId;
  final int totalSeats;
  final int availableSeats;
  final List<Seat> seats;

  SeatMap({required this.tripId, required this.totalSeats, required this.availableSeats, required this.seats});

  factory SeatMap.fromJson(Map<String, dynamic> json) => SeatMap(
    tripId: json['trip_id'] ?? '',
    totalSeats: json['total_seats'] ?? 0,
    availableSeats: json['available_seats'] ?? 0,
    seats: (json['seats'] as List?)?.map((s) => Seat.fromJson(s)).toList() ?? [],
  );
}
