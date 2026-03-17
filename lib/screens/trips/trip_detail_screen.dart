import 'package:flutter/material.dart';

class TripDetailScreen extends StatelessWidget {
  final String ref;
  const TripDetailScreen({super.key, required this.ref});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text('Booking $ref')), body: const Center(child: Text('Booking detail — coming soon')));
}
