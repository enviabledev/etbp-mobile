import 'package:flutter/material.dart';
import 'package:etbp_mobile/config/theme.dart';

class Country {
  final String code;
  final String dialCode;
  final String flag;
  final String name;

  const Country({
    required this.code,
    required this.dialCode,
    required this.flag,
    required this.name,
  });
}

const countries = [
  Country(code: "NG", dialCode: "+234", flag: "\u{1F1F3}\u{1F1EC}", name: "Nigeria"),
  Country(code: "GH", dialCode: "+233", flag: "\u{1F1EC}\u{1F1ED}", name: "Ghana"),
  Country(code: "KE", dialCode: "+254", flag: "\u{1F1F0}\u{1F1EA}", name: "Kenya"),
  Country(code: "ZA", dialCode: "+27", flag: "\u{1F1FF}\u{1F1E6}", name: "South Africa"),
  Country(code: "CM", dialCode: "+237", flag: "\u{1F1E8}\u{1F1F2}", name: "Cameroon"),
  Country(code: "GB", dialCode: "+44", flag: "\u{1F1EC}\u{1F1E7}", name: "United Kingdom"),
  Country(code: "US", dialCode: "+1", flag: "\u{1F1FA}\u{1F1F8}", name: "United States"),
];

class PhoneInput extends StatefulWidget {
  final String? initialValue;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final bool enabled;
  final String? label;

  const PhoneInput({
    super.key,
    this.initialValue,
    required this.onChanged,
    this.errorText,
    this.enabled = true,
    this.label,
  });

  @override
  State<PhoneInput> createState() => _PhoneInputState();
}

class _PhoneInputState extends State<PhoneInput> {
  late Country _country;
  final _controller = TextEditingController();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _country = countries[0];
    _parseInitial();
  }

  void _parseInitial() {
    if (_initialized || widget.initialValue == null || widget.initialValue!.isEmpty) return;
    _initialized = true;

    for (final c in countries) {
      if (widget.initialValue!.startsWith(c.dialCode)) {
        _country = c;
        _controller.text = widget.initialValue!.substring(c.dialCode.length);
        return;
      }
    }
    // Fallback: strip leading 0
    String val = widget.initialValue!;
    if (val.startsWith("0")) val = val.substring(1);
    _controller.text = val;
  }

  void _onLocalChanged(String raw) {
    String digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('0')) digits = digits.substring(1);
    if (digits != raw) {
      _controller.text = digits;
      _controller.selection = TextSelection.fromPosition(TextPosition(offset: digits.length));
    }
    widget.onChanged(digits.isNotEmpty ? '${_country.dialCode}$digits' : '');
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => ListView(
        shrinkWrap: true,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Select Country', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          ...countries.map((c) => ListTile(
                leading: Text(c.flag, style: const TextStyle(fontSize: 24)),
                title: Text(c.name),
                trailing: Text(c.dialCode, style: const TextStyle(color: AppTheme.textSecondary)),
                selected: c.code == _country.code,
                onTap: () {
                  setState(() => _country = c);
                  Navigator.pop(context);
                  final digits = _controller.text;
                  widget.onChanged(digits.isNotEmpty ? '${c.dialCode}$digits' : '');
                },
              )),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(widget.label!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ),
        Row(
          children: [
            // Country selector
            GestureDetector(
              onTap: widget.enabled ? _showCountryPicker : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: widget.errorText != null ? AppTheme.error : AppTheme.border),
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                  color: Colors.white,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_country.flag, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 4),
                    Text(_country.dialCode, style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
                    const SizedBox(width: 2),
                    const Icon(Icons.keyboard_arrow_down, size: 16, color: AppTheme.textSecondary),
                  ],
                ),
              ),
            ),
            // Number input
            Expanded(
              child: TextField(
                controller: _controller,
                enabled: widget.enabled,
                keyboardType: TextInputType.phone,
                onChanged: _onLocalChanged,
                decoration: InputDecoration(
                  hintText: '8012345678',
                  errorText: widget.errorText,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
                    borderSide: BorderSide(color: widget.errorText != null ? AppTheme.error : AppTheme.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
                    borderSide: BorderSide(color: widget.errorText != null ? AppTheme.error : AppTheme.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
                    borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
