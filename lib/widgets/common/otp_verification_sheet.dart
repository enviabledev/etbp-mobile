import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:etbp_mobile/config/theme.dart';
import 'package:etbp_mobile/core/auth/auth_provider.dart';
import 'package:etbp_mobile/core/api/endpoints.dart';

/// Shows the OTP verification bottom sheet. Returns true if verified.
Future<bool> showOTPVerification(
  BuildContext context,
  WidgetRef ref,
  String phoneNumber,
) async {
  return await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => _OTPSheet(phone: phoneNumber, ref: ref),
      ) ??
      false;
}

class _OTPSheet extends StatefulWidget {
  final String phone;
  final WidgetRef ref;

  const _OTPSheet({required this.phone, required this.ref});

  @override
  State<_OTPSheet> createState() => _OTPSheetState();
}

class _OTPSheetState extends State<_OTPSheet> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  String _error = '';
  bool _sending = false;
  bool _verifying = false;
  int _cooldown = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _sendOTP();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  Future<void> _sendOTP() async {
    setState(() {
      _sending = true;
      _error = '';
    });
    try {
      final api = widget.ref.read(apiClientProvider);
      await api.post(Endpoints.sendOTP, data: {'phone_number': widget.phone});
      setState(() {
        _cooldown = 60;
        _sending = false;
      });
      _startCooldown();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _sending = false;
      });
    }
  }

  void _startCooldown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_cooldown <= 0) {
        _timer?.cancel();
      } else {
        setState(() => _cooldown--);
      }
    });
  }

  Future<void> _verify() async {
    final pin = _controllers.map((c) => c.text).join();
    if (pin.length != 6) {
      setState(() => _error = 'Please enter all 6 digits');
      return;
    }

    setState(() {
      _verifying = true;
      _error = '';
    });
    try {
      final api = widget.ref.read(apiClientProvider);
      await api.post(Endpoints.verifyOTP, data: {
        'phone_number': widget.phone,
        'pin': pin,
      });
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _error = 'Invalid OTP. Please try again.';
        _verifying = false;
      });
      _clearInputs();
    }
  }

  void _clearInputs() {
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes[0].requestFocus();
  }

  void _onDigitChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    // Auto-verify when all 6 digits entered
    if (_controllers.every((c) => c.text.length == 1)) {
      _verify();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          const Icon(Icons.shield, size: 32, color: AppTheme.primary),
          const SizedBox(height: 12),
          const Text('Verify Phone Number',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            _sending
                ? 'Sending code...'
                : 'Enter the 6-digit code sent to ${widget.phone}',
            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // OTP inputs
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (i) {
              return Container(
                width: 44,
                height: 52,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: TextField(
                  controller: _controllers[i],
                  focusNode: _focusNodes[i],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  enabled: !_verifying,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    counterText: '',
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: AppTheme.primary, width: 1.5),
                    ),
                  ),
                  onChanged: (v) => _onDigitChanged(i, v),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),

          // Error
          if (_error.isNotEmpty)
            Text(_error,
                style: const TextStyle(color: AppTheme.error, fontSize: 13)),

          const SizedBox(height: 16),

          // Verify button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _verifying
                  ? null
                  : _controllers.every((c) => c.text.length == 1)
                      ? _verify
                      : null,
              child: _verifying
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Verify'),
            ),
          ),
          const SizedBox(height: 12),

          // Resend
          _cooldown > 0
              ? Text('Resend in ${_cooldown}s',
                  style: const TextStyle(
                      fontSize: 13, color: AppTheme.textSecondary))
              : TextButton(
                  onPressed: _sending ? null : _sendOTP,
                  child: Text(_sending ? 'Sending...' : 'Resend OTP',
                      style: const TextStyle(fontSize: 13)),
                ),
        ],
      ),
    );
  }
}
