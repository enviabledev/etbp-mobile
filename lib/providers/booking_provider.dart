import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:etbp_mobile/models/trip.dart';
import 'package:etbp_mobile/models/seat.dart';

class PassengerData {
  final String seatId;
  final String seatNumber;
  final String firstName;
  final String lastName;
  final String gender;
  final String phone;
  final bool isPrimary;

  PassengerData({
    required this.seatId,
    required this.seatNumber,
    required this.firstName,
    required this.lastName,
    this.gender = 'male',
    this.phone = '',
    this.isPrimary = false,
  });

  Map<String, dynamic> toJson() => {
        'seat_id': seatId,
        'first_name': firstName,
        'last_name': lastName,
        'gender': gender,
        'phone': phone,
        'is_primary': isPrimary,
      };
}

class BookingState {
  final TripSearchResult? trip;
  final List<Seat> selectedSeats;
  final List<PassengerData> passengers;
  final String? contactEmail;
  final String? contactPhone;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String paymentMethod;
  final String? bookingReference;
  final String? paymentUrl;
  final DateTime? lockExpiresAt;

  BookingState({
    this.trip,
    this.selectedSeats = const [],
    this.passengers = const [],
    this.contactEmail,
    this.contactPhone,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.paymentMethod = 'card',
    this.bookingReference,
    this.paymentUrl,
    this.lockExpiresAt,
  });

  BookingState copyWith({
    TripSearchResult? trip,
    List<Seat>? selectedSeats,
    List<PassengerData>? passengers,
    String? contactEmail,
    String? contactPhone,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? paymentMethod,
    String? bookingReference,
    String? paymentUrl,
    DateTime? lockExpiresAt,
  }) {
    return BookingState(
      trip: trip ?? this.trip,
      selectedSeats: selectedSeats ?? this.selectedSeats,
      passengers: passengers ?? this.passengers,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      bookingReference: bookingReference ?? this.bookingReference,
      paymentUrl: paymentUrl ?? this.paymentUrl,
      lockExpiresAt: lockExpiresAt ?? this.lockExpiresAt,
    );
  }

  double get totalAmount {
    if (trip == null) return 0;
    return selectedSeats.fold(0.0, (sum, seat) => sum + trip!.price + seat.priceModifier);
  }
}

class BookingNotifier extends StateNotifier<BookingState> {
  BookingNotifier() : super(BookingState());

  void setTrip(TripSearchResult trip) => state = state.copyWith(trip: trip);
  void setSelectedSeats(List<Seat> seats) => state = state.copyWith(selectedSeats: seats);
  void setPassengers(List<PassengerData> passengers) => state = state.copyWith(passengers: passengers);
  void setContactInfo(String email, String phone) => state = state.copyWith(contactEmail: email, contactPhone: phone);
  void setEmergencyContact(String name, String phone) => state = state.copyWith(emergencyContactName: name, emergencyContactPhone: phone);
  void setPaymentMethod(String method) => state = state.copyWith(paymentMethod: method);
  void setBookingReference(String ref) => state = state.copyWith(bookingReference: ref);
  void setPaymentUrl(String url) => state = state.copyWith(paymentUrl: url);
  void setLockExpiry(DateTime expiry) => state = state.copyWith(lockExpiresAt: expiry);
  void reset() => state = BookingState();
}

final bookingProvider = StateNotifierProvider<BookingNotifier, BookingState>(
  (ref) => BookingNotifier(),
);
