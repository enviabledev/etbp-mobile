class Booking {
  final String id;
  final String reference;
  final String? bookingReference;
  final String tripId;
  final String status;
  final double totalAmount;
  final String currency;
  final int passengerCount;
  final String? contactEmail;
  final String? contactPhone;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String createdAt;
  final BookingTrip? trip;
  final List<BookingPassenger> passengers;
  final String? promoCode;
  final double promoDiscount;
  final String? paymentMethod;
  final String? paymentMethodHint;
  final String? paymentDeadline;
  final String? cancellationReason;
  final String? cancelledAt;

  Booking({
    required this.id,
    required this.reference,
    this.bookingReference,
    required this.tripId,
    this.status = 'pending',
    required this.totalAmount,
    this.currency = 'NGN',
    this.passengerCount = 1,
    this.contactEmail,
    this.contactPhone,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.createdAt = '',
    this.trip,
    this.passengers = const [],
    this.promoCode,
    this.promoDiscount = 0,
    this.paymentMethod,
    this.paymentMethodHint,
    this.paymentDeadline,
    this.cancellationReason,
    this.cancelledAt,
  });

  String get ref => bookingReference ?? reference;

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
    id: json['id'] ?? '',
    reference: json['reference'] ?? '',
    bookingReference: json['booking_reference'],
    tripId: json['trip_id'] ?? '',
    status: json['status'] ?? 'pending',
    totalAmount: (json['total_amount'] ?? 0).toDouble(),
    currency: json['currency'] ?? 'NGN',
    passengerCount: json['passenger_count'] ?? 1,
    contactEmail: json['contact_email'],
    contactPhone: json['contact_phone'],
    emergencyContactName: json['emergency_contact_name'],
    emergencyContactPhone: json['emergency_contact_phone'],
    createdAt: json['created_at'] ?? '',
    trip: json['trip'] != null ? BookingTrip.fromJson(json['trip']) : null,
    passengers: (json['passengers'] as List?)?.map((p) => BookingPassenger.fromJson(p)).toList() ?? [],
    promoCode: json['promo_code'],
    promoDiscount: (json['promo_discount'] ?? 0).toDouble(),
    paymentMethod: json['payment_method'],
    paymentMethodHint: json['payment_method_hint'],
    paymentDeadline: json['payment_deadline'],
    cancellationReason: json['cancellation_reason'],
    cancelledAt: json['cancelled_at'],
  );
}

class BookingTrip {
  final String id;
  final String departureDate;
  final String departureTime;
  final String status;
  final double price;
  final BookingRoute? route;

  BookingTrip({required this.id, required this.departureDate, required this.departureTime, this.status = '', required this.price, this.route});

  factory BookingTrip.fromJson(Map<String, dynamic> json) => BookingTrip(
    id: json['id'] ?? '',
    departureDate: json['departure_date'] ?? '',
    departureTime: json['departure_time'] ?? '',
    status: json['status'] ?? '',
    price: (json['price'] ?? 0).toDouble(),
    route: json['route'] != null ? BookingRoute.fromJson(json['route']) : null,
  );
}

class BookingRoute {
  final String name;
  final BookingTerminal? originTerminal;
  final BookingTerminal? destinationTerminal;

  BookingRoute({required this.name, this.originTerminal, this.destinationTerminal});

  factory BookingRoute.fromJson(Map<String, dynamic> json) => BookingRoute(
    name: json['name'] ?? '',
    originTerminal: json['origin_terminal'] != null ? BookingTerminal.fromJson(json['origin_terminal']) : null,
    destinationTerminal: json['destination_terminal'] != null ? BookingTerminal.fromJson(json['destination_terminal']) : null,
  );
}

class BookingTerminal {
  final String city;
  final String name;

  BookingTerminal({required this.city, this.name = ''});

  factory BookingTerminal.fromJson(Map<String, dynamic> json) => BookingTerminal(
    city: json['city'] ?? '',
    name: json['name'] ?? '',
  );
}

class BookingPassenger {
  final String id;
  final String firstName;
  final String lastName;
  final String? gender;
  final String? phone;
  final bool isPrimary;
  final bool checkedIn;
  final String? seatNumber;
  final String? seatType;
  final String? qrCodeData;

  BookingPassenger({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.gender,
    this.phone,
    this.isPrimary = false,
    this.checkedIn = false,
    this.seatNumber,
    this.seatType,
    this.qrCodeData,
  });

  String get fullName => '$firstName $lastName';

  factory BookingPassenger.fromJson(Map<String, dynamic> json) => BookingPassenger(
    id: json['id'] ?? '',
    firstName: json['first_name'] ?? '',
    lastName: json['last_name'] ?? '',
    gender: json['gender'],
    phone: json['phone'],
    isPrimary: json['is_primary'] ?? false,
    checkedIn: json['checked_in'] ?? false,
    seatNumber: json['seat_number'],
    seatType: json['seat_type'],
    qrCodeData: json['qr_code_data'],
  );
}
