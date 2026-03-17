import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
    setState(() => _loading = true);
    try {
      final api = ref.read(apiClientProvider);
      final walletRes = await api.get(Endpoints.walletBalance);
      final txRes = await api.get(Endpoints.walletTransactions);
      setState(() {
        _wallet = Wallet.fromJson(walletRes.data);
        _transactions = (txRes.data is List ? txRes.data : [])
            .map<WalletTransaction>((t) => WalletTransaction.fromJson(t))
            .toList();
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  void _showTopUp() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _TopUpSheet(
        onSuccess: () {
          Navigator.pop(context);
          _load();
        },
        api: ref.read(apiClientProvider),
        goRouter: GoRouter.of(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Wallet')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Balance card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.primaryDark]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Available Balance', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 8),
                    Text(formatCurrency(_wallet?.balance ?? 0),
                        style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _showTopUp,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Top Up'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        minimumSize: const Size(0, 40),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Transactions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 12),
              if (_transactions.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('No transactions yet', style: TextStyle(color: AppTheme.textSecondary)),
                )
              else
                ..._transactions.map((tx) => ListTile(
                      leading: CircleAvatar(
                        backgroundColor: tx.isCredit
                            ? AppTheme.success.withValues(alpha: 0.1)
                            : AppTheme.error.withValues(alpha: 0.1),
                        child: Icon(
                          tx.isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                          color: tx.isCredit ? AppTheme.success : AppTheme.error,
                          size: 18,
                        ),
                      ),
                      title: Text(tx.description ?? (tx.isCredit ? 'Top Up' : 'Payment'),
                          style: const TextStyle(fontSize: 14)),
                      subtitle: Text(formatDate(tx.createdAt), style: const TextStyle(fontSize: 12)),
                      trailing: Text(
                        '${tx.isCredit ? '+' : '-'}${formatCurrency(tx.amount)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: tx.isCredit ? AppTheme.success : AppTheme.error,
                        ),
                      ),
                    )),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Top-Up Bottom Sheet ──

class _TopUpSheet extends StatefulWidget {
  final VoidCallback onSuccess;
  final dynamic api;
  final GoRouter goRouter;

  const _TopUpSheet({required this.onSuccess, required this.api, required this.goRouter});

  @override
  State<_TopUpSheet> createState() => _TopUpSheetState();
}

class _TopUpSheetState extends State<_TopUpSheet> {
  final _amountC = TextEditingController();
  bool _agreed = false;
  bool _processing = false;
  final _presets = [1000, 2000, 5000, 10000, 20000, 50000];

  int get _amount => int.tryParse(_amountC.text) ?? 0;

  Future<void> _topUp() async {
    if (_amount < 100 || !_agreed) return;
    setState(() => _processing = true);
    try {
      final response = await widget.api.post(Endpoints.walletTopup, data: {
        'amount': _amount,
        'callback_url': 'https://app.enviabletransport.ng/wallet?topup=success',
      });
      final authUrl = (response.data['authorization_url'] ?? '') as String;
      if (authUrl.isNotEmpty && mounted) {
        Navigator.pop(context);
        widget.goRouter.push('/booking/payment?url=${Uri.encodeComponent(authUrl)}&ref=wallet-topup');
      } else {
        widget.onSuccess();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  void dispose() {
    _amountC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 16),
            const Text('Top Up Wallet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // No-refund warning
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.warning.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded, color: AppTheme.warning, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Non-Refundable',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.warning)),
                        const SizedBox(height: 4),
                        Text(
                          'Wallet top-ups cannot be withdrawn or refunded. Funds can only be used for bookings.',
                          style: TextStyle(fontSize: 12, color: Colors.amber.shade900),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Checkbox
            InkWell(
              onTap: () => setState(() => _agreed = !_agreed),
              child: Row(
                children: [
                  Checkbox(
                    value: _agreed,
                    onChanged: (v) => setState(() => _agreed = v ?? false),
                    activeColor: AppTheme.primary,
                  ),
                  const Expanded(
                    child: Text('I understand that wallet top-ups are non-refundable',
                        style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Amount input
            TextField(
              controller: _amountC,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixText: '₦ ',
                prefixStyle: const TextStyle(fontWeight: FontWeight.w600),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),

            // Preset chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _presets.map((p) {
                final selected = _amountC.text == p.toString();
                return ChoiceChip(
                  label: Text(formatCurrency(p)),
                  selected: selected,
                  selectedColor: AppTheme.primary.withValues(alpha: 0.15),
                  labelStyle: TextStyle(
                    color: selected ? AppTheme.primary : AppTheme.textPrimary,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 13,
                  ),
                  onSelected: (_) {
                    _amountC.text = p.toString();
                    setState(() {});
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Confirm button
            ElevatedButton(
              onPressed: (_amount >= 100 && _agreed && !_processing) ? _topUp : null,
              child: _processing
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(_amount >= 100 ? 'Top Up ${formatCurrency(_amount)}' : 'Top Up'),
            ),
          ],
        ),
      ),
    );
  }
}
