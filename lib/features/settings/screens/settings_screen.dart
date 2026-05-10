import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/theme_provider.dart';
import '../../../core/shared_widgets/gradient_background.dart';
import '../widgets/theme_selector_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres', style: TextStyle(fontWeight: FontWeight.w600)), centerTitle: true),
      body: GradientBackground(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Thème de l\'application', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 10),
            ThemeSelectorCard(themeProvider: themeProvider),
          ],
        ),
      ),
    );
  }
}
