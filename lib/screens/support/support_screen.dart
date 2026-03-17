import 'package:flutter/material.dart';
import 'package:etbp_mobile/config/theme.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Frequently Asked Questions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _faqItem('How do I book a trip?',
              'Search for your desired route on the home screen, select a trip, choose your seats, and proceed to payment.'),
          _faqItem('What is the cancellation policy?',
              'More than 24h: 90% refund. 12-24h: 50% refund. Less than 12h: no refund.'),
          _faqItem('What payment methods are accepted?',
              'We accept card payments (Visa, Mastercard), bank transfers, and wallet payments.'),
          _faqItem('How much luggage can I bring?',
              'Each passenger is allowed one piece of luggage (up to 23kg) and one carry-on bag.'),
        ],
      ),
    );
  }

  Widget _faqItem(String q, String a) => ExpansionTile(
        title: Text(q,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Text(a,
              style:
                  const TextStyle(color: AppTheme.textSecondary, fontSize: 13))
        ],
      );
}
