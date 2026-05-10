
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/patient_provider.dart';
import 'providers/intubation_provider.dart';
import 'providers/theme_provider.dart'; 

import 'features/auth/screens/auth_screen.dart';
import 'features/splash/splash_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PatientProvider()),
        ChangeNotifierProvider(create: (_) => IntubationProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()), 
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'AeroCare',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.currentTheme,
          home: const SplashScreen(),
        );
      }
    );
  }
}
