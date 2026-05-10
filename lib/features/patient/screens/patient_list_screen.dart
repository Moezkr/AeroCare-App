
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../services/database_service.dart';
import '../../../services/sync_service.dart';
import '../../../providers/patient_provider.dart';
import '../../../models/patient.dart';

import 'create_patient_screen.dart';
import '../widgets/patient_list_card.dart';
import '../widgets/dossier_bottom_sheet.dart';

import '../../dashboard/screens/dashboard_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../auth/screens/auth_screen.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PatientProvider>(context, listen: false).loadPatients();
    });
  }

  void _logout(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Déconnexion...'), backgroundColor: Colors.redAccent),
    );
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthScreen()),
        (route) => false,
      );
    }
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

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    if (index == 0) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
    if (index == 2) _syncAction();
    if (index == 3) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
  }

  void _showPatientDossiers(Patient patient) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DossierBottomSheet(patient: patient),
    );
  }

  void _confirmDelete(BuildContext context, Patient patient) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer ?', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        content: Text('Voulez-vous supprimer ${patient.nom} ${patient.prenom} ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              await Provider.of<PatientProvider>(context, listen: false).deletePatient(patient.id!);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
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
        title: const Text('Patients du Jour', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            tooltip: 'Déconnexion',
            onPressed: () => _logout(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Patients ajoutés aujourd'hui", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Consumer<PatientProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) return const Center(child: CircularProgressIndicator());

                final now = DateTime.now();
                final patientsToday = provider.patients.where((p) {
                  try {
                    DateTime pDate = DateTime.parse(p.createdAt);
                    return pDate.year == now.year && pDate.month == now.month && pDate.day == now.day;
                  } catch (_) { return false; }
                }).toList();

                if (patientsToday.isEmpty) {
                  return Center(
                    child: const Text('Aucun patient ajouté aujourd\'hui', style: TextStyle(color: Colors.grey, fontSize: 16))
                        .animate().fade().scale(),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: patientsToday.length,
                  itemBuilder: (context, index) {
                    final patient = patientsToday[index];
                    return PatientListCard(
                      patient: patient,
                      onOpenDossiers: () => _showPatientDossiers(patient),
                      onEdit: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CreatePatientScreen(patientToEdit: patient))),
                      onDelete: () => _confirmDelete(context, patient),
                    ).animate().fade(delay: (50 * index).ms).slideX(begin: 0.1);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreatePatientScreen())),
        backgroundColor: Theme.of(context).primaryColor, foregroundColor: Colors.white,
        child: const Icon(Icons.add, size: 28),
      ).animate().scale(delay: 400.ms),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))]),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          elevation: 0,
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
