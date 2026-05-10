import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:mini_music_visualizer/mini_music_visualizer.dart';

import '../../../providers/patient_provider.dart';
import '../../../models/patient.dart';
import '../../../models/intubation_dossier.dart'; 
import '../../../services/database_service.dart';
import '../../../services/ai_service.dart';
import '../../../services/sync_service.dart';
import '../../../core/shared_widgets/gradient_background.dart';

import '../../intubation/screens/intubation_form_screen.dart'; 
import '../../intubation/screens/intubation_dossier_detail_screen.dart'; 
import '../../dashboard/screens/dashboard_screen.dart'; 
import '../../profile/screens/profile_screen.dart';
import '../../patient/screens/patient_list_screen.dart';
import '../../auth/screens/auth_screen.dart';
import '../widgets/ai_assistant_overlay.dart';
import '../widgets/search_filter_sheet.dart';

class SearchPatientScreen extends StatefulWidget {
  const SearchPatientScreen({super.key});

  @override
  State<SearchPatientScreen> createState() => _SearchPatientScreenState();
}

class _SearchPatientScreenState extends State<SearchPatientScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  DateTime _startDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  DateTime _endDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59, 59);
  String _selectedSexe = 'Tous';
  final int _selectedIndex = 1; 

  late stt.SpeechToText _speech;
  bool _isAiActive = false;
  bool _isListening = false;
  bool _isAiThinking = false;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    AIService.initTTS(); 
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PatientProvider>(context, listen: false).loadPatients();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    AIService.stop(); 
    super.dispose();
  }

  void _toggleAiAssistant() async {
    if (_isAiActive) {
      _closeAi();
      return;
    }
    setState(() => _isAiActive = true);
    _startVoicePipeline();
  }

  void _closeAi() {
    _speech.stop();
    AIService.stop(); 
    setState(() {
      _isAiActive = false;
      _isListening = false;
      _isAiThinking = false;
      _isSpeaking = false;
    });
  }

  void _startVoicePipeline() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() { _isListening = true; _isSpeaking = false; });
      _speech.listen(
        localeId: 'fr_FR',
        onResult: (result) async {
          if (result.finalResult) {
            setState(() { _isListening = false; _isAiThinking = true; });

            String? sql = await AIService.generateSQL(result.recognizedWords);
            if (sql != null) {
              final db = await DatabaseService().database;
              final List<Map<String, dynamic>> results = await db.rawQuery(sql);
              String summary = await AIService.generateSummary(results);

              setState(() { _isAiThinking = false; _isSpeaking = true; });
              await AIService.speak(summary);

              if (results.length == 1 && mounted) {
                final p = Patient.fromMap(results.first);
                final d = IntubationDossier.fromMap(results.first);
                
                await Future.delayed(const Duration(seconds: 3)); 
                _closeAi();
                Navigator.push(context, MaterialPageRoute(builder: (_) => IntubationDossierDetailScreen(patient: p, dossier: d)));
              }
            } else {
               setState(() { _isAiThinking = false; });
               AIService.speak("Je n'ai pas compris la demande.");
            }
          }
        },
      );
    }
  }

  void _logout(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Déconnexion...'), backgroundColor: Colors.redAccent));
    await Future.delayed(const Duration(milliseconds: 500)); 
    if (mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const AuthScreen()), (route) => false);
  }

  void _onItemTapped(int index) {
    if (index == 0) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
    if (index == 1) return;
    if (index == 2) _syncAction(); 
    if (index == 3) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
  }

  void _syncAction() async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Synchronisation en cours...')));
    final result = await SyncService().syncDataToVPS();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result), 
        backgroundColor: result.contains('réussie') || result.contains('déjà') ? Colors.green : Colors.red
      ));
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SearchFilterSheet(
        initialStartDate: _startDate,
        initialEndDate: _endDate,
        initialSexe: _selectedSexe,
        onApply: (start, end, sexe) {
          setState(() {
            _startDate = start;
            _endDate = end;
            _selectedSexe = sexe;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recherche Avancée', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.tune_rounded, color: Colors.blue), onPressed: _showFilterSheet),
          IconButton(icon: const Icon(Icons.logout_rounded, color: Colors.redAccent), onPressed: () => _logout(context)),
        ],
      ),
      body: Stack(
        children: [
          GradientBackground(child: const SizedBox.expand()),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Nom, prénom ou mobile...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
              ),
              Expanded(
                child: Consumer<PatientProvider>(
                  builder: (context, provider, child) {
                    final filtered = provider.patients.where((p) {
                      bool matchesQuery = p.nom.toLowerCase().contains(_searchQuery) || p.prenom.toLowerCase().contains(_searchQuery);
                      bool matchesSexe = _selectedSexe == 'Tous' || p.sexe == _selectedSexe;
                      return matchesQuery && matchesSexe;
                    }).toList();

                    if (filtered.isEmpty) return const Center(child: Text('Aucun patient trouvé'));

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final p = filtered[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: p.sexe == 'Homme' ? Colors.blue.shade50 : Colors.pink.shade50,
                              child: Icon(p.sexe == 'Homme' ? Icons.male : Icons.female, color: p.sexe == 'Homme' ? Colors.blue : Colors.pink),
                            ),
                            title: Text("${p.nom} ${p.prenom}", style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(p.telephone),
                            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                          ),
                        ).animate().fade(delay: (50 * index).ms).slideX(begin: 0.1);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          if (_isAiActive)
            AiAssistantOverlay(
              isListening: _isListening,
              isAiThinking: _isAiThinking,
              isSpeaking: _isSpeaking,
              onClose: _closeAi,
            ),
        ],
      ),
      floatingActionButton: !_isAiActive ? FloatingActionButton.extended(
        onPressed: _toggleAiAssistant,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.mic_rounded),
        label: const Text("Assistant IA", style: TextStyle(fontWeight: FontWeight.w600)),
      ) : null,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))]),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          selectedItemColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
          unselectedItemColor: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
          type: BottomNavigationBarType.fixed, showSelectedLabels: true, showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Accueil'),
            BottomNavigationBarItem(icon: Icon(Icons.people_alt_rounded), label: 'Patients'),
            BottomNavigationBarItem(icon: Icon(Icons.autorenew_rounded), label: 'Sync'), 
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profil'),
          ],
        ),
      ),
    );
  }
}
