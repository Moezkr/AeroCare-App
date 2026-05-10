import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../services/database_service.dart';
import '../../../services/sync_service.dart';
import '../../../models/patient.dart';
import '../../../models/intubation_dossier.dart';
import '../../../core/shared_widgets/gradient_background.dart';

import '../widgets/dashboard_card.dart';
import '../widgets/recent_dossier_card.dart';
import '../../patient/screens/create_patient_screen.dart';
import '../../patient/screens/patient_list_screen.dart';
import '../../search/screens/search_patient_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../auth/screens/auth_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Key _listKey = UniqueKey();
  final int _selectedIndex = 0;

  void _logout(BuildContext context) async {
    _showModernNotification('Déconnexion réussie', true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const AuthScreen()), (route) => false);
    }
  }

  void _showModernNotification(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isSuccess ? Icons.check_circle_rounded : Icons.error_rounded, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Expanded(child: Text(message, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
          ],
        ),
        backgroundColor: isSuccess ? const Color(0xFF10B981) : const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(20), elevation: 8, duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchRecentDossiers() async {
    final db = await DatabaseService().database;
    return await db.rawQuery('''
      SELECT a.*, p.nom, p.prenom, p.telephone, p.sexe, p.dateNaissance, p.profession, p.statutMatrimonial, p.bmi
      FROM intubation_dossiers a
      JOIN patients p ON a.patientId = p.id
      ORDER BY a.id DESC
      LIMIT 3
    ''');
  }

  void _syncAll() async {
    _showModernNotification('Synchronisation en cours...', true);
    final result = await SyncService().syncDataToVPS();
    _showModernNotification(result, result.contains('réussie') || result.contains('déjà'));
    setState(() { _listKey = UniqueKey(); });
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    if (index == 1) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => PatientListScreen()));
    if (index == 2) _syncAll();
    if (index == 3) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.menu),
        title: const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(icon: const Icon(Icons.settings_rounded), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
          IconButton(icon: const Icon(Icons.logout_rounded, color: Colors.redAccent), onPressed: () => _logout(context)),
        ],
      ),
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                  children: [
                    DashboardCard(title: 'Nouveau patient', subtitle: 'Ajouter un patient', icon: Icons.person_add_rounded, iconColor: const Color(0xFF3B82F6), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreatePatientScreen())).then((_) => setState(() { _listKey = UniqueKey(); }))),
                    DashboardCard(title: 'Liste des patients', subtitle: 'Voir tous les patients', icon: Icons.list_alt_rounded, iconColor: const Color(0xFF10B981), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PatientListScreen())).then((_) => setState(() { _listKey = UniqueKey(); }))),
                    DashboardCard(title: 'Rechercher', subtitle: 'Rechercher un patient', icon: Icons.search_rounded, iconColor: const Color(0xFF6366F1), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchPatientScreen()))),
                    DashboardCard(title: 'Synchronisation', subtitle: 'Synchroniser', icon: Icons.autorenew_rounded, iconColor: const Color(0xFFF59E0B), onTap: _syncAll),
                  ].animate(interval: 50.ms).fade(duration: 400.ms).scale(begin: const Offset(0.95, 0.95)),
                ),
                const SizedBox(height: 30),
                const Text('Derniers dossiers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
                    .animate().fade(delay: 200.ms).slideX(begin: -0.05),
                const SizedBox(height: 16),
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    key: _listKey,
                    future: _fetchRecentDossiers(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: const Text('Aucun dossier récent', style: TextStyle(color: Colors.grey))
                              .animate().fade(),
                        );
                      }
                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return RecentDossierCard(
                            dataMap: snapshot.data![index],
                            onReturn: () => setState(() { _listKey = UniqueKey(); }),
                          ).animate().fade(delay: (100 * index).ms).slideY(begin: 0.1);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          showUnselectedLabels: true,
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
