import 'package:flutter/material.dart';

import '../../../models/patient.dart';
import '../../../models/intubation_dossier.dart';
import '../../intubation/screens/intubation_dossier_detail_screen.dart';

class RecentDossierCard extends StatelessWidget {
  final Map<String, dynamic> dataMap;
  final VoidCallback onReturn;

  const RecentDossierCard({
    super.key,
    required this.dataMap,
    required this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    final isSynced = dataMap['is_synced'] == 1;

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => IntubationDossierDetailScreen(
                patient: Patient.fromMap(dataMap),
                dossier: IntubationDossier.fromMap(dataMap),
              ),
            ),
          ).then((_) => onReturn());
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFE0E7FF),
                child: Icon(Icons.person, color: Color(0xFF3B82F6)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${dataMap['nom']} ${dataMap['prenom']}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(
                        (dataMap['acteOperatoire'] == null || dataMap['acteOperatoire'] == '')
                            ? 'Acte non spécifié'
                            : dataMap['acteOperatoire'],
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSynced ? const Color(0xFFD1FAE5) : const Color(0xFFFFEDD5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isSynced ? 'Synchronisé' : 'Brouillon',
                  style: TextStyle(
                    color: isSynced ? const Color(0xFF065F46) : const Color(0xFFC2410C),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
