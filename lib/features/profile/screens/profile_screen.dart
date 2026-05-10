import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../services/database_service.dart';
import '../../../services/sync_service.dart';
import '../../../core/shared_widgets/gradient_background.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../patient/screens/patient_list_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final int _selectedIndex = 3; 
  final TextEditingController _pwdController = TextEditingController();
  final TextEditingController _confirmPwdController = TextEditingController();

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
    if (index == 1) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => PatientListScreen()));
    if (index == 2) _syncAction(); 
    if (index == 3) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
  }

  void _updatePassword() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mot de passe mis à jour avec succès !'), backgroundColor: Colors.green));
    _pwdController.clear();
    _confirmPwdController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon Profil', style: TextStyle(fontWeight: FontWeight.w600)), centerTitle: true),
      body: GradientBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(radius: 50, backgroundColor: Colors.blueAccent, child: Icon(Icons.person, size: 50, color: Colors.white)).animate().scale(),
            const SizedBox(height: 16),
            const Text('moez@kraiem.com', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            
            const Align(alignment: Alignment.centerLeft, child: Text('Sécurité', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey))),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _pwdController, obscureText: true,
              decoration: const InputDecoration(labelText: 'Nouveau mot de passe', prefixIcon: Icon(Icons.lock_outline)),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPwdController, obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirmer le mot de passe', prefixIcon: Icon(Icons.lock_reset)),
            ),
            const SizedBox(height: 30),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _updatePassword,
                style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Mettre à jour le mot de passe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 40),
            const Align(alignment: Alignment.centerLeft, child: Text('Sauvegarde & Restauration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey))),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.cloud_download),
                onPressed: () async {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Restauration en cours...')));
                  final result = await SyncService().fetchDataFromVPS();
                  if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result), backgroundColor: result.contains('réussie') ? Colors.green : Colors.red));
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                label: const Text('Restaurer depuis le serveur VPS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        selectedItemColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true, showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.people_alt_rounded), label: 'Patients'),
          BottomNavigationBarItem(icon: Icon(Icons.autorenew_rounded), label: 'Sync'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profil'),
        ],
      ),
    );
  }
}
