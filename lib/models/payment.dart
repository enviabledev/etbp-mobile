class Payment {
  final String id;
  final double amount;
  final String currency;
  final String method;
  final String status;
  final String? gateway;
  final String? gatewayReference;
  final String? paidAt;
  final String createdAt;

  Payment({
    required this.id,
    required this.amount,
    this.currency = 'NGN',
    required this.method,
    this.status = 'pending',
    this.gateway,
    this.gatewayReference,
    this.paidAt,
    this.createdAt = '',
  });

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
    id: json['id'] ?? '',
    amount: (json['amount'] ?? 0).toDouble(),
    currency: json['currency'] ?? 'NGN',
    method: json['method'] ?? '',
    status: json['status'] ?? 'pending',
    gateway: json['gateway'],
    gatewayReference: json['gateway_reference'],
    paidAt: json['paid_at'],
    createdAt: json['created_at'] ?? '',
  );
}

class PaymentInitResponse {
  final String paymentId;
  final String authorizationUrl;
  final String reference;

  PaymentInitResponse({required this.paymentId, required this.authorizationUrl, required this.reference});

  factory PaymentInitResponse.fromJson(Map<String, dynamic> json) => PaymentInitResponse(
    paymentId: json['payment_id'] ?? '',
    authorizationUrl: json['authorization_url'] ?? '',
    reference: json['reference'] ?? '',
  );
}
