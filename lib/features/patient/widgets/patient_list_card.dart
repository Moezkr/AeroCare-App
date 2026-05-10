import 'package:flutter/material.dart';
import '../../../models/patient.dart';

class PatientListCard extends StatelessWidget {
  final Patient patient;
  final VoidCallback onOpenDossiers;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PatientListCard({
    super.key,
    required this.patient,
    required this.onOpenDossiers,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25, 
              backgroundColor: patient.sexe == 'Homme' ? Colors.blue.shade50 : Colors.pink.shade50,
              child: Icon(patient.sexe == 'Homme' ? Icons.male : Icons.female, color: patient.sexe == 'Homme' ? Colors.blue : Colors.pink, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${patient.nom} ${patient.prenom}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(patient.telephone, style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.folder_shared_rounded, color: Colors.indigo), onPressed: onOpenDossiers),
                IconButton(icon: const Icon(Icons.edit_rounded, color: Colors.blue), onPressed: onEdit),
                IconButton(icon: const Icon(Icons.delete_outline_rounded, color: Colors.red), onPressed: onDelete),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
