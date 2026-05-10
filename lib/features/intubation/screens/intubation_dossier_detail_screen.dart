import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';

import '../../../models/patient.dart';
import '../../../models/intubation_dossier.dart';
import '../../../services/pdf_service.dart';
import '../../../services/database_service.dart';
import '../../../core/shared_widgets/info_card.dart';

import '../widgets/export_action_button.dart';
import 'intubation_form_screen.dart';

class IntubationDossierDetailScreen extends StatefulWidget {
  final Patient patient;
  final IntubationDossier dossier;

  const IntubationDossierDetailScreen({super.key, required this.patient, required this.dossier});

  @override
  State<IntubationDossierDetailScreen> createState() => _IntubationDossierDetailScreenState();
}

class _IntubationDossierDetailScreenState extends State<IntubationDossierDetailScreen> {
  late IntubationDossier _currentDossier;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _currentDossier = widget.dossier;
  }

  Future<void> _refreshDossier() async {
    final db = await DatabaseService().database;
    final List<Map<String, dynamic>> maps = await db.query('intubation_dossiers', where: 'id = ?', whereArgs: [_currentDossier.id]);
    if (maps.isNotEmpty && mounted) {
      setState(() => _currentDossier = IntubationDossier.fromMap(maps.first));
    }
  }

  void _syncSingleDossier() async {
    setState(() => _isSyncing = true);
    await Future.delayed(const Duration(seconds: 2));
    final db = await DatabaseService().database;
    await db.rawUpdate('UPDATE intubation_dossiers SET is_synced = 1 WHERE id = ?', [_currentDossier.id]);
    await _refreshDossier();
    if (mounted) {
      setState(() => _isSyncing = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dossier synchronisé avec succès !'), backgroundColor: Colors.green));
    }
  }

  void _generateAndShare(BuildContext context, String method) async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Génération du PDF en cours...')));
    try {
      final file = await PdfService.generateIntubationReport(widget.patient, _currentDossier);
      await PdfService.shareReport(file); 
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28), SizedBox(width: 10), Text('Supprimer ?', style: TextStyle(fontWeight: FontWeight.bold))]),
        content: const Text('Voulez-vous vraiment supprimer ce dossier d\'intubation ? Cette action est irréversible.', style: TextStyle(fontSize: 15)),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), style: TextButton.styleFrom(foregroundColor: Colors.grey.shade700), child: const Text('Annuler', style: TextStyle(fontWeight: FontWeight.bold))),
          ElevatedButton(
            onPressed: () async {
              await DatabaseService().deleteIntubationDossier(_currentDossier.id!);
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de l\'Intubation', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_document, color: Colors.blue),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => IntubationFormScreen(patient: widget.patient, dossierToEdit: _currentDossier),
              )).then((_) => _refreshDossier()); 
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(gradient: LinearGradient(colors: [Theme.of(context).primaryColor, Colors.blue.shade800]), borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        children: [
                          const CircleAvatar(radius: 30, backgroundColor: Colors.white24, child: Icon(Icons.medical_services, size: 30, color: Colors.white)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${widget.patient.nom} ${widget.patient.prenom}', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: _currentDossier.isSynced == 1 ? Colors.greenAccent.withOpacity(0.2) : Colors.orangeAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                                  child: Text(_currentDossier.isSynced == 1 ? 'Synchronisé' : 'Brouillon Local', style: TextStyle(color: _currentDossier.isSynced == 1 ? Colors.greenAccent : Colors.orangeAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ).animate().fade().slideY(begin: 0.1),

                    const SizedBox(height: 24),
                    const Text('Résumé Clinique', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),

                    InfoCard(title: 'Évaluation Initiale', children: [
                      InfoDataRow(label: 'Score ASA', value: _currentDossier.scoreAsa),
                      InfoDataRow(label: 'Score STOPBANG', value: _currentDossier.scoreStopbang.isEmpty ? 'N/A' : _currentDossier.scoreStopbang),
                      InfoDataRow(label: 'Intubation Prévue', value: _currentDossier.intubationPrevue, isAlert: _currentDossier.intubationPrevue == 'Difficile'),
                    ]).animate().fade(delay: 100.ms),

                    InfoCard(title: 'Critères Prédictifs', children: [
                      InfoDataRow(label: 'Mallampati', value: _currentDossier.mallampati),
                      InfoDataRow(label: 'DTM', value: _currentDossier.dtm),
                      InfoDataRow(label: 'Ouverture Buccale', value: _currentDossier.ouvertureBuccale),
                      InfoDataRow(label: 'Mobilité Cervicale', value: _currentDossier.mobiliteRachis),
                    ]).animate().fade(delay: 200.ms),

                    InfoCard(title: 'Déroulement de l\'acte', children: [
                      InfoDataRow(label: 'Score Cormack', value: _currentDossier.cormack),
                      InfoDataRow(label: 'Résultat', value: _currentDossier.intubationRealisee, isAlert: _currentDossier.intubationRealisee.contains('Difficile')),
                      InfoDataRow(label: 'Vidéolaryngoscope', value: _currentDossier.videoLaryngoscope == 1 ? 'Oui' : 'Non'),
                      InfoDataRow(label: 'Guide Eichmann', value: _currentDossier.guideEichmann == 1 ? 'Oui' : 'Non'),
                    ]).animate().fade(delay: 300.ms),
                    
                    InfoCard(title: 'Médias Attachés', children: [
                      InfoDataRow(label: 'Photos', value: [
                        _currentDossier.photoFace, _currentDossier.photoProfil, _currentDossier.photoBouche, _currentDossier.photoProfilNeutre, _currentDossier.photoProfilExt
                      ].where((e) => e != null).length.toString()),
                      InfoDataRow(label: 'Enregistrements Audio', value: [
                        _currentDossier.audioA, _currentDossier.audioKha, _currentDossier.audioHa, _currentDossier.audioHaa, _currentDossier.audioGha, _currentDossier.audioAaa
                      ].where((e) => e != null).length.toString()),
                    ]).animate().fade(delay: 400.ms),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_currentDossier.isSynced == 0) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isSyncing ? null : _syncSingleDossier,
                        icon: _isSyncing ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.cloud_upload_rounded),
                        label: Text(_isSyncing ? 'Synchronisation...' : 'Synchroniser ce dossier', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade500, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                      ),
                    ).animate().fade().slideY(begin: 0.2),
                    const SizedBox(height: 20),
                  ],
                  const Text('Exporter & Partager le rapport PDF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ExportActionButton(label: 'PDF', icon: Icons.picture_as_pdf_rounded, color: Colors.blue.shade600, onTap: () => _generateAndShare(context, 'pdf')),
                      ExportActionButton(label: 'Email', icon: Icons.mail_rounded, color: Colors.red.shade500, onTap: () => _generateAndShare(context, 'email')),
                      ExportActionButton(label: 'WhatsApp', icon: Icons.chat_bubble_rounded, color: Colors.green.shade600, onTap: () => _generateAndShare(context, 'whatsapp')),
                    ],
                  ).animate().fade(delay: 200.ms).scale(begin: const Offset(0.9, 0.9)),
                  const SizedBox(height: 20),
                  TextButton.icon(onPressed: () => _confirmDelete(context), icon: const Icon(Icons.delete_outline_rounded, color: Colors.red), label: const Text('Supprimer ce dossier', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15))).animate().fade(delay: 300.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
