import 'package:flutter/material.dart';
import 'package:add_2_calendar/add_2_calendar.dart';

class AddToCalendarButton extends StatefulWidget {
  final String title;
  final String description;
  final String location;
  final DateTime startTime;
  final DateTime endTime;

  const AddToCalendarButton({
    super.key,
    required this.title,
    required this.description,
    required this.location,
    required this.startTime,
    required this.endTime,
  });

  @override
  State<AddToCalendarButton> createState() => _AddToCalendarButtonState();
}

class _AddToCalendarButtonState extends State<AddToCalendarButton> {
  bool _added = false;

  Future<void> _addToCalendar() async {
    final event = Event(
      title: widget.title,
      description: widget.description,
      location: widget.location,
      startDate: widget.startTime,
      endDate: widget.endTime,
      iosParams: const IOSParams(reminder: Duration(hours: 1)),
      androidParams: const AndroidParams(emailInvites: []),
    );

    try {
      Add2Calendar.addEvent2Cal(event);
      if (mounted) {
        setState(() => _added = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Opening calendar...')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open calendar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: _addToCalendar,
      icon: Icon(_added ? Icons.check : Icons.calendar_today, size: 18),
      label: Text(_added ? 'Added to Calendar' : 'Add to Calendar'),
      style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
    );
  }
}
