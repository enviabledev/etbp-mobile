class Wallet {
  final String id;
  final double balance;
  final String currency;
  final bool isActive;

  Wallet({required this.id, this.balance = 0, this.currency = 'NGN', this.isActive = true});

  factory Wallet.fromJson(Map<String, dynamic> json) => Wallet(
    id: json['id'] ?? '',
    balance: (json['balance'] ?? 0).toDouble(),
    currency: json['currency'] ?? 'NGN',
    isActive: json['is_active'] ?? true,
  );
}

class WalletTransaction {
  final String id;
  final String type;
  final double amount;
  final double balanceAfter;
  final String? reference;
  final String? description;
  final String createdAt;

  WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    this.balanceAfter = 0,
    this.reference,
    this.description,
    this.createdAt = '',
  });

  bool get isCredit => type == 'credit' || type == 'top_up';

  factory WalletTransaction.fromJson(Map<String, dynamic> json) => WalletTransaction(
    id: json['id'] ?? '',
    type: json['type'] ?? '',
    amount: (json['amount'] ?? 0).toDouble(),
    balanceAfter: (json['balance_after'] ?? 0).toDouble(),
    reference: json['reference'],
    description: json['description'],
    createdAt: json['created_at'] ?? '',
  );
}
