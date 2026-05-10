import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SearchFilterSheet extends StatefulWidget {
  final DateTime initialStartDate;
  final DateTime initialEndDate;
  final String initialSexe;
  final Function(DateTime, DateTime, String) onApply;

  const SearchFilterSheet({
    super.key,
    required this.initialStartDate,
    required this.initialEndDate,
    required this.initialSexe,
    required this.onApply,
  });

  @override
  State<SearchFilterSheet> createState() => _SearchFilterSheetState();
}

class _SearchFilterSheetState extends State<SearchFilterSheet> {
  late DateTime _startDate;
  late DateTime _endDate;
  late String _selectedSexe;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
    _selectedSexe = widget.initialSexe;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Filtres avancés', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Période'),
            subtitle: Text('${DateFormat('dd/MM').format(_startDate)} - ${DateFormat('dd/MM').format(_endDate)}'),
            onTap: () async {
              final picked = await showDateRangePicker(
                context: context, 
                initialDateRange: DateTimeRange(start: _startDate, end: _endDate), 
                firstDate: DateTime(2020), 
                lastDate: DateTime.now()
              );
              if (picked != null) { 
                setState(() { 
                  _startDate = picked.start; 
                  _endDate = picked.end; 
                }); 
              }
            },
          ),
          const Divider(),
          DropdownButtonFormField<String>(
            value: _selectedSexe,
            decoration: const InputDecoration(labelText: "Sexe"),
            items: ['Tous', 'Homme', 'Femme'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (val) => setState(() => _selectedSexe = val!),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.all(16)),
              onPressed: () {
                widget.onApply(_startDate, _endDate, _selectedSexe);
                Navigator.pop(context);
              }, 
              child: const Text('Appliquer les filtres', style: TextStyle(fontWeight: FontWeight.bold))
            ),
          ),
        ],
      ),
    );
  }
}
