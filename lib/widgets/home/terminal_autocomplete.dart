import 'dart:async';
import 'package:flutter/material.dart';
import 'package:etbp_mobile/config/theme.dart';
import 'package:etbp_mobile/core/api/api_client.dart';
import 'package:etbp_mobile/core/api/endpoints.dart';
import 'package:etbp_mobile/models/terminal.dart';

class TerminalAutocomplete extends StatefulWidget {
  final ApiClient api;
  final String label;
  final IconData icon;
  final String? initialValue;
  final ValueChanged<String> onSelected;

  const TerminalAutocomplete({
    super.key,
    required this.api,
    required this.label,
    required this.icon,
    this.initialValue,
    required this.onSelected,
  });

  @override
  State<TerminalAutocomplete> createState() => _TerminalAutocompleteState();
}

class _TerminalAutocompleteState extends State<TerminalAutocomplete> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  List<Terminal> _suggestions = [];
  bool _showDropdown = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        // Delay to allow tap on suggestion to register
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) setState(() => _showDropdown = false);
        });
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String query) {
    widget.onSelected(query);
    _debounce?.cancel();
    if (query.length < 2) {
      setState(() {
        _suggestions = [];
        _showDropdown = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () => _search(query));
  }

  Future<void> _search(String query) async {
    try {
      final response = await widget.api.get(
        Endpoints.terminals,
        queryParameters: {'search': query},
      );
      final data = response.data;
      final list = (data is List ? data : (data['results'] ?? data['items'] ?? []))
          as List;
      if (mounted) {
        setState(() {
          _suggestions = list.map((t) => Terminal.fromJson(t)).toList();
          _showDropdown = _suggestions.isNotEmpty;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _showDropdown = false);
    }
  }

  void _select(Terminal terminal) {
    _controller.text = terminal.city;
    widget.onSelected(terminal.city);
    setState(() {
      _showDropdown = false;
      _suggestions = [];
    });
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            labelText: widget.label,
            prefixIcon: Icon(widget.icon, size: 20),
          ),
          onChanged: _onChanged,
        ),
        if (_showDropdown && _suggestions.isNotEmpty)
          Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.border),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _suggestions.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: AppTheme.border),
                itemBuilder: (_, i) {
                  final t = _suggestions[i];
                  return InkWell(
                    onTap: () => _select(t),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 18, color: AppTheme.textSecondary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(t.name,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500)),
                                Text('${t.city}, ${t.state}',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textSecondary)),
                              ],
                            ),
                          ),
                          Text(t.code,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                  fontFamily: 'monospace')),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
