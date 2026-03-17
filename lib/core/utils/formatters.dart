import 'package:intl/intl.dart';
import 'package:etbp_mobile/config/constants.dart';

String formatCurrency(num amount, {String? currency}) {
  final symbol = currency == 'USD' ? '\$' : AppConstants.currencySymbol;
  final formatter = NumberFormat('#,##0', 'en_NG');
  return '$symbol${formatter.format(amount)}';
}

String formatDate(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return '—';
  try {
    final date = DateTime.parse(dateStr.contains('T') ? dateStr : '${dateStr}T00:00:00');
    return DateFormat('d MMM yyyy').format(date);
  } catch (_) {
    return '—';
  }
}

String formatTime(String? timeStr) {
  if (timeStr == null || timeStr.isEmpty) return '—';
  try {
    if (timeStr.contains('T')) {
      final dt = DateTime.parse(timeStr);
      return DateFormat('h:mm a').format(dt);
    }
    final parts = timeStr.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts[1];
    final ampm = hour >= 12 ? 'PM' : 'AM';
    final h12 = hour % 12 == 0 ? 12 : hour % 12;
    return '$h12:$minute $ampm';
  } catch (_) {
    return timeStr;
  }
}

String formatDuration(int? minutes) {
  if (minutes == null || minutes == 0) return '—';
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h == 0) return '${m}m';
  if (m == 0) return '${h}h';
  return '${h}h ${m}m';
}
