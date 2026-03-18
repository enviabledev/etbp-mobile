import 'package:flutter/material.dart';
import 'package:add_2_calendar/add_2_calendar.dart';

class AddToCalendarButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        final event = Event(
          title: title,
          description: description,
          location: location,
          startDate: startTime,
          endDate: endTime,
          iosParams: const IOSParams(reminder: Duration(hours: 1)),
          androidParams: const AndroidParams(emailInvites: []),
        );
        Add2Calendar.addEvent2Cal(event);
      },
      icon: const Icon(Icons.calendar_today, size: 18),
      label: const Text('Add to Calendar'),
    );
  }
}
