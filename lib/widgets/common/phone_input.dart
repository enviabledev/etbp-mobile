import 'package:flutter/material.dart';
import 'package:etbp_mobile/config/theme.dart';

class Country {
  final String code;
  final String dialCode;
  final String name;

  const Country(this.code, this.dialCode, this.name);

  String get flag => String.fromCharCodes(
        code.toUpperCase().codeUnits.map((c) => c - 0x41 + 0x1F1E6),
      );
}

// Nigeria first, then alphabetical
const _defaultIndex = 0;
const countries = [
  Country("NG", "+234", "Nigeria"),
  Country("AF", "+93", "Afghanistan"),
  Country("AL", "+355", "Albania"),
  Country("DZ", "+213", "Algeria"),
  Country("AD", "+376", "Andorra"),
  Country("AO", "+244", "Angola"),
  Country("AR", "+54", "Argentina"),
  Country("AM", "+374", "Armenia"),
  Country("AU", "+61", "Australia"),
  Country("AT", "+43", "Austria"),
  Country("AZ", "+994", "Azerbaijan"),
  Country("BS", "+1242", "Bahamas"),
  Country("BH", "+973", "Bahrain"),
  Country("BD", "+880", "Bangladesh"),
  Country("BB", "+1246", "Barbados"),
  Country("BY", "+375", "Belarus"),
  Country("BE", "+32", "Belgium"),
  Country("BZ", "+501", "Belize"),
  Country("BJ", "+229", "Benin"),
  Country("BT", "+975", "Bhutan"),
  Country("BO", "+591", "Bolivia"),
  Country("BA", "+387", "Bosnia and Herzegovina"),
  Country("BW", "+267", "Botswana"),
  Country("BR", "+55", "Brazil"),
  Country("BN", "+673", "Brunei"),
  Country("BG", "+359", "Bulgaria"),
  Country("BF", "+226", "Burkina Faso"),
  Country("BI", "+257", "Burundi"),
  Country("KH", "+855", "Cambodia"),
  Country("CM", "+237", "Cameroon"),
  Country("CA", "+1", "Canada"),
  Country("CV", "+238", "Cape Verde"),
  Country("CF", "+236", "Central African Republic"),
  Country("TD", "+235", "Chad"),
  Country("CL", "+56", "Chile"),
  Country("CN", "+86", "China"),
  Country("CO", "+57", "Colombia"),
  Country("KM", "+269", "Comoros"),
  Country("CD", "+243", "Congo (DRC)"),
  Country("CG", "+242", "Congo (Republic)"),
  Country("CR", "+506", "Costa Rica"),
  Country("HR", "+385", "Croatia"),
  Country("CU", "+53", "Cuba"),
  Country("CY", "+357", "Cyprus"),
  Country("CZ", "+420", "Czech Republic"),
  Country("DK", "+45", "Denmark"),
  Country("DJ", "+253", "Djibouti"),
  Country("DO", "+1809", "Dominican Republic"),
  Country("EC", "+593", "Ecuador"),
  Country("EG", "+20", "Egypt"),
  Country("SV", "+503", "El Salvador"),
  Country("GQ", "+240", "Equatorial Guinea"),
  Country("ER", "+291", "Eritrea"),
  Country("EE", "+372", "Estonia"),
  Country("SZ", "+268", "Eswatini"),
  Country("ET", "+251", "Ethiopia"),
  Country("FJ", "+679", "Fiji"),
  Country("FI", "+358", "Finland"),
  Country("FR", "+33", "France"),
  Country("GA", "+241", "Gabon"),
  Country("GM", "+220", "Gambia"),
  Country("GE", "+995", "Georgia"),
  Country("DE", "+49", "Germany"),
  Country("GH", "+233", "Ghana"),
  Country("GR", "+30", "Greece"),
  Country("GT", "+502", "Guatemala"),
  Country("GN", "+224", "Guinea"),
  Country("GW", "+245", "Guinea-Bissau"),
  Country("GY", "+592", "Guyana"),
  Country("HT", "+509", "Haiti"),
  Country("HN", "+504", "Honduras"),
  Country("HK", "+852", "Hong Kong"),
  Country("HU", "+36", "Hungary"),
  Country("IS", "+354", "Iceland"),
  Country("IN", "+91", "India"),
  Country("ID", "+62", "Indonesia"),
  Country("IR", "+98", "Iran"),
  Country("IQ", "+964", "Iraq"),
  Country("IE", "+353", "Ireland"),
  Country("IL", "+972", "Israel"),
  Country("IT", "+39", "Italy"),
  Country("CI", "+225", "Ivory Coast"),
  Country("JM", "+1876", "Jamaica"),
  Country("JP", "+81", "Japan"),
  Country("JO", "+962", "Jordan"),
  Country("KZ", "+7", "Kazakhstan"),
  Country("KE", "+254", "Kenya"),
  Country("KW", "+965", "Kuwait"),
  Country("KG", "+996", "Kyrgyzstan"),
  Country("LA", "+856", "Laos"),
  Country("LV", "+371", "Latvia"),
  Country("LB", "+961", "Lebanon"),
  Country("LS", "+266", "Lesotho"),
  Country("LR", "+231", "Liberia"),
  Country("LY", "+218", "Libya"),
  Country("LI", "+423", "Liechtenstein"),
  Country("LT", "+370", "Lithuania"),
  Country("LU", "+352", "Luxembourg"),
  Country("MO", "+853", "Macau"),
  Country("MG", "+261", "Madagascar"),
  Country("MW", "+265", "Malawi"),
  Country("MY", "+60", "Malaysia"),
  Country("MV", "+960", "Maldives"),
  Country("ML", "+223", "Mali"),
  Country("MT", "+356", "Malta"),
  Country("MR", "+222", "Mauritania"),
  Country("MU", "+230", "Mauritius"),
  Country("MX", "+52", "Mexico"),
  Country("MD", "+373", "Moldova"),
  Country("MC", "+377", "Monaco"),
  Country("MN", "+976", "Mongolia"),
  Country("ME", "+382", "Montenegro"),
  Country("MA", "+212", "Morocco"),
  Country("MZ", "+258", "Mozambique"),
  Country("MM", "+95", "Myanmar"),
  Country("NA", "+264", "Namibia"),
  Country("NP", "+977", "Nepal"),
  Country("NL", "+31", "Netherlands"),
  Country("NZ", "+64", "New Zealand"),
  Country("NI", "+505", "Nicaragua"),
  Country("NE", "+227", "Niger"),
  Country("KP", "+850", "North Korea"),
  Country("MK", "+389", "North Macedonia"),
  Country("NO", "+47", "Norway"),
  Country("OM", "+968", "Oman"),
  Country("PK", "+92", "Pakistan"),
  Country("PS", "+970", "Palestine"),
  Country("PA", "+507", "Panama"),
  Country("PG", "+675", "Papua New Guinea"),
  Country("PY", "+595", "Paraguay"),
  Country("PE", "+51", "Peru"),
  Country("PH", "+63", "Philippines"),
  Country("PL", "+48", "Poland"),
  Country("PT", "+351", "Portugal"),
  Country("QA", "+974", "Qatar"),
  Country("RO", "+40", "Romania"),
  Country("RU", "+7", "Russia"),
  Country("RW", "+250", "Rwanda"),
  Country("SA", "+966", "Saudi Arabia"),
  Country("SN", "+221", "Senegal"),
  Country("RS", "+381", "Serbia"),
  Country("SC", "+248", "Seychelles"),
  Country("SL", "+232", "Sierra Leone"),
  Country("SG", "+65", "Singapore"),
  Country("SK", "+421", "Slovakia"),
  Country("SI", "+386", "Slovenia"),
  Country("SO", "+252", "Somalia"),
  Country("ZA", "+27", "South Africa"),
  Country("KR", "+82", "South Korea"),
  Country("SS", "+211", "South Sudan"),
  Country("ES", "+34", "Spain"),
  Country("LK", "+94", "Sri Lanka"),
  Country("SD", "+249", "Sudan"),
  Country("SR", "+597", "Suriname"),
  Country("SE", "+46", "Sweden"),
  Country("CH", "+41", "Switzerland"),
  Country("SY", "+963", "Syria"),
  Country("TW", "+886", "Taiwan"),
  Country("TJ", "+992", "Tajikistan"),
  Country("TZ", "+255", "Tanzania"),
  Country("TH", "+66", "Thailand"),
  Country("TG", "+228", "Togo"),
  Country("TT", "+1868", "Trinidad and Tobago"),
  Country("TN", "+216", "Tunisia"),
  Country("TR", "+90", "Turkey"),
  Country("TM", "+993", "Turkmenistan"),
  Country("UG", "+256", "Uganda"),
  Country("UA", "+380", "Ukraine"),
  Country("AE", "+971", "United Arab Emirates"),
  Country("GB", "+44", "United Kingdom"),
  Country("US", "+1", "United States"),
  Country("UY", "+598", "Uruguay"),
  Country("UZ", "+998", "Uzbekistan"),
  Country("VE", "+58", "Venezuela"),
  Country("VN", "+84", "Vietnam"),
  Country("YE", "+967", "Yemen"),
  Country("ZM", "+260", "Zambia"),
  Country("ZW", "+263", "Zimbabwe"),
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
    _country = countries[_defaultIndex];
    _parseInitial();
  }

  void _parseInitial() {
    if (_initialized || widget.initialValue == null || widget.initialValue!.isEmpty) return;
    _initialized = true;

    // Match longest dial code first
    Country? matched;
    int matchLen = 0;
    for (final c in countries) {
      if (widget.initialValue!.startsWith(c.dialCode) && c.dialCode.length > matchLen) {
        matched = c;
        matchLen = c.dialCode.length;
      }
    }
    if (matched != null) {
      _country = matched;
      _controller.text = widget.initialValue!.substring(matchLen);
      return;
    }
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
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _CountryPickerSheet(
        selected: _country,
        onSelect: (c) {
          setState(() => _country = c);
          Navigator.pop(context);
          final digits = _controller.text;
          widget.onChanged(digits.isNotEmpty ? '${c.dialCode}$digits' : '');
        },
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

class _CountryPickerSheet extends StatefulWidget {
  final Country selected;
  final ValueChanged<Country> onSelect;

  const _CountryPickerSheet({required this.selected, required this.onSelect});

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  final _searchC = TextEditingController();
  List<Country> _filtered = countries;

  void _filter(String query) {
    final q = query.toLowerCase();
    setState(() {
      _filtered = countries
          .where((c) => c.name.toLowerCase().contains(q) || c.dialCode.contains(q) || c.code.toLowerCase().contains(q))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (_, scrollController) => Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchC,
              onChanged: _filter,
              decoration: InputDecoration(
                hintText: 'Search country...',
                prefixIcon: const Icon(Icons.search, size: 20),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: _filtered.length,
              itemBuilder: (_, i) {
                final c = _filtered[i];
                final selected = c.code == widget.selected.code;
                return ListTile(
                  leading: Text(c.flag, style: const TextStyle(fontSize: 24)),
                  title: Text(c.name, style: TextStyle(fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
                  trailing: Text(c.dialCode, style: const TextStyle(color: AppTheme.textSecondary)),
                  selected: selected,
                  onTap: () => widget.onSelect(c),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
