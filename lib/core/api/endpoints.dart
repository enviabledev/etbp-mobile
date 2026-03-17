class Endpoints {
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  static const String updateProfile = '/auth/me';
  static const String terminals = '/terminals';
  static const String searchTrips = '/routes/search';
  static const String popularRoutes = '/routes/popular';
  static String tripDetail(String id) => '/trips/$id';
  static String tripSeats(String id) => '/trips/$id/seats';
  static String lockSeats(String id) => '/trips/$id/seats/lock';
  static const String bookings = '/bookings';
  static String bookingDetail(String ref) => '/bookings/$ref';
  static String cancelBooking(String ref) => '/bookings/$ref/cancel';
  static String eTicket(String ref) => '/bookings/$ref/ticket';
  static String applyPromo(String ref) => '/bookings/$ref/apply-promo';
  static const String initiatePayment = '/payments/initiate';
  static String verifyPayment(String ref) => '/payments/verify/$ref';
  static const String payWithWallet = '/payments/pay-with-wallet';
  static const String walletBalance = '/payments/wallet/balance';
  static const String walletTransactions = '/payments/wallet/transactions';
  static const String walletTopup = '/payments/wallet/topup';
  static const String support = '/support';
}
