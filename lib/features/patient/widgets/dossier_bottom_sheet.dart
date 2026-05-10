import 'package:flutter/material.dart';
import '../../../services/database_service.dart';
import '../../../models/intubation_dossier.dart';
import '../../../models/patient.dart';
import '../../intubation/screens/intubation_dossier_detail_screen.dart';
import '../../intubation/screens/intubation_form_screen.dart';

class DossierBottomSheet extends StatefulWidget {
  final Patient patient;
  const DossierBottomSheet({super.key, required this.patient});

  @override
  State<DossierBottomSheet> createState() => _DossierBottomSheetState();
}

class _DossierBottomSheetState extends State<DossierBottomSheet> {
  List<IntubationDossier> _dossiers = []; 
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDossiers();
  }

  Future<void> _loadDossiers() async {
    setState(() => _isLoading = true);
    final dossiers = await DatabaseService().getIntubationDossiersForPatient(widget.patient.id!);
    if (mounted) {
      setState(() {
        _dossiers = dossiers;
        _isLoading = false;
      });
    }
  }

  void _deleteDossier(IntubationDossier dossier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer ?', style: TextStyle(color: Colors.red)),
        content: const Text('Voulez-vous vraiment supprimer ce dossier ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              await DatabaseService().deleteIntubationDossier(dossier.id!); 
              if (ctx.mounted) Navigator.pop(ctx);
              _loadDossiers();
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Dossier de ${widget.patient.nom}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const Divider(),
          Flexible(
            child: _isLoading 
              ? const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator()))
              : _dossiers.isEmpty
                  ? const Padding(padding: EdgeInsets.all(30.0), child: Center(child: Text("Aucun dossier d'intubation trouvé.", style: TextStyle(color: Colors.grey))))
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _dossiers.length,
                      itemBuilder: (context, index) {
                        final d = _dossiers[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                          child: ListTile(
                            leading: const CircleAvatar(backgroundColor: Color(0xFFE0E7FF), child: Icon(Icons.medical_services_rounded, color: Colors.blue)),
                            title: Text(d.acteOperatoire.isEmpty ? 'Acte non spécifié' : d.acteOperatoire, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Score ASA: ${d.scoreAsa}'),
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => IntubationDossierDetailScreen(patient: widget.patient, dossier: d)))
                                .then((_) => _loadDossiers());
                            },
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(icon: const Icon(Icons.edit_document, color: Colors.blue, size: 22), onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => IntubationFormScreen(patient: widget.patient, dossierToEdit: d)))
                                    .then((_) => _loadDossiers());
                                }),
                                IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22), onPressed: () => _deleteDossier(d)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
          if (_dossiers.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: 10, bottom: MediaQuery.of(context).padding.bottom + 20),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => IntubationFormScreen(patient: widget.patient)))
                    .then((_) => _loadDossiers());
                },
                icon: const Icon(Icons.add_chart_rounded),
                label: const Text("Créer le dossier d'intubation", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor, foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            )
          else 
             SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
        ],
      ),
    );
  }
}
