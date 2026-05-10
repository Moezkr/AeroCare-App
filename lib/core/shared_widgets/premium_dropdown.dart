import 'package:flutter/material.dart';

class PremiumDropdown extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<String> items;
  final String value;
  final void Function(String?) onChanged;

  const PremiumDropdown({
    super.key,
    required this.label,
    required this.icon,
    required this.items,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.grey),
        ),
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
        borderRadius: BorderRadius.circular(16),
        dropdownColor: Theme.of(context).cardColor,
        items: items.map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
