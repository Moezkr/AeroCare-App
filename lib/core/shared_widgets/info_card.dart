import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const InfoCard({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey)),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }
}

class InfoDataRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isAlert;

  const InfoDataRow({super.key, required this.label, required this.value, this.isAlert = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isAlert ? Colors.red : null)),
        ],
      ),
    );
  }
}
