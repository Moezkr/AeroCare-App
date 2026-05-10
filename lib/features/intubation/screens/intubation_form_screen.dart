
import 'dart:io';
import 'dart:async';
import 'dart:math' show cos, sin, pi;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mini_music_visualizer/mini_music_visualizer.dart';

import '../../../models/patient.dart';
import '../../../models/intubation_dossier.dart';
import '../../../services/database_service.dart';
import '../../../core/shared_widgets/gradient_background.dart';
import '../../../core/shared_widgets/custom_switch_tile.dart';
import '../../../core/shared_widgets/premium_dropdown.dart';

class IntubationFormScreen extends StatefulWidget {
  final Patient patient;
  final IntubationDossier? dossierToEdit;

  const IntubationFormScreen({super.key, required this.patient, this.dossierToEdit});

  @override
  State<IntubationFormScreen> createState() => _IntubationFormScreenState();
}

class _IntubationFormScreenState extends State<IntubationFormScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final ImagePicker _picker = ImagePicker();

  bool _intubationDifficile = false; bool _saos = false; bool _diabete = false; bool _goitre = false;
  bool _maladieRhumatismale = false; bool _traumatismeCervical = false;
  bool _brulureFaciale = false; bool _dysmorphieFaciale = false; bool _tumeurFaciale = false;
  final _brulureLocController    = TextEditingController();
  final _dysmorphieLocController = TextEditingController();
  final _tumeurLocController     = TextEditingController();

  String _scoreAsa = 'I'; String _mallampati = 'I'; String _dtm = '<6 cm'; String _ouvertureBuccale = '<35 mm';
  String _tourDeCou = '<45 cm'; String _mobiliteRachis = 'Souple'; bool _macroglossie = false;
  String _intubationPrevue = 'Facile'; String _typeIntubation = 'Orale'; String _nombreTentatives = '1';
  bool _videoLaryngoscope = false; bool _guideEichmann = false; String _cormack = 'I';
  bool _intubationDifficileSfar = false; final _complicationsController = TextEditingController();

  String? _photoFace; String? _photoProfil; String? _photoBouche; String? _photoProfilNeutre; String? _photoProfilExt;
  String? _audioA; String? _audioKha; String? _audioHa; String? _audioHaa; String? _audioGha; String? _audioAaa;

  @override
  void initState() {
    super.initState();
    if (widget.dossierToEdit != null) {
      final d = widget.dossierToEdit!;
      _intubationDifficile = d.intubationDifficile == 1; _saos = d.saos == 1; _diabete = d.diabete == 1; _goitre = d.goitre == 1;
      _maladieRhumatismale = d.maladieRhumatismale == 1; _traumatismeCervical = d.traumatismeCervical == 1;
      _brulureFaciale = d.brulureFaciale == 1; _dysmorphieFaciale = d.dysmorphieFaciale == 1; _tumeurFaciale = d.tumeurFaciale == 1;
      _brulureLocController.text = d.brulureLocalisation;
      _dysmorphieLocController.text = d.dysmorphieLocalisation;
      _tumeurLocController.text = d.tumeurLocalisation;
      _scoreAsa = d.scoreAsa; _mallampati = d.mallampati; _dtm = d.dtm; _ouvertureBuccale = d.ouvertureBuccale;
      _tourDeCou = d.tourDeCou; _mobiliteRachis = d.mobiliteRachis; _macroglossie = d.macroglossie == 1;
      _intubationPrevue = d.intubationPrevue; _typeIntubation = d.typeIntubation; _nombreTentatives = d.nombreTentatives;
      _videoLaryngoscope = d.videoLaryngoscope == 1; _guideEichmann = d.guideEichmann == 1; _cormack = d.cormack;
      _intubationDifficileSfar = d.intubationDifficileSfar == 1; _complicationsController.text = d.complications;
      
      _photoFace = d.photoFace; _photoProfil = d.photoProfil; _photoBouche = d.photoBouche;
      _photoProfilNeutre = d.photoProfilNeutre; _photoProfilExt = d.photoProfilExt;
      _audioA = d.audioA; _audioKha = d.audioKha; _audioHa = d.audioHa;
      _audioHaa = d.audioHaa; _audioGha = d.audioGha; _audioAaa = d.audioAaa;
    }
  }

  bool _isSaving = false;

  void _nextPage() {
    if (_currentStep < 5) {
      _pageController.nextPage(duration: 400.ms, curve: Curves.easeInOutCubic);
    } else {
      _saveDossier();
    }
  }
  
  void _previousPage() {
    if (_currentStep > 0) _pageController.previousPage(duration: 400.ms, curve: Curves.easeInOutCubic);
  }

  void _saveDossier() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final dossier = IntubationDossier(
        id: widget.dossierToEdit?.id, patientId: widget.patient.id!, dateCreation: DateTime.now().toIso8601String(),
        intubationDifficile: _intubationDifficile ? 1 : 0, saos: _saos ? 1 : 0, diabete: _diabete ? 1 : 0, goitre: _goitre ? 1 : 0,
        maladieRhumatismale: _maladieRhumatismale ? 1 : 0, traumatismeCervical: _traumatismeCervical ? 1 : 0,
        brulureFaciale: _brulureFaciale ? 1 : 0, brulureLocalisation: _brulureLocController.text,
        dysmorphieFaciale: _dysmorphieFaciale ? 1 : 0, dysmorphieLocalisation: _dysmorphieLocController.text,
        tumeurFaciale: _tumeurFaciale ? 1 : 0, tumeurLocalisation: _tumeurLocController.text,
        scoreAsa: _scoreAsa, mallampati: _mallampati, dtm: _dtm, ouvertureBuccale: _ouvertureBuccale, tourDeCou: _tourDeCou, mobiliteRachis: _mobiliteRachis, macroglossie: _macroglossie ? 1 : 0,
        intubationPrevue: _intubationPrevue, typeIntubation: _typeIntubation, nombreTentatives: _nombreTentatives, videoLaryngoscope: _videoLaryngoscope ? 1 : 0, guideEichmann: _guideEichmann ? 1 : 0, cormack: _cormack,
        intubationDifficileSfar: _intubationDifficileSfar ? 1 : 0, complications: _complicationsController.text,
        photoFace: _photoFace, photoProfil: _photoProfil, photoBouche: _photoBouche, photoProfilNeutre: _photoProfilNeutre, photoProfilExt: _photoProfilExt,
        audioA: _audioA, audioKha: _audioKha, audioHa: _audioHa, audioHaa: _audioHaa, audioGha: _audioGha, audioAaa: _audioAaa,
      );

      if (widget.dossierToEdit == null) {
        await DatabaseService().insertIntubationDossier(dossier);
      } else {
        await DatabaseService().updateIntubationDossier(dossier);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('âœ… Dossier enregistré avec succès !'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        await Future.delayed(const Duration(milliseconds: 600));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('âŒ Erreur lors de l\'enregistrement : $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Widget _buildStepContent(int index) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Étape ${index + 1} sur 6", style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
          Text(["Antécédents médicaux", "Évaluation clinique", "Évaluation du risque", "Données per-intubation", "Difficultés et complications", "Médias cliniques (Optionnels)"][index], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _getPageFields(index),
        ],
      ),
    ).animate(key: ValueKey(index)).fade(duration: 400.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _getPageFields(int index) {
    switch (index) {
      case 0: return Column(
        children: [
          CustomSwitchTile(title: 'Intubation difficile', value: _intubationDifficile, onChanged: (val) => setState(() => _intubationDifficile = val)),
          CustomSwitchTile(title: 'Syndrome apnée (SAOS)', value: _saos, onChanged: (val) => setState(() => _saos = val)),
          CustomSwitchTile(title: 'Diabète', value: _diabete, onChanged: (val) => setState(() => _diabete = val)),
          CustomSwitchTile(title: 'Goitre', value: _goitre, onChanged: (val) => setState(() => _goitre = val)),
          CustomSwitchTile(title: 'Maladie rhumatismale', value: _maladieRhumatismale, onChanged: (val) => setState(() => _maladieRhumatismale = val)),
          CustomSwitchTile(title: 'Traumatisme cervical', value: _traumatismeCervical, onChanged: (val) => setState(() => _traumatismeCervical = val)),
          CustomSwitchTile(title: 'Brûlure cervico-faciale', value: _brulureFaciale, onChanged: (val) => setState(() => _brulureFaciale = val)),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _brulureFaciale
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: TextFormField(
                    controller: _brulureLocController,
                    decoration: InputDecoration(
                      labelText: 'Localisation (brûlure)',
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2)),
                    ),
                  ).animate().fade(duration: 250.ms).slideY(begin: -0.15),
                )
              : const SizedBox.shrink(),
          ),
          CustomSwitchTile(title: 'Dysmorphie faciale', value: _dysmorphieFaciale, onChanged: (val) => setState(() => _dysmorphieFaciale = val)),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _dysmorphieFaciale
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: TextFormField(
                    controller: _dysmorphieLocController,
                    decoration: InputDecoration(
                      labelText: 'Localisation (dysmorphie)',
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2)),
                    ),
                  ).animate().fade(duration: 250.ms).slideY(begin: -0.15),
                )
              : const SizedBox.shrink(),
          ),
          CustomSwitchTile(title: 'Tumeur cervico-faciale', value: _tumeurFaciale, onChanged: (val) => setState(() => _tumeurFaciale = val)),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _tumeurFaciale
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: TextFormField(
                    controller: _tumeurLocController,
                    decoration: InputDecoration(
                      labelText: 'Localisation (tumeur)',
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2)),
                    ),
                  ).animate().fade(duration: 250.ms).slideY(begin: -0.15),
                )
              : const SizedBox.shrink(),
          ),
        ],
      );
      case 1: return Column(children: [ PremiumDropdown(label: 'Score ASA', icon: Icons.assessment, items: const ['I', 'II', 'III'], value: _scoreAsa, onChanged: (val) => setState(() => _scoreAsa = val!)), PremiumDropdown(label: 'Mallampati', icon: Icons.visibility, items: const ['I', 'II', 'III', 'IV'], value: _mallampati, onChanged: (val) => setState(() => _mallampati = val!)), PremiumDropdown(label: 'Distance thyromentonnière', icon: Icons.straighten, items: const ['<6 cm', '>6 cm'], value: _dtm, onChanged: (val) => setState(() => _dtm = val!)), PremiumDropdown(label: 'Ouverture buccale', icon: Icons.accessibility, items: const ['<35 mm', '>35 mm'], value: _ouvertureBuccale, onChanged: (val) => setState(() => _ouvertureBuccale = val!)), PremiumDropdown(label: 'Tour de cou', icon: Icons.accessibility_new, items: const ['<45 cm', '>45 cm'], value: _tourDeCou, onChanged: (val) => setState(() => _tourDeCou = val!)), PremiumDropdown(label: 'Mobilité cervicale', icon: Icons.compare_arrows, items: const ['Souple', 'Raide'], value: _mobiliteRachis, onChanged: (val) => setState(() => _mobiliteRachis = val!)), CustomSwitchTile(title: 'Macroglossie', value: _macroglossie, onChanged: (val) => setState(() => _macroglossie = val)), ]);
      case 2: return PremiumDropdown(label: 'Intubation prévue', icon: Icons.warning, items: const ['Facile', 'Difficile'], value: _intubationPrevue, onChanged: (val) => setState(() => _intubationPrevue = val!));
      case 3: return Column(children: [ PremiumDropdown(label: 'Type intubation', icon: Icons.device_thermostat, items: const ['Orale', 'Nasale'], value: _typeIntubation, onChanged: (val) => setState(() => _typeIntubation = val!)), PremiumDropdown(label: 'Nombre tentatives', icon: Icons.replay, items: const ['1', '2', '3', '4+'], value: _nombreTentatives, onChanged: (val) => setState(() => _nombreTentatives = val!)), CustomSwitchTile(title: 'Vidéolaryngoscope', value: _videoLaryngoscope, onChanged: (val) => setState(() => _videoLaryngoscope = val)), CustomSwitchTile(title: 'Guide Eichmann', value: _guideEichmann, onChanged: (val) => setState(() => _guideEichmann = val)), PremiumDropdown(label: 'Score Cormack', icon: Icons.score, items: const ['I', 'II', 'III', 'IV'], value: _cormack, onChanged: (val) => setState(() => _cormack = val!)), ]);
      case 4: return Column(children: [ CustomSwitchTile(title: 'Intubation difficile (Selon SFAR)', value: _intubationDifficileSfar, onChanged: (val) => setState(() => _intubationDifficileSfar = val)), const SizedBox(height: 10), TextFormField(controller: _complicationsController, maxLines: 4, decoration: InputDecoration(labelText: 'Complications', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))), ]);
      case 5: return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Photos Cliniques', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          const SizedBox(height: 16),
          Wrap(spacing: 15, runSpacing: 15, alignment: WrapAlignment.center, children: [
            FuturisticPhotoCard(label: 'Face', path: _photoFace, onUpdate: (p) => setState(() => _photoFace = p)),
            FuturisticPhotoCard(label: 'Profil', path: _photoProfil, onUpdate: (p) => setState(() => _photoProfil = p)),
            FuturisticPhotoCard(label: 'Bouche', path: _photoBouche, onUpdate: (p) => setState(() => _photoBouche = p)),
            FuturisticPhotoCard(label: 'Neutre', path: _photoProfilNeutre, onUpdate: (p) => setState(() => _photoProfilNeutre = p)),
            FuturisticPhotoCard(label: 'Extension', path: _photoProfilExt, onUpdate: (p) => setState(() => _photoProfilExt = p)),
          ]),
          const SizedBox(height: 40),
          const Text('Voix (Enregistrements)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          const SizedBox(height: 16),
          FuturisticAudioRow(label: 'أ', path: _audioA, onUpdate: (p) => setState(() => _audioA = p)),
          FuturisticAudioRow(label: 'خ', path: _audioKha, onUpdate: (p) => setState(() => _audioKha = p)),
          FuturisticAudioRow(label: 'ه', path: _audioHa, onUpdate: (p) => setState(() => _audioHa = p)),
          FuturisticAudioRow(label: 'ح', path: _audioHaa, onUpdate: (p) => setState(() => _audioHaa = p)),
          FuturisticAudioRow(label: 'غ', path: _audioGha, onUpdate: (p) => setState(() => _audioGha = p)),
          FuturisticAudioRow(label: 'ع', path: _audioAaa, onUpdate: (p) => setState(() => _audioAaa = p)),
        ]);
      default: return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dossierToEdit == null ? 'Nouveau Dossier' : 'Modifier Dossier'),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(6), child: LinearProgressIndicator(value: (_currentStep + 1) / 6, backgroundColor: Colors.grey.shade200, valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor))),
      ),
      body: GradientBackground(
        child: PageView.builder(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 6,
          onPageChanged: (index) => setState(() => _currentStep = index),
          itemBuilder: (context, i) => _buildStepContent(i),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
        child: Row(children: [
          if (_currentStep > 0) Expanded(child: OutlinedButton(onPressed: _previousPage, style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Précédent'))),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _isSaving ? null : _nextPage,
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), 
              child: _isSaving
                ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                : Text(_currentStep == 5 ? 'Enregistrer' : 'Suivant', style: const TextStyle(fontWeight: FontWeight.bold)),
            )
          ),
        ]),
      ),
    );
  }
}

class FuturisticPhotoCard extends StatelessWidget {
  final String label;
  final String? path;
  final Function(String?) onUpdate;
  
  const FuturisticPhotoCard({super.key, required this.label, this.path, required this.onUpdate});

  Future<void> _takePhoto() async {
    final XFile? image = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 50);
    if (image != null) onUpdate(image.path);
  }

  @override
  Widget build(BuildContext context) {
    bool hasImage = path != null;
    return GestureDetector(
      onTap: hasImage ? null : _takePhoto,
      child: Column(
        children: [
          Container(
            width: 105, height: 105,
            decoration: BoxDecoration(
              color: hasImage ? Colors.black : Colors.blueGrey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: hasImage ? Colors.green : Colors.blueGrey.withOpacity(0.2), width: 2),
              image: hasImage ? DecorationImage(image: FileImage(File(path!)), fit: BoxFit.cover, colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken)) : null,
              boxShadow: hasImage ? [BoxShadow(color: Colors.green.withOpacity(0.2), blurRadius: 10)] : [],
            ),
            child: hasImage 
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(icon: const Icon(Icons.cameraswitch_rounded, color: Colors.white), onPressed: _takePhoto, tooltip: "Reprendre"),
                    IconButton(icon: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent), onPressed: () => onUpdate(null), tooltip: "Supprimer"),
                  ],
                )
              : const Icon(Icons.add_a_photo_rounded, color: Colors.blueGrey, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: hasImage ? Colors.green : Colors.grey.shade700)),
        ],
      ),
    );
  }
}

class FuturisticAudioRow extends StatefulWidget {
  final String label;
  final String? path;
  final Function(String?) onUpdate;

  const FuturisticAudioRow({super.key, required this.label, this.path, required this.onUpdate});
  @override
  State<FuturisticAudioRow> createState() => _FuturisticAudioRowState();
}

class _FuturisticAudioRowState extends State<FuturisticAudioRow>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  late AnimationController _glowCtrl;

  static const Color _green = Color(0xFF00FF88);

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    _player.dispose();
    super.dispose();
  }

  void _togglePlay() async {
    if (_isPlaying) {
      await _player.pause();
      setState(() => _isPlaying = false);
    } else {
      await _player.play(DeviceFileSource(widget.path!));
      setState(() => _isPlaying = true);
    }
  }

  Future<void> _openFuturisticRecorder(BuildContext context) async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('âŒ Permission microphone refusée'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }

    final record = AudioRecorder();
    bool isRecording = false;
    int recordDuration = 0;
    Timer? timer;
    String? tempPath;

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (_, setModalState) {
          void startRecording() async {
            final dir = await getApplicationDocumentsDirectory();
            tempPath = '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
            await record.start(const RecordConfig(), path: tempPath!);
            setModalState(() { isRecording = true; recordDuration = 0; });
            timer = Timer.periodic(const Duration(seconds: 1), (_) => setModalState(() => recordDuration++));
          }

          void stopRecording() async {
            final path = await record.stop();
            timer?.cancel();
            setModalState(() => isRecording = false);
            if (path != null) widget.onUpdate(path);
            if (ctx.mounted) {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('âœ… Son "${widget.label}" enregistré !'), backgroundColor: Colors.green),
              );
            }
          }

          String fmt(int s) => '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

          return Container(
            height: MediaQuery.of(context).size.height * 0.65,
            decoration: const BoxDecoration(
              color: Color(0xFF080E1A),
              borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
                    child: CustomPaint(painter: _HexGridPainter()),
                  ),
                ),
                Column(
                  children: [
                    const SizedBox(height: 14),
                    Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _green.withOpacity(0.4)),
                        color: _green.withOpacity(0.06),
                      ),
                      child: Text(
                        'Enregistrement vocal',
                        style: TextStyle(color: _green, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: _green,
                        fontSize: 64,
                        fontWeight: FontWeight.w900,
                        shadows: [Shadow(color: _green.withOpacity(0.6), blurRadius: 24)],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isRecording ? 'â— ENREGISTREMENT EN COURS' : 'PRÊT',
                      style: TextStyle(
                        color: isRecording ? Colors.redAccent : Colors.white38,
                        fontSize: 10,
                        letterSpacing: 3,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                             Builder(
                      builder: (context) {
                        final sw = MediaQuery.of(context).size.width;
                        final outerR = sw * 0.88;
                        final innerR = sw * 0.66;
                        final btnR = sw * 0.28;
                        return GestureDetector(
                          onTap: isRecording ? stopRecording : startRecording,
                          child: SizedBox(
                            width: double.infinity,
                            height: outerR,
                            child: Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.center,
                              children: [
                                if (isRecording) ...[ 
                                  Container(
                                    width: outerR * 0.8, height: outerR * 0.8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.redAccent.withOpacity(0.5), width: 2),
                                    ),
                                  ).animate(onPlay: (c) => c.repeat())
                                    .scale(begin: const Offset(0.6, 0.6), end: const Offset(1.4, 1.4), duration: 1200.ms)
                                    .fade(begin: 0.7, end: 0, duration: 1200.ms),
                                  Container(
                                    width: outerR * 0.8, height: outerR * 0.8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.redAccent.withOpacity(0.3), width: 1.5),
                                    ),
                                  ).animate(onPlay: (c) => c.repeat())
                                    .scale(begin: const Offset(0.5, 0.5), end: const Offset(1.7, 1.7), duration: 1200.ms, delay: 400.ms)
                                    .fade(begin: 0.5, end: 0, duration: 1200.ms),
                                  Container(
                                    width: outerR * 0.8, height: outerR * 0.8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.redAccent.withOpacity(0.15), width: 1),
                                    ),
                                  ).animate(onPlay: (c) => c.repeat())
                                    .scale(begin: const Offset(0.4, 0.4), end: const Offset(2.0, 2.0), duration: 1200.ms, delay: 800.ms)
                                    .fade(begin: 0.3, end: 0, duration: 1200.ms),
                                ] else ...[
                                  Container(
                                    width: outerR, height: outerR,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: _green.withOpacity(0.5), width: 2),
                                    ),
                                  ).animate(onPlay: (c) => c.repeat())
                                    .scale(begin: const Offset(0.6, 0.6), end: const Offset(1.0, 1.0), duration: 1500.ms)
                                    .fade(begin: 0.7, end: 0, duration: 1500.ms),
                                  Container(
                                    width: innerR, height: innerR,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: _green.withOpacity(0.4), width: 1.5),
                                    ),
                                  ).animate(onPlay: (c) => c.repeat())
                                    .scale(begin: const Offset(0.65, 0.65), end: const Offset(1.0, 1.0), duration: 1500.ms, delay: 500.ms)
                                    .fade(begin: 0.6, end: 0, duration: 1500.ms),
                                  Container(
                                    width: innerR * 0.7, height: innerR * 0.7,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: _green.withOpacity(0.25), width: 1),
                                    ),
                                  ).animate(onPlay: (c) => c.repeat())
                                    .scale(begin: const Offset(0.7, 0.7), end: const Offset(1.0, 1.0), duration: 1500.ms, delay: 1000.ms)
                                    .fade(begin: 0.4, end: 0, duration: 1500.ms),
                                ],
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: btnR, height: btnR,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: isRecording
                                        ? [Colors.red.shade800, Colors.red.shade600]
                                        : [const Color(0xFF00C853), const Color(0xFF00FF88)],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isRecording ? Colors.redAccent.withOpacity(0.6) : _green.withOpacity(0.5),
                                        blurRadius: 40, spreadRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                                    color: Colors.white,
                                    size: btnR * 0.44,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 40,
                      child: isRecording
                        ? MiniMusicVisualizer(color: Colors.redAccent, width: 4, height: 32)
                        : const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Text(
                        fmt(recordDuration),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (!isRecording)
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Annuler', style: TextStyle(color: Colors.white38, fontSize: 15)),
                      ),
                    SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 8),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasAudio = widget.path != null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AnimatedBuilder(
        animation: _glowCtrl,
        builder: (_, __) => GestureDetector(
          onTap: hasAudio ? null : () => _openFuturisticRecorder(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Theme.of(context).cardColor,
              border: Border.all(
                color: hasAudio
                  ? Theme.of(context).primaryColor.withOpacity(0.6 + _glowCtrl.value * 0.3)
                  : Theme.of(context).dividerColor,
                width: hasAudio ? 1.5 : 1,
              ),
              boxShadow: hasAudio ? [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.08 + _glowCtrl.value * 0.06),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ] : [],
            ),
            child: Row(
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: hasAudio
                      ? Theme.of(context).primaryColor.withOpacity(0.15)
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                    border: Border.all(
                      color: hasAudio
                        ? Theme.of(context).primaryColor.withOpacity(0.7)
                        : Theme.of(context).dividerColor,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      widget.label,
                      style: TextStyle(
                        color: hasAudio
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        shadows: hasAudio
                          ? [Shadow(color: Theme.of(context).primaryColor.withOpacity(0.5), blurRadius: 10)]
                          : [],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasAudio ? 'Son enregistré' : 'Appuyer pour enregistrer',
                        style: TextStyle(
                          color: hasAudio
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hasAudio ? 'â— Audio disponible' : 'â—‹ Optionnel',
                        style: TextStyle(
                          color: hasAudio
                            ? Theme.of(context).primaryColor.withOpacity(0.6)
                            : Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                          fontSize: 11,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasAudio) ...[
                  GestureDetector(
                    onTap: _togglePlay,
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue.withOpacity(0.15),
                        border: Border.all(color: Colors.blue.withOpacity(0.4)),
                      ),
                      child: Icon(
                        _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: Colors.blue.shade300, size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      _player.stop();
                      setState(() => _isPlaying = false);
                      widget.onUpdate(null);
                    },
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red.withOpacity(0.1),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Icon(Icons.delete_outline_rounded, color: Colors.red.shade300, size: 20),
                    ),
                  ),
                  const SizedBox(width: 4),
                ] else ...[
                  GestureDetector(
                    onTap: () => _openFuturisticRecorder(context),
                    child: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00C853), Color(0xFF00FF88)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [BoxShadow(color: _green.withOpacity(0.3), blurRadius: 12)],
                      ),
                      child: const Icon(Icons.mic_rounded, color: Colors.white, size: 22),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HexGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.015)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    const r = 24.0;
    const h = r * 1.732;
    const w = r * 2;
    for (double y = 0; y < size.height + r; y += h) {
      for (double x = 0; x < size.width + r; x += w * 1.5) {
        final off = (y ~/ h % 2 == 0) ? 0.0 : w * 0.75;
        final path = Path();
        for (int i = 0; i < 6; i++) {
          final a = (3.14159 / 180) * (60 * i - 30);
          final px = x + off + r * cos(a);
          final py = y + r * sin(a);
          if (i == 0) path.moveTo(px, py); else path.lineTo(px, py);
        }
        path.close();
        canvas.drawPath(path, paint);
      }
    }
  }
  @override bool shouldRepaint(_) => false;
}
