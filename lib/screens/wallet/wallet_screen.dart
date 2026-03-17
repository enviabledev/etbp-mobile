import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:etbp_mobile/config/theme.dart';
import 'package:etbp_mobile/core/auth/auth_provider.dart';
import 'package:etbp_mobile/core/api/endpoints.dart';
import 'package:etbp_mobile/core/utils/formatters.dart';
import 'package:etbp_mobile/models/wallet.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});
  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  Wallet? _wallet;
  List<WalletTransaction> _transactions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final api = ref.read(apiClientProvider);
      final walletRes = await api.get(Endpoints.walletBalance);
      final txRes = await api.get(Endpoints.walletTransactions);
      setState(() {
        _wallet = Wallet.fromJson(walletRes.data);
        _transactions = (txRes.data is List ? txRes.data : []).map<WalletTransaction>((t) => WalletTransaction.fromJson(t)).toList();
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: const Text('Wallet')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Balance card
          Container(
            width: double.infinity, padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.primaryDark]), borderRadius: BorderRadius.circular(16)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Available Balance', style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 8),
              Text(formatCurrency(_wallet?.balance ?? 0), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            ]),
          ),
          const SizedBox(height: 24),
          const Align(alignment: Alignment.centerLeft, child: Text('Transactions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
          const SizedBox(height: 12),
          if (_transactions.isEmpty) const Padding(padding: EdgeInsets.all(32), child: Text('No transactions yet', style: TextStyle(color: AppTheme.textSecondary)))
          else ..._transactions.map((tx) => ListTile(
            leading: CircleAvatar(backgroundColor: tx.isCredit ? AppTheme.success.withValues(alpha: 0.1) : AppTheme.error.withValues(alpha: 0.1),
              child: Icon(tx.isCredit ? Icons.arrow_downward : Icons.arrow_upward, color: tx.isCredit ? AppTheme.success : AppTheme.error, size: 18)),
            title: Text(tx.description ?? (tx.isCredit ? 'Top Up' : 'Payment'), style: const TextStyle(fontSize: 14)),
            subtitle: Text(formatDate(tx.createdAt), style: const TextStyle(fontSize: 12)),
            trailing: Text('${tx.isCredit ? '+' : '-'}${formatCurrency(tx.amount)}', style: TextStyle(fontWeight: FontWeight.w600, color: tx.isCredit ? AppTheme.success : AppTheme.error)),
          )),
        ]),
      ),
    );
  }
}
