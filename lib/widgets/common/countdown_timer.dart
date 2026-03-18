import 'dart:async';
import 'package:flutter/material.dart';
import 'package:etbp_mobile/config/theme.dart';

/// Full banner countdown for booking detail screens
class PaymentDeadlineBanner extends StatefulWidget {
  final DateTime deadline;
  final String? terminalName;
  final VoidCallback? onExpired;

  const PaymentDeadlineBanner({
    super.key,
    required this.deadline,
    this.terminalName,
    this.onExpired,
  });

  @override
  State<PaymentDeadlineBanner> createState() => _PaymentDeadlineBannerState();
}

class _PaymentDeadlineBannerState extends State<PaymentDeadlineBanner> {
  Timer? _timer;
  Duration _remaining = Duration.zero;
  bool _expired = false;

  @override
  void initState() {
    super.initState();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final diff = widget.deadline.difference(DateTime.now());
    if (diff.isNegative) {
      setState(() {
        _remaining = Duration.zero;
        _expired = true;
      });
      _timer?.cancel();
      widget.onExpired?.call();
    } else {
      setState(() => _remaining = diff);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool get _isUrgent => !_expired && _remaining.inMinutes < 30;
  bool get _isCritical => !_expired && _remaining.inMinutes < 5;

  String get _formattedTime {
    if (_expired) return '';
    final h = _remaining.inHours;
    final m = _remaining.inMinutes.remainder(60);
    final s = _remaining.inSeconds.remainder(60);
    if (h > 0) return '${h}h ${m}m ${s}s remaining';
    if (m > 0) return '${m}m ${s}s remaining';
    return '${s}s remaining';
  }

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color textColor;
    final String title;
    final IconData icon;

    if (_expired) {
      bg = Colors.grey[200]!;
      textColor = Colors.grey[700]!;
      title = 'This booking has expired';
      icon = Icons.timer_off;
    } else if (_isUrgent) {
      bg = AppTheme.error.withValues(alpha: 0.1);
      textColor = AppTheme.error;
      title = _isCritical ? 'Hurry! Your booking expires soon' : 'Pay at terminal before your booking expires';
      icon = Icons.warning_amber;
    } else {
      bg = AppTheme.warning.withValues(alpha: 0.12);
      textColor = const Color(0xFF92400E); // amber-800
      title = 'Pay at terminal before your booking expires';
      icon = Icons.access_time;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: textColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
                ),
              ),
            ],
          ),
          if (!_expired) ...[
            const SizedBox(height: 8),
            AnimatedOpacity(
              opacity: _isCritical ? (_remaining.inSeconds.isOdd ? 0.4 : 1.0) : 1.0,
              duration: const Duration(milliseconds: 500),
              child: Text(
                _formattedTime,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor, fontFeatures: const [FontFeature.tabularFigures()]),
              ),
            ),
          ],
          if (widget.terminalName != null && !_expired) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 14, color: textColor.withValues(alpha: 0.7)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Pay at ${widget.terminalName}',
                    style: TextStyle(fontSize: 13, color: textColor.withValues(alpha: 0.7)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Compact countdown badge for trip list cards
class PaymentDeadlineBadge extends StatefulWidget {
  final DateTime deadline;

  const PaymentDeadlineBadge({super.key, required this.deadline});

  @override
  State<PaymentDeadlineBadge> createState() => _PaymentDeadlineBadgeState();
}

class _PaymentDeadlineBadgeState extends State<PaymentDeadlineBadge> {
  Timer? _timer;
  Duration _remaining = Duration.zero;
  bool _expired = false;

  @override
  void initState() {
    super.initState();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _tick());
  }

  void _tick() {
    final diff = widget.deadline.difference(DateTime.now());
    setState(() {
      if (diff.isNegative) {
        _remaining = Duration.zero;
        _expired = true;
        _timer?.cancel();
      } else {
        _remaining = diff;
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUrgent = !_expired && _remaining.inMinutes < 30;
    final color = _expired ? Colors.grey : isUrgent ? AppTheme.error : AppTheme.warning;

    String text;
    if (_expired) {
      text = 'Expired';
    } else {
      final h = _remaining.inHours;
      final m = _remaining.inMinutes.remainder(60);
      text = h > 0 ? 'Expires in ${h}h ${m}m' : 'Expires in ${m}m';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}
